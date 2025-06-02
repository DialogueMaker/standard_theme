--!strict

local packages = script.Parent.Parent.Parent.Parent.roblox_packages;
local React = require(packages.react);
local ITheme = require(packages.theme_types);
local DialogueContentFitter = require(packages.dialogue_content_fitter);

local useTypewriter = require(packages.use_typewriter);

type TextComponentProperties = ITheme.TextComponentProperties;

local function TextSegment(properties: TextComponentProperties)

  local text = properties.text;
  local lineHeight = properties.lineHeight;
  local maxVisibleGraphemes = useTypewriter({
    text = text;
    letterDelay = properties.letterDelay;
    onComplete = properties.onComplete;
    skipPageSignal = properties.skipPageSignal;
  });
  local minimumHeight = React.useMemo(function()

    local textLabel = Instance.new("TextLabel");
    
    local lineBreaks = DialogueContentFitter:getLineBreakIndices(textLabel);
    return (#lineBreaks + 1) * properties.textSize * lineHeight;
  
  end, {text :: unknown, properties.textSize, lineHeight});

  return React.createElement("TextLabel", {
    AutomaticSize = Enum.AutomaticSize.XY;
    Text = text;
    MaxVisibleGraphemes = maxVisibleGraphemes;
    LayoutOrder = properties.layoutOrder;
    FontFace = Font.fromName("BuilderSans", Enum.FontWeight.Regular);
    TextSize = properties.textSize;
    LineHeight = lineHeight;
    BackgroundTransparency = 1;
    TextXAlignment = Enum.TextXAlignment.Left;
    TextYAlignment = Enum.TextYAlignment.Top;
    TextWrapped = true;
    TextColor3 = Color3.new(1, 1, 1);
  }, {
    LineHeightConstraint = if text ~= "" then
      React.createElement("UISizeConstraint", {
        MinSize = Vector2.new(0, minimumHeight);
      })
    else nil;
  });

end;

return TextSegment;