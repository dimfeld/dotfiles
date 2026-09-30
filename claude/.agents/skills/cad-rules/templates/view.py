"""Show the model in a viewer.

build123d Studio: open the CAD folder, open this file, and press Run.
Change the settings below and run again to see another pose or part.

Outside Studio, this file uses ocp_vscode instead, so it also works with the
VS Code "OCP CAD Viewer" extension:  .venv/bin/python view.py

Template from the cad-rules skill. It expects:
  - build.PRINTED: {part name: make function}
  - build.POSES: {pose name: joint value}
  - assembly.assemble(joint_value, ...) -> bodies with .name, .shape, .color
Change the module names in PROJECT_MODULES and the settings to suit the project.

For a mechanism, add animation and turn it on by default (the viewer loads it
paused). See "Animation" in references/viewers.md. The pattern:

    if ANIMATE:
        show(assembly.animated_compound(start))
        animation = Animation()   # from build123d_studio or ocp_vscode
        for track in assembly.animation_tracks(start, values, seconds):
            animation.add_track(*track)
        animation.animate(speed=1)
"""

# %% Settings
import sys

# Studio keeps one Python kernel between runs. Drop the project modules so a
# run picks up edits to params.py and the part files.
PROJECT_MODULES = ("measurements", "params", "common", "assembly", "build")
for _name in [
    n for n in sys.modules if n in PROJECT_MODULES or n.startswith("parts")
]:
    del sys.modules[_name]

import params as p

# What to show: "assembly", or one printed part name from build.PRINTED.
SHOW = "assembly"

# Joint position for the assembly. The first setting that is not None wins.
ANGLE = None  # joint value, for example 30.0
POSE = "open"  # a name from build.POSES

# %% Show
try:
    from build123d_studio import show
except ImportError:
    from ocp_vscode import show

import assembly
from build import POSES, PRINTED


def joint_value():
    if ANGLE is not None:
        return ANGLE
    return POSES[POSE]


if SHOW == "assembly":
    value = joint_value()
    bodies = assembly.assemble(value)
    show(
        *[b.shape for b in bodies],
        names=[b.name for b in bodies],
        colors=[b.color for b in bodies],
    )
    print(f"joint {value:.1f}")
else:
    show(PRINTED[SHOW](), names=[SHOW])
