local nvim_lsp=require('lspconfig');
local path= require('lspconfig/util').path;

-- Configure to work with Ultisnips templates
vim.g.completion_enable_snippet='UltiSnips'

-- Get home dir
local home_dir=os.getenv("HOME")
-- Get location where pip installs executables by deault
local local_bin=os.getenv("HOME").."/.local/bin/"
-- Get location for npm global bin installs
local npm_bin=os.getenv("HOME").."/.npm_new_global/bin/"
-- Get location of where sumneko_lua is git cloned
local sumneko_root_path=os.getenv("HOME").."/Git-Repos/lua-language-server/"

-- Configure for buffers complete
vim.g.completion_chain_complete_list={
    {complete_items= {'lsp'}},
    {complete_items = {'buffers'}},
    {mode = { '<c-p>' }},
    {mode = { '<c-n>' }}
}

local map= function (type,key,value)
    vim.api.nvim_buf_set_keymap(0,type,key,value,{noremap=true, silent=true});
end

-- for creating commands! for lsp
local nvim_create_command= function (command_name,command)
    vim.cmd('command! '..command_name..
        ' :'..command..'<CR>')
end


-- for java
vim.env.JAR=home_dir.."/Git-Repos/jdtls/plugins/org.eclipse.equinox.launcher_1.6.0.v20200915-1508.jar"
vim.env.JAVA_HOME="/usr/lib/jvm/adoptopenjdk-11-openj9-amd64/"
vim.env.JDTLS_CONFIG=home_dir.."/Git-Repos/jdtls/config_linux/"
vim.env.GRADLE_HOME=home_dir.."/Apps/Gradle/gradle-6.7.1/"
vim.env.WORKSPACE=home_dir.."/jdtls-workspace"

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
    map('n','<c-]>','<cmd>lua vim.lsp.buf.definition()<CR>')
    map('n','K','<cmd>lua vim.lsp.buf.hover()<CR>')
    map('n','D','<cmd>lua vim.lsp.buf.hover();vim.lsp.buf.hover()<CR>')
    map('n','<c-i>','<cmd>lua vim.lsp.buf.implementation()<CR>')
    map('n','<c-k>','<cmd>lua vim.lsp.buf.signature_help()<CR>')
    map('n','gotdef','<cmd>lua vim.lsp.buf.type_definition()<CR>')
    map('n','goref','<cmd>lua vim.lsp.buf.references()<CR>')
    map('n','godoc','<cmd>lua vim.lsp.buf.document_symbol()<CR>')
    map('n','goW','<cmd>lua vim.lsp.buf.workspace_symbol()<CR>')
    map('n','godec','<cmd>lua vim.lsp.buf.declaration()<CR>')
    map('n','X','<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>')
    map('n','fix','<cmd>lua vim.lsp.buf.code_action()<CR>')
end

local custom_on_init_lsp=function (client)
    -- Setup for java
    if client.name == "jdtls" then
        print("LAMBA LOLOOOLOOO!")
    end
    local alert='LSP '..client.name..' initializing....'
    vim.api.nvim_command('echom "'..alert..'"')
end

-- Installed from ubuntu packages
nvim_lsp.clangd.setup{on_attach=custom_on_attach_lsp,
    cmd = {"/usr/bin/clang++-10","--background-index"}}
-- Installed from npm
nvim_lsp.vimls.setup{on_attach=custom_on_attach_lsp,
    cmd = {npm_bin..'/vim-language-server',"--stdio"}}
-- Installed from pip
nvim_lsp.cmake.setup{on_attach=custom_on_attach_lsp,
    cmd = {local_bin..'/cmake-language-server'}
}
-- Install from https://github.com/sumneko/lua-language-server
nvim_lsp.sumneko_lua.setup{
    cmd = {sumneko_root_path.."/bin/Linux/lua-language-server",
        "-E",sumneko_root_path.."/main.lua"
    },
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
-- Installed from pip
nvim_lsp.pyls.setup{on_attach=custom_on_attach_lsp,
    cmd={local_bin..'/pyls'}
}
-- Installed from jdtls eclipse website
nvim_lsp.jdtls.setup{
    cmd_env={
    },
    on_init=custom_on_init_lsp,
    on_attach=custom_on_attach_lsp,
    init_options={
        workspace= path.join {vim.loop.os_homedir(),
            "jdtls-workspace"};
          jvm_args = {};
          os_config = nil;
    },
    root_dir = vim.loop.cwd
}

