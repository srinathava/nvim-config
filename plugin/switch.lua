local function fileparts(fname)
    local basename = vim.fn.fnamemodify(fname, ":t:r")
    local ext = vim.fn.fnamemodify(fname, ":e")
    return basename, ext
end

local function switchFiles()
    local curfname = vim.api.nvim_buf_get_name(0)
    local curbase, curext = fileparts(curfname)

    local otherext
    if string.match(curext, '^[cC]') then
        otherext = '.h*'
    else
        otherext = '.c*'
    end

    -- First try to see if the alternate file is already opened.
    for bufnr = 1, vim.fn.bufnr('$') do
        if not vim.api.nvim_buf_is_valid(bufnr) then
            goto continue
        end

        local otherfname = vim.api.nvim_buf_get_name(bufnr)
        local otherbase, _ = fileparts(otherfname)
        if curbase == otherbase and (not curfname == otherfname) then
            vim.cmd('drop ' .. otherfname)
            return
        end
        ::continue::
    end

    local cmd
    local projdir = require('user.cruise').projdir()
    -- I swill want things to work outside cruise repos.
    if projdir == nil then
        projdir = vim.fn.getcwd()
    end
    print(projdir)
    if vim.fn.executable('fd') then
        cmd = "fd --glob '" .. curbase .. otherext .. "' " .. projdir
    else
        cmd = "find " .. projdir .. " --name '" .. curbase .. otherext .. "'"
    end
    local output = vim.fn.system(cmd)
    if string.len(output) > 0 then
        vim.cmd('drop ' .. output)
    end
end

vim.api.nvim_create_user_command("EH", switchFiles, { desc = "Switch between header and source file" })
