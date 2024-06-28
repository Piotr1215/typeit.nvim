local M = {}

local is_typing = false
local timer = nil
local default_config = {
  default_speed = 50,
  default_pause = 'line',
}
local config = vim.deepcopy(default_config)

-- Setup function for configuration
function M.setup(user_config)
  config = vim.tbl_deep_extend('force', default_config, user_config or {})
end

-- Function to expand the home directory
function M.expand_home(path)
  if path:sub(1, 1) == '~' then
    local home = os.getenv('HOME')
    if home then
      return home .. path:sub(2)
    end
  end
  return path
end

-- Function to read the entire content of a file
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

-- Function to set the filetype based on the file extension or name
function M.set_filetype(file_path)
  local extension = vim.fn.fnamemodify(file_path, ':e')
  local filename = vim.fn.fnamemodify(file_path, ':t')
  local filetype = extension

  -- Special cases
  if filename:lower() == 'dockerfile' then
    filetype = 'dockerfile'
  elseif extension == 'md' then
    filetype = 'markdown'
    -- Add more special cases here if needed
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

-- Function to simulate typing
function M.simulate_typing(text, speed)
  speed = speed or config.default_speed
  if timer then
    timer:stop()
    timer:close()
  end
  timer = vim.loop.new_timer()
  local i = 1
  is_typing = true

  local function type_char()
    if not is_typing or i > #text then
      if timer then
        timer:stop()
        timer:close()
        timer = nil
      end
      return
    end
    local char = text:sub(i, i)
    if char == '\n' then
      vim.api.nvim_command('normal! o')
    else
      vim.api.nvim_put({ char }, 'c', true, true)
    end
    i = i + 1
    if i <= #text then
      vim.schedule(type_char)
    end
  end

  timer:start(0, speed, vim.schedule_wrap(type_char))
end

-- Function to simulate typing with pauses
function M.simulate_typing_with_pauses(text, pause_at, speed)
  speed = speed or config.default_speed
  pause_at = pause_at or config.default_pause
  if timer then
    timer:stop()
    timer:close()
  end
  timer = vim.loop.new_timer()
  local lines = vim.split(text, '\n', { plain = true })
  local i = 1
  local j = 1
  is_typing = true
  local in_paragraph = false

  local function type_line()
    if not is_typing or i > #lines then
      if timer then
        timer:stop()
        timer:close()
        timer = nil
      end
      return
    end
    local line = lines[i]
    if j <= #line then
      vim.api.nvim_put({ line:sub(j, j) }, 'c', true, true)
      j = j + 1
      vim.schedule(type_line)
    else
      if i < #lines then
        vim.api.nvim_command('normal! o')
        local should_pause = false
        if pause_at == 'line' then
          should_pause = true
        elseif pause_at == 'paragraph' then
          if line == '' then
            in_paragraph = false
            should_pause = true
          elseif not in_paragraph then
            in_paragraph = true
            should_pause = true
          end
        end
        if should_pause then
          if vim.g.typeit_testing then
            -- For testing, use a brief timer instead of waiting for user input
            vim.defer_fn(function()
              i = i + 1
              j = 1
              vim.schedule(type_line)
            end, 10) -- 10ms pause
          else
            -- In normal operation, wait for user input
            vim.cmd("echo 'Press Enter to continue...'")
            vim.fn.getchar()
            vim.cmd("echo ''")
            i = i + 1
            j = 1
            vim.schedule(type_line)
          end
        else
          i = i + 1
          j = 1
          vim.schedule(type_line)
        end
      end
    end
  end

  vim.schedule(type_line)
end

-- Function to stop typing simulation
function M.stop_typing_simulation()
  is_typing = false
  if timer then
    timer:stop()
    timer:close()
    timer = nil
  end
end

-- Function to start typing simulation from a file
function M.start_typing_simulation_from_file(file_path, speed, pause_at)
  local text = M.read_file(file_path)
  if text then
    M.set_filetype(file_path)
    if pause_at then
      M.simulate_typing_with_pauses(text, pause_at, speed or config.default_speed)
    else
      M.simulate_typing(text, speed or config.default_speed)
    end
  else
    print('Failed to read file: ' .. file_path)
  end
end

-- Autocompletion function for file paths and speed
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
