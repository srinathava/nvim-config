local M = {}

M.init = function()
    local buf = vim.api.nvim_create_buf(false -- listed
    , true                                    -- scratch
    )
    local function update_buf()
        vim.api.nvim_buf_set_lines(buf, 0, 1, true, { vim.api.nvim_get_current_line() })
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
