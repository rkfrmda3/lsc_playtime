fx_version 'cerulean'
game 'gta5'
lua54 "yes"
author "Lsc Development"

shared_scripts {
    '@ox_lib/init.lua',
	'config.lua'
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'server/*.lua',
}

client_scripts {
	'client/*.lua',
}

escrow_ignore {
    'config.lua',
	'client/*.lua',
	'server/*.lua',
}