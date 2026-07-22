local state_file = vim.fn.expand("~/.cache/hypr-theme-switcher/nvim-theme.lua")

local fallback = {
  id = "default",
  name = "Default",
  mode = "dark",
  bg = "#1e1e2e",
  fg = "#cdd6f4",
  cursor = "#f5e0dc",
  selection_bg = "#cdd6f4",
  selection_fg = "#1e1e2e",
  surface = "#3b4252",
  surface_alt = "#4c566a",
  muted = "#787c99",
  accent = "#7aa2f7",
  accent_alt = "#41a6b5",
  warn = "#e0af68",
  red = "#f7768e",
  green = "#a3be8c",
  yellow = "#e0af68",
  blue = "#7aa2f7",
  magenta = "#b48ead",
  cyan = "#88c0d0",
  white = "#e5e9f0",
  ansi = {
    "#3b4252", "#bf616a", "#a3be8c", "#ebcb8b",
    "#81a1c1", "#b48ead", "#88c0d0", "#e5e9f0",
    "#4c566a", "#bf616a", "#a3be8c", "#ebcb8b",
    "#81a1c1", "#b48ead", "#89bcbb", "#eceff4",
  },
}

local ok, palette = pcall(dofile, state_file)
if not ok or type(palette) ~= "table" then
  palette = fallback
end

vim.cmd("highlight clear")
if vim.fn.exists("syntax_on") == 1 then
  vim.cmd("syntax reset")
end

vim.o.termguicolors = true
vim.o.background = palette.mode == "light" and "light" or "dark"
vim.g.colors_name = "hypr-sync"

for index, color in ipairs(palette.ansi or fallback.ansi) do
  vim.g["terminal_color_" .. (index - 1)] = color
end

local set = vim.api.nvim_set_hl
local function link(name, target)
  set(0, name, { link = target })
end

set(0, "Normal", { fg = palette.fg, bg = palette.bg })
set(0, "NormalNC", { fg = palette.fg, bg = palette.bg })
set(0, "NormalFloat", { fg = palette.fg, bg = palette.surface })
set(0, "FloatBorder", { fg = palette.accent, bg = palette.surface })
set(0, "FloatTitle", { fg = palette.accent, bg = palette.surface, bold = true })
set(0, "Cursor", { fg = palette.bg, bg = palette.cursor })
set(0, "CursorLine", { bg = palette.surface })
set(0, "CursorColumn", { bg = palette.surface })
set(0, "ColorColumn", { bg = palette.surface })
set(0, "Visual", { fg = palette.selection_fg, bg = palette.selection_bg })
set(0, "VisualNOS", { fg = palette.selection_fg, bg = palette.selection_bg })
set(0, "LineNr", { fg = palette.muted })
set(0, "CursorLineNr", { fg = palette.accent, bold = true })
set(0, "SignColumn", { fg = palette.muted, bg = palette.bg })
set(0, "FoldColumn", { fg = palette.muted, bg = palette.bg })
set(0, "Folded", { fg = palette.muted, bg = palette.surface })
set(0, "WinSeparator", { fg = palette.surface_alt })
set(0, "NonText", { fg = palette.surface_alt })
set(0, "Whitespace", { fg = palette.surface_alt })
set(0, "EndOfBuffer", { fg = palette.bg })
set(0, "StatusLine", { fg = palette.fg, bg = palette.surface, bold = true })
set(0, "StatusLineNC", { fg = palette.muted, bg = palette.surface })
set(0, "TabLine", { fg = palette.muted, bg = palette.surface })
set(0, "TabLineSel", { fg = palette.selection_fg, bg = palette.accent, bold = true })
set(0, "TabLineFill", { bg = palette.surface })
set(0, "WinBar", { fg = palette.fg, bg = palette.bg })
set(0, "WinBarNC", { fg = palette.muted, bg = palette.bg })
set(0, "Pmenu", { fg = palette.fg, bg = palette.surface })
set(0, "PmenuSel", { fg = palette.selection_fg, bg = palette.accent, bold = true })
set(0, "PmenuSbar", { bg = palette.surface_alt })
set(0, "PmenuThumb", { bg = palette.accent_alt })
set(0, "Search", { fg = palette.bg, bg = palette.yellow })
set(0, "IncSearch", { fg = palette.selection_fg, bg = palette.accent })
set(0, "CurSearch", { fg = palette.selection_fg, bg = palette.accent })
set(0, "Substitute", { fg = palette.selection_fg, bg = palette.magenta })
set(0, "MatchParen", { fg = palette.accent, bold = true, underline = true })
set(0, "Directory", { fg = palette.blue, bold = true })
set(0, "Title", { fg = palette.accent, bold = true })
set(0, "Question", { fg = palette.green })
set(0, "MoreMsg", { fg = palette.green })
set(0, "ModeMsg", { fg = palette.accent, bold = true })
set(0, "WarningMsg", { fg = palette.yellow, bold = true })
set(0, "ErrorMsg", { fg = palette.red, bold = true })

set(0, "Comment", { fg = palette.muted, italic = true })
set(0, "Constant", { fg = palette.magenta })
set(0, "String", { fg = palette.green })
set(0, "Character", { fg = palette.green })
set(0, "Number", { fg = palette.yellow })
set(0, "Boolean", { fg = palette.yellow, bold = true })
set(0, "Float", { fg = palette.yellow })
set(0, "Identifier", { fg = palette.fg })
set(0, "Function", { fg = palette.blue })
set(0, "Statement", { fg = palette.magenta, bold = true })
set(0, "Conditional", { fg = palette.magenta })
set(0, "Repeat", { fg = palette.magenta })
set(0, "Label", { fg = palette.accent })
set(0, "Operator", { fg = palette.accent })
set(0, "Keyword", { fg = palette.magenta, italic = true })
set(0, "Exception", { fg = palette.red })
set(0, "PreProc", { fg = palette.cyan })
set(0, "Include", { fg = palette.cyan })
set(0, "Define", { fg = palette.cyan })
set(0, "Macro", { fg = palette.cyan })
set(0, "Type", { fg = palette.yellow })
set(0, "StorageClass", { fg = palette.yellow })
set(0, "Structure", { fg = palette.yellow })
set(0, "Typedef", { fg = palette.yellow })
set(0, "Special", { fg = palette.accent_alt })
set(0, "SpecialChar", { fg = palette.accent_alt })
set(0, "Tag", { fg = palette.accent })
set(0, "Delimiter", { fg = palette.muted })
set(0, "Underlined", { fg = palette.blue, underline = true })
set(0, "Todo", { fg = palette.bg, bg = palette.yellow, bold = true })

set(0, "DiagnosticError", { fg = palette.red })
set(0, "DiagnosticWarn", { fg = palette.yellow })
set(0, "DiagnosticInfo", { fg = palette.blue })
set(0, "DiagnosticHint", { fg = palette.cyan })
set(0, "DiagnosticOk", { fg = palette.green })
set(0, "DiagnosticUnderlineError", { undercurl = true, sp = palette.red })
set(0, "DiagnosticUnderlineWarn", { undercurl = true, sp = palette.yellow })
set(0, "DiagnosticUnderlineInfo", { undercurl = true, sp = palette.blue })
set(0, "DiagnosticUnderlineHint", { undercurl = true, sp = palette.cyan })

set(0, "DiffAdd", { fg = palette.green })
set(0, "DiffChange", { fg = palette.yellow })
set(0, "DiffDelete", { fg = palette.red })
set(0, "DiffText", { fg = palette.blue, bold = true })
set(0, "GitSignsAdd", { fg = palette.green })
set(0, "GitSignsChange", { fg = palette.yellow })
set(0, "GitSignsDelete", { fg = palette.red })

link("@comment", "Comment")
link("@constant", "Constant")
link("@constant.builtin", "Special")
link("@string", "String")
link("@string.escape", "SpecialChar")
link("@number", "Number")
link("@boolean", "Boolean")
link("@variable", "Identifier")
link("@variable.builtin", "Special")
link("@function", "Function")
link("@function.builtin", "Special")
link("@function.call", "Function")
link("@keyword", "Keyword")
link("@keyword.return", "Keyword")
link("@keyword.operator", "Operator")
link("@operator", "Operator")
link("@type", "Type")
link("@type.builtin", "Special")
link("@property", "Identifier")
link("@punctuation", "Delimiter")
link("@tag", "Tag")
link("@tag.attribute", "Identifier")
link("@markup.heading", "Title")
link("@markup.link", "Underlined")
link("@markup.raw", "String")
link("@lsp.type.comment", "Comment")
link("@lsp.type.function", "Function")
link("@lsp.type.method", "Function")
link("@lsp.type.keyword", "Keyword")
link("@lsp.type.type", "Type")
link("@lsp.type.variable", "Identifier")

set(0, "SnacksDashboardHeader", { fg = palette.accent, bold = true })
set(0, "SnacksDashboardIcon", { fg = palette.accent_alt })
set(0, "SnacksDashboardKey", { fg = palette.magenta, bold = true })
set(0, "SnacksDashboardDesc", { fg = palette.fg })
set(0, "SnacksDashboardFooter", { fg = palette.muted, italic = true })
set(0, "TelescopeBorder", { fg = palette.accent, bg = palette.surface })
set(0, "TelescopeTitle", { fg = palette.selection_fg, bg = palette.accent, bold = true })
set(0, "TelescopeSelection", { fg = palette.selection_fg, bg = palette.selection_bg, bold = true })
set(0, "NeoTreeNormal", { fg = palette.fg, bg = palette.bg })
set(0, "NeoTreeNormalNC", { fg = palette.fg, bg = palette.bg })
set(0, "NeoTreeDirectoryIcon", { fg = palette.blue })
set(0, "NeoTreeDirectoryName", { fg = palette.blue })
