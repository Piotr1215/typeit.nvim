-- Explicitly require the plugin
local typeit = require('typeit')

-- Set testing mode
vim.g.typeit_testing = true

describe('TypeIt Plugin', function()
  before_each(function()
    -- Create a new buffer for each test
    vim.cmd('new')
    -- Reset to default configuration before each test
    typeit.setup({})
  end)

  after_each(function()
    -- Stop any ongoing typing simulation
    typeit.stop_typing_simulation()
    -- Close the buffer after each test
    vim.cmd('bdelete!')
  end)

  describe('Setup function', function()
    it('should set default configuration', function()
      typeit.setup({})
      local test_text = 'This is a test.'
      typeit.simulate_typing(test_text)
      vim.wait(1000, function()
        local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
        return #lines[1] == #test_text
      end)
      local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
      assert.are.same({ test_text }, lines)
    end)

    it('should override default configuration', function()
      typeit.setup({ default_speed = 1 })
      local test_text = 'This is a faster test.'
      typeit.simulate_typing(test_text)
      vim.wait(100, function()
        local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
        return #lines[1] == #test_text
      end)
      local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
      assert.are.same({ test_text }, lines)
    end)

    it('should use custom pause behavior', function()
      typeit.setup({ default_pause = 'paragraph' })
      local test_text = 'Paragraph 1\n\nParagraph 2'
      typeit.simulate_typing_with_pauses(test_text)
      vim.wait(2000, function()
        local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
        return #lines == 3 and lines[3] == 'Paragraph 2'
      end)
      local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
      assert.are.same({ 'Paragraph 1', '', 'Paragraph 2' }, lines)
    end)
  end)

  describe('Core functionality', function()
    it('should have the main functions', function()
      assert.is_function(typeit.start_typing_simulation_from_file)
      assert.is_function(typeit.stop_typing_simulation)
      assert.is_function(typeit.simulate_typing)
      assert.is_function(typeit.simulate_typing_with_pauses)
    end)
  end)

  describe('Typing simulation', function()
    it('should simulate typing in a buffer', function()
      local test_text = 'This is a test.'
      typeit.simulate_typing(test_text, 1) -- Use 1ms speed for faster typing in tests
      vim.wait(1000, function() -- Wait up to 1 second for typing to complete
        local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
        return #lines[1] == #test_text
      end)
      local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
      assert.are.same({ test_text }, lines)
    end)

    it('should simulate typing with line pauses', function()
      local test_text = 'Line 1\nLine 2\nLine 3'
      typeit.simulate_typing_with_pauses(test_text, 'line', 1)
      vim.wait(2000, function() -- Wait up to 2 seconds for typing to complete
        local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
        return #lines == 3 and lines[3] == 'Line 3'
      end)
      local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
      assert.are.same({ 'Line 1', 'Line 2', 'Line 3' }, lines)
    end)

    it('should simulate typing with paragraph pauses', function()
      local test_text = 'Paragraph 1\n\nParagraph 2\n\nParagraph 3'
      typeit.simulate_typing_with_pauses(test_text, 'paragraph', 1)
      vim.wait(3000, function() -- Wait up to 3 seconds for typing to complete
        local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
        return #lines == 5 and lines[5] == 'Paragraph 3'
      end)
      local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
      assert.are.same({ 'Paragraph 1', '', 'Paragraph 2', '', 'Paragraph 3' }, lines)
    end)
  end)

  describe('File operations', function()
    it('should expand home directory', function()
      local path = '~/test'
      local expanded = typeit.expand_home(path)
      assert.is_not.equals(path, expanded)
      assert.is_true(expanded:find(os.getenv('HOME')) == 1)
    end)

    it('should set filetype based on file extension', function()
      typeit.set_filetype('test.lua')
      assert.equals('lua', vim.bo.filetype)
    end)

    it('should set filetype for special cases', function()
      typeit.set_filetype('Dockerfile')
      assert.equals('dockerfile', vim.bo.filetype)
    end)
  end)

  describe('Command creation', function()
    it('should create SimulateTyping command', function()
      assert.is_not_nil(vim.fn.exists(':SimulateTyping'))
    end)

    it('should create SimulateTypingWithPauses command', function()
      assert.is_not_nil(vim.fn.exists(':SimulateTypingWithPauses'))
    end)

    it('should create SimulateTypingWithParagraphPauses command', function()
      assert.is_not_nil(vim.fn.exists(':SimulateTypingWithParagraphPauses'))
    end)

    it('should create StopTyping command', function()
      assert.is_not_nil(vim.fn.exists(':StopTyping'))
    end)
  end)
end)
