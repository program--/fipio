# fipio Storage Format

```
<IDENTIFIER> <GEOMETRY OFFSET> <PROPERTIES OFFSET> <NEXT LEVEL OFFSET | 0>
```

- `IDENTIFIER`
    + Description: 2-digit FIPS code, 5-digit FIPS code
    + Align: 7 bits
- `GEOMETRY OFFSET`
    + Description: Offset to this `IDENTIFIER`'s geometry
    + Align: 64 bits
