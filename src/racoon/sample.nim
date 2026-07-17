import std/[math, random, sequtils]
import dataframe


func frac_to_n(df: DataFrame, frac: float): int =
    return math.ceil(df.shape[0].float * frac).int


proc shuffle*(df: DataFrame): DataFrame =
    # shuffle rows of dataframe
    var indices = toSeq(0..<df.shape[0])
    random.shuffle(indices)
    return df.selectRow(indices)


proc sample_n_with_replacement(df: DataFrame, n: int): DataFrame =
    var indices: seq[int]
    for _ in 0..<n:
        indices.add(random.rand(df.shape[0]-1))
    return df.selectRow(indices)


proc sample_n_without_replacement(df: DataFrame, n: int): DataFrame =
    let n_rows = df.shape[0]
    if n > n_rows:
        raise newException(
            ValueError,
            "without replacement, can't sample more rows than in the dataframe"
        )
    # shuffle row indices and take the first n
    var indices = toSeq(0..<n_rows)
    random.shuffle(indices)
    return df.selectRow(indices[0..<n])


proc sample_frac_with_replacement(df: DataFrame, frac: float): DataFrame =
    # calculate how many n for frac of rows
    let n = frac_to_n(df, frac)
    return sample_n_with_replacement(df, n)


proc sample_frac_without_replacement(df: DataFrame, frac: float): DataFrame =
    # calculate how many n for frac of rows
    let n = frac_to_n(df, frac)
    return sample_n_without_replacement(df, n)


func check_arguments(n: int, frac: float) =
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


proc sample*(df: DataFrame, n=0, frac=0.0, replace=false): DataFrame =
    # dispatch sample to correct function given parameters
    check_arguments(n, frac)
    var df_sampled: DataFrame
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
