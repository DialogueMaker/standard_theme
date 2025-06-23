--!strict

local packages = script.Parent.Parent.Parent.roblox_packages;
local React = require(packages.react);

local function useSetting<Settings>(...: Settings)
  
  local dialogueSetting, conversationSetting, clientSetting = ...;

  return React.useMemo(function()
  
    return if dialogueSetting ~= nil then dialogueSetting elseif conversationSetting ~= nil then conversationSetting else clientSetting;

  end, {dialogueSetting :: unknown, conversationSetting, clientSetting});

end;

return useSetting;