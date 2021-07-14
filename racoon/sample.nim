import std/[math, strformat]
import dataframe


func frac_to_n(df: DataFrame, frac:float): int =
    return math.ceil(df.shape[0].float * frac).int


func sample_n_with_replacement(df: DataFrame, n:int): DataFrame =
    # TODO
    return DataFrame()


func sample_n_without_replacement(df: DataFrame, n:int): DataFrame =
    let n_rows = df.shape[0]
    if n > n_rows:
        raise newException(
            ValueError,
            fmt"can't sample {n} times without replacement with only {n_rows} rows"
        )
    # TODO
    return DataFrame()



func sample_frac_with_replacement(df: DataFrame, frac:float): DataFrame =
    # calculate how many n for frac of rows
    let n = frac_to_n(df, frac)
    return sample_n_with_replacement(df, n)


func sample_frac_without_replacement(df: DataFrame, frac: float): DataFrame =
    # calculate how many n for frac of rows
    let n = frac_to_n(df, frac)
    return sample_n_without_replacement(df, n)


func sample*(df: DataFrame, n=0, frac=0.0, replace=false): DataFrame =
    var df_sampled: DataFrame
    if n != 0 and frac != 0.0:
        raise newException(
            ValueError, "can't specify both 'n' and 'frac' arguments"
        )
    if n < 0:
        raise newException(
            ValueError, "can't have 'n' as negative numbers"
        )
    if frac > 1.0 or frac < 0.0:
        raise newException(
            ValueError, "'frac' has to be between 0 and 1"
        )
    if n > 0 and replace == true:
        df_sampled = sample_n_with_replacement(df, n)
    elif n > 0 and replace == false:
        df_sampled = sample_n_without_replacement(df, n)
    elif frac > 0.0 and replace == true:
        df_sampled = sample_frac_with_replacement(df, frac)
    elif frac > 0.0 and replace == false:
        df_sampled = sample_frac_without_replacement(df, frac)
    else:
        raise newException(ValueError, "invalid combination of arguments")
    return df_sampled