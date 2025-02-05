local lang_utils = require("utils.lang")
local tbl_utils = require("utils.table")
local keymap_utils = require("utils.keymap")
local command_utils = require("utils.command")
local editor_utils = require("utils.editor")

local safe_require = lang_utils.safe_require

local jumplist = safe_require("jumplist")

---@module 'conform'
local conform = safe_require("conform")

---@module 'cmp'
local cmp = safe_require("cmp")

---@module 'git-conflict'
local git_conflict = safe_require("git-conflict")

---@param opts? {  }
local setup = function(opts)
  -- Pageup/down
  keymap_utils.create("n", "<PageUp>", "<C-u><C-u>")
  keymap_utils.create("n", "<PageDown>", "<C-d><C-d>")
  keymap_utils.create("v", "<PageUp>", "<C-u><C-u>")
  keymap_utils.create("v", "<PageDown>", "<C-d><C-d>")
  keymap_utils.create("i", "<PageUp>", "<C-o><C-u><C-o><C-u>") -- Execute <C-u> twice in normal mode
  keymap_utils.create("i", "<PageDown>", "<C-o><C-d><C-o><C-d>")

  -- Find and replace (local)
  -- TODO: better find and replace?
  keymap_utils.create("n", "rw", "*N:%s///g<left><left>") -- Select next occurrence of word under cursor then go back to current instance
  keymap_utils.create("n", "rr", ":%s//g<left><left>")
  keymap_utils.create("v", "rr", ":s//g<left><left>")
  keymap_utils.create("v", "r.", ":&gc<CR>") -- Reset flags & add flags
  keymap_utils.create("v", "ry", [["ry]]) -- Yank it into register "r" for later use with "rp"
  local function rp_rhs(whole_file) -- Use register "r" as the replacement rather than the subject
    return function()
      local content = vim.fn.getreg("r")
      local length = #content
      return (
        (whole_file and ":%s" or ":s")
        .. [[//<C-r>r/gc<left><left><left>]]
        .. ("<left>"):rep(length)
        .. "<left>"
      )
    end
  end
  keymap_utils.create("n", "rp", rp_rhs(true), { expr = true })
  keymap_utils.create("v", "rp", rp_rhs(false), { expr = true })
  keymap_utils.create("v", "ra", [["ry:%s/<C-r>r//gc<left><left><left>]]) -- Paste selection into register "y" and paste it into command line with <C-r>
  keymap_utils.create("v", "ri", [["rygv*N:s/<C-r>r//g<left><left>]]) -- "ra" but backward direction only. Because ":s///c" doesn't support backward direction, rely on user pressing "N" and "r."
  keymap_utils.create("v", "rk", [["ry:.,$s/<C-r>r//gc<left><left><left>]]) -- "ra" but forward direction only

  -- Diff / Git conflicts / Git signs
  keymap_utils.create("n", "sj", function()
    local diff_buffers = vim.t.diff_buffers ---@diagnostic disable-line: undefined-field
    if not diff_buffers then
      vim.cmd([[Gitsigns stage_hunk]])
      return
    end

    lang_utils.switch(vim.api.nvim_get_current_buf(), {
      [diff_buffers[2]] = function()
        vim.cmd(([[diffget %s]]):format(diff_buffers[1]))
      end,
      [diff_buffers[3]] = function()
        vim.cmd(([[diffput %s]]):format(diff_buffers[2]))
      end,
    })
  end)
  keymap_utils.create("n", "sl", function()
    local diff_buffers = vim.t.diff_buffers ---@diagnostic disable-line: undefined-field
    if not diff_buffers then
      vim.cmd([[Gitsigns undo_stage_hunk]])
      return
    end

    lang_utils.switch(vim.api.nvim_get_current_buf(), {
      [diff_buffers[2]] = function()
        vim.cmd(([[diffget %s]]):format(diff_buffers[3]))
      end,
      [diff_buffers[1]] = function()
        vim.cmd(([[diffput %s]]):format(diff_buffers[2]))
      end,
    })
  end)
  keymap_utils.create("n", "su", function()
    local has_conflicts = git_conflict.conflict_count() > 0
    if has_conflicts then
      vim.cmd([[GitConflictChooseOurs]])
    else
      vim.cmd([[Gitsigns preview_hunk_inline]])
    end
  end)
  keymap_utils.create("n", "si", function()
    local diff_buffers = vim.t.diff_buffers ---@diagnostic disable-line: undefined-field
    if not diff_buffers then
      local has_conflicts = git_conflict.conflict_count() > 0
      if has_conflicts then
        vim.cmd([[GitConflictPrevConflict]])
      else
        vim.cmd([[Gitsigns prev_hunk]])
      end
    else
      vim.cmd("normal! [c") -- Goto previous diff
    end
  end)
  keymap_utils.create("n", "sk", function()
    local diff_buffers = vim.t.diff_buffers ---@diagnostic disable-line: undefined-field
    if not diff_buffers then
      local has_conflicts = git_conflict.conflict_count() > 0
      if has_conflicts then
        vim.cmd([[GitConflictNextConflict]])
      else
        vim.cmd([[Gitsigns next_hunk]])
      end
    else
      vim.cmd("normal! ]c") -- Goto next diff
    end
  end)
  keymap_utils.create("n", "sb", "<cmd>Gitsigns blame_line<CR>")
  keymap_utils.create("n", "s;", "<cmd>Gitsigns reset_hunk<CR>")
  keymap_utils.create("n", "so", function()
    local has_conflicts = git_conflict.conflict_count() > 0
    if has_conflicts then vim.cmd([[GitConflictChooseTheirs]]) end
  end)
  keymap_utils.create("n", "sp", function()
    local has_conflicts = git_conflict.conflict_count() > 0
    if has_conflicts then vim.cmd([[GitConflictChooseBoth]]) end
  end)
  keymap_utils.create("n", "sy", function()
    local has_conflicts = git_conflict.conflict_count() > 0
    if has_conflicts then vim.cmd([[GitConflictChooseNone]]) end
  end)

  -- Move by word
  -- FIX: sometimes not moving by word
  keymap_utils.create("n", "<C-Left>", "b")
  keymap_utils.create("n", "<C-S-Left>", "B")
  keymap_utils.create("n", "<C-Right>", "w")
  keymap_utils.create("n", "<C-S-Right>", "W")

  -- Delete word
  -- FIX: sometimes not deleting whole word
  keymap_utils.create("i", "<C-BS>", "<C-W>")

  -- Move/swap line/selection up/down
  local auto_indent = false
  keymap_utils.create(
    "n",
    "<C-up>",
    "<cmd>m .-2<CR>" .. (auto_indent and "==" or "")
  )
  keymap_utils.create(
    "n",
    "<C-down>",
    "<cmd>m .+1<CR>" .. (auto_indent and "==" or "")
  )
  keymap_utils.create(
    "v",
    "<C-up>",
    ":m .-2<CR>gv" .. (auto_indent and "=gv" or "")
  )
  keymap_utils.create(
    "v",
    "<C-down>",
    ":m '>+1<CR>gv" .. (auto_indent and "=gv" or "")
  )

  -- Delete line
  keymap_utils.create("n", "<M-y>", "dd", { noremap = false })
  keymap_utils.create("i", "<M-y>", "<C-o><M-y>", { noremap = false })
  keymap_utils.create("v", "<M-y>", ":d<CR>")

  -- Duplicate line/selection
  keymap_utils.create("n", "<M-g>", "<cmd>t .<CR>")
  keymap_utils.create("i", "<M-g>", "<C-o><M-g>", { noremap = false })
  keymap_utils.create("v", "<M-g>", ":t '><CR>")

  -- Matching pair
  keymap_utils.create("n", "m", "%")
  keymap_utils.create("v", "m", "%")

  -- Macro
  local macro_keymaps = false
  if macro_keymaps then
    keymap_utils.create("n", ",", "@") -- replay macro x
    keymap_utils.create("n", "<", "Q") -- replay last macro
  end

  -- Clear search highlights
  keymap_utils.create("n", "<Space>/", "<cmd>noh<CR>")

  -- Redo
  keymap_utils.create("n", "U", "<C-R>")

  -- New line
  keymap_utils.create("n", "o", "o<Esc>")
  keymap_utils.create("n", "O", "O<Esc>")

  -- Fold
  keymap_utils.create("n", "zl", "zo")
  keymap_utils.create("n", "zj", "zc")
  keymap_utils.create("n", "zp", "za")

  -- Insert/append swap
  keymap_utils.create("n", "i", "a")
  keymap_utils.create("n", "a", "i")
  keymap_utils.create("n", "I", "A")
  keymap_utils.create("n", "A", "I")
  keymap_utils.create("v", "I", "A")
  keymap_utils.create("v", "A", "I")

  -- Home
  keymap_utils.create("n", "<Home>", "^")
  keymap_utils.create("v", "<Home>", "^")
  keymap_utils.create("i", "<Home>", "<C-o>^") -- Execute ^ in normal mode

  -- Indent
  keymap_utils.create("n", "<Tab>", ">>")
  keymap_utils.create("n", "<S-Tab>", "<<")
  keymap_utils.create("v", "<Tab>", ">gv") -- keep selection after
  keymap_utils.create("v", "<S-Tab>", "<gv")

  -- Yank
  keymap_utils.create("v", "y", "ygv<Esc>") -- Stay at cursor after yank

  -- Paste
  keymap_utils.create("v", "p", '"pdP') -- Don't keep the overwritten text in register "+". Instead, keep it in "p"

  -- Fold
  keymap_utils.create("n", "z.", "zo")
  keymap_utils.create("n", "z,", "zc")
  keymap_utils.create("n", "z>", "zr")
  keymap_utils.create("n", "z<", "zm")

  -- Screen movement
  keymap_utils.create("n", "<S-Up>", "5<C-Y>")
  keymap_utils.create("v", "<S-Up>", "5<C-Y>")
  keymap_utils.create("i", "<S-Up>", "<C-o>5<C-Y>")
  keymap_utils.create("n", "<S-Down>", "5<C-E>")
  keymap_utils.create("v", "<S-Down>", "5<C-E>")
  keymap_utils.create("i", "<S-Down>", "<C-o>5<C-E>")

  -- Window (pane)
  keymap_utils.create("n", "wi", "<cmd>wincmd k<CR>")
  keymap_utils.create("n", "wk", "<cmd>wincmd j<CR>")
  keymap_utils.create("n", "wj", "<cmd>wincmd h<CR>")
  keymap_utils.create("n", "wl", "<cmd>wincmd l<CR>")
  keymap_utils.create("n", "<C-e>", "<cmd>wincmd k<CR>")
  keymap_utils.create("n", "<C-d>", "<cmd>wincmd j<CR>")
  keymap_utils.create("n", "<C-s>", "<cmd>wincmd h<CR>")
  keymap_utils.create("n", "<C-f>", "<cmd>wincmd l<CR>")

  -- TODO: more intuitive control with lua
  keymap_utils.create("n", "<C-S-->", "10<C-w>-") -- Decrease height
  keymap_utils.create("n", "<C-S-=>", "10<C-w>+") -- Increase height
  keymap_utils.create("n", "<C-S-.>", "20<C-w>>") -- Increase width
  keymap_utils.create("n", "<C-S-,>", "20<C-w><") -- Decrease width

  keymap_utils.create("n", "ww", "<cmd>clo<CR>")

  keymap_utils.create("n", "wd", "<cmd>split<CR>")
  keymap_utils.create("n", "wf", "<cmd>vsplit<CR>")
  keymap_utils.create("n", "we", "<cmd>split<CR>")
  keymap_utils.create("n", "ws", "<cmd>vsplit<CR>")

  keymap_utils.create("n", "wt", "<cmd>wincmd T<CR>") -- Move to new tab

  -- Tab
  keymap_utils.create("n", "tj", "<cmd>tabp<CR>")
  keymap_utils.create("n", "tl", "<cmd>tabn<CR>")
  keymap_utils.create("n", "tt", "<cmd>tabnew<CR>")
  local close_tab = function()
    local is_only_tab = vim.fn.tabpagenr("$") == 1
    if is_only_tab then
      vim.cmd([[tabnew]])
      vim.cmd([[tabprevious]])
    end

    vim.cmd([[tabclose]])

    local is_last_tab = vim.fn.tabpagenr("$")
      == vim.api.nvim_tabpage_get_number(0)
    if not is_last_tab and vim.fn.tabpagenr() > 1 then
      vim.cmd([[tabprevious]])
    end
  end
  keymap_utils.create("n", "tw", close_tab)
  keymap_utils.create("n", "tq", "<cmd>tabonly<CR>")
  keymap_utils.create("n", "<C-j>", "<cmd>tabp<CR>")
  keymap_utils.create("n", "<C-l>", "<cmd>tabn<CR>")

  keymap_utils.create("n", "tu", "<cmd>tabm -1<CR>")
  keymap_utils.create("n", "to", "<cmd>tabm +1<CR>")
  keymap_utils.create("n", "<C-S-j>", "<cmd>tabm -1<CR>")
  keymap_utils.create("n", "<C-S-l>", "<cmd>tabm +1<CR>")

  -- Delete & cut
  keymap_utils.create("n", "d", '"dd') -- Put in d register, in case if needed
  keymap_utils.create("v", "d", '"dd')
  keymap_utils.create("n", "x", "d")
  keymap_utils.create("v", "x", "d")
  keymap_utils.create("n", "xx", "dd")
  keymap_utils.create("n", "X", "D")

  -- Change (add to register 'd')
  keymap_utils.create("n", "c", '"dc')
  keymap_utils.create("n", "C", '"dC')
  keymap_utils.create("v", "c", '"dc')
  keymap_utils.create("v", "C", '"dC')

  -- Jump (jumplist)
  if jumplist then
    keymap_utils.create("n", "<C-u>", jumplist.jump_back)
    keymap_utils.create("n", "<C-o>", jumplist.jump_forward)
  end

  -- Fzf

  keymap_utils.create(
    "n",
    "<f3>",
    function() require("fzf.selector.files")():start() end
  )

  keymap_utils.create("n", "<f4><f2>", function()
    -- require("fzf.selector.buffers")():start()
    vim.warn("Not implemented")
  end)
  keymap_utils.create("n", "<f4><f1>", function()
    -- require("fzf.selector.tabs")():start()
    vim.warn("Not implemented")
  end)

  keymap_utils.create("n", "<f5><f3>", function()
    -- require("fzf.selector.grep.file")():start()
    vim.warn("Not implemented")
  end)
  keymap_utils.create("n", "<f5><f4>", function()
    -- require("fzf.selector.grep.workspace")():start()
    vim.warn("Not implemented")
  end)
  keymap_utils.create("v", "<f5><f3>", function()
    -- require("fzf.grep.file")({
    --   initial_query = table.concat(editor_utils.get_visual_selection(), "\n"),
    -- }):start()
    vim.warn("Not implemented")
  end)
  keymap_utils.create("v", "<f5><f4>", function()
    -- require("fzf.selector.grep.workspace")({
    --   initial_query = table.concat(editor_utils.get_visual_selection(), "\n"),
    -- }):start()
    vim.warn("Not implemented")
  end)

  keymap_utils.create(
    "n",
    "<f11><f6>",
    function() require("fzf.selector.git.stash")():start() end
  )
  keymap_utils.create(
    "n",
    "<f11><f5>",
    function() require("fzf.selector.git.commits")():start() end
  )
  keymap_utils.create("n", "<f11><f4>", function()
    local current_file = vim.fn.expand("%")
    if not current_file or current_file == "" then
      vim.warn("No current file")
      return
    end

    require("fzf.selector.git.commits")({
      filepaths = {
        current_file,
      },
    }):start()
  end)
  keymap_utils.create(
    "n",
    "<f11><f3>",
    function() require("fzf.selector.git.status")():start() end
  )
  keymap_utils.create("n", "<f11><f2>", function()
    -- require("fzf.selector.git.branch")():start()
    vim.warn("Not implemented")
  end)
  keymap_utils.create("n", "<f11><f11>", function()
    -- require("fzf.selector.git.reflog")():start()
    vim.warn("Not implemented")
  end)

  keymap_utils.create(
    "n",
    "li",
    function() require("fzf.selector.lsp.definitions")():start() end
  )
  keymap_utils.create(
    "n",
    "lr",
    function() require("fzf.selector.lsp.references")():start() end
  )
  keymap_utils.create(
    "n",
    "ls",
    function() require("fzf.selector.lsp.document-symbols")():start() end
  )
  keymap_utils.create(
    "n",
    "lS",
    function() require("fzf.lsp.workspace-symbols")():start() end
  )
  keymap_utils.create(
    "n",
    "ld",
    function()
      require("fzf.selector.diagnostics")({
        current_buffer_only = true,
      }):start()
    end
  )
  keymap_utils.create(
    "n",
    "lD",
    function() require("fzf.selector.diagnostics")():start() end
  )

  keymap_utils.create("n", "<space>u", function()
    -- require("fzf.selector.undo")():start()
    vim.warn("Not implemented")
  end)
  keymap_utils.create(
    "n",
    "<space>m",
    function() require("fzf.selector.notification")():start() end
  )
  keymap_utils.create(
    "n",
    "<space>j",
    function() require("fzf.selector.jump")():start() end
  )

  keymap_utils.create(
    "n",
    "<f9><f1>",
    function() require("fzf.selector.docker.images")():start() end
  )
  keymap_utils.create(
    "n",
    "<f9><f2>",
    function() require("fzf.selector.docker.containers")():start() end
  )

  -- LSP
  keymap_utils.create("n", "lu", function() vim.lsp.buf.hover() end)
  keymap_utils.create("n", "lj", function() vim.diagnostic.open_float() end)
  keymap_utils.create("n", "lI", function() vim.lsp.buf.definition() end)
  keymap_utils.create("i", "<C-p>", function() vim.lsp.buf.signature_help() end)
  keymap_utils.create("n", "le", function() vim.lsp.buf.rename() end)
  keymap_utils.create("n", "lR", function()
    vim.info("Restarting LSP")
    vim.cmd("LspRestart")
  end)
  keymap_utils.create("n", "<space>l", function() vim.cmd("LspInfo") end)

  keymap_utils.create("n", "ll", function()
    if not conform then return vim.lsp.buf.format() end

    local success = conform.format()
    if success then
      return vim.info("Formatted with", conform.list_formatters()[1].name)
    else
      vim.lsp.buf.format()
      vim.info("Conform failed. Formatted with 'vim.lsp.buf.format()'")
    end
  end)

  local lsp_pick_formatter = function()
    ---@type vim.lsp.get_clients.Filter
    local filter = {
      bufnr = 0,
    }
    local clients = vim.lsp.get_clients(filter)

    local formatters = tbl_utils.filter(
      clients,
      function(i, e) return e.server_capabilities.documentFormattingProvider end
    )

    vim.ui.select(formatters, {
      prompt = "[LSP] Select formatter:",
      format_item = function(formatter) return formatter.name end,
    }, function(formatter)
      vim.lsp.buf.format({
        filter = function(client) return client.name == formatter.name end,
      })
    end)
  end

  local conform_pick_formatter = function()
    local formatters = conform.list_formatters()
    formatters = tbl_utils.filter(
      formatters,
      function(_, formatter) return formatter.available end
    )
    vim.ui.select(formatters, {
      prompt = "[Conform] Select formatter:",
      format_item = function(formatter) return formatter.name end,
    }, function(formatter) conform.format({ formatters = formatter.name }) end)
  end

  keymap_utils.create("n", "lL", function()
    if conform then
      conform_pick_formatter()
    else
      lsp_pick_formatter()
    end
  end)

  -- Comment
  keymap_utils.create("n", "<C-/>", "<Plug>(comment_toggle_linewise_current)")
  keymap_utils.create("v", "<C-/>", "<Plug>(comment_toggle_linewise_visual)gv") -- Re-select the last block
  local comment_api = require("Comment.api")
  if not vim.tbl_isempty(comment_api) then
    keymap_utils.create("i", "<C-/>", comment_api.toggle.linewise.current)
  end

  -- :qa, :q!, :wq
  keymap_utils.create("n", "<space>q", ":q<cr>")
  keymap_utils.create("n", "<space>w", ":wq<cr>")
  keymap_utils.create("n", "<space><BS>", ":q!<cr>")
  keymap_utils.create("n", "<space>s", ":w<cr>")
  keymap_utils.create("n", "<space>a", ":qa<cr>")
  keymap_utils.create("n", "<space>e", ":e<cr>")
  keymap_utils.create("n", "<space><delete>", ":qa!<cr>")

  -- Command line window
  keymap_utils.create("n", "<space>;", "q:")

  -- Session restore
  -- TODO
  keymap_utils.create("n", "<Space>r", function()
    -- persist.load_session()
    -- vim.info("Reloaded session")
    vim.warn("Not implemented")
  end)

  -- Colorizer
  keymap_utils.create("n", "<leader>c", function()
    vim.cmd([[ColorizerToggle]])
    vim.info("Colorizer toggled")
  end)
  keymap_utils.create("n", "<leader>C", function()
    vim.cmd([[ColorizerReloadAllBuffers]])
    vim.info("Colorizer reloaded")
  end)

  -- Nvim Cmp
  keymap_utils.create("i", "<M-r>", function()
    if not cmp then return end

    if cmp.visible() then cmp.confirm({ select = true }) end
  end)

  -- Copy path
  keymap_utils.create("n", "<leader>g", function()
    local path = vim.fn.expand("%:~")
    vim.fn.setreg("+", path)
    vim.info("Copied", path)
  end)
  command_utils.create("CopyRelativePath", function()
    local path = vim.fn.expand("%:~")
    vim.fn.setreg("+", path)
    vim.info("Copied", path)
  end)

  -- Misc
  command_utils.create(
    "LogCurrentBuf",
    function() vim.info(vim.api.nvim_get_current_buf()) end
  )
end

return {
  setup = setup,
}
