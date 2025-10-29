# Guide: Durations & Time

## Parsing

`parse_minutes()` accepts several human-friendly forms and a small ISO-8601 subset.

```python
from utils.time import parse_minutes

parse_minutes("90")       # 90
parse_minutes("1h30m")    # 90
parse_minutes("1:30")     # 90
parse_minutes("PT1H30M")  # 90
```

## Formatting

```python
from utils.time import format_minutes_compact, format_hhmm

format_minutes_compact(75)  # "1h 15m"
format_hhmm(75)             # "01:15"
```

## Rounding and Clamping

```python
from utils.time import clamp_minutes, ceil_to_increment

clamp_minutes(500, 0, 240)     # 240
ceil_to_increment(53, 15)      # 60
```
