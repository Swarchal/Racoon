# Racoon

Simple DataFrames in nim.

A bit like [pandas](https://pandas.pydata.org/), but worse in almost every way.

--------

### Examples
input:
```nim
import racoon

let
    csvString = readFile("example.csv")
    df = csvString.toDataFrame()

```
output:
```
first_name | second_name | age | favourite_food
Bill       | Gates       | 60  | Burgers
Bill       | Clinton     | 71  | Salad
Bill       | Murray      | 59  | Pizza

shape = [3, 4]
```
--------


input:
```nim
echo df["second_name"]
```

output:
```
second_name
-----------
Gates
Clinton
Murray

shape = 3
```

-----
input:
```nim
let wanted_cols = @["second_name", "favourite_food"]
echo df[wanted_cols]
```

output:
```
second_name | favourite_food
Gates       | Burgers
Clinton     | Salad
Murray      | Pizza

shape = [3, 2]
```

### TODO
- types / schema
- filtering
- slicing
- sorting
- aggregations / group by
