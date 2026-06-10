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

# dfi - query Nushell pipeline data with DuckDB SQL
#
# Input is loaded into a 'df' table. With no query, runs DESCRIBE and drops
# into an interactive DuckDB REPL. With a query, the results come back as
# Nushell structured data and participate in the pipeline.
#
#   open foo.xlsx | dfi                            # explore interactively
#   open foo.xlsx | dfi 'select max(bar) from df'  # query in the pipeline
def dfi [
    query?: string  # DuckDB SQL query over the 'df' table (omit for a REPL)
] {
    # Datetimes serialize with variable sub-second precision, but DuckDB needs one
    # uniform format per column to type it as a timestamp — pin them to 9 digits.
    let input = $in
    let normalized = if ($input | describe | str starts-with 'table') {
        $input | update cells {|v|
            if ($v | describe) == 'datetime' { $v | format date '%Y-%m-%dT%H:%M:%S%.9f%z' } else { $v }
        }
    } else { $input }
    let data = $normalized | to json

    let load = {|src| $"create table df as select * from read_json\('($src)', timestampformat='%Y-%m-%dT%H:%M:%S.%n%z'\)" }

    if $query == null {
        # The REPL needs stdin for the terminal, so stage the data in a temp file
        let tmp = mktemp --tmpdir dfi-XXXXXXXX
        $data | save -f --raw $tmp
        let describe = if (is-terminal --stdout) { " describe df;" } else { "" }
        try { ^duckdb -cmd $"(do $load $tmp);($describe)" }
        rm $tmp
    } else {
        # A trailing semicolon would end the COPY's subquery early
        let q = $query | str trim | str trim --right --char ';'
        $data | ^duckdb -c $"(do $load '/dev/stdin'); copy \(($q)\) to '/dev/stdout' \(format json, array true\)" | from json
    }
}
