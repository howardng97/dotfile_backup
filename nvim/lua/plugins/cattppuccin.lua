return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "mocha",
        color_overrides = {
          mocha = {
            base = "#0f1117", -- nền tối hơn
            mantle = "#0b0d13",
            crust = "#07080d",
            blue = "#89b4fa",     -- giữ xanh catppuccin
            sapphire = "#74c7ec", -- aqua blue
            sky = "#89dceb",      -- bright cyan
            -- bỏ bớt đỏ để đỡ gắt mắt
            red = "#7aa2f7",      -- dùng xanh thay đỏ
            maroon = "#5a6fc0",
          }
        }
      })
      vim.cmd("syntax off")
      vim.cmd("filetype off")

      -- màu cơ bản
      local fg = "#ffffff"     -- trắng
      local bg = "#000000"     -- đen
      local cursor = "#74c7ec" -- ocean blue cho con trỏ

      -- text chính
      vim.api.nvim_set_hl(0, "Normal", { fg = fg, bg = bg })
      vim.api.nvim_set_hl(0, "NormalFloat", { fg = fg, bg = bg })

      -- line numbers & dấu nháy
      vim.api.nvim_set_hl(0, "LineNr", { fg = fg, bg = bg })
      vim.api.nvim_set_hl(0, "CursorLineNr", { fg = fg, bg = bg })
      vim.api.nvim_set_hl(0, "NonText", { fg = fg, bg = bg })
      vim.api.nvim_set_hl(0, "EndOfBuffer", { fg = bg, bg = bg }) -- ẩn ~ cuối file

      -- UI cơ bản
      vim.api.nvim_set_hl(0, "StatusLine", { fg = fg, bg = bg })
      vim.api.nvim_set_hl(0, "VertSplit", { fg = fg, bg = bg })
      vim.api.nvim_set_hl(0, "WinSeparator", { fg = fg, bg = bg })
      -- highlight con trỏ
      vim.api.nvim_set_hl(0, "Cursor", { fg = bg, bg = cursor })

      -- nếu dùng CursorLine
      vim.api.nvim_set_hl(0, "CursorLine", { bg = "#111111" })
    end
  }
}
