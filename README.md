# typeit.nvim

typeit.nvim is a Neovim plugin that simulates typing in real-time. It's perfect for creating engaging demos, tutorials, or presentations where you want to showcase code or text being typed out dynamically.

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

You can configure typeit.nvim globally using the `setup` function:

```lua
require('typeit').setup({
    default_speed = 30,    -- Default typing speed (milliseconds)
    default_pause = 'line' -- Default pause behavior ('line' or 'paragraph')
})
```

## Usage

### Vim Commands

typeit.nvim provides the following commands that should be used in an empty buffer. The typing simulation always starts from the beginning of the current buffer.

- `:SimulateTyping [file_path] [speed]`: Simulate typing from a file
- `:SimulateTypingWithPauses [file_path] [speed] [pause_at]`: Simulate typing with pauses ('line' or 'paragraph')
- `:StopTyping`: Stop the current typing simulation

#### Simulating typing from a file

To simulate typing the contents of a file:

1. Open a new empty buffer: `:enew`
2. Use the `SimulateTyping` command:

```vim
:SimulateTyping ~/example.txt 30
```

This will simulate typing the contents of `example.txt` at a speed of 30 milliseconds per character.

#### Simulating typing with pauses

To simulate typing with pauses between lines or paragraphs:

1. Open a new empty buffer: `:enew`
2. Use the `SimulateTypingWithPauses` command:

```vim
:SimulateTypingWithPauses ~/example.txt 50 line
```

This will simulate typing the contents of `example.txt` at a speed of 50 milliseconds per character, pausing after each line.

For paragraph pauses:

```vim
:SimulateTypingWithPauses ~/example.txt 50 paragraph
```

This will pause after each paragraph instead of each line.

#### Simulating typing of custom text

You can also simulate typing of custom text directly in Neovim:

1. Open a new empty buffer: `:enew`
2. Enter command mode and type your text in quotes:

```vim
:call luaeval("require('typeit').simulate_typing(_A[1], _A[2])", ["This is a custom text being typed out.", 40])
```

This will simulate typing "This is a custom text being typed out." at a speed of 40 milliseconds per character.

For custom text with pauses:

```vim
:call luaeval("require('typeit').simulate_typing_with_pauses(_A[1], _A[2], _A[3])", ["Line 1\nLine 2\nLine 3", "line", 30])
```

This will simulate typing the given lines with pauses after each line, at a speed of 30 milliseconds per character.

#### Stopping the simulation

To stop the typing simulation at any point:

```vim
:StopTyping
```

Remember, you can always use `Ctrl+C` to interrupt the typing simulation as well.

These commands give you flexibility to simulate typing from files or custom text, with or without pauses, directly from Vim command mode.

## Advanced Usage

### Custom Keybindings

You can set up custom keybindings for typeit.nvim commands:

```lua
vim.api.nvim_set_keymap('n', '<leader>st', ':SimulateTyping<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>sp', ':SimulateTypingWithPauses<CR>', { noremap = true, silent = true })
```

## Development

To load the plugin from a local environment for development, add this to your `init.lua`:

```lua
vim.opt.runtimepath:prepend("/path/to/your/typeit.nvim")
```

## Testing

typeit.nvim uses the `vusted` framework for testing. To run the tests:

1. Install `vusted` if you haven't already:
   ```
   luarocks install vusted
   ```

2. Navigate to the plugin directory and run:
   ```
   vusted test
   ```

The tests cover various aspects of the plugin, including typing simulation, pausing behavior, and file operations. They ensure that the plugin functions correctly in different scenarios.

## Contributing

Contributions to typeit.nvim are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
