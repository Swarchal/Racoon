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


func head*(df: DataFrame, n=10): DataFrame =
    var n_rows = min(n, df.shape[0])
    return df.selectRow(toSeq(0..n_rows-1))


func tail*(df: DataFrame, n=10): DataFrame =
    let total_rows = df.shape[0]
    var n_rows = min(n, total_rows)
    return df.selectRow(toSeq(total_rows-n_rows..total_rows-1))

