--!strict

local root = script.Parent.Parent.Parent.Parent.Parent.Parent.Parent.Parent.Parent;
local React = require(root.roblox_packages.react);

local function useMinimumTextHeight(textLabelRef: React.Ref<TextLabel?>, lineHeight: number, text: string): number

  local minimumHeight, setMinimumHeight = React.useState(0);

  React.useEffect(function(): ()
  
    if typeof(textLabelRef) == "function" then

      return;

    end;

    local textLabel = textLabelRef.current;
    if not textLabel then
      
      return;
      
    end;

    setMinimumHeight(textLabel.TextBounds.Y * lineHeight);

  end, {textLabelRef :: unknown, lineHeight :: unknown});

  return minimumHeight;

end;

return useMinimumTextHeight;