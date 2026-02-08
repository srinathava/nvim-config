local M = {}

M.init = function()
    local buf = vim.api.nvim_create_buf(false -- listed
    , true                                    -- scratch
    )
    local function update_buf()
        local row = vim.api.nvim_win_get_cursor(0)[1] -- 1-indexed
        local raw_line = vim.api.nvim_get_current_line()
        local final_text = raw_line

        -- 1. Check if the line ends with the start of a region "({"
        if raw_line:match("%(%{%s*$") then
            local line_count = vim.api.nvim_buf_line_count(0)
            -- Look ahead (up to 50 lines to avoid hanging on massive files)
            for i = row + 1, math.min(row + 50, line_count) do
                local next_line = vim.api.nvim_buf_get_lines(0, i - 1, i, false)[1]

                -- 2. Find the first line that starts with "})"
                -- and grab the trailing type info
                if next_line:match("^%s*%}%s*%)") then
                    final_text = raw_line .. "..." .. next_line:gsub("^%s*", "")
                    break
                end
            end
        end

        -- Capture the ENTIRE block between tensor< and >>
        local clean_line = final_text:gsub("(tensor<.-#xml%.XExt<.-%>%>)", function(full_tensor)
            local loc = full_tensor:match("bufferType%s*=%s*([^,%s]+)") or "L?"
            local fmt = full_tensor:match("fmt%s*=%s*([^,%s]+)") or "L?"
            local addr = full_tensor:match("addr%s*=%s*([^,%s]+)") or "a?"
            -- Strip the ': si64' type if present
            addr = addr:gsub("%s*:.*$", "")

            return string.format("t<%s,%s,addr=%s>", loc, fmt, addr)
        end)
        vim.api.nvim_buf_set_lines(buf, 0, 1, true, { clean_line })
    end
    local win = vim.api.nvim_open_win(buf, false -- enter
    , {
        split = 'above',
        win = 0,
        height = 5
    })
    vim.api.nvim_set_option_value('number', false, { win = win })
    vim.api.nvim_set_option_value('wrap', true, { win = win })
    local id = vim.api.nvim_create_augroup("UpdatePreviewWindow", {
        clear = true
    })
    vim.api.nvim_create_autocmd({ "CursorMoved" }, {
        pattern = { "*" },
        callback = function(ev)
            update_buf()
        end,
        group = id,
    })
    update_buf()
end

return M
