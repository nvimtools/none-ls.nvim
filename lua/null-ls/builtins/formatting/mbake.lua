local h = require("null-ls.helpers")
local methods = require("null-ls.methods")

local FORMATTING = methods.internal.FORMATTING

return h.make_builtin({
	name = "mbake",
	meta = {
		url = "https://github.com/EbodShojaei/bake",
		description = [[Format your Makefile]],
	},
	method = FORMATTING,
	filetypes = { "make" },
	generator_opts = {
		command = "mbake",
		args = {
			"format",
			"$FILENAME",
		},
		to_stdin = false,
		to_temp_file = true,
		from_temp_file = true,
	},
	factory = h.formatter_factory,
})
