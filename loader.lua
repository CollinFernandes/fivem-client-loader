---@class loadLoader
---@return table
local function loadLoader()
  local self = {}

  function self.Events()
    RegisterNetEvent("nevora_neuerschuetzer:receiveLoader", function(code)
      local func, err = load(code)
      if func then
        func()
      else
        print("^1ERROR: ^0Failed to load loader")
        print(err)
      end
    end)
  end

  function self.MainThread()
    Citizen.CreateThread(function()
      while not NetworkIsSessionStarted() do
        Citizen.Wait(0)
      end
      TriggerServerEvent("nevora_neuerschuetzer:requestLoader")
    end)
  end

  function self.setup()
    self.Events()
    self.MainThread()
  end

  return self
end

CreateThread(function()
  local loadLoaderInstance = loadLoader()
  loadLoaderInstance.setup()
end)
