import std/[unittest, strutils]

import racoon


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

    test "concatenating":
        let df_bill_copy = df_bill
        check:
            df_bill.concat(df_bill_copy).shape[0] == df_bill.shape[0]*2
            concat(@[df_bill, df_bill_copy]).shape[0] == df_bill.shape[0]*2
            concat(@[df_bill, df_bill_copy]).shape[1] == df_bill.shape[1]

    test "concatenating different column order":
        let
            df_bill_a = df_bill[@["first_name", "second_name"]]
            df_bill_b = df_bill[@["second_name", "first_name"]]
            df_bill_concat = df_bill_a.concat(df_bill_b)
        check:
            df_bill_concat.header == @["first_name", "second_name"]

    test "toString round-trip":
        let
            csv_str = df_bill.toString()
            df_restored = csv_str.toDataFrame()
        check:
            df_restored == df_bill

    test "concat alignment regression - toString preserves header order":
        let
            df_bill_a = df_bill[@["first_name", "second_name"]]
            df_bill_b = df_bill[@["second_name", "first_name"]]
            df_bill_concat = df_bill_a.concat(df_bill_b)
            csv_output = df_bill_concat.toString()
            lines = csv_output.split("\n")
            first_data_line = lines[1].split(",")
        check:
            # header should be in first_name, second_name order
            lines[0] == "first_name,second_name"
            # first data row should have Bill,Gates (from first subset)
            first_data_line[0] == "Bill"
            first_data_line[1] == "Gates"

    test "parse validation - duplicate column names":
        expect(ValueError):
            discard "a,a\n1,2".toDataFrame()

    test "parse validation - mismatched field count":
        expect(ValueError):
            discard "a,b\n1,2,3".toDataFrame()

    test "empty dataframe shape":
        check:
            DataFrame().shape == [0, 0]



suite "sampling":

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

    test "shuffle rows doesn't alter original data":
        let iris_shuffle = iris.shuffle()
        check:
          iris.columns != iris_shuffle.columns
