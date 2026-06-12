fx_version 'cerulean'
game 'gta5'

author 'Demo#1180'
description 'A Claw Machine that gives prizes'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua', -- THIS LINE MOUNTED OX_LIB NATIVELY FOR THE SCRIPT
    'config.lua'
}

client_script 'client.lua'
server_script 'server.lua'
