---@type LazySpec
return {
  {
    -- https://github.com/nvim-neo-tree/neo-tree.nvim
    "nvim-neo-tree/neo-tree.nvim",
    opts = function(_, opts)
      local maps = opts.window.mappings
      maps["<space>"] = "none" -- Disable the mapping, since we want to use it as the <Leader>
    end,
  },
}
