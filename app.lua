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
local aios_cli = require("aios_cli_functions")

local trim = helpers.trim
local humanize_bytes = helpers.humanize_bytes
local processAvailableLine = helpers.processAvailableLine
local clearConsole = helpers.clearConsole
local promptEnter = helpers.promptEnter
local promptEnterCustom = helpers.promptEnterCustom
local runCommand = helpers.runCommand
local exec = helpers.exec
local prompt = helpers.prompt

local checkAiosCliInstalled = aios_cli.checkAiosCliInstalled
local installAiosCli = aios_cli.installAiosCli
local runHiveInfer = aios_cli.runHiveInfer
local addModel = aios_cli.addModel
local listAvailableModels = aios_cli.listAvailableModels
local addModelWithList = aios_cli.addModelWithList
local removeModel = aios_cli.removeModel

-- Global variable to hold the background daemon process
local daemonProcess = nil

-- Reset the aios.log file at the start of each script run.
local log_file, err = io.open("aios.log", "w")
if log_file then
  log_file:close()
else
  io.stderr:write("Failed to reset aios.log: " .. tostring(err) .. "\n")
end

-- Check if platform is supported (Linux or macOS)
local handle_platform = io.popen("uname")
local platform = handle_platform:read("*l")
handle_platform:close()
platform = platform:lower()
if platform ~= "linux" and platform ~= "darwin" then
  io.stderr:write(Colors.Red .. "This script only supports Linux and macOS." .. Colors.Reset .. "\n")
  os.exit(1)
end

-- -------------------------------------------
-- Coder Sign
-- -------------------------------------------
local function CoderMark()
    print("\n" ..
"╭━━━╮╱╱╱╱╱╱╱╱╱╱╱╱╱╭━━━┳╮\n" ..
"┃╭━━╯╱╱╱╱╱╱╱╱╱╱╱╱╱┃╭━━┫┃" .. Colors.Green .. "\n" ..
"┃╰━━┳╮╭┳━┳━━┳━━┳━╮┃╰━━┫┃╭╮╱╭┳━╮╭━╮\n" ..
"┃╭━━┫┃┃┃╭┫╭╮┃╭╮┃╭╮┫╭━━┫┃┃┃╱┃┃╭╮┫╭╮╮" .. Colors.Blue .. "\n" ..
"┃┃╱╱┃╰╯┃┃┃╰╯┃╰╯┃┃┃┃┃╱╱┃╰┫╰━╯┃┃┃┃┃┃┃\n" ..
"╰╯╱╱╰━━┻╯╰━╮┣━━┻╯╰┻╯╱╱╰━┻━╮╭┻╯╰┻╯╰╯" .. Colors.Reset .. "\n" ..
"╱╱╱╱╱╱╱╱╱╱╱┃┃╱╱╱╱╱╱╱╱╱╱╱╭━╯┃" .. Colors.Blue .. "{" .. Colors.Neon .. "cmalf" .. Colors.Blue .. "}" .. Colors.Reset .. "\n" ..
"╱╱╱╱╱╱╱╱╱╱╱╰╯╱╱╱╱╱╱╱╱╱╱╱╰━━╯\n\n" ..
Colors.Reset .. "HyperSpace " .. Colors.Gold .. "LUA " .. Colors.Blue .. "{ " .. Colors.Neon .. "aios-cli" .. Colors.Blue .. " }" .. Colors.Reset .. "\n    \n" ..
Colors.Green .. string.rep("―", 50) .. "\n    \n" ..
Colors.Gold .. "[+]" .. Colors.Reset .. " DM : " .. Colors.Teal .. "https://t.me/furqonflynn" .. "\n    \n" ..
Colors.Gold .. "[+]" .. Colors.Reset .. " GH : " .. Colors.Teal .. "https://github.com/cmalf/" .. "\n    \n" ..
Colors.Gold .. "[+]" .. Colors.Reset .. " BOT: " .. Colors.Blue .. "{ " .. Colors.Neon .. "HyperSpace-Cli v1.0" .. Colors.Blue .. " } " .. Colors.Reset .. Colors.Blue .. "{ " .. Colors.Gold .. "Lua v5.4.7" .. Colors.Blue .. " } " .. Colors.Reset .. "\n    \n" ..
Colors.Green .. string.rep("―", 50) .. Colors.Reset .. "\n")
end

-- -------------------------------------------
-- Hive Commands Sub Menu
-- -------------------------------------------
local function hiveMenu()
  clearConsole()
  CoderMark()
  print(Colors.Reset .. "\n=== " .. Colors.Neon .. "HIVE Commands Submenu" .. Colors.Reset .. " ===\n")
  print(Colors.Gold .. "1." .. Colors.Reset .. "  Hive: Login               " .. Colors.Neon .. "]>" .. Colors.Teal .. " aios-cli hive login" .. Colors.Reset)
  print(Colors.Gold .. "2." .. Colors.Reset .. "  Hive: Import keys         " .. Colors.Neon .. "]>" .. Colors.Teal .. " aios-cli hive import-keys <filepath>" .. Colors.Reset)
  print(Colors.Gold .. "3." .. Colors.Reset .. "  Hive: Connect             " .. Colors.Neon .. "]>" .. Colors.Teal .. " aios-cli hive connect" .. Colors.Reset)
  print(Colors.Gold .. "4." .. Colors.Reset .. "  Hive: Registered          " .. Colors.Neon .. "]>" .. Colors.Teal .. " aios-cli hive registered" .. Colors.Reset)
  print(Colors.Gold .. "5." .. Colors.Reset .. "  Hive: Reregister          " .. Colors.Neon .. "]>" .. Colors.Teal .. " aios-cli hive reregister" .. Colors.Reset)
  print(Colors.Gold .. "6." .. Colors.Reset .. "  Hive: Whoami              " .. Colors.Neon .. "]>" .. Colors.Teal .. " aios-cli hive whoami" .. Colors.Reset)
  print(Colors.Gold .. "7." .. Colors.Reset .. "  Hive: Disconnect          " .. Colors.Neon .. "]>" .. Colors.Teal .. " aios-cli hive disconnect" .. Colors.Reset)
  print(Colors.Gold .. "8." .. Colors.Reset .. "  Hive: Infer               " .. Colors.Neon .. "]>" .. Colors.Teal .. " aios-cli hive infer --model <model> --prompt \"<text>\"" .. Colors.Reset)
  print(Colors.Gold .. "9." .. Colors.Reset .. "  Hive: Listen              " .. Colors.Neon .. "]>" .. Colors.Teal .. " aios-cli hive listen" .. Colors.Reset)
  print(Colors.Gold .. "10." .. Colors.Reset .. " Hive: Interrupt           " .. Colors.Neon .. "]>" .. Colors.Teal .. " aios-cli hive interrupt" .. Colors.Reset)
  print(Colors.Gold .. "11." .. Colors.Reset .. " Hive: Select-tier         " .. Colors.Neon .. "]>" .. Colors.Teal .. " aios-cli hive select-tier <tier>" .. Colors.Reset)
  print(Colors.Gold .. "12." .. Colors.Reset .. " Hive: Allocate            " .. Colors.Neon .. "]>" .. Colors.Teal .. " aios-cli hive allocate" .. Colors.Reset)
  print(Colors.Gold .. "13." .. Colors.Reset .. " Hive: Points              " .. Colors.Neon .. "]>" .. Colors.Teal .. " aios-cli hive points" .. Colors.Reset)
  print(Colors.Gold .. "14." .. Colors.Reset .. " Hive: Rounds              " .. Colors.Neon .. "]>" .. Colors.Teal .. " aios-cli hive rounds" .. Colors.Reset)
  print(Colors.Gold .. "15." .. Colors.Reset .. " Hive: Help                " .. Colors.Neon .. "]>" .. Colors.Teal .. " aios-cli hive help" .. Colors.Reset)
  print(Colors.Gold .. "0." .. Colors.Reset .. "  Return to Main Menu")

  local choice = prompt("\nSelect a Hive option: ")
  if choice == '1' then
      runCommand("aios-cli hive login", hiveMenu)
  elseif choice == '2' then
      local keyFile = prompt("Enter the file path for your key (.pem or .base58): ")
      if keyFile ~= "" then
        runCommand("aios-cli hive import-keys " .. keyFile, hiveMenu)
      else
        print(Colors.Red .. "File path is required." .. Colors.Reset)
        promptEnter(hiveMenu)
      end
  elseif choice == '3' then
      runCommand("aios-cli hive connect", hiveMenu)
  elseif choice == '4' then
      runCommand("aios-cli hive registered", hiveMenu)
  elseif choice == '5' then
      runCommand("aios-cli hive reregister", hiveMenu)
  elseif choice == '6' then
      runCommand("aios-cli hive whoami", hiveMenu)
  elseif choice == '7' then
      runCommand("aios-cli hive disconnect", hiveMenu)
  elseif choice == '8' then
      runHiveInfer(hiveMenu)
  elseif choice == '9' then
      runCommand("aios-cli hive listen", hiveMenu)
  elseif choice == '10' then
      runCommand("aios-cli hive interrupt", hiveMenu)
  elseif choice == '11' then
      local tier = prompt("Enter the tier (e.g., 5,4,3,2,or,1): ")
      if tier ~= "" then
        runCommand("aios-cli hive select-tier " .. tier, hiveMenu)
      else
        print(Colors.Red .. "Tier selection is required." .. Colors.Reset)
        promptEnter(hiveMenu)
      end
  elseif choice == '12' then
      runCommand("aios-cli hive allocate", hiveMenu)
  elseif choice == '13' then
      runCommand("aios-cli hive points", hiveMenu)
  elseif choice == '14' then
      runCommand("aios-cli hive rounds", hiveMenu)
  elseif choice == '15' then
      runCommand("aios-cli hive help", hiveMenu)
  elseif choice == '0' then
      clearConsole()
      menu()
  else
      print(Colors.Red .. "Invalid option." .. Colors.Reset)
      promptEnter(hiveMenu)
  end
end

-- -------------------------------------------
-- Main Menu
-- -------------------------------------------
function menu()
  clearConsole()
  CoderMark()
  print(Colors.Reset .. "\n===" .. Colors.Neon .. " aios-cli Bot Menu " .. Colors.Reset .. "===\n")
  
  print(Colors.Gold .. "1." .. Colors.Reset .. "  Start daemon           " .. Colors.Neon .. "]>" .. Colors.Teal .. " (aios-cli start)" .. Colors.Reset)
  print(Colors.Gold .. "2." .. Colors.Reset .. "  Check daemon status    " .. Colors.Neon .. "]>" .. Colors.Teal .. " (aios-cli status)" .. Colors.Reset)
  print(Colors.Gold .. "3." .. Colors.Reset .. "  Kill daemon            " .. Colors.Neon .. "]>" .. Colors.Teal .. " (aios-cli kill)" .. Colors.Reset)
  print(Colors.Gold .. "4." .. Colors.Reset .. "  List downloaded models " .. Colors.Neon .. "]>" .. Colors.Teal .. " (aios-cli models list)" .. Colors.Reset)
  print(Colors.Gold .. "5." .. Colors.Reset .. "  Add a model            " .. Colors.Neon .. "]>" .. Colors.Teal .. " List available models then add selected" .. Colors.Reset)
  print(Colors.Gold .. "6." .. Colors.Reset .. "  Remove a model         " .. Colors.Neon .. "]>" .. Colors.Teal .. " (aios-cli models remove <model>)" .. Colors.Reset)
  print(Colors.Gold .. "7." .. Colors.Reset .. "  List available models  " .. Colors.Neon .. "]>" .. Colors.Teal .. " (aios-cli models available)" .. Colors.Reset)
  print(Colors.Gold .. "8." .. Colors.Reset .. "  Show system info       " .. Colors.Neon .. "]>" .. Colors.Teal .. " (aios-cli system-info)" .. Colors.Reset)
  print(Colors.Gold .. "9." .. Colors.Reset .. "  Run inference          " .. Colors.Neon .. "]>" .. Colors.Teal .. " (aios-cli hive infer ...)+ auto registered" .. Colors.Reset)
  print(Colors.Gold .. "10." .. Colors.Reset .. " Show version           " .. Colors.Neon .. "]>" .. Colors.Teal .. " (aios-cli version)" .. Colors.Reset)
  print(Colors.Gold .. "11." .. Colors.Reset .. " Hive Submenu           " .. Colors.Neon .. "]>" .. Colors.Teal .. " (Hive related commands)" .. Colors.Reset)
  print(Colors.Gold .. "12." .. Colors.Reset .. " Uninstall              " .. Colors.Neon .. "]>" .. Colors.Teal .. " curl https://download.hyper.space/api/uninstall | sh" .. Colors.Reset)
  print(Colors.Gold .. "0." .. Colors.Reset .. "  Exit")

  local choice = prompt("\nSelect an option: ")
  if choice == '1' then
    -- Start daemon with output redirected to a log file to avoid flexi_logger errors.
    if daemonProcess then
      print(Colors.Yellow .. "Daemon is already running in the background." .. Colors.Reset)
      promptEnter(menu)
    else
      local handle = io.popen("aios-cli start --connect >> aios.log 2>&1 & echo $!")
      local pid_str = handle:read("*l") or ""
      handle:close()
      daemonProcess = tonumber(pid_str)
      print(Colors.Green .. "Daemon started in the background. Logs are appended to aios.log." .. Colors.Reset)
      promptEnter(menu)
    end
  elseif choice == '2' then
    runCommand("aios-cli status", menu)
  elseif choice == '3' then
    -- Kill the background daemon using 'pkill -f aios'
    if daemonProcess then
      runCommand("pkill -f aios", function()
        print(Colors.Green .. "Background daemon process has been killed." .. Colors.Reset)
        daemonProcess = nil
        promptEnter(menu)
      end)
    else
      print(Colors.Yellow .. "No background daemon process is currently running." .. Colors.Reset)
      promptEnter(menu)
    end
  elseif choice == '4' then
    runCommand("aios-cli models list", menu)
  elseif choice == '5' then
    addModelWithList(menu)
  elseif choice == '6' then
    removeModel(menu)
  elseif choice == '7' then
    runCommand("aios-cli models available", menu)
  elseif choice == '8' then
    runCommand("aios-cli system-info", menu)
  elseif choice == '9' then
    runHiveInfer(menu)
  elseif choice == '10' then
    runCommand("aios-cli version", menu)
  elseif choice == '11' then
    hiveMenu()
  elseif choice == '12' then
    -- Uninstallation using the specified endpoint.
    runCommand("curl https://download.hyper.space/api/uninstall | sh", menu)
  elseif choice == '0' then
    print(Colors.Green .. "Exiting..." .. Colors.Reset)
    os.exit(0)
  else
    print(Colors.Red .. "Invalid option." .. Colors.Reset)
    promptEnter(menu)
  end
end

-- Main execution flow: Check if the aios-cli tool is installed, and install it if missing.
checkAiosCliInstalled(function(installed)
  if not installed then
    -- Automatically install aios-cli if it's missing.
    installAiosCli(function()
      -- After installation, verify before starting the menu.
      checkAiosCliInstalled(function(installedAfter)
        if not installedAfter then
          io.stderr:write(Colors.Red .. "aios-cli installation failed. Exiting." .. Colors.Reset .. "\n")
          os.exit(1)
        else
          print(Colors.Green .. "aios-cli installed successfully." .. Colors.Reset)
          promptEnter(menu)
        end
      end)
    end)
  else
    menu()
  end
end)