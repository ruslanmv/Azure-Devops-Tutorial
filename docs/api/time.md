# API — `utils.time`

Time & duration utilities centered around minutes/hours handling.

## `hours_to_minutes(hours: float) -> int`

Convert fractional hours to whole minutes (rounded, floor at 0).

## `minutes_to_hours_tuple(total_minutes: int) -> Tuple[int, int]`

Return `(hours, minutes)` from total minutes.

## `format_minutes_compact(total_minutes: int) -> str`

Return human-friendly strings like `"2h 30m"`, `"45m"`, or `"3h"`.

## `format_hhmm(total_minutes: int) -> str`

Format minutes as a zero-padded 24h `"HH:MM"`.

## `clamp_minutes(value: int, min_value: int = 0, max_value: int | None = None) -> int`

Clamp minutes into `[min_value, max_value]` if `max_value` is provided.

## `ceil_to_increment(minutes: int, increment: int) -> int`

Ceil minutes upward to the nearest `increment`. For example, `(53, 15) -> 60`.

## `parse_minutes(text: str) -> int`

Parse human-friendly durations into minutes. Accepted forms:

- Plain minutes: `"90"`, `"45"`
- Units: `"90m"`, `"1h"`, `"1h30m"`, `"2h 15m"`
- Clock: `"1:30"`, `"0:45"`
- ISO8601 subset: `"PT90M"`, `"PT1H30M"`, `"P1DT45M"`

Raises `ValueError` if parsing fails.

**Examples**:

```python
parse_minutes("1h")          # 60
parse_minutes("1h 5m")       # 65
parse_minutes("1:05")        # 65
parse_minutes("PT1H5M")      # 65
parse_minutes("P1DT30M")     # 1470
```
