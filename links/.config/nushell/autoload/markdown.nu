# Markdown-related commands
def md [] {
	help md
}

# Reformats a Markdown document.
def "md format" []: string -> string {
	$in | ^pandoc -f gfm -t gfm -s --wrap=none
}
