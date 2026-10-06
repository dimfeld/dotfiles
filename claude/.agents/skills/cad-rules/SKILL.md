---
name: cad-rules
description: Rules and workflow for mechanical CAD with build123d - parametric printed parts, assemblies with purchased-part proxies, motion sweeps, interference and clearance checks, and viewing in build123d Studio or OCP CAD Viewer. Use when you create or change CAD models, design 3D-printed or mechanical parts, check fit or motion, or set up a CAD project to view in build123d Studio.
---

# Mechanical CAD rules

A valid solid is not a valid design. The design must also be correct in size, printable, possible to assemble, able to move through its full range, and serviceable. Design the physical process, not only the final shape.

Read these before you start:

- `references/mechanical-cad-agent-rules.md`: the full engineering rules (envelopes, fasteners, tool access, motion, verification report, definition of done). Read it in full for every new design and for every large change.
- `references/build123d-notes.md`: build123d API traps, coordinate conventions, and environment problems found in real work.
- `references/viewers.md`: how to show models in build123d Studio, OCP CAD Viewer, and the build123d MCP server.
- `references/milling-rules.md`: when to mill a part instead of printing it, materials (6061, POM-C), the machine-frame convention, and the machining checks. Read it when the user has a CNC mill or router, or a part is milled.
- `templates/`: `view.py` (Studio and OCP viewer script), `part-card.md` (the per-part record), `measurements.py` (real-part dimensions with source and confirmed status), `check_helpers.py` (overlap, clearance, hole finding, and report helpers), and `milling.py` (`MilledPart` data, materials, and the design-for-machining checks).

## Workflow

1. **Read the brief and every earlier model.** If a model of the same part exists in a different tool, sweep its geometry before you copy it. Earlier models can have collisions that nobody checked.
2. **Do the numbers before the geometry.** Calculate the kinematics, lever ratios, travel, and fastener adjustment range in plain Python first. A brief can contain targets that conflict (for example, a 2:1 lever and 40-70° of servo travel cannot both be met with a standard horn radius). Find the conflict, choose, and record the reason.
3. **Record every real-part dimension in `measurements.py`** (copy `templates/measurements.py`). Each entry has a value, a `confirmed` flag, its source (tool, document, or person, with the date), its accuracy, and a note on what it controls. Use `confirmed=True` only for a measurement of the actual part or a published standard. Briefs, typical datasheets, and estimates stay provisional. Running the file lists what still needs measuring, and `check.py` lists the provisional values in its report.
4. **Put the design dimensions in one module** (`params.py`), which takes its real-part values from `measurements.py`. Calculate derived values (pivot positions, joint limits) from the requirements, not by hand. Print settings and design choices (clearances, wall thickness) belong in `params.py`, not in `measurements.py`.
5. **Model each printed or milled part in its own module**, with a `make()` function, and give it a part card (see "Part cards"). Model a printed part in print orientation, with the bed at z = 0, and a milled part in the machine frame of its first setup, with the stock bottom at z = 0 (see `references/milling-rules.md`). A `place()` function moves it into the assembly frame. You can model parts that do not move in the assembly frame if that frame is already their print or machine orientation.
6. **Model purchased parts as proxies** that keep every feature that affects fit: bodies, heads, nuts, spacers, bearings, horns, tubes, and servo cases with their ears. Leave a 0.05 mm gap where a proxy rests on a face, so that any solid overlap is a real collision.
7. **Write an assembly function** that places every body at a given joint value and tags each one with a motion group, a printed flag, and a colour.
8. **Write `check.py`** that measures the generated B-rep, not the input parameters, and exits non-zero on failure. See "Required checks".
9. **Run the checks, fix the problems, and run them again.** Expect the first sweep to find collisions, mostly at the ends of the motion range.
10. **Look at renders** to find problems. Then confirm each problem with a number before you change anything.
11. **Update the part cards.** Add a dated changelog entry to each card whose part changed, and update its "Design notes" and "Don't" sections.
12. **Update `hardware.py`** and run it to write `hardware.md` again (see "Hardware list").
13. **Write a README** that gives the design summary, the changes from earlier designs with reasons, the provisional values, and what is not modelled. Give a verification report that lists only the checks you actually ran.

## Part cards

Each part module `parts/<name>.py` has a card `parts/<name>.md`, and the assembly has `assembly.md`. Copy `templates/part-card.md`. The card is the record that survives the session: weeks later, it tells the next person what the part is for and what was already tried.

- **Read the card before you change a part.** The "Don't" section records what was tried and rejected. Do not add a rejected feature again without new evidence.
- **Sections:**
  - "What it is": its job, its print count and orientation, and the parts it touches.
  - "Design notes": the governing numbers and the reason for each.
  - "Don't": rejected options, each with its reason.
  - "Changelog": dated entries, newest last.
- **Changelog entries** give the date (YYYY-MM-DD), what changed, why, and what showed the need: a check result, a print, or a physical test. Record failures and the collisions that the checks found. These are the most useful entries.
- **Use numbers from the checks** in the notes and the reasons ("passes 0.8 mm from the stop tower at the 1.0 mm setting"). Measure them; do not estimate them.
- **One module that makes several parts** (for example, two rocker plates) can share one card. List each part in it.
- Point the project's `AGENTS.md` at the cards, so that other agents read them before they edit.

## Hardware list

Keep the purchased parts in `hardware.py`, and generate `hardware.md` from it (the same pattern as `measurements.py`, where Python is the source and the Markdown is readable output).

- **List every item:** the quantity, the full size (for example, "M3 x 16 socket head cap screw, ISO 4762"), where it goes, the card that describes the joint, and notes on fitting (for example, how far to tighten it).
- **Track stock for every item:** give each item in `hardware.py` an explicit `stock` value from a three-state `Stock` enum: `IN_STOCK` (the full required quantity is available), `ORDERED` (ordered, not yet received), or `NEEDED` (not available and not ordered). Show it as a "Stock" column in `hardware.md`. Start new items as `NEEDED` unless the user confirms stock or an order. Preserve existing values when you update the list; if the size or required quantity changes, set the item to `NEEDED` and tell the user, because the stock or order may not match. Change the values in Python, then generate the Markdown again.
- **List the milled pieces** in `MILL_PARTS` (`templates/milling.py`): material, stock, setups, smallest end mill, and instructions. Generate a milled-parts table with the hole and tap list.
- **List the printed pieces too:** keep each piece's export name, quantity, suggested filament, and special print instructions in the Python module that makes it. Include orientation, support needs, and any fitting steps that apply. A module that makes several pieces must supply one entry for each piece. Generate a printed-parts table in `hardware.md` from this data, with links to the source modules. Use the same entries for the export list, so the table and exported pieces stay in agreement. Do not list features joined to another part as separate prints.
- **Calculate the screw lengths** from the same stack widths the model uses. Required length = grip + nut height + at least 2 threads past the nut, which a nylon-insert nut needs. Then choose the next stock length, and record the grip, the requirement, and the thread past the nut in a table.
- **Build the assembly's screw proxies from these lengths and nut heights**, so the swept check covers the hardware you will buy. A longer screw or a thicker lock nut can cause a new collision.
- **Have `check.py` fail if `hardware.md` is out of date**, and have `build.py` write it again.
- **Rotating joints:** use nylon-insert lock nuts, tightened only until the end play is gone. Clamp a bearing inner race with metal spacers. Never use printed spacers.
- **Record items that depend on parts outside the model** ("length = mounting plate thickness + 4 mm") instead of leaving them out.

## Required checks

- Each printed part is a valid single solid with its lowest face on the bed.
- Each milled part passes `check_milled()`: within the stock and the machine travel, every face reachable from a setup, and no inside radius smaller than the end mill.
- Critical dimensions are measured from faces and holes: hole diameters, hole spacings, axis positions, wall thickness around holes, channel widths.
- Functional outputs are measured from the placed geometry (for example, roller-to-anvil gap at the open and closed positions).
- Kinematics:
  - The linkage reaches every joint value.
  - The motion is monotonic, with no toggle.
  - The actuator travel is within the specification.
  - The worst transmission angle is 40° or more.
- **Swept interference** in small steps over the whole range, including the service position and the extreme adjustment setting. Check every pair of bodies in different motion groups. Check bodies in the same group once. Keep a list of intended contacts (for example, threads) and skip only those.
- Minimum clearance, with the angle where it occurs, for each important pair. Use print clearance (about 0.5 mm) between moving printed parts.
- Adjusters (stop screws and similar): the travel over the required range, the change per turn, that the screw stays inside the part at each end, and that it engages the nut or insert fully. Find the first contact over the full tip diameter, not only on the screw axis.
- **Joints between regions of one printed part:** measure the cross-section area that carries the load (intersect the part with a thin slab), and set a minimum. A valid single solid is not proof of a strong joint. Two regions can be joined by a few square millimetres.
- A list of the items that are "not checked", for human review: tool access that was not modelled, provisional dimensions, forces.

## Lessons from real work

- **Most collisions occur at the ends of the range.** One design passed at its nominal positions and collided only between 39° and 42°, at the extreme stop setting.
- **Fastener reality changes the design.** One example: a screw with a head would hang below the base over part of its adjustment range. A headless set screw solved it. Another example: a nut on a pin intersected the next part. A screw threaded into the part solved it. Calculate the screw position at both ends of its adjustment.
- **Sensitivity is a requirement.** A stop 4 mm from a pivot gave about 2 mm of gap change per screw turn, which is too coarse. Calculate mm per turn.
- **Give each moving part its own plane.** Stack the parts along the axis (part, washer, plate, link, horn) and check each gap in the stack.
- **Leave room for deformable parts.** A pinched tube flattens to about π·(OD−wall)/2 + wall wide. Design the anvil and the nearby parts for the flattened width, not for the OD.
- **"One solid" passed while the joint was 6 mm².** A servo tray joined to a body by a short web and a rib touched the tray only at a corner. A section-area check caught it. The rib carried no load. Find the load path first, then put the material on it.
- **Straps under a base lift the part** unless the base has a groove for them.
- **Make horizontal holes in printed parts teardrops**, so they print without supports.

## Viewing

Copy `templates/view.py` into the CAD folder and change the imports to match the project. In build123d Studio, open the folder, open `view.py`, and press Run. The settings at the top of the file select the part or pose. Read `references/viewers.md` before you change it. The main points are:

- Studio runs files in a persistent kernel, so do not use argparse.
- Reload the project modules on each run.
- Studio uses its own Python environment with an older build123d. Test against that environment.
- To animate a mechanism, use the viewer's keyframe `Animation`. Each moving group needs its geometry relative to its rotation axis and its location on that axis. See "Animation" in `references/viewers.md`.
