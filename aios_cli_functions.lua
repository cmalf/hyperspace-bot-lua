#!/usr/bin/env lua

--------------------------------------------------------
--                                                     -
--  CODE  : Hyperspace-Cli Bot v1.0                    -
--  LUA   : v5.4.7                                     -
--  Author: Furqonflynn (cmalf)                        -
--  TG    : https://t.me/furqonflynn                   -
--  GH    : https://github.com/cmalf                   -
--                                                     -
--------------------------------------------------------

-- This code is open-source and welcomes contributions! 
-- 
-- If you'd like to add features or improve this code, please follow these steps:
-- 1. Fork this repository to your own GitHub account.
-- 2. Make your changes in your forked repository.
-- 3. Submit a pull request to the original repository. 
-- 
-- This allows me to review your contributions and ensure the codebase maintains high quality. 
-- 
-- Let's work together to improve this project!
-- 
-- P.S. Remember to always respect the original author's work and avoid plagiarism. 
-- Let's build a community of ethical and collaborative developers.
-- ------------------------------------------------------

local io = io
local os = os
local string = string
local math = math
local Colors = require("colors")
local helpers = require("helpers")

local trim = helpers.trim
local humanize_bytes = helpers.humanize_bytes
local processAvailableLine = helpers.processAvailableLine
local clearConsole = helpers.clearConsole
local promptEnter = helpers.promptEnter
local promptEnterCustom = helpers.promptEnterCustom
local runCommand = helpers.runCommand
local exec = helpers.exec
local prompt = helpers.prompt


-- Function to check if aios-cli is installed
local function checkAiosCliInstalled(callback)
  exec("which aios-cli", function(error, stdout, _)
    if error or trim(stdout) == "" then
      callback(false)
      return
    end
    callback(true)
  end)
end

-- Function to install aios-cli automatically
local function installAiosCli(callback)
  print(Colors.Yellow .. "Installing aios-cli..." .. Colors.Reset)
  runCommand('curl https://download.hyper.space/api/install | sh', function()
    print(Colors.Green .. "aios-cli installation process finished." .. Colors.Reset)
    -- Give a short delay for installation to settle
    os.execute("sleep 2")
    callback()
  end)
end

-- -------------------------------------------
-- Helper: Run Hive Inference Logic
-- -------------------------------------------
local function runHiveInfer(callback)
  -- Automatically run the "registered" command as in Hive submenu option 8
  exec('aios-cli hive registered', function(error, stdout, stderr)
    if error then
      io.stderr:write(Colors.Red .. "Error retrieving registered models: " .. (stderr ~= "" and stderr or error) .. Colors.Reset .. "\n")
      promptEnter(callback)
      return
    end

    -- Split and filter out unnecessary lines
    local models = {}
    for line in (stdout .. "\n"):gmatch("(.-)\n") do
      local trimmed = trim(line)
      if trimmed ~= "" and not trimmed:find("^Found") then
        table.insert(models, trimmed)
      end
    end

    if #models == 0 then
      -- No registered models found; ask user to input identifier manually.
      print(Colors.Yellow .. "No registered models found." .. Colors.Reset)
      local modelName = prompt("Enter the model identifier for hive inference: ")
      local promptText = prompt("Enter the prompt text: ")
      if modelName ~= "" and promptText ~= "" then
        runCommand('aios-cli hive infer --model ' .. modelName .. ' --prompt "' .. promptText .. '"', callback)
      else
        print(Colors.Red .. "Both model identifier and prompt are required." .. Colors.Reset)
        promptEnter(callback)
      end
    elseif #models == 1 then
      -- Only one model registered; auto-select it.
      print(Colors.Green .. "Automatically selected model:" .. Colors.Reset .. " " .. models[1])
      local promptText = prompt("Enter the prompt text: ")
      if promptText ~= "" then
        runCommand('aios-cli hive infer --model ' .. models[1] .. ' --prompt "' .. promptText .. '"', callback)
      else
        print(Colors.Red .. "Prompt text is required." .. Colors.Reset)
        promptEnter(callback)
      end
    else
      -- Multiple models registered; let the user choose one.
      print(Colors.Green .. "Multiple registered models found. Please select one:" .. Colors.Reset)
      for index, model in ipairs(models) do
        print(Colors.Gold .. tostring(index) .. "." .. Colors.Reset .. " " .. model)
      end
      local choiceIndex = prompt("Enter your choice (number): ")
      local index = tonumber(choiceIndex)
      if index and index >= 1 and index <= #models then
        local selectedModel = models[index]
        local promptText = prompt("Enter the prompt text: ")
        if promptText ~= "" then
          runCommand('aios-cli hive infer --model ' .. selectedModel .. ' --prompt "' .. promptText .. '"', callback)
        else
          print(Colors.Red .. "Prompt text is required." .. Colors.Reset)
          promptEnter(callback)
        end
      else
        print(Colors.Red .. "Invalid selection." .. Colors.Reset)
        promptEnter(callback)
      end
    end
  end)
end

-- Helper function: Add Model with error handling for unexpected argument errors.
local function addModel(modelArg, callback)
  -- Use exec to capture output/errors from aios-cli models add command
  exec("aios-cli models add " .. modelArg, function(err, output, errOutput)
    if err then
      -- Check if the error output contains the 'unexpected argument' message
      if output:find("unexpected argument") then
        print(Colors.Yellow .. "Error detected: " .. trim(output) .. Colors.Reset)
        print(Colors.Yellow .. "It seems there is an unexpected argument error. " ..
              "Please enter the model identifier manually in the following format:" .. Colors.Reset)
        print(Colors.Bright .. "(e.g., hf:Qwen/qwen2.5-coder-1.5b-instruct-GGUF:qwen2.5-coder-1.5b-instruct-q4_k_m.gguf )" .. Colors.Reset)
        local manualModel = prompt("Enter the model identifier to add: ")
        if manualModel ~= "" then
          runCommand("aios-cli models add " .. manualModel, callback)
        else
          print(Colors.Red .. "Model identifier is required." .. Colors.Reset)
          promptEnter(callback)
        end
      else
        io.stderr:write(Colors.Red .. "Error adding model: " .. trim(output) .. Colors.Reset .. "\n")
        promptEnter(callback)
      end
    else
      print(Colors.Green .. "Model added successfully." .. Colors.Reset)
      promptEnter(callback)
    end
  end)
end

-- -------------------------------------------
-- Helper: List Available Models with Size Conversion
-- This function captures the output of 'aios-cli models available', converts any size values,
-- and prints the processed table.
-- -------------------------------------------
local function listAvailableModels(callback)
  exec('aios-cli models available', function(error, stdout, stderr)
    if error then
      io.stderr:write(Colors.Red .. "Error retrieving available models: " .. (stderr ~= "" and stderr or error) .. Colors.Reset .. "\n")
      promptEnter(callback)
      return
    end
    for line in (stdout .. "\n"):gmatch("(.-)\n") do
      local processed = processAvailableLine(line)
      print(processed)
    end
    if callback then
      promptEnter(callback)
    end
  end)
end

-- Helper: Add Model with Available List
local function addModelWithList(callback)
  exec('aios-cli models available', function(error, stdout, stderr)
    if error then
      io.stderr:write(Colors.Red .. "Error retrieving available models: " ..
          (stderr ~= "" and stderr or error) .. Colors.Reset .. "\n")
      promptEnter(callback)
      return
    end

    -- Split and filter output to get a list of models
    local models = {}
    for line in (stdout .. "\n"):gmatch("(.-)\n") do
      local trimmed = trim(line)
      if trimmed ~= "" then
        table.insert(models, trimmed)
      end
    end

    if #models == 0 then
      print(Colors.Yellow .. "No available models found." .. Colors.Reset)
      -- As a fallback, ask for manual input.
      local modelName = prompt("Enter the model identifier to add: ")
      if modelName ~= "" then
        addModel(modelName, callback)
      else
        print(Colors.Red .. "Model identifier is required." .. Colors.Reset)
        promptEnter(callback)
      end
    elseif #models == 1 then
      -- Only one available model; auto-select it.
      print(Colors.Green .. "Automatically selected model:" .. Colors.Reset .. " " .. processAvailableLine(models[1]))
      addModel(models[1], callback)
    else
      -- Multiple available models; let the user choose one.
      print(Colors.Green .. "Available models:" .. Colors.Reset)
      for index, model in ipairs(models) do
        print(Colors.Gold .. tostring(index) .. "." .. Colors.Reset .. " " .. processAvailableLine(model))
      end
      local choiceIndex = prompt("Enter your choice (number): ")
      local index = tonumber(choiceIndex)
      if index and index >= 1 and index <= #models then
        local selectedModel = models[index]
        addModel(selectedModel, callback)
      else
        print(Colors.Red .. "Invalid selection." .. Colors.Reset)
        promptEnter(callback)
      end
    end
  end)
end

-- -------------------------------------------
-- Helper: Remove Model Logic
-- This function first lists downloaded models (aios-cli models list) and then
-- allows the user to select which one to remove.
-- If only one model is found, it asks for confirmation before removal.
-- -------------------------------------------
local function removeModel(callback)
  exec('aios-cli models list', function(error, stdout, stderr)
    if error then
      io.stderr:write(Colors.Red .. "Error retrieving downloaded models: " .. (stderr ~= "" and stderr or error) .. Colors.Reset .. "\n")
      promptEnter(callback)
      return
    end

    -- Parse the output to get a list of models.
    local models = {}
    for line in (stdout .. "\n"):gmatch("(.-)\n") do
      local trimmed = trim(line)
      if trimmed ~= "" then
        table.insert(models, trimmed)
      end
    end

    if #models == 0 then
      print(Colors.Yellow .. "No downloaded models found." .. Colors.Reset)
      promptEnter(callback)
    elseif #models == 1 then
      print(Colors.Green .. "Only one downloaded model found:" .. Colors.Reset .. " " .. models[1])
      local answer = prompt("Are you sure you want to remove this model? (y/n): ")
      if answer:lower() == "y" then
        runCommand("aios-cli models remove " .. models[1], callback)
      else
        print(Colors.Yellow .. "Operation cancelled." .. Colors.Reset)
        promptEnter(callback)
      end
    else
      print(Colors.Green .. "Downloaded models:" .. Colors.Reset)
      for index, model in ipairs(models) do
        print(Colors.Gold .. tostring(index) .. "." .. Colors.Reset .. " " .. model)
      end
      local choiceIndex = prompt("Enter the number of the model to remove: ")
      local index = tonumber(choiceIndex)
      if index and index >= 1 and index <= #models then
        local selectedModel = models[index]
        runCommand("aios-cli models remove " .. selectedModel, callback)
      else
        print(Colors.Red .. "Invalid selection." .. Colors.Reset)
        promptEnter(callback)
      end
    end
  end)
end

return {
  checkAiosCliInstalled = checkAiosCliInstalled,
  installAiosCli = installAiosCli,
  runHiveInfer = runHiveInfer,
  addModel = addModel,
  listAvailableModels = listAvailableModels,
  addModelWithList = addModelWithList,
  removeModel = removeModel,
}