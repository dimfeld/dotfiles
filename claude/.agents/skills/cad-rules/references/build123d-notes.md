# build123d notes

These are the API traps, conventions, and environment problems found while building a servo pinch valve (build123d 0.13 locally, and 0.11.1 in build123d Studio).

## Project setup

- Use a `uv` project in the CAD folder: `pyproject.toml` with `build123d>=0.9`, `requires-python = ">=3.11,<3.13"`, and `[tool.uv] package = false`.
- In the Claude Code sandbox, `uv sync` and `uv run` fail because the sandbox blocks the uv cache (`~/Library/Caches/uv`). Run `uv sync` once with the sandbox off. After that, run scripts with `.venv/bin/python`, not `uv run`.
- Use this file layout:
  - `params.py`: dimensions and kinematics
  - `common.py`: helpers
  - `parts/<name>.py`: one part per module, each with a `make()` function
  - `assembly.py`: placement and proxies
  - `check.py`: verification
  - `build.py`: STL and STEP export to `build/`
  - `view.py`: the viewer script
- Put `.venv/`, `build/`, and `__pycache__/` in `.gitignore`.
- Run modules from the CAD folder (`.venv/bin/python -m parts.body`), so that `import params` works.

## Coordinates and transforms

- `Rot(90, 0, 0)` (a rotation about X) moves local +Y to world +Z, and local +Z to world −Y. Use it to stand a flat plate (profile in XY) up into the XZ plane.
- `shape.rotate(Axis((x, 0, z), (0, 1, 0)), a)` with a positive `a` turns +X toward −Z. For a rocker whose arm points along +X, a positive angle moves the arm tip down.
- For a plate with its thickness on z ∈ [0, t], place it with `Pos(pivot) * Rot(90, 0, 0) * Pos(0, 0, -t/2) * plate`, then rotate it about the pivot axis.
- To align a link from point H to point Q in the XZ plane: `alpha = atan2(Qz-Hz, Qx-Hx)`. Then use `Pos(H) * (Rot(90, 0, 0) * link).rotate(Axis.Y, -alpha)`.
- Make a feature horizontal in the world at a given joint angle (for example, a stop pad): define it in world coordinates at that angle, then transform its corners into the part frame. For a rocker at angle θ about a pivot (px, pz):
  - u = dx·cosθ − dz·sinθ
  - v = dx·sinθ + dz·cosθ

## API traps

- **`Plane.XZ.offset(...).move(...)` gives unexpected positions.** The XZ normal is −Y, so offsets go the opposite way. Build the profile on `Plane.XZ` at the origin, extrude it, measure its bounding box, and then translate it with `Pos`.
- **Order of fillets.** If a fillet edge runs into a feature added later (for example, a channel edge 0.35 mm from a post), `fillet` fails with "BRep_API: command not done". Fillet the edges first, then add the nearby features.
- **`make_hull(edges)` makes good link and rocker profiles.** Use the edges of circles placed at each boss. The result is a tapered, convex, stiff outline.
- **`Face.radius` can be `None`** on some cylindrical faces. Filter out those faces before you use `2 * f.radius`.
- **To find holes,** use `faces().filter_by(GeomType.CYLINDER)`, then `f.axis_of_rotation` (direction and position) and `f.radius`.
- **To find a planar face by location,** use `faces().filter_by(GeomType.PLANE)` with `f.normal_at()` and `f.center()`.
- **`RegularPolygon(r, 6, major_radius=False)`** gives a hexagon measured across the flats. Its default orientation puts the corners on ±X. Use `rotation=30` to put the flats toward ±X.
- **`SlotCenterToCenter(length, width, rotation=90)`** makes a slot along X. (The default slot is along Y, so the rotation turns it.)
- **To test for overlap:** check the bounding boxes first. Then use `a & b` and add the volume of each solid. Count an overlap only above about 1e-4 mm³, so that touching faces do not count.
- **`a.distance_to(b)`** gives the minimum distance between two shapes. It returns 0 if they touch or overlap.
- **To find a first contact,** intersect the moving part with a probe cylinder (the full tip diameter) and take `bounding_box().min.Z`.

## Teardrop bore

```python
def teardrop(d):
    r = d / 2; s = r / math.sqrt(2)
    return Circle(r) + Polygon((-s, s), (0, r * math.sqrt(2)), (s, s), align=None)

def y_teardrop_bore(x, z, d, y0, y1):
    bore = extrude(Plane.XZ * teardrop(d), amount=y1 - y0, dir=(0, 1, 0))
    return Pos(x, y0 - bore.bounding_box().min.Y, z) * bore
```

## Linkage solving

For a four-bar linkage (servo horn of radius r at S, link of length L, rocker pin Q(θ)), the horn angle is:

`φ = atan2(Qz−Sz, Qx−Sx) − acos((r² + d² − L²) / (2·r·d))`, where d = |Q − S|.

If d > r + L, or d < |r − L|, the linkage cannot reach. Choose the branch once and keep it.

To find a layout, do a grid search over the servo position, L, and the arm length. Score each layout on:
- monotonic φ over the full range,
- servo travel within the specification,
- worst transmission angle (90° minus the angle between the link and each moving tangent).

Run this search before you model.

## Export

- `export_stl(part, path, tolerance=0.01, angular_tolerance=0.1)`
- `export_step(part, path)`
- For a coloured assembly STEP: set `shape.label` and `shape.color = Color("orange")` on each body. Then use `export_step(Compound(children=[...], label="..."), path)`.
- Export only printed parts as print files. Proxies and envelopes go into assembly STEP files only.
