return {
    'alexghergh/nvim-tmux-navigation',
    config = function()
        require 'nvim-tmux-navigation'.setup {
            disable_when_zoomed = true, -- defaults to false
            keybindings = {
                left = "<C-w><C-h>",
                down = "<C-w><C-j>",
                up = "<C-w><C-k>",
                right = "<C-w><C-l>",
                last_active = "<C-w><C-w>"
            }
        }
    end
}
