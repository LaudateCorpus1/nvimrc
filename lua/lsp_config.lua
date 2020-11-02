local nvim_lsp=require('nvim_lsp');

local map= function (type,key,value)
    vim.api.nvim_buf_set_keymap(0,type,key,value,{noremap=true, silent=true});
end

-- for creating commands! for lsp
local nvim_create_command= function (command_name,command)
    vim.cmd('command! '..command_name..
        ' :'..command..'<CR>')
end


-- for restarting all lsp servers
lspes_restart_all=function ()
    vim.lsp.stop_client(vim.lsp.get_active_clients())
    vim.cmd('edit')
    vim.cmd('edit')
end
nvim_create_command('LspRestart',"lua lspes_restart_all()")

-- for checking status of lsp servers per buffer
lspes_buffer_running=function ()
    local clientMaps=vim.lsp.buf_get_clients(0);

    vim.api.nvim_command('echom "current running lsp servers on buffer:\n"')

    for k, v in pairs(clientMaps) do
        vim.api.nvim_command('echom "ID: '..k..
            ' CLIENT: '..tostring(v.name)..'"')
    end
end
nvim_create_command('LspClientBuffer',"lua lspes_buffer_running()")

-- for checking status of lsp-servers for current nvim instance
lspes_running=function ()
    local clientMaps=vim.lsp.get_active_clients();

    vim.api.nvim_command('echom "current running lsp servers:\n"')

    for k, v in pairs(clientMaps) do
        vim.api.nvim_command('echom "ID: '..k..' CLIENT: '..tostring(v.name)..'"')
    end
end
nvim_create_command('LspClientsAll',"lua lspes_running()")


-- for renaming using lsp
nvim_create_command('LspRename','lua vim.lsp.buf.rename()')



-- Handle mapping and execution once LSP is attatched
local custom_on_attach_lsp=function (client)
    local alert='LSP '..client.name..' started'
    vim.api.nvim_command('echom "'..alert..'"')

    -- Set key mappings
    map('n','godef','<cmd>lua vim.lsp.buf.definition()<CR>')
    map('n','K','<cmd>lua vim.lsp.buf.hover()<CR>')
    map('n','D','<cmd>lua vim.lsp.buf.hover();vim.lsp.buf.hover()<CR>')
    map('n','goimp','<cmd>lua vim.lsp.buf.implementation()<CR>')
    map('n','<c-k>','<cmd>lua vim.lsp.buf.signature_help()<CR>')
    map('n','gotdef','<cmd>lua vim.lsp.buf.type_definition()<CR>')
    map('n','goref','<cmd>lua vim.lsp.buf.references()<CR>')
    map('n','godoc','<cmd>lua vim.lsp.buf.document_symbol()<CR>')
    map('n','goW','<cmd>lua vim.lsp.buf.workspace_symbol()<CR>')
    map('n','godec','<cmd>lua vim.lsp.buf.declaration()<CR>')
end

local custom_on_init_lsp=function (client)
    local alert='LSP '..client.name..' initializing....'
    vim.api.nvim_command('echom "'..alert..'"')
end

nvim_lsp.clangd.setup{on_attach=custom_on_attach_lsp}
nvim_lsp.vimls.setup{on_attach=custom_on_attach_lsp}
nvim_lsp.cmake.setup{on_attach=custom_on_attach_lsp}
nvim_lsp.sumneko_lua.setup{
    on_attach=custom_on_attach_lsp,
    settings = {
        Lua = {
          runtime = {
            version = "LuaJIT",
            path = vim.split(package.path, ';'),
          },
          workspace = {
            library = {
              [vim.fn.expand("$VIMRUNTIME/lua")] = true,
              [vim.fn.expand("$VIMRUNTIME/lua/vim/lsp")] = true,
            },
          },
          diagnostics = {
            globals = {"vim"},
            disable = {"lowercase-global", "unused-function"},
          },
        },
      },
}
nvim_lsp.pyls.setup{on_attach=custom_on_attach_lsp}
nvim_lsp.jdtls.setup{
    on_init=custom_on_init_lsp,
    on_attach=custom_on_attach_lsp
}

