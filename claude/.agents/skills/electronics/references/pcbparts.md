# pcbparts basics

Source: [pcbparts MCP guide](https://pcbparts.dev/llms.txt). Check current tool schemas before calling.

Endpoint: `https://pcbparts.dev/mcp`; Streamable HTTP; no authentication.

| Need | Tool and basic arguments |
| --- | --- |
| Find parts | `jlc_search(query="100nF 25V X7R 0805", min_stock=100, limit=5)` |
| Exact part details | `jlc_get_part(lcsc="C...")`; use `mpn="..."` to find LCSC codes |
| Pins and pads | `jlc_get_pinout(lcsc="C...", footprint=true)` |
| Replacements | `jlc_find_alternatives(lcsc="C...")` |
| Reference wiring | `board_search(component="...")`, then `board_get(slug="...", focus="...")` |
| Other tasks | `sensor_recommend`, `get_design_rules`, `cse_get_kicad` |

Search uses a daily snapshot with stock ≥10. Inspect `data_as_of`, `relaxed`, and `ignored_filters`; use `strict=true` to disable relaxation. `jlc_search_help` lists supported filters. A snapshot miss does not prove unavailability.

Use `jlc_get_part(lcsc=...)` for live details, cached up to an hour. Use `jlc_stock_check` before ordering or for low-stock searches. Footprint coordinates use millimetres with Y down.

Use Mouser/DigiKey tools when that distributor is requested. Batch Mouser lookups; request one DigiKey part per call. Do not retry quota errors.
