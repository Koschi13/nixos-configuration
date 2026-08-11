---@type LazySpec
local prefix = "<Leader>c"
return {
  "mistricky/codesnap.nvim",
  version = "1.6.3", -- locked due to issues with V2
  build = "make",
  cmd = { "CodeSnap", "CodeSnapSave", "CodeSnapHighlight", "CodeSnapSaveHighlight" },
  dependencies = {
    {
      "AstroNvim/astrocore",
      opts = {
        mappings = {
          v = {
            [prefix] = { desc = " CodeSnap" },
            [prefix .. "s"] = { ":'<,'>CodeSnap<CR>", desc = "CodeSnap (clipboard)" },
            [prefix .. "S"] = { ":'<,'>CodeSnapSave<CR>", desc = "CodeSnap (save)" },
            [prefix .. "h"] = { ":'<,'>CodeSnapHighlight<CR>", desc = "CodeSnap with highlight (clipboard)" },
            [prefix .. "H"] = { ":'<,'>CodeSnapSaveHighlight<CR>", desc = "CodeSnap with highlight (save)" },
          },
        },
      },
    },
  },
  opts = {
    mac_window_bar = false,
    watermark = "",
    bg_padding = 0,
    has_breadcrumbs = true,
    show_workspace = true,
    has_line_number = true,
    code_font_family = "Lilex Nerd Font Mono",
  },
}
