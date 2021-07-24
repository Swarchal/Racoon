import std/[strutils, strformat, tables]

import dataframe


func longestString(col: Column): int =
    # Find the longest string out of the column header
    # and column values so we can pad columns in echo.
    # Column and DataFrame echo procs
    let limit = 20
    var
        i_len: int
        max_len = 0
    # first check header
    max_len = len(col.name)
    # then iterate through row values
    for i in col.data:
        i_len = len($i)
        if i_len > max_len:
            max_len = i_len
    return min(max_len, limit)


func longestString(df: DataFrame): Table[string, int] =
    # Get the longest string in each column of the DataFrame df.
    # Return this has a table with column names as keys, and longest length as
    # values.
    var
        counter = initTable[string, int]()
        column: Column
    for col_name in df.header:
        column = df[col_name]
        counter[col_name] = column.longestString
    return counter


func getTotalWidth(counts: Table[string, int]): int =
    # Find the total width of a printed table including borders and padding
    var total = 0
    for count in counts.values:
        total += (count + 3) # 3 for space either side and right-edge separator
    total += 1 # left-edge separator
    return total


proc echo*(df: DataFrame) =
    # TODO: get longest string for each column, pad columns
    # need to print row by row
    # but have custom padding for each column
    # this is going to be wild
    let
        counts = df.longestString
        totalWidth = counts.getTotalWidth
    var
        headerLine: string
        rowLine: string
    echo repeat("-", totalWidth)
    # header line
    headerLine = "|"
    for colName in df.header:
        var padding = counts[colName]
        headerLine = headerLine & fmt" {align(colName, padding)} |"
    echo headerLine
    echo repeat("-", totalWidth)
    # iterate through rows
    for row in df.data:
        rowLine = "|"
        for colName in df.header:
            var val = row[colName]
            var padding = counts[colName]
            rowLine = rowLine & fmt" {align(val, padding)} |"
        echo rowLine
    echo repeat("-", totalWidth)
    echo fmt"shape = {df.shape}"



proc echo*(col: Column) =
    let pad_length = col.longestString
    # 4 because 2*| and 2*(space)
    echo repeat("-", pad_length+4)
    echo fmt"| {align(col.name, pad_length)} |"
    echo repeat("-", pad_length+4)
    for i in col.data:
        echo fmt"| {align(i, pad_length)} |"
    echo repeat("-", pad_length+4)
    echo "shape = " & $len(col.data)
