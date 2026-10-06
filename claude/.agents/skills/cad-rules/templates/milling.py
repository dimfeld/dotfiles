"""Milled-part data and design-for-machining checks (template).

Copy this file into each build123d project that has milled parts (do not
import across projects). Set MACHINE_TRAVEL and MATERIALS for the user's
machine and stock. A part module lists its milled pieces in `MILL_PARTS`, the same way
it lists printed pieces in `PRINT_PARTS`.

Machine frame: model each milled part in its first setup. The stock bottom is
on z = 0 and the tool comes down from +Z. Each extra setup is a direction the
tool comes from, for example (0, 0, -1) when you turn the part over.

The checks measure the B-rep:
  - one valid solid, no taller than the stock
  - the machined region fits the machine travel
  - every face can be reached by a straight tool from one of the setups
  - no sharp inside corner along a setup axis, and no inside radius smaller
    than the end mill radius (round holes are drilled and are exempt)
They also list the holes, with the tap for each tap-drill size.
"""

import math
from collections import defaultdict
from collections.abc import Callable
from dataclasses import dataclass

from build123d import Align, Cylinder, GeomType, Location, Vector

# X, Y, Z travel of the user's machine. Example: Genmitsu 3030-PROVer Ultra,
# 300 x 300 mm (Z 78 mm from the vendor listing). Confirm with the user.
MACHINE_TRAVEL = (300.0, 300.0, 78.0)


@dataclass(frozen=True)
class Material:
    name: str
    density: float  # g/cm3
    note: str


MATERIALS = {
    "6061": Material("6061-T6 aluminium", 2.70, "Single-flute carbide, air blast or mist, shallow passes."),
    "POM-C": Material(
        "Acetal copolymer (POM-C)", 1.41,
        "Copolymer, not homopolymer (Delrin): it resists hot water better. Sharp O-flute or 2-flute, no coolant.",
    ),
}

# Tap-drill diameters in the model -> the tap. Model a tapped hole at its tap-drill size.
TAP_DRILLS = {1.6: "M2", 2.5: "M3", 3.3: "M4", 4.2: "M5"}

UP = (0.0, 0.0, 1.0)
DOWN = (0.0, 0.0, -1.0)


@dataclass(frozen=True)
class MilledPart:
    name: str
    make: Callable  # returns the part in the machine frame (first setup)
    material: str  # key in MATERIALS
    stock: str  # what to buy or cut, for example "8 mm plate"
    stock_t: float  # stock thickness (mm)
    instructions: str
    tool_d: float = 3.175  # smallest end mill; sets the smallest inside radius
    setups: tuple = (UP,)  # tool directions, first setup first
    outline_from_stock: bool = False  # True when the outline is the purchased stock edge
    qty: int = 1

    @property
    def density(self):
        return MATERIALS[self.material].density


def _u_span(face):
    from OCP.BRepTools import BRepTools

    u0, u1, _, _ = BRepTools.UVBounds_s(face.wrapped)
    return u1 - u0


def _samples(face, n=3):
    """Up to n points that lie on the face, from a UV grid."""
    out = []
    for fu, fv in ((0.5, 0.5), (0.25, 0.25), (0.75, 0.75), (0.25, 0.75), (0.75, 0.25), (0.5, 0.1), (0.5, 0.9)):
        pt = face.position_at(fu, fv)  # normalised UV
        if face.distance_to(pt) < 1e-5:
            out.append(pt)
        if len(out) == n:
            break
    if not out:
        out = [face.center()]
    return out


def _ray_clear(solid, pt, d, length, r=0.02):
    """True when a thin rod from pt along d does not enter the solid."""
    rod = Cylinder(r, length, align=(Align.CENTER, Align.CENTER, Align.MIN))
    z = Vector(0, 0, 1)
    dv = Vector(*d).normalized()
    axis = z.cross(dv)
    if axis.length < 1e-9:
        loc = Location(pt) if dv.Z > 0 else Location(pt, (1, 0, 0), 180)
    else:
        ang = math.degrees(math.acos(max(-1.0, min(1.0, z.dot(dv)))))
        loc = Location(pt, tuple(axis.normalized()), ang)
    common = solid & (loc * rod)
    return not common.solids() or sum(s.volume for s in common.solids()) < 1e-9


def _stock_face(f, bb, sides):
    """A planar face on the stock bottom (or on the stock edges, for parts cut
    to size before machining): it is never cut."""
    if f.geom_type != GeomType.PLANE:
        return False
    c, n = f.center(), f.normal_at()
    if n.Z < -0.999 and abs(c.Z - bb.min.Z) < 1e-6:
        return True
    if not sides:
        return False
    return (abs(n.X) > 0.999 and min(abs(c.X - bb.min.X), abs(c.X - bb.max.X)) < 1e-6) or (
        abs(n.Y) > 0.999 and min(abs(c.Y - bb.min.Y), abs(c.Y - bb.max.Y)) < 1e-6
    )


def unreachable_faces(solid, setups, offset=0.05, stock_sides=False):
    """Faces that no straight tool from any setup direction can reach. Faces
    on the stock bottom (and on the stock edges with stock_sides) are skipped."""
    bb = solid.bounding_box()
    length = bb.diagonal + 10
    bad = []
    for f in solid.faces():
        if _stock_face(f, bb, stock_sides):
            continue
        for pt in _samples(f):
            n = f.normal_at(pt)
            start = pt + n * offset
            ok = any(
                n.dot(Vector(*d)) > -1e-6 and _ray_clear(solid, start, d, length)
                for d in setups
            )
            if not ok:
                bad.append(f)
                break
    return bad


def _parallel(v, d):
    return abs(abs(v.normalized().dot(Vector(*d).normalized())) - 1) < 1e-6


def sharp_inside_corners(solid, setups, eps=0.02):
    """Straight concave edges along a setup axis: a round end mill cannot cut them."""
    out = []
    for e in solid.edges().filter_by(GeomType.LINE):
        direction = e.position_at(1) - e.position_at(0)
        if direction.length < 1e-6 or not any(_parallel(direction, d) for d in setups):
            continue
        mid = e.position_at(0.5)
        faces = [f for f in solid.faces() if f.distance_to(mid) < 1e-6]
        if len(faces) != 2:
            continue
        n1, n2 = (f.normal_at(mid) for f in faces)
        if (n1 - n2).length < 1e-2:
            continue  # tangent: not a corner
        if solid.is_inside(mid + (n2 - n1).normalized() * eps):
            out.append(mid)
    return out


def concave_cylinders(solid, setups):
    """Cylindrical faces along a setup axis that face their own axis (holes and
    inside radii). Returns (holes, radii): holes are full circles, grouped by
    (diameter, axis position); radii are partial arcs: (radius, face)."""
    groups = defaultdict(list)
    for f in solid.faces().filter_by(GeomType.CYLINDER):
        ax = f.axis_of_rotation
        if not any(_parallel(ax.direction, d) for d in setups):
            continue
        pt = _samples(f, 1)[0]
        a = ax.position
        q = pt - a
        radial = q - ax.direction * q.dot(ax.direction)
        r = radial.length
        if f.normal_at(pt).dot(radial) >= 0:
            continue  # convex (a boss or an outside radius)
        key = (round(2 * r, 3), round(a.X, 2), round(a.Y, 2), round(a.Z, 2) if not _parallel(ax.direction, UP) else 0)
        groups[key].append(f)
    holes, radii = [], []
    for key, faces in groups.items():
        if sum(_u_span(f) for f in faces) >= 2 * math.pi - 1e-3:
            holes.append(key)
        else:
            radii += [(key[0] / 2, f) for f in faces]
    return holes, radii


def check_milled(part: MilledPart, travel=MACHINE_TRAVEL):
    """Design-for-machining checks for one milled part.

    Returns (shape, results); results are (ok, text) with ok None for info lines.
    """
    shape = part.make()
    out = []
    bb = shape.bounding_box()
    out.append((shape.is_valid and len(shape.solids()) == 1,
                f"{part.name}: valid single solid, {bb.size.X:.1f} x {bb.size.Y:.1f} x {bb.size.Z:.1f} mm, "
                f"{shape.volume / 1000:.1f} cm3, {shape.volume / 1000 * part.density:.0f} g ({MATERIALS[part.material].name})"))
    out.append((abs(bb.min.Z) < 1e-6 and bb.size.Z <= part.stock_t + 1e-6,
                f"{part.name}: stock bottom on z = 0 and {bb.size.Z:.2f} mm tall, within the {part.stock_t:g} mm stock"))
    tool_r = part.tool_d / 2
    if part.outline_from_stock:
        from build123d import Box, Pos

        stock = Pos(bb.min.X, bb.min.Y, 0) * Box(bb.size.X, bb.size.Y, part.stock_t, align=(Align.MIN,) * 3)
        cut = stock - shape
        cbb = cut.bounding_box() if cut.solids() else bb
        need = (cbb.size.X, cbb.size.Y)
        what = "machined features"
    else:
        need = (bb.size.X + part.tool_d, bb.size.Y + part.tool_d)
        what = "outline plus the tool"
    fits = sorted(need)[1] <= max(travel[:2]) and sorted(need)[0] <= min(travel[:2]) and part.stock_t <= travel[2]
    out.append((fits, f"{part.name}: {what} {need[0]:.1f} x {need[1]:.1f} mm fit the {travel[0]:g} x {travel[1]:g} mm travel"))

    bad = unreachable_faces(shape, part.setups, stock_sides=part.outline_from_stock)
    where = ", ".join(f"({f.center().X:.1f}, {f.center().Y:.1f}, {f.center().Z:.1f})" for f in bad[:4])
    out.append((not bad, f"{part.name}: every face reachable from the {len(part.setups)} setup(s){': not ' + where if bad else ''}"))

    sharp = sharp_inside_corners(shape, part.setups)
    where = ", ".join(f"({q.X:.1f}, {q.Y:.1f}, {q.Z:.1f})" for q in sharp[:4])
    out.append((not sharp, f"{part.name}: no sharp inside corners along a setup axis{': ' + where if sharp else ''}"))

    holes, radii = concave_cylinders(shape, part.setups)
    small = [(r, f) for r, f in radii if r < tool_r - 1e-3]
    rmin = min((r for r, _ in radii), default=None)
    out.append((not small, f"{part.name}: smallest inside radius "
                f"{'none' if rmin is None else f'{rmin:.2f} mm'} (min {tool_r:.2f} for a {part.tool_d:g} mm end mill)"
                + (": at " + ", ".join(f"({f.center().X:.1f}, {f.center().Y:.1f})" for _, f in small[:4]) if small else "")))
    out.append((None, f"{part.name}: holes: {hole_summary(holes) or 'none'}"))
    return shape, out


def hole_summary(holes):
    count = defaultdict(int)
    for key in holes:
        count[key[0]] += 1
    parts = []
    for d in sorted(count):
        tap = TAP_DRILLS.get(round(d, 1))
        note = f" ({tap} tap)" if tap and abs(d - round(d, 1)) < 1e-3 else (" (milled opening)" if d > 13 else "")
        parts.append(f"{count[d]} x {d:g} mm{note}")
    return ", ".join(parts)


def holes_of(part: MilledPart):
    shape = part.make()
    holes, _ = concave_cylinders(shape, part.setups)
    return hole_summary(holes)


def markdown_table(parts):
    """The milled-parts section of hardware.md."""
    lines = [
        "## Milled parts",
        "",
        "Machining data comes from each part's Python module. Names match the STEP exports",
        "(machine frame: first setup, stock bottom at z = 0). Holes at a tap-drill size are tapped.",
        "",
        "| Qty | Piece | Material | Stock | Setups | Smallest end mill | Holes | Instructions | Source |",
        "|---:|---|---|---|---:|---:|---|---|---|",
    ]
    for part in parts:
        source = part.make.__module__.replace(".", "/") + ".py"
        lines.append(
            f"| {part.qty} | {part.name} | {MATERIALS[part.material].name} | {part.stock} | {len(part.setups)} "
            f"| {part.tool_d:g} mm | {holes_of(part) or 'none'} | {part.instructions} | [{source}]({source}) |"
        )
    lines += ["", "Material notes:", ""]
    for key in sorted({p.material for p in parts}):
        lines.append(f"- {MATERIALS[key].name}: {MATERIALS[key].note}")
    lines.append("")
    return lines


def round_inside_corners(face, radius):
    """Round only the concave (inside) corners of a flat 2D face, so that an end
    mill can cut it: offset out by the radius, then back in, both with arc
    joins. Outside corners come back sharp. Use this on outlines made by
    joining shapes; fillet() on the merged outline often fails."""
    from build123d import Kind, offset

    return offset(offset(face, radius, kind=Kind.ARC), -radius, kind=Kind.ARC)
