local Path = require("plenary.path")
local uv = vim.loop

local M = {}

local CSPELL_CONFIG_FILES = {
    "cspell.json",
    ".cspell.json",
    "cSpell.json",
    ".cspell.json",
    ".cspell.config.json",
}

---@type table<string, CSpellConfigInfo|nil>
local CONFIG_INFO_BY_CWD = {}
local PATH_BY_CWD = {}

--- create a bare minimum cspell.json file
---@param params GeneratorParams
---@return CSpellConfigInfo
M.create_cspell_json = function(params)
    ---@type CSpellSourceConfig
    local code_action_config = params:get_config()
    local config_file_preferred_name = code_action_config.config_file_preferred_name or "cspell.json"
    local encode_json = code_action_config.encode_json or vim.json.encode

    if not vim.tbl_contains(CSPELL_CONFIG_FILES, config_file_preferred_name) then
        vim.notify(
            "Invalid config_file_preferred_name for cspell json file: "
                .. config_file_preferred_name
                .. '. The name "cspell.json" will be used instead',
            vim.log.levels.WARN
        )
        config_file_preferred_name = "cspell.json"
    end

    local cspell_json = {
        version = "0.2",
        language = "en",
        words = {},
        flagWords = {},
    }

    local cspell_json_str = encode_json(cspell_json)
    local cspell_json_file_path = require("null-ls.utils").path.join(params.cwd, config_file_preferred_name)

    Path:new(cspell_json_file_path):write(cspell_json_str, "w")
    vim.notify("Created a new cspell.json file at " .. cspell_json_file_path, vim.log.levels.INFO)

    local info = {
        config = cspell_json,
        path = cspell_json_file_path,
    }

    CONFIG_INFO_BY_CWD[params.cwd] = info

    return info
end

---@param filename string
---@param cwd string
---@return string|nil
local function find_file(filename, cwd)
    ---@type string|nil
    local current_dir = cwd
    local root_dir = "/"

    repeat
        local file_path = current_dir .. "/" .. filename
        local stat = uv.fs_stat(file_path)
        if stat and stat.type == "file" then
            return file_path
        end

        current_dir = uv.fs_realpath(current_dir .. "/..")
    until current_dir == root_dir

    return nil
end

--- Find the first cspell.json file in the directory tree
---@param cwd string
---@return string|nil
local find_cspell_config_path = function(cwd)
    for _, file in ipairs(CSPELL_CONFIG_FILES) do
        local path = find_file(file, cwd or vim.loop.cwd())
        if path then
            return path
        end
    end
    return nil
end

---@class GeneratorParams
---@field bufnr number
---@field bufname string
---@field ft string
---@field row number
---@field col number
---@field cwd string
---@field get_config function

---@param params GeneratorParams
---@return CSpellConfigInfo|nil
M.get_cspell_config = function(params)
    ---@type CSpellSourceConfig
    local code_action_config = params:get_config()
    local decode_json = code_action_config.decode_json or vim.json.decode

    local cspell_json_path = M.get_config_path(params)

    if cspell_json_path == nil or cspell_json_path == "" then
        return
    end

    local content = Path:new(cspell_json_path):read()
    local ok, cspell_config = pcall(decode_json, content)

    if not ok then
        vim.notify("\nCannot parse cspell json file as JSON.\n", vim.log.levels.ERROR)
        return
    end

    return {
        config = cspell_config,
        path = cspell_json_path,
    }
end

--- Non-blocking config parser
--- The first run is meant to be a cache warm up
---@param params GeneratorParams
---@return CSpellConfigInfo|nil
M.async_get_config_info = function(params)
    ---@type uv_async_t|nil
    local async
    async = vim.loop.new_async(function()
        if CONFIG_INFO_BY_CWD[params.cwd] == nil then
            local config = M.get_cspell_config(params)
            CONFIG_INFO_BY_CWD[params.cwd] = config
        end
        async:close()
    end)

    async:send()

    return CONFIG_INFO_BY_CWD[params.cwd]
end

M.get_config_path = function(params)
    if PATH_BY_CWD[params.cwd] == nil then
        local code_action_config = params:get_config()
        local find_json = code_action_config.find_json or find_cspell_config_path
        local cspell_json_path = find_json(params.cwd)
        PATH_BY_CWD[params.cwd] = cspell_json_path
    end
    return PATH_BY_CWD[params.cwd]
end

--- Checks that both sources use the same config
--- We need to do that so we can start reading and parsing the cspell
--- configuration asynchronously as soon as we get the first diagnostic.
---@param code_actions_config CSpellSourceConfig
---@param diagnostics_config CSpellSourceConfig
M.matching_configs = function(code_actions_config, diagnostics_config)
    return (vim.tbl_isempty(code_actions_config) and vim.tbl_isempty(diagnostics_config))
        or code_actions_config == diagnostics_config
end

--- Get the word associated with the diagnostic
---@param diagnostic Diagnostic
---@return string
M.get_word = function(diagnostic)
    return vim.api.nvim_buf_get_text(
        diagnostic.bufnr,
        diagnostic.lnum,
        diagnostic.col,
        diagnostic.end_lnum,
        diagnostic.end_col,
        {}
    )[1]
end

--- Replace the diagnostic's word with a new word
---@param diagnostic Diagnostic
---@param new_word string
M.set_word = function(diagnostic, new_word)
    vim.api.nvim_buf_set_text(
        diagnostic.bufnr,
        diagnostic.lnum,
        diagnostic.col,
        diagnostic.end_lnum,
        diagnostic.end_col,
        { new_word }
    )
end

M.clear_cache = function()
    PATH_BY_CWD = {}
    CONFIG_INFO_BY_CWD = {}
end

return M

---@class Diagnostic
---@field bufnr number Buffer number
---@field lnum number The starting line of the diagnostic
---@field end_lnum number The final line of the diagnostic
---@field col number The starting column of the diagnostic
---@field end_col number The final column of the diagnostic
---@field severity number The severity of the diagnostic
---@field message string The diagnostic text
---@field source string The source of the diagnostic
---@field code number The diagnostic code
---@field user_data UserData

---@class CodeAction
---@field title string
---@field action function

---@class UserData
---@field suggestions table<number, string> Suggested words for the diagnostic

---@class CSpellConfigInfo
---@field config CSpellConfig
---@field path string

---@class CSpellConfig
---@field flagWords table<number, string>
---@field language string
---@field version string
---@field words table<number, string>
---@field dictionaryDefinitions table<number, CSpellDictionary>|nil

---@class CSpellDictionary
---@field name string
---@field path string
---@field addWords boolean|nil

---@class CSpellSourceConfig
---@field config_file_preferred_name string|nil
---@field find_json function|nil
---@field decode_json function|nil
---@field encode_json function|nil
---@field on_success function|nil
