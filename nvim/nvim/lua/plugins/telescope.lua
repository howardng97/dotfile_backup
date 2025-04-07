return {
  {
    'nvim-telescope/telescope.nvim', tag = '0.1.8',
-- or                              , branch = '0.1.x',
      dependencies = { 'nvim-lua/plenary.nvim' },
      config = function()
        local builtin = require('telescope.builtin')
        vim.keymap.set('n', '<Leader>ff', ':Telescope find_files<CR>', { noremap = true, silent = true })
        vim.keymap.set('n', '<Leader>fg', ':Telescope live_grep<CR>', { noremap = true, silent = true })
        vim.keymap.set('n', '<Leader>fb', ':Telescope buffers<CR>', { noremap = true, silent = true })
      end
    },
  {
    "nvim-telescope/telescope-ui-select.nvim",
    config = function() 
      require("telescope").setup {
        extensions = {
          ["ui-select"] = {
            require("telescope.themes").get_dropdown {
        -- even more opts
             }
          }
        }
      }
      require("telescope").load_extension("ui-select")
    end
  }
}
