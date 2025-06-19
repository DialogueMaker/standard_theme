--!strict
-- MessageText is a component that displays a string of text in the message container.
-- It may use a typewriter effect to display the text one character at a time.
-- 
-- Programmer: Christian Toney (Christian_Toney)
-- © 2025 Dialogue Maker Group

local packages = script.Parent.Parent.Parent.Parent.Parent.Parent.Parent.roblox_packages;
local React = require(packages.react);
local DialogueMakerTypes = require(packages.DialogueMakerTypes);
local useMinimumTextHeight = require(script.hooks.useMinimumTextHeight);
local useTypewriter = require(packages.useTypewriter);

type Client = DialogueMakerTypes.Client;

export type MessageTextProperties = {
  text: string;
  skipPageSignal: RBXScriptSignal;
  letterDelay: number;
  layoutOrder: number;
  textSize: number;
  onComplete: () -> ();
  lineHeight: number;
}

local function MessageText(properties: MessageTextProperties)

  local text = properties.text;
  local lineHeight = properties.lineHeight;
  local textSize = properties.textSize;
  local textLabelRef = React.useRef(nil :: TextLabel?);
  local minimumHeight = useMinimumTextHeight(textLabelRef, lineHeight, text);
  local maxVisibleGraphemes = useTypewriter({
    text = text;
    letterDelay = properties.letterDelay;
    onComplete = properties.onComplete;
    skipPageSignal = properties.skipPageSignal;
  });

  return React.createElement("TextLabel", {
    AutomaticSize = Enum.AutomaticSize.XY;
    Text = text;
    MaxVisibleGraphemes = maxVisibleGraphemes;
    LayoutOrder = properties.layoutOrder;
    FontFace = Font.fromName("BuilderSans", Enum.FontWeight.Regular);
    TextSize = textSize;
    LineHeight = lineHeight;
    BackgroundTransparency = 1;
    TextXAlignment = Enum.TextXAlignment.Left;
    TextYAlignment = Enum.TextYAlignment.Top;
    TextWrapped = true;
    TextColor3 = Color3.new(1, 1, 1);
    ref = textLabelRef;
  }, {
    LineHeightConstraint = if text ~= "" then
      React.createElement("UISizeConstraint", {
        MinSize = Vector2.new(0, minimumHeight);
      })
    else nil;
  });

end;

return React.memo(MessageText);