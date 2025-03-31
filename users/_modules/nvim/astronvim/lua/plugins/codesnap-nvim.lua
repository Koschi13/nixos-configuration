---@type LazySpec
return {
  {
    -- https://github.com/mistricky/codesnap.nvim
    "mistricky/codesnap.nvim",
    opts = function(_, opts)
      opts.bg_padding = 0
      opts.has_breadcrumbs = true
      opts.show_workspace = true
      opts.has_line_number = true
      opts.code_font_family = "NotoSansM Nerd Font Mono"
    end,
  },
}
