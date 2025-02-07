---@class LoadLoader
---@return table
local function LoadLoader()
  local self = {}
  self.loadedPlayers = {}

  function self.Events()
    RegisterNetEvent('clientLoader:requestLoader', function()
      if (not self.loadedPlayers[source]) then
        local code = LoadResourceFile(GetCurrentResourceName(), 'loader/loader.lua')
        self.loadedPlayers[source] = true
        TriggerClientEvent('clientLoader:receiveLoader', source, code)
      else
        print("^1ERROR: ^0Player already loaded " .. source)
      end
    end)
  end

  function self.setup()
    self.Events()
  end

  return self
end

CreateThread(function()
  local loadLoaderInstance = LoadLoader()
  loadLoaderInstance.setup()
end)
