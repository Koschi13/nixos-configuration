-- AstroUI provides the basis for configuring the AstroNvim User Interface
-- Configuration documentation can be found with `:h astroui`

---@type LazySpec
return {
  "AstroNvim/astroui",
  lazy = false, -- disable lazy loading
  priority = 10000, -- load AstroUI first
  ---@type AstroUIOpts
  opts = {
    -- change colorscheme
    colorscheme = "catppuccin-frappe",
  }
}
