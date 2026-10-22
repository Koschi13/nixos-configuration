---@type LazySpec
return {
  {
    "EthanJWright/vs-tasks.nvim",
    name = "vs-tasks.nvim",
    dependencies = {
      "nvim-lua/popup.nvim",
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
      { "AstroNvim/astroui", opts = { icons = { VSTask = "" } } },
      {
        "AstroNvim/astrocore",
        opts = function(_, opts)
          local maps = opts.mappings
          local prefix = "<Leader>R"
          maps.n[prefix] = { desc = require("astroui").get_icon("VSTask", 1, true) .. "VSTask" }
          maps.n[prefix .. "a"] =
            { function() require("telescope").extensions.vstask.tasks() end, desc = "Show all tasks" }
          maps.n[prefix .. "i"] =
            { function() require("telescope").extensions.vstask.inputs() end, desc = "Show all inputs" }
          maps.n[prefix .. "j"] =
            { function() require("telescope").extensions.vstask.jobs() end, desc = "Show all jobs" }
          maps.n[prefix .. "h"] =
            { function() require("telescope").extensions.vstask.jobs() end, desc = "Show history" }
          maps.n[prefix .. "l"] = {
            function() require("telescope").extensions.vstask.launch() end,
            desc = "Show all launch configurations",
          }
          maps.n[prefix .. "r"] = {
            function() require("telescope").extensions.vstask.command() end,
            desc = "Run any command",
          }
          maps.n[prefix .. "d"] = {
            function() require("telescope").extensions.vstask.clear_inputs() end,
            desc = "Clear all configured inputs for the current session",
          }
          maps.n[prefix .. "c"] = {
            function() require("telescope").extensions.vstask.cleanup_completed_jobs() end,
            desc = "Remove all completed jobs from the list",
          }
        end,
      },
    },
    opts = {
      terminal = "toggleterm",
      default_tasks = {},
    },
    config = function(_, _)
      --require "astronvim.plugins.configs.vstasks"(plugin, opts)
      require("telescope").load_extension "vstask"
    end,
  },
}
