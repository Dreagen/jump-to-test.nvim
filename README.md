# Description
This plugin allows you to jump to matching test files and back to their source files.

From `MyService.cs`, it searches under Neovim's current working directory for files with the same extension whose name contains `MyService` and `test` (case-insensitive). This supports names such as `MyServiceTests.cs`, `MyService.Test.cs`, and `MyServiceTests.Unit.cs`. If there is one match it opens it directly; if there are multiple matches, it shows a picker.

When toggling from a filename containing `test`, the plugin removes `test` from the name and searches for same-extension, non-test files containing the remaining name. It uses the same direct-open or picker behavior for source matches.

# Configuration

## Lazy Nvim
This is my lazy configuration with example bindings

```lua
return {
  'Dreagen/jump-to-test.nvim',
  name = 'jump-to-test',
  keys = {
    {
      '<leader>jt',
      '<cmd>lua require("jump-to-test").toggle()<CR>',
      mode = { 'n', 'o', 'x' },
    },
    {
      '<leader>je',
      '<cmd>lua require("jump-to-test").jump_to_test()<CR>',
      mode = { 'n', 'o', 'x' },
    },
    {
      '<leader>js',
      '<cmd>lua require("jump-to-test").jump_to_source()<CR>',
      mode = { 'n', 'o', 'x' },
    },
  },
}
```
