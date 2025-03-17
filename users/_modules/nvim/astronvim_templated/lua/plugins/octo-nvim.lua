---@type LazySpec
return {
	{
		-- https://github.com/pwntester/octo.nvim
		"octo.nvim",
		opts = {
			ssh_aliases = { ["<githubAlias>"] = "github.com" },
		},
	},
}
