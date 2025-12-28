local h = require("null-ls.helpers")
local methods = require("null-ls.methods")

local FORMATTING = methods.internal.FORMATTING

return h.make_builtin({
    name = "atlas_fmt",
    meta = {
        url = "https://atlasgo.io/cli-reference#atlas-schema-fmt",
        description = "atlas fmt command rewrites `atlas` config and schema files to a canonical format and style.",
    },
    method = FORMATTING,
    filetypes = {
        "hcl",
        "atlas-config",
        "atlas-schema-mysql",
        "atlas-schema-sqlite",
        "atlas-schema-mariadb",
        "atlas-schema-redshift",
        "atlas-schema-clickhouse",
        "atlas-schema-postgresql",
        "atlas-schema-mssql",
        "atlas-plan",
        "atlas-test",
    },
    generator_opts = {
        command = "atlas",
        to_temp_file = true,
        from_temp_file = true,
        args = {
            "schema",
            "fmt",
            "$FILENAME",
        },
    },
    factory = h.formatter_factory,
})
