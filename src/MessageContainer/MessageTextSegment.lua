--!strict

local package = script.Parent.Parent;
local React = require(package.Parent.react);
local ITheme = require(package.Parent["theme-types"]);

local useTypewriter = require(package.Parent["use-typewriter"]);

type TextComponentProperties = ITheme.TextComponentProperties;

local function TextSegment(props: TextComponentProperties)

  local ref = React.useRef(nil :: TextLabel?);

  local text = props.text;
  local maxVisibleGraphemes = useTypewriter({
    text = text;
    letterDelay = props.letterDelay;
    onComplete = props.onComplete;
    skipPageSignal = props.skipPageSignal;
  });

  return React.createElement("TextLabel", {
    AutomaticSize = Enum.AutomaticSize.XY;
    Text = text;
    ref = props.ref2 or ref;
    MaxVisibleGraphemes = maxVisibleGraphemes;
    LayoutOrder = props.layoutOrder;
    FontFace = Font.fromName("BuilderSans", Enum.FontWeight.Regular);
    TextSize = props.textSize;
    BackgroundTransparency = 1;
    TextXAlignment = Enum.TextXAlignment.Left;
    TextWrapped = true;
    TextColor3 = Color3.new(1, 1, 1);
  })

end;

return TextSegment;