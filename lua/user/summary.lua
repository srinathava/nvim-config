local M = {}
local ns_id = vim.api.nvim_create_namespace("TensorPreview")

--- Configuration: Add or remove attributes here
local attrs_to_show = {
    { key = "bufferLoc",  label = "l" },
    { key = "bufferType", label = "t" },
    { key = "fmt",        label = "f" },
    { key = "addr",       label = "a" },
}

--- Helper: Split string at the first space after the limit
local function wrap_text_intelligent(str, limit)
    local lines = {}
    local start = 1
    while start <= #str do
        if #str - start < limit then
            table.insert(lines, str:sub(start))
            break
        end

        local split_at = str:find("%s", start + limit)
        if split_at then
            table.insert(lines, str:sub(start, split_at - 1))
            start = split_at + 1
        else
            table.insert(lines, str:sub(start))
            break
        end
    end
    return lines
end

--- Core: Transform verbose tensors into compact tags
local function compactify(line)
    return line:gsub("(tensor<.-#xml%.XExt<.-%>%>)", function(full_tensor)
        local parts = {}
        for _, attr in ipairs(attrs_to_show) do
            local pattern = attr.key .. "%s*=%s*([^,%s>]+)"
            local value = full_tensor:match(pattern)

            if value then
                if attr.key == "addr" then
                    value = value:gsub("%s*:.*$", "")
                end
                table.insert(parts, string.format("%s=%s", attr.label, value))
            end
        end
        return "t<" .. table.concat(parts, ",") .. ">"
    end)
end

--- Main: Generate and display the virtual lines
M.show_preview = function()
    local bufnr = vim.api.nvim_get_current_buf()
    local winid = vim.api.nvim_get_current_win()
    local cursor = vim.api.nvim_win_get_cursor(winid)
    local row = cursor[1] -- 1-indexed line number
    local raw_line = vim.api.nvim_buf_get_lines(bufnr, row - 1, row, false)[1] or ""

    -- Clear previous preview
    vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)

    -- Feature: Multi-line Look-ahead for regions "({"
    local processing_text = raw_line
    if raw_line:match("%(%{%s*$") then
        local line_count = vim.api.nvim_buf_line_count(bufnr)
        -- Look ahead up to 50 lines for the closing "})"
        for i = row + 1, math.min(row + 50, line_count) do
            local next_line = vim.api.nvim_buf_get_lines(bufnr, i - 1, i, false)[1] or ""
            if next_line:match("^%s*%}%s*%)") then
                -- Concat current line with the signature found after "})"
                processing_text = raw_line .. " " .. next_line:gsub("^%s*%}%s*%)", "")
                break
            end
        end
    end

    -- Exit if no tensors found in the (potentially combined) string
    if not processing_text:find("tensor<") then return end

    -- 1. Compactify the attributes
    local clean_text = compactify(processing_text)

    -- 2. Slice string to start at the signature ": ("
    local sig_start = clean_text:find(":%s*%(")
    if sig_start then
        clean_text = clean_text:sub(sig_start)
    end

    -- 3. Get dynamic width
    local win_width = vim.api.nvim_win_get_width(winid)
    local dynamic_limit = math.max(20, win_width - 12)

    -- 4. Wrap text for display
    local wrapped = wrap_text_intelligent("󰅪 " .. clean_text, dynamic_limit)

    local virt_lines = {}
    for _, l in ipairs(wrapped) do
        local trimmed = l:gsub("^%s*(.-)%s*$", "%1")
        if #trimmed > 0 then
            table.insert(virt_lines, { { "  " .. trimmed, "DiagnosticVirtualTextInfo" } })
        end
    end

    -- 5. Set the virtual lines above the current line
    vim.api.nvim_buf_set_extmark(bufnr, ns_id, row - 1, 0, {
        virt_lines = virt_lines,
        virt_lines_above = true,
    })
end

--- Initialization: Set up autocommands
M.init = function()
    local group = vim.api.nvim_create_augroup("TensorVirtualLine", { clear = true })

    vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "BufEnter", "VimResized" }, {
        group = group,
        callback = function()
            M.show_preview()
        end,
    })

    M.show_preview()
end

return M
