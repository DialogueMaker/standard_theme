--!strict
-- Allow external scripts to skip pages and continue the dialogue outside of the theme.

local root = script.Parent.Parent.Parent.Parent.Parent;
local React = require(root.roblox_packages.react);
local DialogueMakerTypes = require(root.roblox_packages.DialogueMakerTypes);

type Client = DialogueMakerTypes.Client;

local function useContinueDialogueBindableFunction(client: Client, continueDialogue: () -> ())

  React.useEffect(function()
  
    client.continueDialogueBindableFunction.OnInvoke = continueDialogue;

    return function()

      client.continueDialogueBindableFunction.OnInvoke = function() end;

    end;

  end, {client});

end;

return useContinueDialogueBindableFunction;