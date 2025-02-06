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

-- Helper function to trim whitespace
local function trim(s)
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end

-- Helper function to convert a size in bytes into a human-readable string
local function humanize_bytes(n)
  if n >= 1073741824 then
    return string.format("%.2f GB", n / 1073741824)
  elseif n >= 1048576 then
    return string.format("%.2f MB", n / 1048576)
  elseif n >= 1024 then
    return string.format("%.2f KB", n / 1024)
  else
    return tostring(n) .. " B"
  end
end

-- Helper function to process a line from the available models table.
local function processAvailableLine(line)
  if not line:find("│") then 
    return line 
  end
  local fields = {}
  -- Split the line into fields based on the vertical bar delimiter.
  for field in line:gmatch("│([^│]+)") do
    table.insert(fields, field)
  end

  -- If there are no fields or not enough columns, return the original line.
  if #fields < 1 then 
    return line 
  end

  -- The last field is the size in bytes.
  local lastIndex = #fields
  local possibleSize = trim(fields[lastIndex])
  local sizeNum = tonumber(possibleSize)
  if sizeNum then
    fields[lastIndex] = " " .. humanize_bytes(sizeNum) .. " "
  end

  -- Reconstruct the line with the original vertical bar delimiters.
  local newLine = "│" .. table.concat(fields, "│") .. "│"
  return newLine
end

-- Helper function to clear the console
local function clearConsole()
  os.execute("clear")
end

-- Helper function to prompt user to press enter
local function promptEnter(callback)
  io.write(Colors.Teal .. Colors.Bright .. "\nEnter to return to the main menu..." .. Colors.Reset)
  io.read("*l")
  clearConsole()
  callback()
end

-- Helper function to prompt user to press enter with custom message
local function promptEnterCustom(message, callback)
  io.write(Colors.Blue .. message .. Colors.Reset)
  io.read("*l")
  clearConsole()
  callback()
end


-- Helper function to run shell commands and output logs with color.
local function runCommand(commandStr, onClose)
  -- Execute command with os.execute to inherit stdio.
  local res = os.execute(commandStr)
  if res ~= 0 then
    io.stderr:write(Colors.Red .. "Command exited with code " .. tostring(res) .. Colors.Reset .. "\n")
  end
  if type(onClose) == "function" then
    promptEnter(onClose)
  end
end

-- Helper
local function exec(command, callback)
  local process = io.popen(command .. " 2>&1")
  if not process then
    callback("Error executing command: " .. command, "", "")
    return
  end
  local stdout = process:read("*a")
  local ok, exit_reason, exit_code = process:close()
  if not ok then
    callback(true, stdout, stdout)
  else
    callback(nil, stdout, "")
  end
end

-- Helper function to prompt a question and return the answer (synchronously)
local function prompt(question)
  io.write(Colors.Cyan .. question .. Colors.Reset)
  local answer = io.read("*l") or ""
  return trim(answer)
end

return {
  trim = trim,
  humanize_bytes = humanize_bytes,
  processAvailableLine = processAvailableLine,
  clearConsole = clearConsole,
  promptEnter = promptEnter,
  promptEnterCustom = promptEnterCustom,
  runCommand = runCommand,
  exec = exec,
  prompt = prompt,
}
