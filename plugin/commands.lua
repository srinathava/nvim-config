vim.api.nvim_create_user_command('CDROOT',
    function()
        vim.fn.chdir(require('user.cruise').rootdir())
    end, {})


vim.api.nvim_create_user_command('CDPROJ',
    function()
        vim.fn.chdir(require('user.cruise').projdir())
    end, {})
