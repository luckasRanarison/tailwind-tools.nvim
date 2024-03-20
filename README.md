# tailwind-tools.nvim

Unofficial [Tailwind CSS](https://github.com/tailwindlabs/tailwindcss) integration and tooling for [Neovim](https://github.com/neovim/neovim) using the built-in LSP client.

## Contents

- [Features](#features)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Configuration](#configuration)
- [Commands](#commands)
- [Utilities](#utilities)
- [Related](#related)
- [Contributing](#contributing)

## Features

The plugin works out of the box with all languages inheriting from html, css and tsx treesitter grammars (php, astro, vue, svelte, ...) and provides the following features:

- Class color hints (uing LSP)
- Class concealing (using treesitter)
- Class sorting (using LSP)
- Completion utilities (using [nvim-cmp](https://github.com/hrsh7th/nvim-cmp))

> [!NOTE]
> Language services like autocompletion, diagnostics and hover are already provided by [tailwindcss-language-server](https://github.com/tailwindlabs/tailwindcss-intellisense/tree/master/packages/tailwindcss-language-server)

## Prerequisites

- Latest Neovim [stable](https://github.com/neovim/neovim/releases/tag/stable) or [nightly](https://github.com/neovim/neovim/releases/tag/nightly) (recommended)
- [tailwindcss-language-server](https://github.com/tailwindlabs/tailwindcss-intellisense/tree/master/packages/tailwindcss-language-server) >= `v0.0.14` (can be installed using [Mason](https://github.com/williamboman/mason.nvim))
- `html`, `css` and `tsx` treesitter grammars (can be installed using [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter))

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
return {
  "luckasRanarison/tailwind-tools.nvim",
  opts = {}
}
```

## Configuration

> [!IMPORTANT]
> Neovim nightly is required for VSCode like inline color hints

Here is the default configuration:

```lua
---@type TailwindTools.Option
{
  document_color = {
    enabled = true, -- can be toggled by commands
    kind = "inline", -- "inline" | "foreground" | "background"
    inline_symbol = "󰝤 ", -- only used in inline mode
    debounce = 200, -- in milliseconds, only applied in insert mode
  },
  conceal = {
    symbol = "󱏿", -- only a single character is allowed
    highlight = { -- extmark highlight options, see :h 'highlight'
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
- `TailwindColorEnable`: enables color hints for all buffers.
- `TailwindColorDisable`: disables color hints.
- `TailwindColorToggle`: toggles color hints.
- `TailwindSort`: sorts all classes in the current buffer.
- `TailwindSortSelection`: sorts selected classes in visual mode.

## Utilities

Utility function for highlighting colors in [nvim-cmp](https://github.com/hrsh7th/nvim-cmp) using [lspkind.nvim](https://github.com/onsails/lspkind.nvim):

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
        before = require("tailwind-tools.cmp").lspkind_format
      })
    }
  end
},
```

## Related

Here are some related projects:

- [tailwindcss-intellisense](https://github.com/tailwindlabs/tailwindcss-intellisense) (official vscode extension)
- [tailwind-fold](https://github.com/stivoat/tailwind-fold) (vscode extension)
- [tailwind-sorter.nvim](https://github.com/laytan/tailwind-sorter.nvim) (uses external scripts)
- [tailwind-fold.nvim](https://github.com/razak17/tailwind-fold.nvim) (has basic queries)
- [document-color.nvim](https://github.com/mrshmllow/document-color.nvim) (archieved)

## Contributing

Read the documentation carefully before submitting any issue.

Feature and pull requests are welcome.
