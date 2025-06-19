--!strict

local root = script.Parent.Parent.Parent.Parent.Parent;
local React = require(root.roblox_packages.react);
local DialogueMakerTypes = require(root.roblox_packages.DialogueMakerTypes);

type Dialogue = DialogueMakerTypes.Dialogue;

local function useNextMessage(dialogue: Dialogue)

  return React.useMemo(function(): Dialogue?
    
    local children = dialogue:getChildren();
    for _, child in children do

      if child.type == "Message" and child:verifyCondition() then

        return child;

      end;

    end;

    return;
    
  end, {dialogue});

end;

return useNextMessage;