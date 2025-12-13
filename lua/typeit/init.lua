local M = {}

local config = {
  default_speed = 50,
  default_pause = 'line',
  scroll_position = 30, -- Percentage from bottom (30% = typing happens in middle-lower area)
}

function M.setup(user_config)
  config = vim.tbl_deep_extend('force', config, user_config or {})
end

local function adjust_view_position()
  if vim.g.typeit_testing then
    return
  end

  -- Calculate desired position: percentage from bottom
  local win_height = vim.api.nvim_win_get_height(0)
  local cursor_line = vim.api.nvim_win_get_cursor(0)[1]

  -- Calculate target screen line (30% from bottom = 70% from top)
  local target_line_from_top = math.floor(win_height * (100 - config.scroll_position) / 100)

  -- Calculate window topline to position cursor at target
  local desired_topline = math.max(1, cursor_line - target_line_from_top + 1)

  -- Set the window's top line
  vim.fn.winrestview({ topline = desired_topline })
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
    adjust_view_position()
  else
    vim.api.nvim_put({ char }, 'c', true, true)
  end
  vim.cmd('redraw')
end

local function type_line_with_skip(text, speed, check_skip)
  for i = 1, #text do
    type_char(text:sub(i, i))
    if not vim.g.typeit_testing then
      -- Sleep in 10ms chunks to check for skip
      local remaining = speed
      while remaining > 0 do
        local sleep_time = math.min(remaining, 10)
        local ok = pcall(vim.cmd, 'sleep ' .. sleep_time .. 'm')
        if not ok then
          return false -- Ctrl+C pressed
        end
        remaining = remaining - sleep_time

        -- Check for Enter key press to skip
        if check_skip then
          local char = vim.fn.getchar(0)
          if char == 13 then -- Enter key
            -- Type rest of text instantly
            for j = i + 1, #text do
              type_char(text:sub(j, j))
            end
            return true -- Skip detected
          end
        end
      end
    end
  end
  return false -- No skip, completed normally
end

function M.simulate_typing(text, speed)
  speed = speed or config.default_speed

  for i = 1, #text do
    type_char(text:sub(i, i))
    if not vim.g.typeit_testing then
      local ok = pcall(vim.cmd, 'sleep ' .. speed .. 'm')
      if not ok then
        return -- Exit cleanly on Ctrl+C
      end
    end
  end
end

function M.simulate_typing_with_pauses(text, pause_at, speed)
  speed = speed or config.default_speed
  pause_at = pause_at or config.default_pause
  local lines = vim.split(text, '\n', { plain = true })

  local i = 1
  while i <= #lines do
    local line = lines[i]
    local is_empty = line == ''

    -- Type empty lines instantly
    if is_empty then
      -- Only add newline if not the last line
      if i < #lines then
        vim.api.nvim_command('normal! o')
        adjust_view_position()
      end
      i = i + 1
    else
      -- Type non-empty line with skip detection
      local skipped = type_line_with_skip(line, speed, true)

      -- Only add newline if not the last line
      if i < #lines then
        vim.api.nvim_command('normal! o')
        adjust_view_position()
      end

      if skipped then
        -- Skip to next pause point
        if pause_at == 'line' then
          -- Already at next pause point (end of current line)
          i = i + 1
        elseif pause_at == 'paragraph' then
          -- Skip to end of paragraph (next empty line or end)
          i = i + 1
          while i <= #lines and lines[i] ~= '' do
            -- Type each character to maintain consistency
            for j = 1, #lines[i] do
              type_char(lines[i]:sub(j, j))
            end
            -- Only add newline if not the last line
            if i < #lines then
              vim.api.nvim_command('normal! o')
              adjust_view_position()
            end
            i = i + 1
          end
        end
      else
        i = i + 1
      end
    end

    -- Determine if we should pause
    local should_pause = false
    if pause_at == 'line' and not is_empty then
      should_pause = true
    elseif pause_at == 'paragraph' and (is_empty or i > #lines) then
      should_pause = true
    end

    if should_pause and not vim.g.typeit_testing then
      vim.cmd("echo 'Press Enter to continue...'")
      local ok = pcall(vim.fn.getchar)
      if not ok then
        return -- Exit cleanly on Ctrl+C
      end
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
