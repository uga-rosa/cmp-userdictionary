local M = {}

function M.setup(opt)
  require("cmp_dictionary.config").setup(opt)
end

function M.update()
  require("cmp_dictionary.caches").update()
end

---@alias dictionaries table<string, string | string[]>
---#key is a pattern, value is a value of option 'dictionary'.

---@param opt { filetype: dictionaries, filepath: dictionaries, spelllang: dictionaries }
--- Usage:
--- require("cmp_dictionary").switcher({
---   filetype = {
---     lua = "/path/to/lua.dict",
---     javascript = { "/path/to/js.dict", "/path/to/js2.dict" },
---   },
---   filepath = {
---     ["*xmake.lua"] = { "/path/to/xmake.dict", "/path/to/lua.dict" }
---     [".tmux*.conf"] = { "/path/to/js.dict", "/path/to/js2.dict" },
---   },
---   spelllang = {
---     en = "/path/to/english.dict",
---   },
--  })
function M.switcher(opt)
  vim.validate({ opt = { opt, "table" } })

  local id = vim.api.nvim_create_augroup("cmp_dictionary", {})

  vim.api.nvim_create_autocmd("User", {
    group = id,
    pattern = "cmp_dictionary",
    callback = function()
      if opt.filetype then
        vim.opt_local.dictionary:append(opt.filetype[vim.bo.filetype] or "")
      end
      if opt.filepath then
        local fullpath = vim.fn.expand("%:p")
        for path, dict in pairs(opt.filepath) do
          if fullpath:find(path) then
            vim.opt_local.dictionary:append(dict)
          end
        end
      end
      if opt.spelllang then
        for _, sl in ipairs(vim.opt.spelllang:get()) do
          vim.opt_local.dictionary:append(opt.spelllang[sl] or "")
        end
      end
      M.update()
    end,
  })

  if opt.filetype then
    vim.api.nvim_create_autocmd("FileType", {
      group = id,
      pattern = vim.tbl_keys(opt.filetype),
      command = "do User cmp_dictionary",
    })
  end

  if opt.filepath then
    vim.api.nvim_create_autocmd("BufEnter", {
      group = id,
      command = "do User cmp_dictionary",
    })
  end

  if opt.spelllang then
    vim.api.nvim_create_autocmd("OptionSet", {
      group = id,
      pattern = "spelllang",
      command = "do User cmp_dictionary",
    })
  end

  vim.cmd("do User cmp_dictionary")
end

return M
