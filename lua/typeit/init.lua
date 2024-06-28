local M = {}

local config = {
  default_speed = 50,
  default_pause = 'line',
}

function M.setup(user_config)
  config = vim.tbl_deep_extend('force', config, user_config or {})
end

function M.expand_home(path)
  if path:sub(1, 1) == '~' then
    local home = os.getenv('HOME')
    if home then
      return home .. path:sub(2)
    end
  end
  return path
end

function M.read_file(file_path)
  file_path = M.expand_home(file_path)
  local file = io.open(file_path, 'r')
  if not file then
    print('Error opening file: ' .. file_path)
    return nil
  end
  local content = file:read('*all')
  file:close()
  return content
end

function M.set_filetype(file_path)
  local extension = vim.fn.fnamemodify(file_path, ':e')
  local filename = vim.fn.fnamemodify(file_path, ':t')
  local filetype = extension

  if filename:lower() == 'dockerfile' then
    filetype = 'dockerfile'
  elseif extension == 'md' then
    filetype = 'markdown'
  elseif extension == '' then
    filetype = ''
  end

  if filetype ~= '' then
    vim.api.nvim_buf_set_option(0, 'filetype', filetype)
    print('Filetype set to: ' .. filetype)
  else
    print('No filetype set')
  end
end

local function type_char(char)
  if char == '\n' then
    vim.api.nvim_command('normal! o')
  else
    vim.api.nvim_put({ char }, 'c', true, true)
  end
  vim.cmd('redraw')
end

function M.simulate_typing(text, speed)
  speed = speed or config.default_speed
  for i = 1, #text do
    type_char(text:sub(i, i))
    if not vim.g.typeit_testing then
      vim.cmd('sleep ' .. speed .. 'm')
    end
  end
end

function M.simulate_typing_with_pauses(text, pause_at, speed)
  speed = speed or config.default_speed
  pause_at = pause_at or config.default_pause
  local lines = vim.split(text, '\n', { plain = true })

  for i, line in ipairs(lines) do
    M.simulate_typing(line, speed)
    vim.api.nvim_command('normal! o')

    local should_pause = pause_at == 'line' or (pause_at == 'paragraph' and (line == '' or i == 1))

    if should_pause and not vim.g.typeit_testing then
      vim.cmd("echo 'Press Enter to continue...'")
      vim.fn.getchar()
      vim.cmd("echo ''")
    end
  end
end

function M.start_typing_simulation_from_file(file_path, speed, pause_at)
  local text = M.read_file(file_path)
  if text then
    M.set_filetype(file_path)
    if pause_at then
      M.simulate_typing_with_pauses(text, pause_at, speed)
    else
      M.simulate_typing(text, speed)
    end
  else
    print('Failed to read file: ' .. file_path)
  end
end

function M.complete_simulate_typing(arg_lead, cmd_line, cursor_pos)
  local args = vim.split(cmd_line, ' ')
  if #args == 2 then
    return vim.fn.getcompletion(arg_lead, 'file')
  elseif #args == 3 then
    return { '10', '20', '30', '40', '50', '60', '70', '80', '90', '100' }
  elseif #args == 4 then
    return { 'line', 'paragraph' }
  end
end

return M
