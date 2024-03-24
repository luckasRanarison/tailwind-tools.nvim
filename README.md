> [!IMPORTANT]
> This plugin is a community project and is **NOT** officialy supported by [Tailwind Labs](https://github.com/tailwindlabs).

# tailwind-tools.nvim

Unofficial [Tailwind CSS](https://github.com/tailwindlabs/tailwindcss) integration and tooling for [Neovim](https://github.com/neovim/neovim) using the built-in LSP client and treesitter, inspired by the official Visual Studio Code [extension](https://github.com/tailwindlabs/tailwindcss-intellisense).

![preview](https://github.com/luckasRanarison/tailwind-tools.nvim/assets/101930730/cb1c0508-8375-474f-9078-2842fb62e0b7)

## Contents

- [Features](#features)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Configuration](#configuration)
- [Commands](#commands)
- [Utilities](#utilities)
- [Extension](#extension)
- [Related projects](#related-projects)
- [Contributing](#contributing)

## Features

The plugin works with all languages inheriting from html, css and tsx treesitter grammars (php, astro, vue, svelte, [...](./queries)) and provides the following features:

- Class color hints
- Class concealing
- Class sorting (without [prettier-plugin](https://github.com/tailwindlabs/prettier-plugin-tailwindcss))
- Completion utilities (using [nvim-cmp](https://github.com/hrsh7th/nvim-cmp))

> [!NOTE]
> Language services like autocompletion, diagnostics and hover are already provided by [tailwindcss-language-server](https://github.com/tailwindlabs/tailwindcss-intellisense/tree/master/packages/tailwindcss-language-server).

## Prerequisites

- Latest Neovim [stable](https://github.com/neovim/neovim/releases/tag/stable) or [nightly](https://github.com/neovim/neovim/releases/tag/nightly) (recommended)
- [tailwindcss-language-server](https://github.com/tailwindlabs/tailwindcss-intellisense/tree/master/packages/tailwindcss-language-server) >= `v0.0.14` (can be installed using [Mason](https://github.com/williamboman/mason.nvim))
- `html`, `css`, `tsx` and your other languages treesitter grammars (using [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter))

> [!TIP]
> If you are not familiar with neovim LSP ecosystem check out [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) to learn how to setup the LSP.

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
-- tailwind-tools.lua
return {
  "luckasRanarison/tailwind-tools.nvim",
  opts = {} -- your configuration
}
```

If you are using other package managers you need to call `setup`:

```lua
require("tailwind-tools").setup({
  -- your configuration
})
```

## Configuration

> [!IMPORTANT]
> Neovim nightly is required for vscode-like inline color hints.

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
  custom_filetypes = {} -- see the extension section to learn how it works
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
-- nvim-cmp.lua
return {
  "hrsh7th/nvim-cmp",
  dependencies = {
    "luckasRanarison/tailwind-tools.nvim",
    "onsails/lspkind-nvim",
    -- ...
  },
  opts = function()
    return {
      -- ...
      formatting = {
        format = require("lspkind").cmp_format({
          before = require("tailwind-tools.cmp").lspkind_format
        },
      })
    }
  end
},
```

> [!TIP]
> You can extend it by calling the function and get the returned `vim_item`, see the nvim-cmp [wiki](https://github.com/hrsh7th/nvim-cmp/wiki/Menu-Appearance) to learn more.

## Extension

The plugin basically works with any language as long it has a treesitter parser and a `class` query. You can check the currently available queries and supported filetypes [here](./queries), feel free to request other languages support.

But you can also create your own queries! If you are not familiar with treesitter queries you should check out the treesitter query documentation from [Neovim](https://neovim.io/doc/user/treesitter.html#treesitter-query) or [Treesitter](https://tree-sitter.github.io/tree-sitter/using-parsers#query-syntax). To add a new filetype you first need to add it to your configuration then the plugin will search for a `class.scm` file (classexpr) associated to the filetype in your `runtimepath`, that file contains a query that will extract all the class values in your file.

You could use your Neovim configuration folder to store queries inside a folder named `query` as shown in the follwing example:

```
~/.config/nvim
.
├── init.lua
├── lua
│   └── ...
└── queries
    └── myfiletype
        └── class.scm
```

The class value should be the **second** matched item in the query as in the follwing example:

```scheme
(attribute
  (attribute_name) @_attribute_name ; first match (usually used to check the attribute name)
  (#eq? @_attribute_name "class")
  (quoted_attribute_value
    (attribute_value) @_class_value)) ; second match (the actual value)
```

Note that this only works for basic use cases, more complex queries cannot be handled in that way and require actual code as in the case of `css`. You can also check out the existing [queries](./queries) to see more examples.

## Related projects

Here are some related projects:

- [tailwindcss-intellisense](https://github.com/tailwindlabs/tailwindcss-intellisense) (official vscode extension)
- [tailwind-sorter.nvim](https://github.com/laytan/tailwind-sorter.nvim) (uses external scripts)
- [tailwind-fold](https://github.com/stivoat/tailwind-fold) (vscode extension)
- [tailwind-fold.nvim](https://github.com/razak17/tailwind-fold.nvim)
- [document-color.nvim](https://github.com/mrshmllow/document-color.nvim) (archieved)

## Contributing

Read the documentation carefully before submitting any issue.

Feature and pull requests are welcome.
