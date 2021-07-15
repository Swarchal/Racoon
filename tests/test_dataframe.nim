import std/[unittest]
import racoon/[dataframe, sample]


suite "test dataframes":

    setup:
        let df_bill = readFile("./example_data/example.csv").toDataFrame()

    test "selecting single column":
        let df_bill_skipped = readFile("./example_data/example_skip.csv").toDataFrame(skipStartRows=2)
        check:
            df_bill["first_name"].data == @["Bill", "Bill", "Bill"]
            df_bill["first_name"] == Column(name: "first_name", data: @["Bill", "Bill", "Bill"])
            # and the same for the skipped rows
            df_bill_skipped["first_name"].data == @["Bill", "Bill", "Bill"]
            df_bill_skipped["first_name"] == Column(name: "first_name", data: @["Bill", "Bill", "Bill"])

    test "selecting multiple columns":
        let
            wanted_cols = @["second_name", "favourite_food"]
            df_select = df_bill[wanted_cols]
        check:
            df_select.header == @["second_name", "favourite_food"]
            df_select.shape[0] == df_bill.shape[0]
            df_select.shape[1] == len(wanted_cols)

    test "add a column":
        let new_col = Column(name: "test", data: @["a", "b", "c"])
        check:
            df_bill.addColumn(new_col)["test"] == new_col
            df_bill.addColumn(new_col).shape == [3, 5]


suite "test sampling":

    setup:
        let
            iris = readFile("./example_data/iris.csv").toDataFrame()
            bills = readFile("./example_data/example.csv").toDataFrame()
    
    test "sample n without replacement":
        let iris_n_10 = iris.sample(n=10, replace=false)
        check:
            iris_n_10.shape == [10, 5]

    test "sample n with replacement":
        let
            iris_n_10 = iris.sample(n=10, replace=true)
            bills_n_100 = bills.sample(n=100, replace=true)
        check:
            iris_n_10.shape == [10, 5]
            bills_n_100.shape[0] == 100

    test "sample frac without replacement":
        let iris_frac_033 = iris.sample(frac=0.33, replace=false)
        check:
            # 150 rows in full dataset, so should have about 50 rows
            iris_frac_033.shape[0] < 55
            iris_frac_033.shape[0] > 45

    test "sample frac with replacement":
        let iris_frac_033 = iris.sample(frac=0.33, replace=false)
        check:
            # 150 rows in full dataset, so should have about 50 rows
            iris_frac_033.shape[0] < 55
            iris_frac_033.shape[0] > 45
    
    test "shuffle rows":
        let
            iris_shuffle = iris.shuffle()
            bills_shuffle = bills.shuffle()
        check:
            iris_shuffle.shape == iris.shape
            iris_shuffle.header == iris.header
            bills_shuffle.shape == bills.shape
            bills_shuffle.header == bills.header