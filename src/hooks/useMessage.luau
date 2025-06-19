local root = script.Parent.Parent.Parent;
local React = require(root.roblox_packages.react);
local DialogueMakerTypes = require(root.roblox_packages.DialogueMakerTypes);

type Client = DialogueMakerTypes.Client;
type Dialogue = DialogueMakerTypes.Dialogue;

local function useMessage(client: Client)

  return React.useMemo(function()
    
    local dialogue = client.dialogue;

    if dialogue.type ~= "Message" then

      local nextDialogue = dialogue:findNextVerifiedDialogue();
      client:clone({
        dialogue = nextDialogue;
      });

      return;

    end;

    return dialogue;

  end, {client});
  
end;

return useMessage;