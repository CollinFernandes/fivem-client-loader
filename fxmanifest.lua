fx_version 'cerulean'
game 'gta5'

author 'CollinFernandes'
description 'secured FiveM Client Loader'

shared_scripts {
  'define.lua',
}

server_scripts {
  'loader/loadLoader.lua',
  'loader/dist/**',
  'loader/exports.lua',
  'server/**',
}

client_scripts {
  'loader.lua'
}
