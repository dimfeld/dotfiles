# Viewing models

## build123d Studio (the user's main viewer)

- **App location.** The app is `/Applications/build123d Studio.app`. Its data is in `~/Library/Application Support/build123d-studio/`, and its log is `build123d-studio.log` in that folder. Read the log when a run in Studio fails: it records kernel errors such as `NameError` and `SystemExit`.
- **How Studio runs files.** Studio runs the open file in a persistent IPython kernel, and the opened folder is on `sys.path`. Because of this:
  - **Do not use argparse.** It reads the kernel's arguments and stops with `SystemExit: 2`. Put the settings as constants at the top of the file.
  - **Reload project modules.** The kernel keeps imported modules between runs. Delete the project modules from `sys.modules` at the top of the script, so that each Run picks up your edits.
- **The display API.** `from build123d_studio import show`. The module is built into the app and does not exist outside it. It uses `ocp_viewer_core`: `show(*objs, names=[...], colors=[...])`. `show_all` is not defined. If the import fails, use `from ocp_vscode import show`, which has the same signature, so the script also works outside Studio.
- **Studio's own environment.** Studio uses `~/Library/Application Support/build123d-studio/runtime/.venv`, with Python 3.14 and build123d 0.11.x. To add packages, use `uv add --group user <pkg>` in `runtime/`.
- **Test the script in Studio's environment.** Write code that works with both build123d 0.11 and the newer local version. Test it in Studio's environment with a stub module:

  ```sh
  mkdir -p $TMPDIR/stub
  cat > $TMPDIR/stub/build123d_studio.py <<'EOF'
  def show(*objs, names=None, colors=None, **kw):
      print(len(objs), "objects:", names, all(o.is_valid for o in objs))
  EOF
  PYTHONPATH=$TMPDIR/stub:. "$HOME/Library/Application Support/build123d-studio/runtime/.venv/bin/python" view.py
  ```

  Also test two runs in one interpreter: `exec(open('view.py').read())` twice. This checks the module reload. With the sandbox off, `$TMPDIR` is a different folder, so run the stub test inside the sandbox.
- **The template.** `templates/view.py` shows the pattern.

## Animation (Studio and OCP CAD Viewer)

Documentation: https://bernhard-42.github.io/ocp_viewer_docs/animation/

- **Order of calls:**
  1. `show(compound)`
  2. `animation = Animation()`. It prints the paths it can animate.
  3. `animation.add_track(path, action, times, values)` for each track.
  4. `animation.animate(speed=1)`.
  The paths are valid only for the last `show`.
- **Imports.** Import `Animation` from the viewer package: `from build123d_studio import Animation, show`, or from `ocp_vscode`. Do not import it from `ocp_viewer_core.animation`, which raises `TypeError`.
- **Paths** come from the compound labels: `/<top label>/<child label>`. Give every group a label.
- **Track values.** Times are in seconds.
  - `t` values are offsets from the shown position. They start at `[0, 0, 0]`.
  - `rx`, `ry`, and `rz` turn the group about its own location origin, in degrees, relative to the shown orientation.
  - One object can have an `ry` track and a `t` track together. A link that turns and moves needs both.
- **Group structure.** Build each moving group so that its location is on its rotation axis:

  ```python
  parts = [b.shape.translate((-ox, 0, -oz)) for b in group_bodies]  # geometry relative to the axis
  group = Pos(ox, 0, oz) * Compound(children=parts, label="rocker")
  ```

  - For a rigid group (a rocker, a horn), send `ry = angle - shown_angle`.
  - For a link: put the origin at one pin. Send `ry` for the change in link angle and `t` for that pin's movement.
  - Match the sign convention that the static placement uses. If a part is placed with `rotate(Axis.Y, -phi)`, then `ry = -(phi - phi0)`.
- **Verify without a viewer.** For each child, calculate `child.rotate(Axis.Y, ry).moved(group.location).moved(Pos(*t))` at the last keyframe. Compare it with the assembly built directly at that pose. The centres must agree.
- **Testing.** Give the stub `build123d_studio` module an `Animation` class that builds the paths from the labels of the last shown compound, and asserts that each track path exists and that `len(times) == len(values)`.
- **Default to animation on.** The viewer loads an animation paused, so it costs nothing until the user presses play. A script can show the animation by default and keep fixed-pose settings for when it is off.
- **Fixed parts that depend on the motion range.** For example, set the stop screw for the most closed position in the animation. Otherwise the moving parts pass through it.

## OCP CAD Viewer

- **Two packages.** `ocp_vscode` (4.x) is the client for the VS Code extension. The standalone browser viewer is now a separate package, `ocp_viewer`: run `python -m ocp_viewer --port N` and open `http://127.0.0.1:N/viewer`. `python -m ocp_vscode` no longer starts a viewer.
- **Lock file.** The viewer writes `~/.ocpvscode` and `~/.ocpvscode.lock`. The sandbox blocks this, and the viewer fails with "Locking issue". Run it with the sandbox off.
- **Testing.** To test, start a viewer on a port that is not the default (not 3939), so it does not clash with the user's viewer. Stop it when you finish.
- **Camera.** `show(..., reset_camera=Camera.KEEP)` keeps the camera between frames, for simple animation loops.

## build123d MCP server (render checks)

- `execute()` blocks the `sys`, `os`, and `pathlib` imports, so it cannot import the project modules.
- To render the project, export STEP with the project's own venv. Then use `import_cad_file(path, name)` and `render_view(objects=name, direction="iso", azimuth=200, save_to=...)`.
- Renders show what the model looks like. Confirm each problem with a number before you change anything.
