# Make available more format types, so e.g. `open foo.ndjson` works.
use std formats *

$env.config.show_banner = false
$env.config.table.mode = "light"
$env.config.table.footer_inheritance = false
$env.config.table.show_empty = false

# Disable the `|` marker while the completion menu is active.
$env.config.menus ++= [{
    name: completion_menu
    only_buffer_difference: false # Search is done on the text written after activating the menu
    marker: ""                    # NOTE: Disable indicator
    type: {
        layout: columnar          # Type of menu
        # columns: 4                # Number of columns where the options are displayed
        col_padding: 2            # Padding between columns
    }
    style: {
        text: green                   # Text style
        selected_text: green_reverse  # Text style for selected option
        description_text: yellow      # Text style for description
    }
}]
