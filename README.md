# tailnwind-tools.nvim

Unofficial [Tailwind CSS](https://github.com/tailwindlabs/tailwindcss) integration and tooling for [Neovim](https://github.com/neovim/neovim).

## Contents

- [Features](#features)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Configuration](#configuration)
- [Commands](#commands)
- [Utilities](#utilities)
- [Credis](#credits)
- [Contributing](#contributing)

## Features

- Class color hints
- Class concealing (using treesitter)
- Class sorting (using built-in LSP)
- Completion utilities (using nvim-cmp)

> [!IMPORTANT]
> Neovim nightly is required for VSCode like inline color hints

## Prerequisites

- Neovim stable or [nightly](https://github.com/neovim/neovim/releases/tag/nightly) (recommended)
- [Tailwind CSS language server](https://github.com/tailwindlabs/tailwindcss-intellisense) (can be installed using [Mason](https://github.com/williamboman/mason.nvim))

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
return {
  "luckasRanarison/tailwind-tools.nvim",
  opts = {}
}
```

## Configuration

```lua
---@type TailwindTools.Option
{
  document_color = {
    kind = "inline", -- "inline" | "foreground" | "backgroubd"
    inline_symbol = "󰝤 ", -- only used in inline mode
    debounce = 200, -- in milliseconds, applied in insert mode
  },
  conceal = {
    symbol = "󱏿",
    highlight = { -- extmark highlight, see :'highlight'
      fg = "#38BDF8",
    },
  },
}
```

## Commands

Available commands:

- `TailwindConcealEnable`: enables conceal for all buffers.
- `TailwindConcealDisable`: disables conceal.
- `TailwindConcealToggle`: toggles conceal.
- `TailwindSort`: sorts all classes in the current buffer.
- `TailwindSortSelection`: sorts selected classes in visual mode.

## Utilities

tailwind-tools provides an utility function for highlighting colors in [nvim-cmp](https://github.com/hrsh7th/nvim-cmp) using [lspkind.nvim](https://github.com/onsails/lspkind.nvim).

```lua
{
  "hrsh7th/nvim-cmp",
  dependencies = {
    "luckasRanarison/tailwind-tools.nvim",
    "onsails/lspkind-nvim",
    -- ...
  },
  opts = function()
    return {
      -- ...
      formatting = require("lspkind").cmp_format({
        before = require("tailwind-tools").lspkind_format
      })
    }
  end
},
```

## Credits

- [tailwindcss-intellisense](https://github.com/tailwindlabs/tailwindcss-intellisense) for inspiration.
- [document-color.nvim](https://github.com/mrshmllow/document-color.nvim) as a reference for the `textDocument/documentColor` support.
- [tailwind-sorter.nvim](https://github.com/laytan/tailwind-sorter.nvim) which also provides sorting but using prettier.

## Contributing

Feature requests, issues and pull requests are all welcome.
