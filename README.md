# Description
This plugin allows you to jump to a test file and back to the source file.
It currently works by looking for a file of the same name ending in `Tests` with the same file extension, I may choose to make this configurable at a later date but for now this works for my needs

for example if you were in `MyService.cs` it would look for any file under the root directory of the current nvim instance called `MyServiceTests.cs`, it will also jump back from a test file by looking for a file with the same name without the Tests

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
