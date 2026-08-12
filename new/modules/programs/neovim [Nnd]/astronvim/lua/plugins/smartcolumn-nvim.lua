---@type LazySpec
return {
  {
    -- https://github.com/m4xshen/smartcolumn.nvim
    "m4xshen/smartcolumn.nvim",
    opts = function(_, opts)
      opts.disabled_filetypes = require("astrocore").extend_tbl(opts.disabled_filetypes or {}, {
        "NvimTree",
        "lazy",
        "mason",
        "help",
        "checkhealth",
        "lspinfo",
        "noice",
        "Trouble",
        "fish",
        "zsh",
      })
      opts.scope = "window"
      opts.custom_colorcolumn = { rust = "100" }
    end,
  },
}
