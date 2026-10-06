# Milled parts (CNC router or mill)

Read this when a project has, or may have, parts cut on a CNC mill or router. It adds to section 12 of `mechanical-cad-agent-rules.md`.

## Choose the process per part

Do not mill everything because a mill is available. Mill a part when it gains one of these:

- **No creep under a clamp.** A screw head or a load cell clamped on PETG creeps, mostly when warm. If the part is the clamp face (the base under a load cell, a yoke on a floating end), make it aluminium. A metal spacer under a printed part does not help when the screw head still clamps the printed part.
- **Heat.** PETG softens near 80 °C, PLA near 60 °C. A surface that carries load next to hot water (an anvil under a pinched hot tube) or a wet part near boiling water (a brewer cradle) gains from aluminium or acetal copolymer.
- **Accurate round bores and low friction.** Pivot plates and links in acetal turn on screw shanks without bushings. Drilled 3.2 mm bores for M3 pins are round, unlike printed bores.
- **Mass and size.** A metal base adds mass low down (tipping stability) and is not limited by the print bed.
- **Stiffness** where a deflection changes a measurement.

Keep printed: complex 3D shapes that would need many setups, snap clips and other flexures, and parts with no load, creep, or heat problem.

## Materials

| Material | Use | Notes |
|---|---|---|
| 6061-T6 aluminium | Bases, yokes, brackets, clamp faces, anvils | Single-flute carbide on a router, air blast or mist, shallow passes. Tap threads directly (at least 1 x d engaged; 1.5 x d for frequent service). |
| Acetal copolymer (POM-C) | Pivot plates, links, wet parts near hot water | Prefer POM-C to homopolymer (Delrin, POM-H) near hot water: POM-C resists hydrolysis better. Good to about 100 °C. Sharp O-flute or 2-flute, no coolant. Threads up to M3 are fine for set-and-forget screws. |
| HDPE / UHMW | Cheap wet or low-load plates | Soft, creeps, about 80 °C. Heat-set inserts and tapped threads hold poorly: use through-bolts and nuts. |
| G10 / FR4 | Avoid on a desktop router | The glass dust is harmful; it needs real dust extraction. |

Record the density of each material, and give milled bodies their own density in any mass or tipping estimate. Do not guess the material from the part name.

## Modelling conventions

- Model each milled part in the **machine frame of its first setup**: stock bottom on z = 0, tool from +Z. Parts that the assembly models in another frame get a `machine_orient()` function, as printed parts get `print_orient()`.
- List each extra setup as a tool direction, for example (0, 0, -1) after the part is turned over for counterbores from below.
- A part module lists milled pieces in `MILL_PARTS` (`MilledPart` in `templates/milling.py`: name, make, material, stock, stock thickness, setups, smallest end mill, instructions, `outline_from_stock`, qty), next to `PRINT_PARTS`. `hardware.py` reads both and adds a "Milled parts" table (`milling.markdown_table()`). `build.py` exports a STEP file per milled part (STL is not needed for CAM). The viewer script can show milled parts by name too.
- **Stock-size parts.** When the user buys the plate cut to size, set `outline_from_stock=True`. The edges are not machined, so only the machined features must fit the machine travel. A plate as large as the travel is possible this way.
- **Tapped holes:** model them at the tap-drill size (M2 1.6, M3 2.5, M4 3.3, M5 4.2). The hole table names the tap from the size.
- **Press-fit dowel pins:** model the hole at the nominal pin size, model the pin as a proxy, and list the pair as an intended overlap. In the instructions, give the drill and ream sizes, or retaining compound for a loose fit.
- **Faced parts.** A part thinner than the stock (a 4 mm link from 5 mm sheet, a 2.5 mm insert from 8 mm plate) is fine. Say "face to N mm" in the instructions.
- No heat-set inserts in milled parts. Tap aluminium; use nuts in soft plastics.
- **Inside corners on outlines** made by joining shapes: use `round_inside_corners()` (in the template). It rounds only the concave corners.
- **An insert in a printed pocket:** give the insert rounded vertical corners (about 1 mm) so it seats in printed inside corners, and a clearance of about 0.15 mm per side. Keep its working face flush with the printed surface next to it, and check the step.
- When a part changes from printed to milled, remove the print-only features (teardrop bores, heat-set insert holes, bosses for inserts) and the print checks for it.

## Required checks for each milled part

`templates/milling.py` has `check_milled()`, which measures the B-rep:

- One valid solid, stock bottom on z = 0, no taller than the stock.
- The machined region fits the machine travel: the outline plus the tool diameter, or, for stock-size parts, the bounding box of the removed material.
- **Tool reach:** every face can be reached by a straight tool from one of the setup directions. It casts a thin rod from points on each face. Faces on the stock bottom (and the stock edges for stock-size parts) are skipped.
- **No sharp inside corners** along a setup axis: a concave straight edge parallel to a tool direction cannot be cut by a round end mill. Tangent edges are not corners (normals at a tangent plane-cylinder joint can differ by about 0.001, so allow about 0.01).
- **Inside radii** at least the end-mill radius. Full round holes are drilled and are exempt.
- An information line with the hole table.

Also check, per project: thread engagement of tapped holes, the screw tip inside the plate, hardware under a base above the counter (on its feet), and the floor left under pockets in printed parts.

## Lessons from real work

- **A heavy base removed a wall strap.** A printed 150 x 245 mm base tipped at 10° with a full reservoir high on a tower. An 8 mm, 300 x 300 mm aluminium plate (1.9 kg) raised the worst side to 30°. Mass low down and a wider footprint both count.
- **Pocket corners near a floating part.** A relief pocket with a 1 mm margin and a 2 mm corner radius came 0.59 mm from a load cell's floating end at the corner. With a margin equal to or larger than the corner radius, the clearance is the margin.
- **Small steps cannot be milled.** A post that stopped 0.5 mm inside the outer edge left a thin ledge with sharp inside corners. The reach check found it. Make features flush with the edge, or leave a step wider than the tool.
- **fillet() on a merged 2D outline failed.** A hull plus a pad polygon gave inside corners that `fillet()` could not round. The offset closing (out by r, in by r, arc joins on both) rounds only the inside corners. An inward offset with intersection joins does not round them.
- **Locating pockets for extrusions.** A 1/8 in end mill leaves 1.6 mm corner radii. A 2020 extrusion fits if its corner radius is 0.92 mm or more with 0.2 mm clearance per side (the allowed radius difference is clearance / (1 - 1/√2)). Record the extrusion corner radius as a measurement, and give the extrusion proxy its corner radius.
- **A shallow pocket does not hold a tower.** With a 2 mm pocket in place of a 20 mm printed socket, use corner brackets for the bending load.
- **Heights shift together.** Removing a 4 mm printed pad under a load cell lowered every part above it by 4 mm. Derive the stack heights from parameters so the whole stack moves, and check the end clearances (for example, tower top to holder ceiling) again.
- **Check the thickness limits of moving parts.** A link that was 4 mm printed must stay 4 mm when milled from 5 mm sheet: its plane had only 0.6 mm to the next part.
