-- The creator of the community plugin 'copilot-cmp' moved their configuration
-- to a private repo and is using this setup, I just copied it from there:
-- https://github.com/corintho/dotfiles/blob/ba725d8709d9c9f5db193ac5a52f3075aac0fc56/files/nvim/lua/plugins/blink-cmp-copilot.lua
---@type LazySpec
return {
	{
		"giuxtaposition/blink-cmp-copilot",
		dependencies = {
			{
				"zbirenbaum/copilot.lua",
				opts = {
					suggestion = { enabled = false },
					panel = { enabled = false },
				},
			},
			{
				"saghen/blink.cmp",
				opts = {
					sources = {
						default = { "copilot" },
						providers = {
							copilot = {
								name = "copilot",
								module = "blink-cmp-copilot",
								score_offset = 100,
								async = true,
								transform_items = function(_, items)
									local CompletionItemKind = require("blink.cmp.types").CompletionItemKind
									local kind_idx = #CompletionItemKind + 1
									CompletionItemKind[kind_idx] = "Copilot"
									for _, item in ipairs(items) do
										item.kind = kind_idx
									end
									return items
								end,
							},
						},
					},
					appearance = {
						-- Blink does not expose its default kind icons so you must copy them all (or set your custom ones) and add Copilot
						kind_icons = {
							Copilot = "",
							Text = "󰉿",
							Method = "󰊕",
							Function = "󰊕",
							Constructor = "󰒓",

							Field = "󰜢",
							Variable = "󰆦",
							Property = "󰖷",

							Class = "󱡠",
							Interface = "󱡠",
							Struct = "󱡠",
							Module = "󰅩",

							Unit = "󰪚",
							Value = "󰦨",
							Enum = "󰦨",
							EnumMember = "󰦨",

							Keyword = "󰻾",
							Constant = "󰏿",

							Snippet = "󱄽",
							Color = "󰏘",
							File = "󰈔",
							Reference = "󰬲",
							Folder = "󰉋",
							Event = "󱐋",
							Operator = "󰪚",
							TypeParameter = "󰬛",
						},
					},
				},
			},
		},
	},
}
