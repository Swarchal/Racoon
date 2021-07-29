import std/[sequtils, strformat]
import ./dataframe


func check_columns(df_a: DataFrame, df_b: DataFrame) =
    if df_a.header.len() != df_b.header.len():
        raise newException(
            ValueError, "dataframes have differing number of columns"
        )
    # check columns are shared between the two dataframes
    # currently the columns need to be in the same order
    for index, df_a_colname in df_a.header.pairs():
        if df_a_colname != df_b.header[index]:
            raise newException(
                ValueError, fmt"column {df_a_colname} not in both dataframes"
            )


func column_order_as(df_change: DataFrame, df_reference: DataFrame): DataFrame =
    # df_to_change.column_order_as(df_refernce)
    # will return a copy of `df_to_change` with the columns in the same order
    # as `df_reference`
    return df_change[df_reference.header]


func concat*(df_a: DataFrame, df_b: DataFrame): DataFrame =
    # concatenate two dataframes
    # check columns are the length
    #check_columns(df_a, df_b)
    let df_a_reordered = df_a.column_order_as(df_b)
    let df_concat = DataFrame(
        header: df_a.header,
        data: sequtils.concat(df_a_reordered.data, df_b.data)
    )
    return df_concat


func concat*(collection: seq[DataFrame]): DataFrame =
    # concatenate a seq of dataframes together
    return sequtils.foldl(collection, concat(a, b))


func concat*(df_a: DataFrame, collection: seq[DataFrame]): DataFrame =
    # concatenate a seq of dataframes onto an existing dataframe
    return sequtils.foldl(collection, concat(a, b), first=df_a)


