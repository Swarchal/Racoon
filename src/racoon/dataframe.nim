#[
#  A really simple DataFrame implementation
]#


import std/[strutils, strformat, tables]


type
    Row* = OrderedTable[string, string]
        # on-demand view of a single row, built from the underlying columns

    Header* = seq[string]

    Column* = object
        name*: string
        data*: seq[string]

    DataFrame* = object
        columns*: seq[Column]



func header*(df: DataFrame): seq[string] =
    # return column names, in column order
    result = newSeq[string](df.columns.len)
    for i, col in df.columns:
        result[i] = col.name


func shape*(df: DataFrame): array[2, int] =
    # return dataframe shape [n_rows, n_cols]
    if df.columns.len == 0:
        return [0, 0]
    return [df.columns[0].data.len, df.columns.len]


func toDataFrame*(csv: string, sep=",", linesep="\n", skipStartRows=0, skipEndRows=0): DataFrame =
    # parse delimited string directly into columns
    # TODO: schema
    #       Table/Tuple
    var lines = csv.split(linesep)
    var header = lines[skipStartRows].split(sep)
    # guard against duplicate column names
    var seen: seq[string]
    for name in header:
        if name in seen:
            raise newException(ValueError, fmt"duplicate column name: {name}")
        seen.add(name)
    var columns: seq[Column]
    for name in header:
        columns.add(Column(name: name, data: newSeq[string]()))
    # ignore trailing empty lines, then drop the last skipEndRows data lines
    var lastLine = lines.high
    while lastLine >= 0 and lines[lastLine].len == 0:
        lastLine -= 1
    lastLine -= skipEndRows
    for lineIdx in (skipStartRows+1)..lastLine:
        let line = lines[lineIdx]
        if len(line) > 0:
            let fields = line.split(sep)
            if fields.len != header.len:
                raise newException(
                    ValueError,
                    fmt"line {lineIdx+1}: expected {header.len} fields, got {fields.len}"
                )
            for colIdx in 0..header.high:
                columns[colIdx].data.add(fields[colIdx])
    return DataFrame(columns: columns)


func toDataFrame*(cols: seq[Column]): DataFrame =
    # sequence of columns to dataframe
    if cols.len > 0:
        let n_rows = cols[0].data.len
        for col in cols:
            assert col.data.len == n_rows
    return DataFrame(columns: cols)


func addColumn*(df: DataFrame, col: Column): DataFrame =
    # append a single column to the dataframe
    assert col.data.len == df.shape[0]
    var df_copy = df
    df_copy.columns.add(col)
    return df_copy


func addColumn*(df: DataFrame, cols: seq[Column]): DataFrame =
    # add seq of columns to a dataframe
    var df_copy = df
    for col in cols:
        assert col.data.len == df_copy.shape[0]
        df_copy.columns.add(col)
    return df_copy


func addRow*(df: DataFrame, row: Row): DataFrame =
    # append new Row to each column
    # returns a new DataFrame
    var df_copy = df
    for col in df_copy.columns.mitems:
        col.data.add(row[col.name])
    return df_copy


func selectRow*(df: DataFrame, rowindex: int): Row =
    # select single row by index, built on-demand from columns
    var row_t: Row
    for col in df.columns:
        row_t[col.name] = col.data[rowindex]
    return row_t


func selectRow*(df: DataFrame, rowindices: seq[int]): DataFrame =
    # select multiple rows using a seq of indices
    var columns: seq[Column]
    for col in df.columns:
        var vals: seq[string]
        for idx in rowindices:
            vals.add(col.data[idx])
        columns.add(Column(name: col.name, data: vals))
    return DataFrame(columns: columns)


func selectColumn*(df: DataFrame, colname: string): Column =
    # select single column from DataFrame
    for col in df.columns:
        if col.name == colname:
            return col
    raise newException(KeyError, fmt"column not found: {colname}")


func `[]`*(df: DataFrame, colname: string): Column =
    # select single column from dataframe
    return df.selectColumn(colname)


func `[]`*(df: DataFrame, colnames: seq[string]): DataFrame =
    # subset dataframe on multiple column names
    var columns: seq[Column]
    for colname in colnames:
        columns.add(df.selectColumn(colname))
    return columns.toDataFrame()


func `[]`*(col: Column, index: int): string =
    # subset value from column via single row index
    return col.data[index]


func `[]`*(col: Column, indices: seq[int]): Column =
    # subset values from single column via multiple row indices
    var vals: seq[string]
    for i in indices:
        vals.add(col.data[i])
    return Column(name: col.name, data: vals)


func toString*(df: DataFrame, sep=",", linesep="\n"): string =
    # convert DataFrame to delimited string
    var rows: seq[string]
    # add header as first row
    rows.add(df.header.join(sep))
    # populate rest of rows, column order == header order by construction
    let n_rows = df.shape[0]
    for rowIdx in 0..<n_rows:
        var row: seq[string] = @[]
        for col in df.columns:
            row.add(col.data[rowIdx])
        rows.add(row.join(sep))
    return rows.join(linesep)


func head*(df: DataFrame, n=10): DataFrame =
    # first n rows of the dataframe
    let total_rows = df.shape[0]
    let n_rows = min(n, total_rows)
    var columns: seq[Column]
    for col in df.columns:
        columns.add(Column(name: col.name, data: col.data[0..<n_rows]))
    return DataFrame(columns: columns)


func tail*(df: DataFrame, n=10): DataFrame =
    # last n rows of the dataframe
    let total_rows = df.shape[0]
    let n_rows = min(n, total_rows)
    var columns: seq[Column]
    for col in df.columns:
        columns.add(Column(name: col.name, data: col.data[total_rows-n_rows..<total_rows]))
    return DataFrame(columns: columns)


iterator rows*(df: DataFrame): Row =
    # yield an on-demand Row view for every index in the dataframe
    for i in 0..<df.shape[0]:
        yield df.selectRow(i)
