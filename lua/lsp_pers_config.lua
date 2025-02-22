require("user_globals")
local lsp_config=require('lspconfig')

-- Configure to work with Ultisnips templates
vim.g.completion_enable_snippet='UltiSnips'

-- Get home dir
local home_dir=os.getenv("HOME")
-- Get location where pip installs executables by deault
local local_bin=os.getenv("HOME").."/.local/bin/"
-- Get location for npm global bin installs
local npm_bin=os.getenv("HOME").."/.npm_global_new/bin/"
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

-- for java https://download.eclipse.org/jdtls/snapshots/jdt-language-server-latest.tar.gz
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
    print('LSP '..client.name..' started')

    -- Set key mappings
    map('n','<Space>n','<cmd>lua vim.lsp.buf.definition()<CR>')
    map('n','<Space>z','<cmd>lua vim.lsp.buf.hover()<CR>')
    map('n','<Space>a','<cmd>lua vim.lsp.buf.hover();vim.lsp.buf.hover()<CR>')
    map('n','<Space>i','<cmd>lua vim.lsp.buf.implementation()<CR>')
    map('n','<Space>s','<cmd>lua vim.lsp.buf.signature_help()<CR>')
    map('n','<Space>d','<cmd>lua vim.lsp.buf.type_definition()<CR>')
    map('n','<Space>r','<cmd>lua vim.lsp.buf.references()<CR>')
    map('n','<Space>q','<cmd>lua vim.lsp.buf.document_symbol()<CR>')
    map('n','<Space>w','<cmd>lua vim.lsp.buf.workspace_symbol()<CR>')
    map('n','<Space>m','<cmd>lua vim.lsp.buf.declaration()<CR>')
    map('n','<Space>x','<cmd>lua vim.lsp.diagnostic.get_all()<CR>')
    map('n','X','<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>')
    map('n','<Space>f','<cmd>lua vim.lsp.buf.code_action()<CR>')
end

local lspinstall=require('lspinstall')
lspinstall.setup()
local servers=lspinstall.installed_servers()
for _, server in pairs(servers) do
    if server == "lua" then
        lsp_config[server].setup{on_attach=custom_on_attach_lsp,
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
    else
        lsp_config[server].setup{on_attach=custom_on_attach_lsp}
    end
end

