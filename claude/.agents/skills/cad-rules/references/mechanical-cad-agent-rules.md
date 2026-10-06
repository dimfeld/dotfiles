# Mechanical CAD Agent Rules

This document defines general rules for agents creating or modifying
mechanical CAD. It is intended to be referenced from a repository's
`AGENTS.md` or equivalent instructions.

The goal is not merely to generate geometrically valid solids. The goal
is to produce designs that are **dimensionally correct, manufacturable,
assemblable, operable, serviceable, and mechanically plausible**.

These rules apply regardless of the CAD backend (for example build123d,
ClassCAD, FreeCAD scripting, OpenSCAD, or another parametric system).

## 1. Treat CAD as an Engineering Model

A successful CAD operation is not proof of a successful mechanical
design.

The agent MUST distinguish between:

-   **Nominal geometry** --- the physical shape of a part.
-   **Clearance / keep-out geometry** --- space that must remain
    unoccupied around a part.
-   **Motion geometry** --- space occupied as a part moves through its
    allowed range.
-   **Assembly geometry** --- space required to install fasteners and
    components.
-   **Tool-access geometry** --- space required for screwdrivers, hex
    keys, sockets, pliers, soldering tools, etc.
-   **Service geometry** --- space required to remove, replace, clean,
    adjust, or inspect components.

The agent MUST reason about all applicable categories, not only nominal
solids.

## 2. Model the Real Parts

Purchased components SHOULD be represented by accurate STEP models when
reliable models are available.

When a detailed model is unavailable or unnecessary, create a simplified
proxy that preserves all mechanically relevant features, including as
applicable:

-   Overall dimensions
-   Mounting holes and hole patterns
-   Shafts and axes
-   Connectors and cable exits
-   Flanges and protrusions
-   Fastener locations
-   Required operating clearance
-   Relevant moving parts
-   Removal direction

Simplification MUST NOT remove geometry that affects fit, motion,
assembly, access, or serviceability.

Do not model a component merely as a mounting-hole pattern if the body
of the real component can collide with surrounding structure.

## 3. Fasteners Are Components, Not Holes

A screw hole does not prove that a screw can be installed.

For mechanically significant fasteners, account for the complete
fastening system as applicable:

-   Screw or bolt shank
-   Head
-   Nut
-   Washer
-   Heat-set insert
-   Standoff or spacer
-   Counterbore or countersink
-   Thread engagement
-   Required insertion path

The agent MUST verify that the actual fastener geometry fits after
assembly.

### Tool access

The agent MUST also consider how the fastener is tightened or removed.

Model or otherwise validate an appropriate **tool-access envelope**,
such as:

-   Screwdriver shaft and handle clearance
-   Hex-key approach and swing clearance
-   Socket diameter and approach
-   Wrench access
-   Pliers access

A design MUST NOT be considered assemblable merely because the fastener
itself does not collide with surrounding geometry.

If the intended tool or assembly method is unknown and access appears
constrained, the agent SHOULD flag the uncertainty rather than assume
access is adequate.

## 4. Model Assembly Paths

Parts often fit in their final positions while being impossible to
install.

For components with constrained installation, define an **assembly or
insertion envelope** representing the space occupied while the component
moves from an accessible position into its installed position.

Examples include:

-   Sliding a motor into a bracket
-   Inserting a bolt through a hinge
-   Installing a nut behind a panel
-   Lowering a reservoir into a cradle
-   Routing a connector through an opening
-   Pressing a bearing into a housing

The agent MUST check the installation path when final-position clearance
alone is insufficient to prove assemblability.

## 5. Model Service and Removal Envelopes

Components that require routine removal, cleaning, replacement,
adjustment, refilling, or inspection MUST have a service/removal path.

Examples:

-   Battery removal
-   Reservoir removal
-   Filter replacement
-   Cup or container removal
-   Electronics enclosure opening
-   Motor replacement
-   Belt tension adjustment

Represent this using a **service envelope** or explicit removal-path
analysis.

A design SHOULD allow normal service without unnecessary disassembly of
unrelated components.

The agent MUST NOT conclude that a removable component is accessible
solely because it is visible or unobstructed in its final position.

## 6. Model Motion Explicitly

Moving mechanisms MUST define their intended degrees of freedom and
motion limits.

Where supported, use explicit joints such as:

-   Revolute
-   Prismatic
-   Cylindrical
-   Rigid
-   Ball/spherical

For every moving component, define or document:

-   Axis or direction of motion
-   Minimum position
-   Maximum position
-   Normal operating range
-   Any mechanically prohibited region

Do not validate a mechanism at only one pose.

## 7. Check Swept Motion and Dynamic Clearance

For moving parts, evaluate interference throughout the required range of
motion.

The agent SHOULD use swept-volume analysis when available. Otherwise,
sample the motion at sufficiently small increments to detect plausible
collisions.

For each relevant pair of components, determine:

-   Whether a collision occurs
-   The position at which it occurs
-   Minimum clearance over the full motion
-   The position of minimum clearance

Example verification output:

``` text
Reservoir motion: 0° to 60°
PASS: no collision with frame
PASS: no collision with tubing
Minimum frame clearance: 3.4 mm at 47°
FAIL: motor bracket collision begins at 56.2°
```

Checking only endpoint positions is insufficient when intermediate
positions can collide.

## 8. Use Explicit Keep-Out and Clearance Envelopes

Create keep-out geometry wherever a physical object requires surrounding
space that is not represented by its nominal solid.

Typical examples include:

-   Cable bend radius
-   Connector insertion/removal
-   Airflow
-   Moving linkage
-   Human finger access
-   Tool access
-   Hot surfaces
-   Vibration/movement allowance
-   Flexible tubing
-   Component tolerances

Keep-out geometry SHOULD be visually distinguishable from manufactured
geometry when displayed.

Keep-out geometry MUST NOT accidentally become part of exported
manufacturing geometry.

## 9. Verify Critical Dimensions Programmatically

Important dimensions MUST NOT rely only on visual inspection.

Where the CAD system permits, verify critical dimensions directly from
generated geometry.

Examples:

-   Overall width/height/depth
-   Hole diameter
-   Hole spacing
-   Wall thickness
-   Shaft diameter
-   Bearing seat diameter
-   Edge distance
-   Clearance
-   Alignment
-   Angle
-   Thread engagement

Prefer tests against actual resulting geometry over tests that merely
repeat input parameters.

For example, checking that `HOLE_DIAMETER == 3.4` verifies a variable.
Checking the generated circular geometry verifies the resulting part.

The agent SHOULD produce a concise verification report after significant
geometry changes.

## 10. Manual Measurement Must Remain Possible

When selecting a CAD workflow or viewer, prefer one that allows the
human reviewer to inspect geometry and measure:

-   Point-to-point distance
-   Face-to-face distance
-   Edge length
-   Circle/hole diameter or radius
-   Angles
-   Bounding dimensions

Automated verification supplements human inspection; it does not
eliminate the need for inspectable geometry.

## 11. Check Static Interference

Assemblies MUST be checked for unintended solid intersections.

Intentional intersections or fits---such as press fits, threaded
engagement, or boolean construction helpers---SHOULD be explicitly
identified so they are not confused with accidental collisions.
For a crush fit, limit the accepted overlap to the crush depth at the
ribs (see "Locating purchased parts in printed pockets" in section 12).

For important interfaces, report minimum clearance rather than merely
reporting "no intersection."

## 12. Account for Manufacturing Reality

Nominal CAD dimensions are not automatically manufacturable dimensions.

The agent MUST account for the intended manufacturing process.

For milled parts (CNC router or mill), read `milling-rules.md`: inside radii, tool reach from each setup, stock and machine travel, tapped holes, and when a part gains from milling.

For FDM printing, consider as applicable:

-   Printer capability
-   Material
-   Dimensional tolerance
-   Hole undersizing
-   Clearance between mating printed parts
-   Layer orientation
-   Anisotropic strength
-   Minimum practical wall thickness
-   Overhangs and support requirements
-   Bridging
-   Heat-set insert geometry
-   Captive nuts
-   Elephant-foot effects
-   Accessible post-processing

### Locating purchased parts in printed pockets

A pocket for a purchased part (servo, motor, board, sensor) needs
clearance so the part fits, but clearance in a load direction is play.
For each direction, state what removes the play:

-   A clamp, strap, or screw holds only in the direction it pushes. It
    does not remove play in the other directions. Friction from a clamp is
    not a reliable hold if the working load is similar to the friction.
-   Find the direction of the main working load (for example, the link
    force on a servo case), and make sure a positive feature holds that
    direction.
-   Consider **crush ribs** on the pocket walls in that direction. They
    are small triangular ribs, about 1-1.5 mm wide at the base, that
    reach about 0.1-0.2 mm past the part face. They take up the part and
    print tolerance without a tight-fitting pocket. Keep the normal
    clearance between the ribs. Taper the top of each rib as a lead-in,
    and keep the ribs clear of slots, notches, and cable exits.
-   Model the ribs, and treat the part-to-rib overlap as an intended
    overlap. Accept it only within the crush depth of the part face, and
    measure the width between the rib tips from the B-rep. Any other
    overlap between the part and the pocket is still a collision.
-   Prefer the part's own mounting features (ear holes, flanges) when a
    tool can reach them. Check the driver path before you decide.

For machined or fabricated parts, use tolerances and features
appropriate to the process.

Do not introduce arbitrary tolerances when requirements are unknown. Use
repository-defined standards when present, otherwise state important
assumptions.

## 13. Design for Assembly

Before considering a design complete, mentally or programmatically walk
through assembly in order.

For every assembly step ask:

1.  Can the part physically reach its installed position?
2.  Can required fasteners be inserted?
3.  Can nuts/washers/inserts be placed?
4.  Can the required tool reach the fastener?
5.  Can the tool actually be operated?
6.  Does installing this part block a later assembly step?
7.  Is there a reasonable assembly order that works?

If no valid assembly sequence exists, the design is invalid even if the
final assembled geometry has no collisions.

## 14. Design for Disassembly and Maintenance

Perform the same reasoning in reverse for components expected to be
serviced.

Ask:

1.  What fails, wears, empties, gets dirty, or needs adjustment?
2.  How is it accessed?
3.  What must be removed first?
4.  Are fasteners accessible in the assembled machine?
5.  Is there room to extract the component?
6.  Will wires, tubes, or connectors prevent removal?

Prefer designs where commonly serviced components require fewer
unrelated parts to be removed.

## 15. Wires, Tubes, and Flexible Components Matter

Do not treat wires, hoses, tubing, belts, and similar flexible elements
as zero-volume lines.

Where mechanically relevant, account for:

-   Outside diameter
-   Bend radius
-   Connector dimensions
-   Strain relief
-   Motion
-   Routing clips
-   Slack required for moving assemblies
-   Pinch/crush hazards
-   Hot or moving surfaces

A routing path that works mathematically but violates minimum bend
radius or cannot be physically threaded through the assembly is not
valid.

## 16. Separate Reference Geometry From Manufacturing Geometry

CAD source SHOULD clearly distinguish among:

-   Manufactured parts
-   Purchased components
-   Reference geometry
-   Keep-out envelopes
-   Motion envelopes
-   Service envelopes
-   Tool envelopes
-   Construction geometry

Only intended manufactured geometry should be exported as
printable/machinable parts.

Use clear naming so an agent and human reviewer can tell these
categories apart.

## 17. Centralize Important Parameters

Important dimensions and design assumptions SHOULD be centralized rather
than duplicated as unexplained numeric literals.

Examples:

-   Fastener sizes
-   Wall thickness
-   Printing clearance
-   Component dimensions
-   Hole patterns
-   Shaft locations
-   Joint limits
-   Minimum clearance requirements

Prefer named parameters with units and descriptive names.

Avoid "magic numbers" unless they are local construction details with no
design significance.

## 18. Preserve Design Intent

When modifying existing CAD, understand why geometry exists before
changing it.

A change to solve one collision MUST NOT silently violate another
requirement such as:

-   Tool access
-   Service removal
-   Structural thickness
-   Motion range
-   Cable routing
-   Manufacturing constraints
-   Alignment with another component

After meaningful changes, rerun all relevant validation rather than
validating only the feature that changed.

## 19. Use Engineering Assertions

Where practical, encode requirements as executable checks.

Examples:

``` text
overall_width <= allowed_width
mount_hole_diameter == required_clearance_diameter
minimum_wall_thickness >= required_wall
minimum_motion_clearance >= required_clearance
frame ∩ service_envelope == empty
frame ∩ tool_access_envelope == empty
collision_count_over_motion_range == 0
```

Assertions SHOULD represent actual design requirements, not merely
implementation details.

Failed assertions MUST be treated as design failures or explicitly
documented exceptions.

## 20. Verification Report

After creating or substantially modifying a mechanical design, report
the checks that were actually performed.

A useful report looks like:

``` text
Geometry
  PASS  All manufactured bodies are valid solids
  PASS  Overall width = 72.00 mm (required 72 mm)
  PASS  Four mounting holes = Ø3.40 mm

Assembly
  PASS  No unintended static intersections
  PASS  M3 bolt heads clear frame by >= 1.8 mm
  PASS  Hex-key access available for all four bolts

Motion
  PASS  Hinge range 0–95°
  PASS  No collision over full range
  PASS  Minimum moving clearance = 2.6 mm at 81°

Service
  PASS  Removable component extraction path clear
  FAIL  Connector cannot be unplugged without removing side panel

Manufacturing
  PASS  Minimum wall = 2.4 mm
  PASS  No unsupported overhang exceeds project limit
```

Do not claim a check passed unless it was actually evaluated.

If a capability cannot be checked with the available CAD tools, say so
explicitly and identify it for human review.

## 21. Definition of Done

A mechanical CAD task is not done merely because the requested shape
exists.

Before declaring a design complete, verify all applicable items:

-   [ ] Critical dimensions match requirements
-   [ ] Purchased components are represented adequately
-   [ ] No unintended static collisions exist
-   [ ] Required minimum clearances are satisfied
-   [ ] Moving parts are checked throughout their full required motion
-   [ ] Fastener bodies and heads fit
-   [ ] Nuts, washers, inserts, and other fastening hardware fit
-   [ ] Fasteners can be inserted
-   [ ] Required tools can reach and operate
-   [ ] Parts have valid assembly paths
-   [ ] A feasible assembly sequence exists
-   [ ] Serviceable components have valid removal paths
-   [ ] Flexible components have plausible routing and bend clearance
-   [ ] Manufacturing tolerances and process constraints are accounted
    for
-   [ ] Keep-out/reference/service geometry is excluded from
    manufacturing exports
-   [ ] Relevant automated validation passes
-   [ ] Remaining unverified assumptions are clearly reported

## Core Principle

**Design the physical process, not just the final shape.**

A mechanically valid design must account for how parts are manufactured,
assembled, fastened, moved, used, adjusted, cleaned, serviced, and
eventually disassembled.

When uncertain, prefer explicit geometry, measurable constraints, and
verifiable envelopes over visual assumptions.
