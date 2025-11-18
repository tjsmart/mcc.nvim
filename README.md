# **mcc.nvim — Mission Control Center for Neovim 🚀**

**mcc.nvim** provides a way to easily define, modify, and execute
**Launch Codes** - custom commands that you want to trigger quickly.

---

## ✨ Features

* 🚀 **Launch Codes** — map arbitrary shell commands to numbered slots
* 📟 **Toggle Terminal** — open/close the MCC terminal in a floating or split window
* ⏱️ **One-key execution** with `mcc.run(<index>)`
* 🗂️ **Per-project configuration**
* 🔄 Runs commands inside a persistent terminal

---

## 📦 Installation

### Using **lazy.nvim**

```lua
{
    "tjsmart/mcc.nvim",
    opts = {},
}
```

---

## 🏃 Getting Started

### API

Toggle the MCC terminal window.
```lua
require("mcc").terminal()
```

Open the MCC Launch Code editor.
```lua
require("mcc").editor()
```

Run Launch Code `{index}` inside the MCC terminal.
```lua
require("mcc").run(index)
```

Rerun the most recently ran Launch Code.
```lua
require("mcc").rerun()
```

Open project notes.
```lua
require("mcc").notes()
```

### Example configuration

```lua
local mcc = require("mcc")

-- Toggle open/close the MCC terminal
vim.keymap.set({ "n", "t" }, "<C-e>", mcc.terminal)

-- Toggle open/close the MCC launch code editor
vim.keymap.set({ "n", "t" }, "<C-m>e", mcc.editor)

-- Keymaps to run launch codes
vim.keymap.set({ "n", "t" }, "<C-m>1", function() mcc.run(1) end)
vim.keymap.set({ "n", "t" }, "<C-m>2", function() mcc.run(2) end)
vim.keymap.set({ "n", "t" }, "<C-m>3", function() mcc.run(3) end)
vim.keymap.set({ "n", "t" }, "<C-m>4", function() mcc.run(4) end)
vim.keymap.set({ "n", "t" }, "<C-m>5", function() mcc.run(5) end)
vim.keymap.set({ "n", "t" }, "<C-m>r", mcc.rerun)

-- Open mcc notes
vim.keymap.set({ "n", "t" }, "<C-m>n", mcc.notes)

-- Launch a TUI (for example, lazygit)
local Terminal = require('mcc.terminal').Terminal
local lg = Terminal:new({ cmd = 'lazygit' })
vim.keymap.set("n", "<leader>lg", function() lg:toggle() end)
```

---

## 📜 License

MIT — free to use, modify, and contribute.
