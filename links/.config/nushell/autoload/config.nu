# Make available more format types, so e.g. `open foo.ndjson` works.
use std formats *

$env.config.show_banner = false
$env.config.table.mode = "light"
$env.config.table.footer_inheritance = false
$env.config.table.show_empty = false
