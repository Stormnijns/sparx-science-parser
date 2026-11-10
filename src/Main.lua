local base64 = require("Modules/Base64")
local json = require("Modules/JSON")
local printTable = require("Modules/PrintTable")
local indexAll = require("Modules/IndexAll")
local questionParser = require("Modules/ParseQuestion")

io.write("Paste base64: ")
local input = io.read()
local result = base64(input)
local jsonString = ""

do
  local closeNextChance = false
  local read = false
  local escapeChar = false
  for i in result:gmatch'.' do
    if (jsonString:find('"marks":')) then
      closeNextChance = true
    end
    if closeNextChance and i == "]" then
      jsonString = jsonString .. i
      break
    end
    if i == "[" then
      read = true
    end
    if read then
      jsonString = jsonString .. i
    end
  end
end

local obj, pos, err = json.decode (jsonString, 1, nil)
if err then
  print ("\nError:", err)
  io.write("Press enter to see decoded data.")
  io.read()
  print(result)
else
  local data = questionParser(obj)
  for _, item in ipairs(data) do
    local prompt, question, answers = item["prompt"], item["question"]:gsub("\\n ", ""), item["answers"]
    print(("Prompt: %s\n\nQuestion: %s\n\nAnswers: %s\n\n=====================\n"):format(prompt, question, answers))
  end
end

io.write("[PROGRAM FINISHED] ")