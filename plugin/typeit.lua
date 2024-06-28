if vim.g.typeit_version then
  return
end

vim.g.typeit_version = '0.0.1'

local typer = require('typeit')

vim.api.nvim_create_user_command('SimulateTyping', function(opts)
  local args = vim.split(opts.args, ' ')
  local file_path = args[1]
  local speed = tonumber(args[2]) or 50
  typer.start_typing_simulation_from_file(file_path, speed)
end, { nargs = '+', complete = typer.complete_simulate_typing })

-- Define the custom command to start typing simulation with pauses after each line
vim.api.nvim_create_user_command('SimulateTypingWithPauses', function(opts)
  local args = vim.split(opts.args, ' ')
  local file_path = args[1]
  local speed = tonumber(args[2]) or 50
  local pause_at = args[3] or 'line'
  typer.start_typing_simulation_from_file(file_path, speed, pause_at)
end, { nargs = '+', complete = typer.complete_simulate_typing })

-- Define the custom command to start typing simulation with pauses after each paragraph
vim.api.nvim_create_user_command('SimulateTypingWithParagraphPauses', function(opts)
  local args = vim.split(opts.args, ' ')
  local file_path = args[1]
  local speed = tonumber(args[2]) or 50
  typer.start_typing_simulation_from_file(file_path, speed, 'paragraph')
end, { nargs = '+', complete = typer.complete_simulate_typing })

-- Define the command to stop typing
vim.api.nvim_create_user_command('StopTyping', function()
  typer.stop_typing_simulation()
end, {})
