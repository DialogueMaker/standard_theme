--!strict

local packages = script.Parent.Parent.Parent.Parent.Parent.Parent.Parent.roblox_packages;
local React = require(packages.react);

local function useSkipPageSignal(skipPageSignal: RBXScriptSignal, setShouldSkip: (boolean) -> ())
  
  React.useEffect(function(): ()

    local skipPageConnection = skipPageSignal:Once(function()

      setShouldSkip(true);

    end);

    return function()

      skipPageConnection:Disconnect();

    end;

  end, {skipPageSignal});

end

return useSkipPageSignal;