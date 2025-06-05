--!strict

local packages = script.Parent.Parent.Parent.roblox_packages;
local React = require(packages.react);

export type NameTagProperties = {
  speakerName: string;
  parentPadding: number;
}

local function NameTag(properties: NameTagProperties)

  local textSize = 20;

  return React.createElement("TextLabel", {
    AutomaticSize = Enum.AutomaticSize.XY;
    BorderSizePixel = 0;
    BackgroundTransparency = 0;
    TextSize = textSize;
    FontFace = Font.fromName("BuilderSans", Enum.FontWeight.Bold);
    Text = properties.speakerName;
    Position = UDim2.fromOffset(0, -properties.parentPadding - textSize / 2);
    TextColor3 = Color3.fromRGB(32, 32, 32);
    BackgroundColor3 = Color3.new(1, 1, 1);
  }, {
    UIPadding = React.createElement("UIPadding", {
      PaddingLeft = UDim.new(0, 15);
      PaddingRight = UDim.new(0, 15);
    });
    UICorner = React.createElement("UICorner", {
      CornerRadius = UDim.new(1, 0);
    });
  });

end;

return NameTag;