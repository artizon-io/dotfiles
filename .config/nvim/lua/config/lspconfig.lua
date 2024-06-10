local workspace_diagnostics = require("workspace-diagnostics")
local schemastore = require("schemastore")

require("neodev").setup({})

local on_attach = function(client, bufnr)
  workspace_diagnostics.populate_workspace_diagnostics(client, bufnr)
end

-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md

-- nvim-cmp supports more types of completion candidates than the default (omnifunc)
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- Rust
require("lspconfig").rust_analyzer.setup({
  capabilities = capabilities,
  on_attach = on_attach,
})

-- Configuration
require("lspconfig").taplo.setup({ -- TODO
  capabilities = capabilities,
  on_attach = on_attach,
})
-- See schemastore catalog
-- https://github.com/SchemaStore/schemastore/blob/master/src/api/json/catalog.json
require("lspconfig").jsonls.setup({
  capabilities = capabilities,
  on_attach = on_attach,
  settings = {
    schemas = schemastore.json.schemas(),
    validate = { enable = true },
  },
})
require("lspconfig").yamlls.setup({
  on_attach = on_attach,
  settings = {
    yaml = {
      schemaStore = {
        -- You must disable built-in schemaStore support if you want to use
        -- this plugin and its advanced options like `ignore`.
        enable = false,
        -- Avoid TypeError: Cannot read properties of undefined (reading 'length')
        url = "",
      },
      schemas = schemastore.yaml.schemas(),
    },
  },
})
require("lspconfig").lemminx.setup({ -- XML
  capabilities = capabilities,
  on_attach = on_attach,
})

-- Python
require("lspconfig").pyright.setup({
  capabilities = capabilities,
  on_attach = on_attach,
})
require("lspconfig").ruff_lsp.setup({ -- TODO
  capabilities = capabilities,
  on_attach = on_attach,
})

-- Nix
require("lspconfig").nil_ls.setup({
  capabilities = capabilities,
  on_attach = on_attach,
})

-- Bash
require("lspconfig").bashls.setup({
  capabilities = capabilities,
  on_attach = on_attach,
})

-- Lua
require("lspconfig").lua_ls.setup({
  capabilities = capabilities,
  on_attach = on_attach,
})

-- Go
require("lspconfig").gopls.setup({
  capabilities = capabilities,
  on_attach = on_attach,
})

-- C/C++/Objective-C
require("lspconfig").clangd.setup({
  capabilities = capabilities,
  on_attach = on_attach,
})
require("lspconfig").neocmake.setup({
  capabilities = capabilities,
  on_attach = on_attach,
})

-- Web
require("lspconfig").cssls.setup({ -- TODO
  capabilities = capabilities,
  on_attach = on_attach,
})
require("lspconfig").tailwindcss.setup({ -- TODO
  capabilities = capabilities,
  on_attach = on_attach,
})
require("lspconfig").html.setup({ -- TODO
  capabilities = capabilities,
  on_attach = on_attach,
})
require("lspconfig").cssls.setup({ -- TODO
  capabilities = capabilities,
  on_attach = on_attach,
})
require("lspconfig").tsserver.setup({
  capabilities = capabilities,
  on_attach = on_attach,
})

-- Docker
require("lspconfig").docker_compose_language_service.setup({ -- TODO
  capabilities = capabilities,
  on_attach = on_attach,
})

-- Terraform
require("lspconfig").terraformls.setup({
  capabilities = capabilities,
  on_attach = on_attach,
})
require("lspconfig").tflint.setup({ -- TODO
  capabilities = capabilities,
  on_attach = on_attach,
})

-- Databases
require("lspconfig").postgres_lsp.setup({
  capabilities = capabilities,
  on_attach = on_attach,
})

-- Shading langauges
require("lspconfig").glsl_analyzer.setup({
  capabilities = capabilities,
  on_attach = on_attach,
})

-- Java
-- See also: ftplugin/java.lua
if not os.getenv("NVIM_USE_JDTLS") then
  require("lspconfig").jdtls.setup({
    capabilities = capabilities,
    on_attach = on_attach,
  })
end
