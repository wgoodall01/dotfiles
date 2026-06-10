# Markdown-related commands
def md [] {
	help md
}

# Reformats a Markdown document.
def "md format" []: string -> string {
	let lua_filter_name = ($nu.default-config-dir | path join 'autoload' 'markdown_lua_filter.lua')

	$in | ^pandoc -f gfm -t gfm -s --wrap=none --lua-filter=($lua_filter_name)
}

# Parse Markdown into structured rows (the built-in `from md`, which is
# shadowed below so `open` doesn't AST-parse .md files). Runs in a clean
# subshell because the shadow hides the built-in here too.
def "md ast" [
	--verbose (-v) # Return the full AST.
]: string -> table {
	let cmd = if $verbose { 'from md --verbose | to nuon' } else { 'from md | to nuon' }
	$in | ^nu --no-config-file --stdin --commands $cmd | from nuon
}

# Shadow the built-in `from md` so `open file.md` yields plain text.
def "from md" []: string -> string { $in }
