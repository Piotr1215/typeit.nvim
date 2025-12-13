local typeit = require('typeit')

vim.g.typeit_testing = true

describe('TypeIt Plugin', function()
  before_each(function()
    vim.cmd('new')
    typeit.setup({})
  end)

  after_each(function()
    vim.cmd('bdelete!')
  end)

  describe('Setup function', function()
    it('should set default configuration', function()
      typeit.setup({})
      local test_text = 'This is a test.'
      typeit.simulate_typing(test_text, 1)
      local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
      assert.are.same({ test_text }, lines)
    end)

    it('should override default configuration', function()
      typeit.setup({ default_speed = 1 })
      local test_text = 'This is a faster test.'
      typeit.simulate_typing(test_text, 1)
      local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
      assert.are.same({ test_text }, lines)
    end)

    it('should accept scroll_position configuration', function()
      typeit.setup({ scroll_position = 40 })
      local test_text = 'Testing scroll position.'
      typeit.simulate_typing(test_text, 1)
      local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
      assert.are.same({ test_text }, lines)
    end)
  end)

  describe('Typing simulation', function()
    it('should simulate typing in a buffer', function()
      local test_text = 'This is a test.'
      typeit.simulate_typing(test_text, 1)
      local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
      assert.are.same({ test_text }, lines)
    end)

    it('should simulate typing with line pauses', function()
      local test_text = 'Line 1\nLine 2\nLine 3'
      typeit.simulate_typing_with_pauses(test_text, 'line', 1)
      local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
      assert.are.same({ 'Line 1', 'Line 2', 'Line 3' }, lines)
    end)

    it('should simulate typing with paragraph pauses', function()
      local test_text = 'Paragraph 1\n\nParagraph 2\n\nParagraph 3'
      typeit.simulate_typing_with_pauses(test_text, 'paragraph', 1)
      local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
      assert.are.same({ 'Paragraph 1', '', 'Paragraph 2', '', 'Paragraph 3' }, lines)
    end)

    it('should handle empty lines instantly', function()
      local test_text = 'Line 1\n\nLine 2'
      typeit.simulate_typing_with_pauses(test_text, 'line', 1)
      local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
      assert.are.same({ 'Line 1', '', 'Line 2' }, lines)
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
end)
