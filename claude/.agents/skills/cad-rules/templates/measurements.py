"""Measured and published dimensions of the real parts the design fits.

Every number that comes from outside the model is recorded here, with where it
came from and how far to trust it. `params.py` reads the values from this file;
do not type these numbers into the parts directly.

  confirmed = True   measured on the actual part, or a published standard
  confirmed = False  provisional: from a brief, a typical datasheet, or a guess

Run `.venv/bin/python measurements.py` to list what still needs measuring.
check.py lists the provisional values in its report.

When you measure a part: change `value`, set `confirmed=True`, and put the
tool, the date, and the spread of readings in `source` and `accuracy`.
"""

from dataclasses import dataclass


@dataclass(frozen=True)
class Measurement:
    value: float
    confirmed: bool
    source: str  # where the number came from: tool, document, or person, and date
    accuracy: str  # how far to trust it, for example "+/-0.05 mm (calipers)"
    unit: str = "mm"
    note: str = ""  # what the number is used for, or what to watch for


# --- Example entries: replace with the project's parts --------------------

tube_od = Measurement(
    6.35,
    confirmed=False,
    source="Design brief: nominal 1/4in OD, 2026-08-29",
    accuracy="nominal only; tube OD tolerance is often +/-0.2 mm or more",
    note="Sets the channel width. Print a fit coupon and measure with calipers.",
)
m3_nut_flats = Measurement(
    5.5,
    confirmed=True,
    source="ISO 4032 M3 hex nut, width across flats",
    accuracy="5.32-5.50 mm",
)


def all_measurements():
    return {k: v for k, v in globals().items() if isinstance(v, Measurement)}


def unconfirmed():
    return {k: v for k, v in all_measurements().items() if not v.confirmed}


if __name__ == "__main__":
    items = all_measurements()
    todo = unconfirmed()
    print(f"{len(items)} measurements, {len(todo)} not confirmed\n")
    for name, m in items.items():
        flag = "ok  " if m.confirmed else "TODO"
        print(f"{flag} {name:26} {m.value:8.3f} {m.unit:3} {m.source}")
        print(f"     {'':26} accuracy: {m.accuracy}")
        if m.note:
            print(f"     {'':26} {m.note}")
