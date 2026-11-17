# Provisional CNC PCB rules

Use these as conservative starting choices for this user's home process. They are not measured machine capabilities or fabrication standards. Revise them after a coupon test with the actual board, tools, spindle, and fixture. The user will verify the Genmitsu 3030 Ultra's limits.

## Starting geometry

All dimensions are millimetres. Clearance means copper edge to copper edge, not track centre spacing.

| Feature | Preferred starting choice | Conditional choice |
| --- | --- | --- |
| Low-current signal trace | 0.40–0.60 wide | 0.30 only after a successful coupon or an agreed local exception |
| Copper clearance | 0.30–0.40 | 0.25 only after a successful coupon or an explicit provisional exception |
| IC lead pitch | At least 0.80; 1.27 is easier | 0.65 may work with a verified land pattern and process; do not assume 0.50 is suitable |
| Passives | 0805 or 1206 | 0603 if the footprint and handling benefit justify it |
| Wire-via drill | 0.80 | Match the actual wire or eyelet; 0.70 may be useful after testing |
| Wire-via copper pad | 1.80–2.00 diameter | 1.60 with a 0.80 hole gives a smaller 0.40 radial ring |
| Ordinary through-hole annular ring | At least 0.30 radial; prefer 0.40 | Smaller rings need a specific tolerance and assembly review |
| Copper to routed board edge | At least 1.00 | Increase for clamping, damaged edges, or loose registration |

An exception can be necessary for a fixed external interface. Identify its location and dimensions; do not silently relax all board rules to fit it. If it has not been proved by a coupon, describe the fabrication result as provisional.

For adjacent pads, compute the actual free gap from pitch and copper width. A trace can pass between pads only if the free gap is at least the trace width plus clearance on both sides. Pitch alone does not establish routability. Check diagonal pads and drill rings as well as straight rows.

Size each component drill from its lead dimensions, tolerances, and the maker's guidance. A square lead requires space for its diagonal. Do not enlarge every drill to a convenient bit size without checking the remaining annular ring. Extra copper on a solder pad must not close a required isolation gap or violate the package land pattern.

## Copper faces and holes

Prefer one copper face when it gives a short, clear route. Two faces are allowed when they improve the design. Keep the number of manual layer connections small and accessible. A small number of explicit insulated wire links can be easier than milling a second face; show and label them as assembly parts.

Milling and drilling do not plate holes. For a two-face board:

- Use soldered wire vias or a specified eyelet process. Confirm hole size, pad size, access to both joints, and clearances to adjacent copper. Do not assume an eyelet flange fits a nominal via pad.
- List all required face-to-face connections, including component leads that join copper on both faces. Solder each required face. A lead merely touching the hole wall is not a connection.
- Avoid vias inside SMT pads, inaccessible solder joints, and component bodies over wire-via ends. Do not depend on a buried joint being made by a hot plate without a defined assembly method.
- Allow room for connector insertion, clamps or tooling pins, solder tools, and removal of test probes. Keep mounting hardware away from exposed copper where it could make contact.
- Use a common fixture and a defined flip axis. Specify the origin for copper, outline, and drill files. Mirror the bottom face exactly once in CAM, not independently in several export steps. Check an asymmetric pin-1 feature in the CAM preview.

Do not remove route vias from an export merely because their drill records also appear elsewhere. Use the exporter or a checked conversion that retains each physical hole exactly once, with its net connection intact.

## Isolation and assembly

Choose the cutter's effective width at the intended depth, including runout, so that it fits the smallest isolation gap. A V-bit becomes wider with depth. Ball screws do not remove this limit. Use shallow copper cuts, a flat supported board, and height compensation where available. Set feeds, speeds, and depth from a test; do not infer them from the machine model alone.

Choose board material that fits both milling and the intended solder profile. Do not assume every paper-based laminate tolerates hot-plate reflow. Consider flatness and heat resistance as well as ease of cutting. Use suitable dust collection for the actual material.

Prefer accessible SMT pads over fine through-hole grids when this gives larger isolation gaps and a practical reflow joint. Do not sacrifice mechanical retention at cable connectors without considering repeated insertion force. Add strain relief or suitable mounting support when needed.

Silkscreen exports are assembly references; the CNC does not print them. Provide a component-side drawing or label overlay. If text will be engraved, place it in a separate operation and keep it out of functional copper.

## Coupon and release evidence

Before claiming a new minimum geometry, propose a coupon with representative parallel traces and gaps, the tightest chosen package, drill rings, and any manual via or two-face registration feature. Inspect isolation and measure continuity between intended nets and resistance between different nets. Check the drill offset and remaining rings under magnification.

Record what was tested: laminate and copper thickness, cutter geometry, effective cut width, drill sizes, spindle/runout observations, depth, feeds, fixture, and results. Change the provisional defaults only when the user supplies measurements or a test supports the change. Keep a fabrication exception separate from a passed electrical CAD check.
