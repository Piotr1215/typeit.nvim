# TypeIt.nvim

TypeIt.nvim is a Neovim plugin that simulates typing in real-time. It's perfect for creating engaging demos, tutorials, or presentations where you want to showcase code or text being typed out dynamically.

## Features

- Simulate typing from files or strings
- Customizable typing speed
- Configurable pauses (line-by-line or paragraph)
- Filetype detection for syntax highlighting
- Easy to use Lua API and Vim commands

## Installation

### Using [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'Piotr1215/typeit.nvim'
```

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use 'Piotr1215/typeit.nvim'
```

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
    'Piotr1215/typeit.nvim',
    config = function()
        require('typeit').setup({
            -- Your configuration here
        })
    end
}
```

## Configuration

You can configure TypeIt.nvim globally using the `setup` function:

```lua
require('typeit').setup({
    default_speed = 30,    -- Default typing speed (milliseconds)
    default_pause = 'line' -- Default pause behavior ('line' or 'paragraph')
})
```

## Usage

### Vim Commands

TypeIt.nvim provides the following commands:

- `:SimulateTyping [file_path] [speed]`: Simulate typing from a file
- `:SimulateTypingWithPauses [file_path] [speed] [pause_at]`: Simulate typing with pauses
- `:SimulateTypingWithParagraphPauses [file_path] [speed]`: Simulate typing with paragraph pauses
- `:StopTyping`: Stop the current typing simulation

Examples:
```vim
:SimulateTyping ~/example.txt 30
:SimulateTypingWithPauses ~/example.txt 50 line
:StopTyping
```

### Lua API

You can also use TypeIt.nvim's functions directly in Lua:

```lua
local typeit = require('typeit')

-- Simulate typing from a file
typeit.start_typing_simulation_from_file('~/example.txt', 50)

-- Simulate typing a string
typeit.simulate_typing("Hello, World!", 30)

-- Simulate typing with line pauses
typeit.simulate_typing_with_pauses("Line 1\nLine 2\nLine 3", 'line', 50)

-- Simulate typing with paragraph pauses
typeit.simulate_typing_with_pauses("Paragraph 1\n\nParagraph 2", 'paragraph', 50)

-- Stop typing simulation
typeit.stop_typing_simulation()
```

## Advanced Usage

### Custom Keybindings

You can set up custom keybindings for TypeIt.nvim commands:

```lua
vim.api.nvim_set_keymap('n', '<leader>st', ':SimulateTyping<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>sp', ':SimulateTypingWithPauses<CR>', { noremap = true, silent = true })
```

### Integration with Other Plugins

TypeIt.nvim can be easily integrated with other plugins. For example, you could use it with a presentation plugin to create interactive coding demonstrations:

```lua
-- Example integration (pseudo-code)
presentation.on_slide_change(function(slide)
    if slide.has_code_demo then
        typeit.start_typing_simulation_from_file(slide.code_file, 30)
    end
end)
```

## Contributing

Contributions to TypeIt.nvim are welcome! Please feel free to submit a Pull Request.

### Development Setup

1. Fork the repository
2. Clone your fork: `git clone https://github.com/your-username/typeit.nvim.git`
3. Create a new branch: `git checkout -b my-new-feature`
4. Make your changes
5. Run the tests: `vusted test`
6. Commit your changes: `git commit -am 'Add some feature'`
7. Push to the branch: `git push origin my-new-feature`
8. Submit a pull request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
