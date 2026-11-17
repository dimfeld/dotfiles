---
name: electronics
description: Design or change electronic circuits and prototype PCBs, choose parts and MCUs, and plan home assembly and board bring-up. Apply the user's CNC milling and hot-plate assembly preferences. Use for electronics design work, not firmware-only changes or mechanical CAD alone.
---

# Electronics design

## Tools and project scope

- Use tscircuit unless the user specifies another tool. Apply the available `tscircuit` skill for its APIs, footprints, routing, and checks. Do not replace an established tool in an existing project without discussing the change.
- Use the pcbparts MCP server for part discovery and checks. Discover its tools by name; do not assume a particular tool namespace. Read [references/pcbparts.md](references/pcbparts.md) for the basic lookup workflow.
- Recheck electrical ratings, pin mapping, and land pattern before calling a replacement compatible. Use reference boards as context, not as proof that a circuit is correct.
- If pcbparts is unavailable, state this and use manufacturer documents and distributor listings. Do not claim that unavailable tools were used or that stock was verified.
- Keep each small project in its own directory. Separate circuit source, tool-specific routing work, replaceable exports, and design notes. Keep the editable source and saved routes reproducible. Use one reviewed board state for previews and fabrication exports.

## Select an MCU with the user

If the user has not selected an MCU family, discuss the choice before making a family-specific design. Present the relevant options and a recommendation, then wait for the user's selection. Continue independent work such as the interface list and power budget while waiting. These preferences guide the recommendation; they do not authorize an assumed choice:

| Family | Usual reason to consider it |
| --- | --- |
| ESP32 | Higher processing needs, Wi-Fi, or a GUI; check the exact part's memory and display interfaces |
| Nordic nRF | Low-power wireless; check the required radio protocol on the exact part |
| CH32 | Very simple applications with modest resource needs |
| STM32 | General-purpose applications without a stronger reason for another family |

For any family, check firmware tools, debugger access, available packages, supply limits, GPIO count, peripherals, and actual stock. A GUI or radio requirement does not by itself select a particular part.

For a wireless MCU, prefer a castellated module over a raw IC. Check its exact module variant, antenna type, exposed ground-pad requirements, and land pattern. Prefer a module that can be assembled and inspected with the available tools. Follow the module maker's antenna overhang and copper, component, and enclosure keep-outs on all layers. Do not assume a module removes these layout requirements.

## Choose parts for purchase and assembly

- Select exact, readily available manufacturer part numbers, not generic symbols or package names as if they were orderable parts. Check the intended purchase quantity and distributor. Record the supplier code, observed stock date, relevant package option, and datasheet link in the BOM or notes. Catalog stock is evidence, not a promise of future supply.
- Prefer active parts with practical replacements. Treat lifecycle status as separate from stock. A part in a board-assembly catalog is not necessarily convenient to buy loose for home assembly.
- Prefer 0805 or 1206 passives and accessible leads such as SOIC, SOT, and suitable TSSOP or LQFP packages. Choose pitch and pads against the milling rules, not only soldering ability. Use 0603 and finer-pitch parts when there is a clear benefit and a workable process.
- SMT assembly on a hot plate is available. Prefer SMT on one face where practical. Avoid BGA, WLCSP, and other hidden-ball packages for this home workflow. QFN/DFN and exposed-pad parts are possible, but discuss the need and process with the user; prefer accessible leads where practical. Include the centre-pad, paste, thermal, and inspection plan if one is selected.
- Verify board material and component reflow limits before specifying a hot-plate process. Do not give a generic plate setpoint as a qualified solder profile. Fit heat-sensitive connectors and through-hole parts after reflow when required.
- Make connector bodies, keying, mating direction, pin-1 marks, and assembly access part of the design. Verify top-view versus bottom-view numbering from the exact manufacturer drawing. Mark UART signals by their endpoint, such as MCU_TX and MCU_RX, and state their directions.

## Design for the actual fabrication process

The default is isolation milling and drilling on the user's Genmitsu 3030 Ultra. Two copper layers are acceptable. Ball screws are useful context, but do not establish spindle runout, backlash, tool deflection, or achievable electrical clearance. Read [references/cnc-pcb.md](references/cnc-pcb.md) when choosing packages, footprints, board stack, or routing rules.

A milled hole has no plated barrel. Do not rely on a CAD plated-hole primitive to make a real connection between faces. Plan each required via and each connector's solder faces. Avoid top-side connections beneath a through-hole connector body unless there is a practical, documented solder-access method. Prefer a different footprint, route, or explicit wire link when that removes an inaccessible joint.

## Electrical and layout decisions

- Establish supply sources, voltage ranges, peak and sleep current, logic levels, connectors, and board-size limits before committing the design. Distinguish voltage-reference inputs from power outputs. Check back-power paths when USB, a programmer, a battery, or another supply can be connected at the same time.
- Use the exact IC's current datasheet and reference layout for required decoupling, regulator capacitors, reset, boot straps, and clocks. Check capacitor effective value, regulator stability, dropout and heat, and transient supply demand as relevant. Do not copy values from an unrelated family variant.
- Provide programming/debug access, reset and boot access where needed, ground, supply test points, and probe access to important interfaces. Check debugger voltage references and signal directions. Account for pin-mux and boot-time restrictions before assigning GPIOs.
- Keep decoupling loops short. Provide a usable return path beside fast signals and do not route them across ground-plane gaps. Keep switching loops and RF areas compact and follow the relevant reference layouts. Use pours where they help, but check isolated islands and the extra milling they require.
- Treat current capacity, temperature rise, voltage drop, voltage clearance, and controlled impedance as separate calculations when the circuit needs them. The prototype geometry defaults are not ratings for power or high-voltage circuits. Add input protection and accessible-connector protection according to the actual use.

## Review and delivery

Check the electrical pin map, schematic, placement, copper connectivity, shorts, and manufacturing clearances. Verify that exported files retain the intended pad nets and drill sizes. Check the actual browser preview as well as the CLI build when the user will use a browser editor; its runtime package exports can differ. Use type-only imports for types and avoid unnecessary runtime dependencies in circuit source.

Deliver the schematic, BOM, board preview, routing source, and required fabrication files for the agreed scope. State unresolved design choices and separate CAD checks from physical validation. Include a short assembly and bring-up order: inspect the bare board, check continuity and shorts, verify rails with a current-limited supply, then test programming and interfaces. Add relevant test points and staged power connections so that this order is practical.
