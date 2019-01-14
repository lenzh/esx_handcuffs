resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

description 'Handcuff script modified by Lenzh'

client_script {
  '@es_extended/locale.lua',
  'locales/en.lua',
  'locales/pl.lua',
  'config.lua',
  'client/main.lua'
}


server_script {
  '@es_extended/locale.lua',
  'locales/en.lua',
  'locales/pl.lua',
  'config.lua',
  'server/main.lua'
}
