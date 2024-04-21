-- A simple bookmarking system which allows a user to bookmark lines and
-- folders

local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"
local conf = require("telescope.config").values
local finders = require "telescope.finders"
local json = require 'json'
local pickers = require "telescope.pickers"
local previewers = require "telescope.previewers"

local ns_previewer = vim.api.nvim_create_namespace "telescope.previewers"

local create_previewer = function(opts)
    local jump_to_line = function(self, prompt_bufnr, lnum)
        pcall(vim.api.nvim_buf_clear_namespace, prompt_bufnr, ns_previewer, 0, -1)

        -- annoyingly, nvim_buf_add_highlight is 0-indexed, while
        -- nvim_win_set_cursor is 1-indexed
        pcall(
            vim.api.nvim_buf_add_highlight,
            prompt_bufnr,
            ns_previewer,
            "TelescopePreviewLine",
            lnum - 1,
            0, -1 -- highlight entire line
        )

        pcall(vim.api.nvim_win_set_cursor, self.state.winid, { lnum, 0 })
        pcall(vim.api.nvim_win_set_option, self.state.winid, 'number', true)
        vim.api.nvim_buf_call(prompt_bufnr, function()
            vim.cmd "norm! zz"
        end)
    end

    return previewers.new_buffer_previewer {
        title = "Preview",
        define_preview = function(self, entry)
            conf.buffer_previewer_maker(entry.value.path, self.state.bufnr, {
                bufname = self.state.bufname,
                winid = self.state.winid,
                preview = opts.preview,
                file_encoding = opts.file_encoding,
                callback = function(prompt_bufnr)
                    jump_to_line(self, prompt_bufnr, entry.value.lnum)
                end,
            })
        end,
    }
end

local bookmarks = nil

local writefile = function(filename, data)
    local fp = assert(io.open(filename, 'w'))
    fp:write(data)
    fp:close()
end

local init_file = function()
    local bookmark_dir = vim.fn.stdpath('data') .. '/bookmarks'
    if vim.fn.isdirectory(bookmark_dir) == 0 then
        vim.print('Creating directory ' .. bookmark_dir)
        vim.fn.mkdir(bookmark_dir, 'p')
    end
    local bookmark_file = bookmark_dir .. '/bookmarks.json'
    if vim.fn.filereadable(bookmark_file) == 0 then
        vim.print('Creating file ' .. bookmark_file)
        writefile(bookmark_file, '[]')
    end
    return bookmark_file
end

local load_bookmarks = function()
    if bookmarks ~= nil then
        return bookmarks
    end

    local bookmark_file = init_file()
    local fp = assert(io.open(bookmark_file, 'r'))
    local txt = fp:read('*all')
    bookmarks = json.decode(txt)
    fp:close()
    return bookmarks
end

local save_bookmarks = function()
    local bookmark_file = init_file()
    writefile(bookmark_file, json.encode(bookmarks))
end

local M = {}
M.pick = function(opts)
    opts = opts or {}
    bookmarks = load_bookmarks()
    if #bookmarks == 0 then
        print('No bookmarks found')
        return
    end

    pickers.new(opts, {
        prompt_title = "Bookmarks",
        finder = finders.new_table {
            results = bookmarks,
            entry_maker = function(entry)
                return {
                    value = entry,
                    display = function()
                        if entry.lnum == -1 then
                            return '[D] ' .. entry.path
                        end
                        return '[F] ' .. entry.path .. ':' .. entry.lnum
                    end,
                    ordinal = entry.path .. ':' .. entry.lnum,
                }
            end,
        },
        sorter = conf.generic_sorter(opts),
        previewer = create_previewer(opts),
        attach_mappings = function(prompt_bufnr)
            actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                local value = selection.value
                print(vim.inspect(value))
                if value.lnum == -1 then
                    vim.cmd('cd ' .. value.path)
                else
                    vim.cmd('drop ' .. value.path)
                    vim.cmd('' .. value.lnum)
                end
            end)
            actions.delete_buffer:replace(function()
                action_state.get_current_picker(prompt_bufnr):delete_selection(function(selection)
                    M.remove(selection.value)
                end)
                save_bookmarks()
            end)
            return true
        end,
    }):find()
end

local fullpath = function()
    return vim.fn.expand('%:p')
end

M.add = function()
    bookmarks = load_bookmarks()
    local bufnr = vim.fn.bufnr()
    local path = fullpath()
    local lnum = vim.fn.line('.')
    local bookmark = { path = path, lnum = lnum }
    table.insert(bookmarks, bookmark)

    -- insert a sign at the current line
    vim.fn.sign_place(0, 'bookmarked', 'bookmarked', bufnr, { lnum = lnum })

    save_bookmarks()
end

M.add_dir = function()
    bookmarks = load_bookmarks()
    local path = vim.fn.getcwd()
    local bookmark = { path = path, lnum = -1 }
    table.insert(bookmarks, bookmark)
    save_bookmarks()
end

M.remove = function(entry)
    bookmarks = load_bookmarks()
    if entry == nil then
        entry = { path = fullpath(), lnum = vim.fn.line('.') }
    end

    local path = entry.path
    local lnum = entry.lnum
    for i, bookmark in ipairs(bookmarks) do
        if bookmark.path == path and bookmark.lnum == lnum then
            table.remove(bookmarks, i)
            break
        end
    end
    -- remove the sign at the current line
    vim.fn.sign_unplace('bookmarked', { buffer = path, id = 0 })
    save_bookmarks()
end

M.refresh = function()
    -- add signs to current buffer based on bookmarks
    -- this is useful when the bookmarks file is updated externally
    bookmarks = load_bookmarks()
    local path = fullpath()
    vim.print('path: ' .. path)
    for _, bookmark in ipairs(bookmarks) do
        if bookmark.path == path then
            vim.fn.sign_place(0, 'bookmarked', 'bookmarked', vim.fn.bufnr(path), { lnum = bookmark.lnum })
        end
    end
end

M.setup = function()
    vim.fn.sign_define('bookmarked', { text = '🔖', texthl = 'Search' })
    vim.cmd [[command! BookmarkAdd lua require('user.bookmarks').add()]]
    vim.cmd [[command! BookmarkDir lua require('user.bookmarks').add_dir()]]
    vim.cmd [[command! BookmarkRemove lua require('user.bookmarks').remove()]]
    vim.cmd [[command! BookmarkPick lua require('user.bookmarks').pick()]]
    vim.cmd [[autocmd BufReadPost * lua require('user.bookmarks').refresh()]]
end

return M
