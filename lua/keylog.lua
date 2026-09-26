-- Keystroke logger for reviewing editing habits.
--   :KeylogStart   start logging; stays on in new nvim sessions until :KeylogStop
--   :KeylogStop    stop logging (other open nvim instances stop when they exit)
--   :KeylogStatus  show whether logging is on and where logs go
--
-- One TSV file per nvim session in stdpath("state")/keylog/, with a header row:
--   ms  mode  ft  buf  line  col  top  bot  keys  snippet
-- line/col is the cursor (1-based, col in bytes) just before the key is handled,
-- so the next row's position is where that key took you. top/bot is the range
-- of lines visible in the window.
--
-- Printable characters typed in insert/replace mode are logged as <char>, and
-- terminal-mode keys are skipped. With setup({ snippets = true }), the text of
-- the cursor line (first 200 bytes) is also logged whenever you land on a new
-- line or the line has changed, outside insert/cmdline mode, in file buffers
-- only. That puts pieces of your code in the logs.

local M = {}

local dir = vim.fn.stdpath("state") .. "/keylog"
local flag = dir .. "/ENABLED"
local ns = vim.api.nvim_create_namespace("keylog")
local header = "ms\tmode\tft\tbuf\tline\tcol\ttop\tbot\tkeys\tsnippet"

local opts = { snippets = false }
local path, start, buf = nil, 0, {}
local last_buf, last_line, last_tick

local ignored = {
  ["<Ignore>"] = true,
  ["<FocusGained>"] = true,
  ["<FocusLost>"] = true,
  ["<CursorHold>"] = true,
  ["<MouseMove>"] = true,
}

local function flush()
  if not path or #buf == 0 then
    return
  end
  local f = io.open(path, "a")
  if f then
    f:write(table.concat(buf, "\n"), "\n")
    f:close()
  end
  buf = {}
end

local function is_printable(typed)
  local b = typed:byte(1)
  return vim.fn.strchars(typed) == 1 and b >= 32 and b ~= 127 and b ~= 0x80
end

-- Text of the cursor line, only when it differs from the last snippet logged
local function snippet(bufnr, line)
  if vim.bo[bufnr].buftype ~= "" then
    return ""
  end
  local tick = vim.api.nvim_buf_get_changedtick(bufnr)
  if bufnr == last_buf and line == last_line and tick == last_tick then
    return ""
  end
  last_buf, last_line, last_tick = bufnr, line, tick
  local text = vim.api.nvim_buf_get_lines(bufnr, line - 1, line, false)[1] or ""
  -- one space per tab keeps byte columns lined up with col
  return (text:sub(1, 200):gsub("[\t\r]", " "))
end

local function on_key(key, typed)
  -- typed is empty for keys produced by mappings; we only want what you pressed
  if not typed or typed == "" then
    return
  end
  local mode = vim.api.nvim_get_mode().mode
  local m = mode:sub(1, 1)
  if m == "t" then
    return
  end
  local keys
  if (m == "i" or m == "R") and key == typed and is_printable(typed) then
    keys = "<char>"
  else
    keys = vim.fn.keytrans(typed)
    if ignored[keys] or keys:find("^<80>") then
      return
    end
  end
  mode = mode:gsub("%c", function(c)
    return "^" .. string.char(c:byte() + 64)
  end)
  local ft = vim.bo.filetype ~= "" and vim.bo.filetype or "-"
  local ms = math.floor((vim.uv.hrtime() - start) / 1e6)
  local bufnr = vim.api.nvim_get_current_buf()
  local pos = vim.api.nvim_win_get_cursor(0)
  local text = ""
  if opts.snippets and m ~= "i" and m ~= "R" and m ~= "c" then
    text = snippet(bufnr, pos[1])
  end
  buf[#buf + 1] = table.concat({
    ms,
    mode,
    ft,
    bufnr,
    pos[1],
    pos[2] + 1,
    vim.fn.line("w0"),
    vim.fn.line("w$"),
    keys,
    text,
  }, "\t")
  if #buf >= 200 then
    flush()
  end
end

function M.start()
  if path then
    return
  end
  vim.fn.mkdir(dir, "p")
  path = string.format("%s/%s-%d.tsv", dir, os.date("%Y%m%d-%H%M%S"), vim.fn.getpid())
  start = vim.uv.hrtime()
  buf = { header }
  last_buf, last_line, last_tick = nil, nil, nil
  vim.on_key(on_key, ns)
end

function M.stop()
  vim.on_key(nil, ns)
  flush()
  path = nil
end

function M.setup(o)
  -- on_key's typed argument and vim.uv need nvim 0.10
  if vim.fn.has("nvim-0.10") == 0 then
    vim.notify("keylog needs nvim 0.10+, not loading", vim.log.levels.WARN)
    return
  end
  opts = vim.tbl_extend("force", opts, o or {})
  vim.api.nvim_create_user_command("KeylogStart", function()
    vim.fn.mkdir(dir, "p")
    local f = io.open(flag, "w")
    if f then
      f:close()
    end
    M.start()
    vim.notify("Keylog on, writing to " .. dir)
  end, {})
  vim.api.nvim_create_user_command("KeylogStop", function()
    os.remove(flag)
    M.stop()
    vim.notify("Keylog off")
  end, {})
  vim.api.nvim_create_user_command("KeylogStatus", function()
    vim.notify(
      ("Keylog %s, snippets %s (%s)"):format(path and "on" or "off", opts.snippets and "on" or "off", dir)
    )
  end, {})
  vim.api.nvim_create_autocmd("VimLeavePre", { callback = flush })
  if vim.uv.fs_stat(flag) then
    M.start()
  end
end

return M
