fx_version 'adamant'
game 'gta5'
lua54 'yes'

author 'Oliver693'
description 'A free car giver script for ESX servers that grants each player one vehicle, ensuring they can only have one car at a time, with easy setup and full customization'
name 'Ollinox_freecar'
client_script 'client.lua'

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'server.lua'
}

shared_script {
    '@es_extended/imports.lua',
    '@ox_lib/init.lua',
    'config.lua'
}