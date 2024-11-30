fx_version 'adamant'
author '0ms WorkShop'
game 'gta5'

shared_script 'resource/config.lua'
client_script 'resource/client.lua'

server_script {
    '@oxmysql/lib/MySQL.lua',
    'resource/server.lua',
}

ui_page 'source/index.html'

files {
    'source/images/*.png',
    'source/images/*.svg',
    'source/sounds/*.mp3',
    'source/index.html',
    'source/style.css',
    'source/script.js'
}