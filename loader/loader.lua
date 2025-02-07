---@class Loader
---@return table
local function Loader()
  local self = {}
  self.loadedScripts = {}
  self.resource = GetCurrentResourceName()
  self.privateKey = nil
  self.publicKey =
  "eTrsWztKYrDv69cRJ47f2QTbLsJV9R2eeF6vkxtSVBjrHCKuk7hSQ8QTudWmx5GaxXQCNdhxfujDxJmmyGSCCZus8mnYprdt8CPZWZHm4pGyvGgyQ3vJByCnbfExZA5AQqazXr4fgwdVHuzNupGUgXHNf3Rg4pQmEbBPuTPSTTqXdmW6uxCUjNDs9whw2jf4px6yESDkA7vmAu3jzUXL3vGFHJ53HcK2pDAvLAyqmKDyY25pmV34fHu83rXg8WUPD8sjh4LMsR4MWKzmEGDquGnCc2Bk2q2rPDYfGRHwfTbDtVqCeSBqZjq7C3xLLjjBqjs4JrC7jdQDYPZDq7M9ffq4ASgSpDmwHFmQfjXUKN9g4FecTngbAsCyW6xkar2GDJeWAT3M3HPRvJNA7H4k2DcJm2ftdM82yUwmqgfXfXhdsKF9bjzHFWftXj6JYsJwaS8zEGzA9w5v6LwUkxhfmkzbBUpgw3YWzzwJu3TUUYUTv3ENBVVFJNFdqPKQvQh6"
  self.functions = {
    BitXOR = function(a, b)
      local p, c = 1, 0
      while a > 0 and b > 0 do
        local ra, rb = a % 2, b % 2
        if ra ~= rb then c = c + p end
        a, b, p = (a - ra) / 2, (b - rb) / 2, p * 2
      end
      if a < b then a = b end
      while a > 0 do
        local ra = a % 2
        if ra > 0 then c = c + p end
        a, p = (a - ra) / 2, p * 2
      end
      return c
    end,
    Dec2Hex = function(val)
      if val >= 0 and val < 16 then
        return string.format("0%X", tonumber(val))
      elseif val > 15 and val < 128 then
        return string.format("%X", tonumber(val))
      elseif val == 0 then
        return "00"
      elseif val < 0 and val > -128 then
        return string.sub(string.format("%X", tostring(val)), 15)
      end
    end,
    XORDecode = function(sentData, sentKey)
      local Answer = {}
      local Keys = {}
      local KeyIndex = 1
      for c in sentKey:gmatch "." do
        table.insert(Keys, string.byte(c))
      end
      if type(sentData) == "string" then
        for c in (sentData .. (" ")):gmatch("(.-)" .. (" ")) do
          local key = Keys[KeyIndex]
          KeyIndex = Keys[KeyIndex + 1] and KeyIndex + 1 or 1
          table.insert(Answer, string.char(self.functions.BitXOR(tonumber(c, 16), key)))
        end
      else
        for i, c in ipairs(sentData) do
          local key = Keys[KeyIndex]
          KeyIndex = Keys[KeyIndex + 1] and KeyIndex + 1 or 1
          table.insert(Answer, string.char(self.functions.BitXOR(tonumber(c, 16), key)))
        end
      end
      return Answer, table.concat(Answer, "")
    end,
    tableContains = function(table, value)
      for _, v in pairs(table) do
        if v == value then
          return true
        end
      end
      return false
    end,
  }

  function self.Events()
    RegisterNetEvent('clientLoader:receiveKey', function(key)
      local _, decryptedKey = self.functions.XORDecode(key, self.publicKey)
      self.privateKey = decryptedKey
    end)

    RegisterNetEvent('clientLoader:receiveScript', function(scriptName, scriptIndex, scriptContent, typeString)
      local _, script = self.functions.XORDecode(scriptContent, self.privateKey)

      if (self.functions.tableContains(self.loadedScripts, scriptName)) then
        print(string.format("^1ERROR: ^0%s %s already loaded (%s)", typeString, scriptName, scriptIndex))
        return
      end

      local success, result = pcall(function()
        local scriptFunction = load(script)

        if not scriptFunction then
          print(string.format("^1ERROR: ^0Failed to load script %s", scriptName))
          return
        end

        scriptFunction()
      end)

      if (not success) then
        print(string.format("^1ERROR: ^0Failed to load %s %s (%s)", typeString, scriptName, scriptIndex))
        return
      end

      print(string.format("^2SUCCESS: ^0Loaded %s %s successfully (%s)", typeString, scriptName, scriptIndex))
      table.insert(self.loadedScripts, scriptName);
    end)
  end

  function self.getKey()
    Citizen.CreateThread(function()
      while self.privateKey == nil do
        TriggerServerEvent("clientLoader:requestKey")
        Wait(200)
      end
    end)
  end

  function self.setup()
    self.getKey()
    self.Events()
  end

  return self
end

CreateThread(function()
  local loaderInstance = Loader()
  loaderInstance.setup()
end)
