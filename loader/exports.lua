function NEVORA:BitXOR(a, b)
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
end

function NEVORA:Dec2Hex(val)
  if val >= 0 and val < 16 then
    return string.format("0%X", tonumber(val))
  elseif val > 15 and val < 128 then
    return string.format("%X", tonumber(val))
  elseif val == 0 then
    return "00"
  elseif val < 0 and val > -128 then
    return string.sub(string.format("%X", tostring(val)), 15)
  end
end

function XORDecode(sentData, sentKey)
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
      table.insert(Answer, string.char(NEVORA:BitXOR(tonumber(c, 16), key)))
    end
  else
    for i, c in ipairs(sentData) do
      local key = Keys[KeyIndex]
      KeyIndex = Keys[KeyIndex + 1] and KeyIndex + 1 or 1
      table.insert(Answer, string.char(NEVORA:BitXOR(tonumber(c, 16), key)))
    end
  end
  return Answer, table.concat(Answer, "")
end

XOREncode = function(sentString, sentKey, customSpace)
  local Answer = {}
  local Keys = {}
  local KeyIndex = 1
  for c in sentKey:gmatch "." do
    table.insert(Keys, string.byte(c))
  end
  for c in sentString:gmatch "." do
    local key = Keys[KeyIndex]
    KeyIndex = Keys[KeyIndex + 1] and KeyIndex + 1 or 1
    table.insert(Answer, NEVORA:Dec2Hex(NEVORA:BitXOR(string.byte(c), key)))
  end
  -- return Answer, table.concat(Answer, customSpace or " ")
  return table.concat(Answer, customSpace or " ")
end
exports("XOREncode", XOREncode)
exports("XORDecode", XORDecode)
exports("randomString", function(length)
  math.randomseed(os.time())
  local alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
  local res = ""
  for i = 1, length do
    res = res .. string.char(alphabet:byte(math.random(#alphabet)))
  end
  return res
end)
