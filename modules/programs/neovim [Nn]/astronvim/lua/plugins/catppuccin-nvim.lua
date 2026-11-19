-- Leaves the background to the terminal, which applies its opacity only to
-- cells without an explicit background color

---@type LazySpec
return {
  "catppuccin/nvim",
  name = "catppuccin",
  opts = {
    transparent_background = true,
  },
}
