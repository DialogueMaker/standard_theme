--!strict

local root = script.Parent.Parent.Parent;
local React = require(root.roblox_packages.react);
local DialogueMakerTypes = require(root.roblox_packages.DialogueMakerTypes);

type Client = DialogueMakerTypes.Client;
type Dialogue = DialogueMakerTypes.Dialogue;

local function useInitializationAction(client: Client)

  local dialogue = client.dialogue;
  local oldDialogue, setOldDialogue = React.useState(nil :: Dialogue?);
  local didRunInitializationAction, setDidRunInitializationAction = React.useState(false);

  React.useEffect(function()
  
    if oldDialogue ~= dialogue then

      setOldDialogue(dialogue);
      setDidRunInitializationAction(false);

    end;

  end, {oldDialogue, dialogue});

  return React.useMemo(function()
    
    if not didRunInitializationAction then

      dialogue:runInitializationAction(client);
      setDidRunInitializationAction(true);

    end

    return didRunInitializationAction;

  end, {didRunInitializationAction :: unknown, dialogue, client});

end;

return useInitializationAction;