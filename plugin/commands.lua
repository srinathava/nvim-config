vim.api.nvim_create_user_command('CDROOT',
    function()
        vim.fn.chdir(require('user.myproj').rootdir())
    end, {})


vim.api.nvim_create_user_command('CDPROJ',
    function()
        vim.fn.chdir(require('user.myproj').projdir())
    end, {})

vim.api.nvim_create_user_command('WrapLine',
    function()
        require('user.wrapline').init()
    end, {})
