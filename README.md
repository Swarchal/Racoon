# Racoon

Simple DataFrames in nim.

A bit like [pandas](https://pandas.pydata.org/), but worse in almost every way.

--------

### Examples

input:
```nim
import racoon/[dataframe]

var df = readFile("example.csv").toDataFrame()
echo df
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

-----

input:
```nim
echo df["favourite_food"][0]
```

output:
```
Burgers
```
-----
input:
```nim
# selecting a single row returns a Row object
echo df.selectRow(2)
```

output:
```
first_name:     Bill
second_name:    Murray
age:    59
favourite_food: Pizza
```

-----

input:
```nim
# selecting multiple rows returns a DataFrame
echo df.selectRow(@[0, 2])
```

output:
```
first_name | second_name | age | favourite_food
Bill       | Gates       | 60  | Burgers
Bill       | Murray      | 59  | Pizza

shape = [2, 4]
```

### TODO
- types / schema
- filtering
- slicing
- sorting
- aggregations / group by
- sampling rows
