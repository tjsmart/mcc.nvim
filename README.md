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
    config = function()
        require("mcc").setup()
    end
}
```

---

## 📜 License

MIT — free to use, modify, and contribute.
