#[
#  A really simple DataFrame implementation
]#


import std/[sequtils, sugar, strutils, strformat, tables]


type
    Row* = OrderedTable[string, string]

    Header* = seq[string]

    Column* = object
        name*: string
        data*: seq[string]

    DataFrame* = object
        header*: Header
        data*: seq[Row]



func shape*(df: DataFrame): array[2, int] =
    # return dataframe shape [n_rows, n_cols]
    return [len(df.data), len(df.header)]


func toDataFrame*(csv: string, sep=",", linesep="\n", skipStartRows=0, skipEndRows=0): DataFrame =
    # parse delimited string to DataFrame object
    # TODO: schema
    #       Table/Tuple
    var
        header = csv.split(linesep)[skipStartRows].split(sep)
        rows = csv.split(linesep)
        data: seq[Row]
    for row in rows[skipStartRows+1..rows.high]:
        if len(row) > 0:
            var zipped = zip(header, row.split(sep))
            var row_t: OrderedTable[string, string]
            for index, (name, value) in zipped:
                row_t[name] = value
            data.add(row_t)
    return DataFrame(
        header: header,
        data: data,
    )


func toDataFrame(cols: seq[Column]): DataFrame =
    # sequence of columns to dataframe
    let
        colnames = sugar.collect(newSeq): (for i in cols: i.name)
        n_rows = cols[0].data.high
    var
        row: seq[string]
        row_collection: seq[Row]
    for row_idx in 0..n_rows:
        row = sugar.collect(newSeq): (for i in cols: i.data[row_idx])
        var row_t: OrderedTable[string, string]
        for i, (name, val) in zip(colnames, row):
            row_t[name] = val
        row_collection.add(row_t)
    return DataFrame(
        header: colnames,
        data: row_collection
    )


func addColumn*(df: DataFrame, col: Column): DataFrame =
    # add value to all rowTables
    assert df.shape[0] == len(col.data)
    var df_copy = df
    for i in 0..df_copy.data.high:
        df_copy.data[i][col.name] = col.data[i]
    df_copy.header.add(col.name)
    return df_copy


func addColumn*(df: DataFrame, cols: seq[Column]): DataFrame =
    # add seq of columns to a dataframe
    # TODO: really inefficient, stop copying so much
    var df_copy = df
    for col in cols:
        df_copy = df_copy.addColumn(col)
    return df_copy


func addRow*(df: DataFrame, row: Row): DataFrame =
    # append new Row to df.data seq
    # returns a new DataFrame
    var df_copy = df
    df_copy.data.add(row)
    return df_copy


func selectRow*(df: DataFrame, rowindex: int): Row =
    # select single row by index
    return df.data[rowindex]


func selectRow*(df: DataFrame, rowindices: seq[int]): DataFrame =
    # select multiple rows using a seq of indices
    var row_collection: seq[Row]
    for idx in rowindices:
        row_collection.add(df.data[idx])
    return DataFrame(header: df.header, data: row_collection)


func selectColumn*(df: DataFrame, colname: string): Column =
    # select single column from DataFrame
    var vals: seq[string]
    for row in df.data:
        vals.add(row[colname])
    return Column(name: colname, data: vals)


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
    var
        output: string
        rows: seq[string]
    # add header as first row
    rows.add(df.header.join(sep))
    # populate rest of rows
    for row_t in df.data:
        var row: seq[string] = @[]
        for field in row_t.values:
            row.add(field)
        rows.add(row.join(sep))
    output = rows.join(linesep)
    return output


func get_longest_string(col: Column): int =
    # Find the longest string out of the column header
    # and column values so we can pad columns in echo.
    # Column and DataFrame echo procs
    # max limit, just truncate at this point
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


proc echo*(df: DataFrame) =
    # TODO: get longest string for each column, pad columns
    echo df.toString(sep=" | ")
    echo "\nshape = " & $df.shape


proc echo*(col: Column) =
    let pad_length = get_longest_string(col)
    # 4 because 2*| and 2*(space)
    echo repeat("-", pad_length+4)
    echo fmt"| {align(col.name, pad_length)} |"
    echo repeat("-", pad_length+4)
    for i in col.data:
        echo fmt"| {align(i, pad_length)} |"
    echo repeat("-", pad_length+4)
    echo "shape = " & $len(col.data)


proc echo*(row: Row) =
    for col_name, value in row.pairs:
        echo col_name, ":\t", $value
