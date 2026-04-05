# DuckDB utilities for dataframe exploration and conversion

# dfconvert - convert between file formats (csv, json, parquet, etc.) via DuckDB
# Uses file extension inference by default, or --mode for DuckDB output modes (e.g. markdown)
def dfconvert [
    input_file: string
    output_file: string
    --mode: string  # DuckDB output mode (e.g. markdown, csv, json)
] {
    if not ($input_file | path exists) {
        error make {msg: $"Input file '($input_file)' does not exist."}
    }
    if $mode != null {
        ^duckdb -c $"install excel; load excel; create table t as select * from '($input_file)'; .mode ($mode); .output '($output_file)'; select * from t;"
    } else {
        ^duckdb -c $"install excel; load excel; create table t as select * from '($input_file)'; copy t to '($output_file)';"
    }
}

# dfi - explore a dataframe interactively with DuckDB
# Loads the file into a 'df' table, runs summarize, then drops into a REPL
def dfi [
    file: string
    --format: string  # Force format: csv, json, parquet, excel (default: infer from extension)
] {
    if not ($file | path exists) {
        error make {msg: $"File '($file)' does not exist."}
    }

    let fmt = if $format != null {
        $format
    } else {
        match ($file | path parse | get extension | str downcase) {
            "csv" | "tsv" => "csv"
            "json" | "jsonl" | "ndjson" => "json"
            "parquet" => "parquet"
            "xls" | "xlsx" => "excel"
            _ => "infer"
        }
    }

    let from_expr = match $fmt {
        "csv" => $"read_csv\('($file)'\)"
        "json" => $"read_json\('($file)'\)"
        "parquet" => $"read_parquet\('($file)'\)"
        "excel" => $"read_xlsx\('($file)', empty_as_varchar=true\)"
        "infer" => $"'./($file)'"
        _ => { error make {msg: $"dfi: unknown format '($fmt)'"} }
    }

    ^duckdb -cmd $"create table df as select * from ($from_expr); summarize df;"
}
