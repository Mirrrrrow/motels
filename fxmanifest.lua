fx_version 'cerulean'
game 'gta5'
use_experimental_fxv2_oal 'yes'
lua54 'yes'

author 'mirow'
description 'Motel Script'
license 'GNU General Public License v3.0'
version '0.0.0'

dependencies {
    'es_extended',
    'oxmysql',
    'ox_lib',
    'ox_target'
}

shared_scripts {
    '@es_extended/imports.lua',
    '@ox_lib/init.lua'
}

client_script 'init.lua'

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'init.lua'
}

files {
    'locales/*.json',
    'data/*.lua',
    'client.lua',
    'modules/**/client.lua',
    'modules/**/shared.lua'
}