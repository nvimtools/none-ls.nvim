-- THIS FILE IS GENERATED. DO NOT EDIT MANUALLY.
-- stylua: ignore
return {
  Jenkinsfile = {
    diagnostics = { "npm_groovy_lint" },
    formatting = { "npm_groovy_lint" }
  },
  arduino = {
    formatting = { "astyle" }
  },
  asciidoc = {
    diagnostics = { "vale" }
  },
  asm = {
    formatting = { "asmfmt" }
  },
  astro = {
    formatting = { "prettier", "prettierd" }
  },
  beancount = {
    diagnostics = { "bean_check" },
    formatting = { "bean_format" }
  },
  bib = {
    formatting = { "bibclean" }
  },
  blade = {
    formatting = { "blade_formatter" }
  },
  brs = {
    diagnostics = { "bslint" },
    formatting = { "bsfmt" }
  },
  bzl = {
    diagnostics = { "buildifier" },
    formatting = { "buildifier" }
  },
  c = {
    diagnostics = { "cppcheck", "gccdiag" },
    formatting = { "astyle", "clang_format", "uncrustify" }
  },
  clj = {
    formatting = { "joker" }
  },
  clojure = {
    diagnostics = { "clj_kondo" },
    formatting = { "cljstyle", "zprint" }
  },
  cmake = {
    diagnostics = { "cmake_lint" },
    formatting = { "cmake_format", "gersemi" }
  },
  cpp = {
    diagnostics = { "clazy", "cppcheck", "gccdiag" },
    formatting = { "astyle", "clang_format", "uncrustify" }
  },
  crystal = {
    formatting = { "crystal_format" }
  },
  cs = {
    formatting = { "astyle", "clang_format", "csharpier", "uncrustify" }
  },
  css = {
    diagnostics = { "stylelint" },
    formatting = { "prettier", "prettierd", "stylelint" }
  },
  cuda = {
    formatting = { "clang_format" }
  },
  cue = {
    diagnostics = { "cue_fmt" },
    formatting = { "cue_fmt", "cueimports" }
  },
  d = {
    formatting = { "dfmt" }
  },
  d2 = {
    formatting = { "d2_fmt" }
  },
  dart = {
    formatting = { "dart_format" }
  },
  delphi = {
    formatting = { "ptop" }
  },
  django = {
    diagnostics = { "djlint" },
    formatting = { "djhtml", "djlint" }
  },
  dockerfile = {
    diagnostics = { "hadolint" }
  },
  dosbatch = {
    hover = { "printenv" }
  },
  elixir = {
    diagnostics = { "credo" },
    formatting = { "mix", "surface" }
  },
  elm = {
    formatting = { "elm_format" }
  },
  epuppet = {
    diagnostics = { "puppet_lint" },
    formatting = { "puppet_lint" }
  },
  erlang = {
    formatting = { "erlfmt" }
  },
  eruby = {
    diagnostics = { "erb_lint" },
    formatting = { "erb_format", "erb_lint", "htmlbeautifier" }
  },
  fennel = {
    formatting = { "fnlfmt" }
  },
  fish = {
    diagnostics = { "fish" },
    formatting = { "fish_indent" }
  },
  fnl = {
    formatting = { "fnlfmt" }
  },
  fortran = {
    formatting = { "findent", "fprettify" }
  },
  fsharp = {
    formatting = { "fantomas" }
  },
  gd = {
    formatting = { "gdformat" }
  },
  gdscript = {
    diagnostics = { "gdlint" },
    formatting = { "gdformat" }
  },
  gdscript3 = {
    formatting = { "gdformat" }
  },
  gitcommit = {
    diagnostics = { "commitlint", "gitlint" }
  },
  gitrebase = {
    code_actions = { "gitrebase" }
  },
  gleam = {
    formatting = { "gleam_format" }
  },
  glsl = {
    diagnostics = { "glslc" }
  },
  gn = {
    formatting = { "gn_format" }
  },
  go = {
    code_actions = { "gomodifytags", "impl", "refactoring" },
    diagnostics = { "golangci_lint", "revive", "semgrep", "staticcheck" },
    formatting = { "gofmt", "gofumpt", "goimports", "goimports_reviser", "golines" }
  },
  graphql = {
    formatting = { "prettier", "prettierd" }
  },
  groovy = {
    diagnostics = { "npm_groovy_lint" },
    formatting = { "npm_groovy_lint" }
  },
  haml = {
    diagnostics = { "haml_lint" }
  },
  handlebars = {
    formatting = { "prettier", "prettierd" }
  },
  haxe = {
    formatting = { "haxe_formatter" }
  },
  hcl = {
    formatting = { "hclfmt", "packer" }
  },
  html = {
    diagnostics = { "markuplint", "tidy" },
    formatting = { "prettier", "prettierd", "rustywind", "tidy" }
  },
  htmldjango = {
    diagnostics = { "djlint" },
    formatting = { "djhtml", "djlint" }
  },
  java = {
    diagnostics = { "checkstyle", "npm_groovy_lint", "pmd", "semgrep" },
    formatting = { "astyle", "clang_format", "google_java_format", "npm_groovy_lint", "uncrustify" }
  },
  javascript = {
    code_actions = { "refactoring" },
    formatting = { "biome", "prettier", "prettierd", "rustywind" }
  },
  javascriptreact = {
    formatting = { "biome", "prettier", "prettierd", "rustywind" }
  },
  jinja = {
    formatting = { "sqlfmt" }
  },
  ["jinja.html"] = {
    diagnostics = { "djlint" },
    formatting = { "djhtml", "djlint" }
  },
  json = {
    diagnostics = { "cfn_lint", "spectral", "vacuum" },
    formatting = { "biome", "prettier", "prettierd" }
  },
  jsonc = {
    formatting = { "biome", "prettier", "prettierd" }
  },
  jsp = {
    diagnostics = { "pmd" }
  },
  just = {
    formatting = { "just" }
  },
  kotlin = {
    diagnostics = { "ktlint" },
    formatting = { "ktlint" }
  },
  less = {
    diagnostics = { "stylelint" },
    formatting = { "prettier", "prettierd", "stylelint" }
  },
  lua = {
    code_actions = { "refactoring" },
    diagnostics = { "selene" },
    formatting = { "stylua" }
  },
  luau = {
    diagnostics = { "selene" },
    formatting = { "stylua" }
  },
  make = {
    diagnostics = { "checkmake" }
  },
  markdown = {
    code_actions = { "proselint" },
    diagnostics = { "alex", "ltrs", "ltrs", "markdownlint", "markdownlint_cli2", "mdl", "proselint", "textidote", "textlint", "vale", "write_good" },
    formatting = { "cbfmt", "markdownlint", "mdformat", "ocdc", "prettier", "prettierd", "remark", "textlint" },
    hover = { "dictionary" }
  },
  ["markdown.mdx"] = {
    formatting = { "prettier", "prettierd" }
  },
  matlab = {
    diagnostics = { "mlint" }
  },
  ncl = {
    formatting = { "topiary" }
  },
  nginx = {
    formatting = { "nginx_beautifier" }
  },
  nickel = {
    formatting = { "topiary" }
  },
  nim = {
    formatting = { "nimpretty" }
  },
  nix = {
    code_actions = { "statix" },
    diagnostics = { "deadnix", "statix" },
    formatting = { "alejandra", "nixfmt", "nixpkgs_fmt" }
  },
  ocaml = {
    formatting = { "ocamlformat" }
  },
  octave = {
    diagnostics = { "mlint" }
  },
  org = {
    formatting = { "cbfmt" },
    hover = { "dictionary" }
  },
  pascal = {
    formatting = { "ptop" }
  },
  perl = {
    diagnostics = { "perlimports" }
  },
  pgsql = {
    formatting = { "pg_format" }
  },
  php = {
    diagnostics = { "phpcs", "phpmd", "phpstan" },
    formatting = { "phpcbf", "phpcsfixer", "pint", "pretty_php" }
  },
  prisma = {
    formatting = { "prisma_format" }
  },
  proto = {
    diagnostics = { "buf", "protolint" },
    formatting = { "buf", "clang_format", "protolint" }
  },
  ps1 = {
    hover = { "printenv" }
  },
  puppet = {
    diagnostics = { "puppet_lint" },
    formatting = { "puppet_lint" }
  },
  purescript = {
    formatting = { "purs_tidy" }
  },
  python = {
    code_actions = { "refactoring" },
    diagnostics = { "mypy", "pylint", "semgrep" },
    formatting = { "black", "blackd", "isort", "isortd", "pyink", "usort", "yapf" }
  },
  qml = {
    diagnostics = { "qmllint" },
    formatting = { "qmlformat" }
  },
  r = {
    formatting = { "format_r", "styler" }
  },
  racket = {
    formatting = { "racket_fixw", "raco_fmt" }
  },
  rego = {
    diagnostics = { "opacheck", "regal" },
    formatting = { "rego" }
  },
  rescript = {
    formatting = { "rescript" }
  },
  rmd = {
    formatting = { "format_r", "styler" }
  },
  rst = {
    diagnostics = { "rstcheck" }
  },
  ruby = {
    diagnostics = { "reek", "rubocop", "semgrep" },
    formatting = { "rubocop", "rubyfmt", "rufo" }
  },
  rust = {
    formatting = { "dxfmt", "leptosfmt" }
  },
  sass = {
    diagnostics = { "stylelint" },
    formatting = { "stylelint" }
  },
  scala = {
    formatting = { "scalafmt" }
  },
  scheme = {
    formatting = { "emacs_scheme_mode" }
  },
  ["scheme.guile"] = {
    formatting = { "emacs_scheme_mode" }
  },
  scss = {
    diagnostics = { "stylelint" },
    formatting = { "prettier", "prettierd", "stylelint" }
  },
  sh = {
    diagnostics = { "dotenv_linter" },
    formatting = { "shellharden", "shfmt" },
    hover = { "printenv" }
  },
  sls = {
    diagnostics = { "saltlint" }
  },
  sml = {
    formatting = { "smlfmt" }
  },
  solidity = {
    diagnostics = { "solhint" },
    formatting = { "forge_fmt" }
  },
  spec = {
    diagnostics = { "rpmspec" }
  },
  sql = {
    diagnostics = { "sqlfluff" },
    formatting = { "pg_format", "sql_formatter", "sqlfluff", "sqlfmt", "sqlformat" }
  },
  stylus = {
    diagnostics = { "stylint" }
  },
  surface = {
    formatting = { "surface" }
  },
  svelte = {
    formatting = { "prettier", "prettierd", "rustywind" }
  },
  swift = {
    diagnostics = { "swiftlint" },
    formatting = { "swift_format", "swiftformat", "swiftlint" }
  },
  systemverilog = {
    diagnostics = { "verilator" },
    formatting = { "verible_verilog_format" }
  },
  teal = {
    diagnostics = { "teal" }
  },
  terraform = {
    diagnostics = { "terraform_validate", "tfsec", "trivy" },
    formatting = { "opentofu_fmt", "terraform_fmt" }
  },
  ["terraform-vars"] = {
    diagnostics = { "terraform_validate", "tfsec", "trivy" },
    formatting = { "opentofu_fmt", "terraform_fmt" }
  },
  tex = {
    code_actions = { "proselint" },
    diagnostics = { "proselint", "textidote", "vale" }
  },
  text = {
    diagnostics = { "ltrs" },
    hover = { "dictionary" }
  },
  tf = {
    diagnostics = { "terraform_validate", "tfsec", "trivy" },
    formatting = { "opentofu_fmt", "terraform_fmt" }
  },
  twig = {
    diagnostics = { "twigcs" }
  },
  txt = {
    diagnostics = { "textlint" },
    formatting = { "textlint" }
  },
  typ = {
    formatting = { "typstfmt", "typstyle" }
  },
  typescript = {
    code_actions = { "refactoring" },
    diagnostics = { "semgrep" },
    formatting = { "biome", "prettier", "prettierd", "rustywind" }
  },
  typescriptreact = {
    diagnostics = { "semgrep" },
    formatting = { "biome", "prettier", "prettierd", "rustywind" }
  },
  typst = {
    formatting = { "typstfmt", "typstyle" }
  },
  verilog = {
    diagnostics = { "verilator" },
    formatting = { "verible_verilog_format" }
  },
  vhdl = {
    formatting = { "emacs_vhdl_mode" }
  },
  vim = {
    diagnostics = { "vint" }
  },
  vue = {
    formatting = { "prettier", "prettierd", "rustywind" }
  },
  xml = {
    diagnostics = { "tidy" },
    formatting = { "tidy", "xmllint" }
  },
  yaml = {
    diagnostics = { "actionlint", "cfn_lint", "spectral", "vacuum", "yamllint" },
    formatting = { "prettier", "prettierd", "yamlfix", "yamlfmt" }
  },
  ["yaml.ansible"] = {
    diagnostics = { "ansiblelint" }
  },
  zsh = {
    diagnostics = { "zsh" }
  }
}
