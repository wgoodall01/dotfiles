local formats = {
    markdown = true,
    markdown_strict = true,
    djot = true,
    gfm = true,
    commonmark = true,
    commonmark_x = true
}


CodeBlock = function(elem)
    if not formats[FORMAT] then
        -- error(FORMAT .. " not supported")
        ---
        -- @no-op
        return elem
    end

    local text, classes, attr = elem.text, elem.classes, elem.attr

    local wd = 2
    for t in text:gmatch("%`+") do
        if #t > wd then
            wd = #t
        end
    end
    local fence = ('`'):rep(wd + 1)
    local block = fence .. "\n" .. text .. "\n" .. fence
    return pandoc.RawBlock(FORMAT, block)
end
