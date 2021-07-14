import std/[unittest]
import racoon/[dataframe]


suite "test dataframes":

    setup:
        var
            df_bill = readFile("./example_data/example.csv").toDataFrame()
            wanted_cols = @["second_name", "favourite_food"]
            df_select = df_bill[wanted_cols]
            new_col = Column(name: "test", data: @["a", "b", "c"])
            df_bill_skipped = readFile("./example_data/example_skip.csv").toDataFrame(skipStartRows=2)

    test "selecting single column":
        check:
            df_bill["first_name"].data == @["Bill", "Bill", "Bill"]
            df_bill["first_name"] == Column(name: "first_name", data: @["Bill", "Bill", "Bill"])
            # and the same for the skipped rows
            df_bill_skipped["first_name"].data == @["Bill", "Bill", "Bill"]
            df_bill_skipped["first_name"] == Column(name: "first_name", data: @["Bill", "Bill", "Bill"])

    test "selecting multiple columns":
        check:
            df_select.header == @["second_name", "favourite_food"]
            df_select.shape[0] == df_bill.shape[0]
            df_select.shape[1] == len(wanted_cols)

    test "add a column":
        check:
            df_bill.addColumn(new_col)["test"] == new_col
            df_bill.addColumn(new_col).shape == [3, 5]

