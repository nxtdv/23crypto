fx_version 'adamant'
game 'gta5'

client_scripts {
    "shared/src/RMenu.lua",
    "shared/src/menu/RageUI.lua",
    "shared/src/menu/Menu.lua",
    "shared/src/menu/MenuController.lua",
    "shared/src/components/*.lua",
    "shared/src/menu/elements/*.lua",
    "shared/src/menu/items/*.lua",
    "shared/src/menu/panels/*.lua",
    "shared/src/menu/windows/*.lua",
    
    'client/main.lua',
    'client/_function.lua'
}

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'server/main.lua'
}

shared_scripts {
    'config.lua',
}

dependencies {
	'es_extended',
}