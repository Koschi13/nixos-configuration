-- AstroLSP allows you to customize the features in AstroNvim's LSP configuration engine
-- Configuration documentation can be found with `:h astrolsp`
--
-- For more info see the template repo or here:
-- https://docs.astronvim.com/recipes/advanced_lsp/

---@type LazySpec
return {
  "AstroNvim/astrolsp",
  -- we must use the function override because table merging
  -- does not play nicely with list-like tables
  ---@param opts AstroLSPOpts
  opts = function(_, opts)
    opts.features = require("astrocore").extend_tbl(opts.features or {}, {
      codelens = true, -- enable/disable codelens refresh on start
      inlay_hints = true, -- enable/disable inlay hints on start
      semantic_tokens = true, -- enable/disable semantic token highlighting
      signature_help = true, -- enable automatic signature help popup globally on startup
    })

    opts.config = require("astrocore").extend_tbl(opts.config or {}, {
      -- The config for ruff and pyright is derived from:
      -- https://github.com/astral-sh/ruff-lsp/issues/384#issuecomment-1992012227
      -- ruff = {
      --     init_options = {
      --         settings = {
      --             args = {
      --                 "--ignore=F821",
      --             },
      --         },
      --     },
      -- },
      basedpyright = {
        settings = {
          basedpyright = {
            disableOrganizeImports = true, -- Using Ruff
          },
          -- python = {
          --   analysis = {
          --     -- Ignore all files for analysis to exclusively use Ruff for linting
          --     ignore = { '*' },
          --   },
          -- },
        },
      },

      harper_ls = {
        settings = {
          ["harper-ls"] = {
            userDictPath = "~/.config/harper-ls/user-dictionary.txt",
            linters = {
              ToDoHyphen = false,
              SentenceCapitalization = false,
            },
            markdown = {
              IgnoreLinkTitle = true,
            },
          },
        },
      },

      -- add opts here
    })
  end,
}
