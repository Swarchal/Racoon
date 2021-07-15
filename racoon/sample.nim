import std/[math, random]
import dataframe


func frac_to_n(df: DataFrame, frac: float): int =
    return math.ceil(df.shape[0].float * frac).int


proc shuffle*(df: DataFrame): DataFrame =
    # shuffle rows of dataframe
    var df_copy: DataFrame
    deepCopy(df_copy, df)
    random.shuffle(df_copy.data)
    return df_copy


proc sample_n_with_replacement(df: DataFrame, n: int): DataFrame =
    var
        df_copy = df
        sample_row_idx: int
        row: Row
        new_data: seq[Row]
        sample_count = 0
    while sample_count < n:
        sample_row_idx = random.rand(df.shape[0]-1)
        row = df.data[sample_row_idx]
        new_data.add(row)
        sample_count += 1
    df_copy.data = new_data
    return df_copy


proc sample_n_without_replacement(df: DataFrame, n: int): DataFrame =
    let n_rows = df.shape[0]
    if n > n_rows:
        raise newException(
            ValueError,
            "without replacement, can't sample more rows than in the dataframe"
        )
    # shuffle rows and take the first n
    var df_shuffled = shuffle(df)
    df_shuffled.data = df_shuffled.data[0..n-1]
    return df_shuffled


proc sample_frac_with_replacement(df: DataFrame, frac: float): DataFrame =
    # calculate how many n for frac of rows
    let n = frac_to_n(df, frac)
    return sample_n_with_replacement(df, n)


proc sample_frac_without_replacement(df: DataFrame, frac: float): DataFrame =
    # calculate how many n for frac of rows
    let n = frac_to_n(df, frac)
    return sample_n_without_replacement(df, n)


proc sample*(df: DataFrame, n=0, frac=0.0, replace=false): DataFrame =
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