import std/[strutils, strformat, tables]

import dataframe
import concat


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


func longestString(row: Row): int =
    var
        max_len = 0
        current: int
    for k in row.keys:
        current = len(k)
        if current > max_len:
            max_len = current
    return max_len


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


func makeSepLine(df: DataFrame, counts: Table[string, int]): string =
    # create separator line
    # i.e +-------+
    # with '+' at vertices separated by '-'
    let totalWidth = counts.getTotalWidth
    var
        padding: int
        charIndex = 0
        sepLine = repeat("-", totalWidth)
    sepLine[0] = '+'
    for colName in df.header:
        padding = counts[colName]
        charIndex += (padding + 3)
        sepLine[charIndex] = '+'
    return sepLine


proc echo*(df: DataFrame) =
    let
        counts = df.longestString
        totalWidth = counts.getTotalWidth
        sepLine = makeSepLine(df, counts)
    var
        headerLine: string
        rowLine: string
        val: string
        padding: int
    echo sepLine
    # header line
    headerLine = "|"
    for colName in df.header:
        var padding = counts[colName]
        headerLine = headerLine & fmt" {align(colName, padding)} |"
    echo headerLine
    echo sepLine
    # iterate through rows
    # if dataframe is less than 50 rows then print entire dataframe
    if df.shape[0] <= 50:
        for row in df.data:
            rowLine = "|"
            for colName in df.header:
                val = row[colName]
                padding = counts[colName]
                rowLine = rowLine & fmt" {align(val, padding)} |"
            echo rowLine
    else:
        # if dataframe is more than 50 rows, then truncate to first and last 10
        # rows
        let df_short = concat(df.head(), df.tail())
        var count = 0
        for row in df_short.data:
            count += 1
            rowLine = "|"
            for colName in df.header:
                if count == 10:
                    val = "..."
                    padding = counts[colName]
                else:
                    val = row[colName]
                    padding = counts[colName]
                rowLine = rowLine & fmt" {align(val, padding)} |"
            echo rowLine
    echo sepLine
    echo fmt"shape = {df.shape}"


proc echo*(col: Column) =
    let
        pad_length = col.longestString
        sepLine = "+" & repeat("-", pad_length+2) & "+"
    # 4 because 2*| and 2*(space)
    echo sepLine
    echo fmt"| {align(col.name, pad_length)} |"
    echo sepLine
    for i in col.data:
        echo fmt"| {align(i, pad_length)} |"
    echo sepLine
    echo "shape = " & $len(col.data)


proc echo*(row: Row) =
    let padding = row.longestString
    for k, v in row.pairs:
        echo fmt"{alignLeft(k, padding)} : {v}"

