"""Helpers for a build123d check.py. Copy into the project and adapt.

Pattern:
    report = Report()
    report.section("Printed parts")
    report.check(part.is_valid and len(part.solids()) == 1, "body: valid single solid")
    ...
    swept = sweep_collisions(assemble, angles, intended={("link", "horn pin")})
    report.check(not swept, f"no collisions at {len(angles)} positions")
    report.finish("build/verification.txt")   # exits non-zero on failure

Check the generated geometry (faces, holes, overlaps, distances), not the
input parameters.
"""

import itertools
import sys
from pathlib import Path

from build123d import GeomType


class Report:
    def __init__(self, title="Verification"):
        self.title = title
        self.lines = []
        self.failures = 0

    def section(self, title):
        self.lines += ["", title]

    def check(self, ok, text):
        if not ok:
            self.failures += 1
        self.lines.append(f"  {'PASS' if ok else 'FAIL'}  {text}")
        return ok

    def info(self, text):
        self.lines.append(f"  INFO  {text}")

    def finish(self, path=None):
        status = "PASS" if self.failures == 0 else f"{self.failures} FAIL"
        out = "\n".join([f"{self.title}: {status}"] + self.lines)
        print(out)
        if path:
            Path(path).parent.mkdir(parents=True, exist_ok=True)
            Path(path).write_text(out + "\n")
        sys.exit(1 if self.failures else 0)


def bbox_overlap(a, b, tol=0.0):
    A, B = a.bounding_box(), b.bounding_box()
    return all(
        getattr(A.min, k) - tol <= getattr(B.max, k)
        and getattr(B.min, k) - tol <= getattr(A.max, k)
        for k in "XYZ"
    )


def overlap_volume(a, b):
    """Volume shared by two solids. Touching faces give zero."""
    if not bbox_overlap(a, b):
        return 0.0
    common = a & b
    return sum(s.volume for s in common.solids()) if common else 0.0


def holes(shape, axis="Z"):
    """Cylindrical faces with an axis parallel to X, Y, or Z.

    Returns (diameter, position of axis) tuples. Some faces have no radius;
    they are skipped.
    """
    out = []
    for f in shape.faces().filter_by(GeomType.CYLINDER):
        if f.radius is None:
            continue
        ax = f.axis_of_rotation
        if abs(abs(getattr(ax.direction, axis)) - 1) < 1e-6:
            out.append((round(2 * f.radius, 4), ax.position))
    return out


def planar_faces(shape, normal, where=lambda f: True):
    """Planar faces whose normal matches (x, y, z), filtered by a predicate."""
    nx, ny, nz = normal
    out = []
    for f in shape.faces().filter_by(GeomType.PLANE):
        n = f.normal_at()
        if abs(n.X - nx) < 1e-6 and abs(n.Y - ny) < 1e-6 and abs(n.Z - nz) < 1e-6 and where(f):
            out.append(f)
    return out


def sweep_collisions(assemble, positions, intended=(), threshold=1e-4):
    """Check every pair of bodies in different motion groups at each position.

    assemble(position) must return bodies with .name, .shape and .group.
    intended: (name, name) pairs that are designed to overlap (threads).
    Returns {"a / b": (first position, last position, max volume)}.
    """
    intended = set(intended) | {(b, a) for a, b in intended}
    found = {}
    for pos in positions:
        for a, b in itertools.combinations(assemble(pos), 2):
            if a.group == b.group or (a.name, b.name) in intended:
                continue
            v = overlap_volume(a.shape, b.shape)
            if v > threshold:
                key = f"{a.name} / {b.name}"
                lo, hi, vmax = found.get(key, (pos, pos, 0.0))
                found[key] = (min(lo, pos), max(hi, pos), max(vmax, v))
    return found


def same_group_collisions(bodies, threshold=1e-4):
    """Bodies that move together: check each pair once."""
    out = []
    for a, b in itertools.combinations(bodies, 2):
        if a.group == b.group:
            v = overlap_volume(a.shape, b.shape)
            if v > threshold:
                out.append(f"{a.name} / {b.name} ({v:.3f} mm3)")
    return out


def min_clearance(assemble, positions, pairs):
    """Minimum distance and its position for each (name, name) pair."""
    best = {pair: (float("inf"), None) for pair in pairs}
    for pos in positions:
        by_name = {b.name: b.shape for b in assemble(pos)}
        for a, b in pairs:
            d = by_name[a].distance_to(by_name[b])
            if d < best[(a, b)][0]:
                best[(a, b)] = (d, pos)
    return best


def first_contact_z(moving, x, y, tip_diameter, z_top=1000.0):
    """Lowest point of a moving part over a vertical screw tip of a given size."""
    from build123d import Align, Cylinder, Pos

    probe = Pos(x, y, 0) * Cylinder(
        tip_diameter / 2, z_top, align=(Align.CENTER, Align.CENTER, Align.MIN)
    )
    common = moving & probe
    return common.bounding_box().min.Z if common.solids() else None
