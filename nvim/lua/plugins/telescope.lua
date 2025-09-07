return {
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.8",
    -- or                              , branch = '0.1.x',
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<Leader>ff", builtin.find_files, { noremap = true, silent = true })
      vim.keymap.set("n", "<Leader>fg", builtin.live_grep, { noremap = true, silent = true })
      -- function()
      --   local filetype = vim.bo.filetype
      --
      --   if filetype == "neo-tree" then
      --     local ok, manager = pcall(require, "neo-tree.sources.manager")
      --     if ok then
      --       local state = manager.get_state("filesystem")
      --       if state and state.tree then
      --         local node = state.tree:get_node()
      --         local path = node.path
      --         if node.type == "file" then
      --           path = vim.fn.fnamemodify(path, ":h") -- folder of the file
      --         end
      --         builtin.live_grep({ search_dirs = { path } })
      --         return
      --       end
      --     end
      --   end
      --
      --   -- fallback: grep whole project
      -- end,
      vim.keymap.set("n", "<Leader>fb", builtin.buffers, { noremap = true, silent = true })
    end,
  },
  {
    "nvim-telescope/telescope-ui-select.nvim",
    config = function()
      require("telescope").setup({
        extensions = {
          ["ui-select"] = {
            require("telescope.themes").get_dropdown({
              -- even more opts
            }),
          },
        },
      })
      require("telescope").load_extension("ui-select")
    end,
  },
}
