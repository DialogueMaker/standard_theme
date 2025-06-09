--!strict

local packages = script.Parent.Parent.Parent.Parent.roblox_packages;
local React = require(packages.react);
local DialogueMakerTypes = require(packages.DialogueMakerTypes);
local DialogueContentFitter = require(packages.dialogue_content_fitter);

local useTypewriter = require(packages.use_typewriter);

type Client = DialogueMakerTypes.Client;

export type TextComponentProperties = {
  text: string;
  skipPageSignal: RBXScriptSignal?;
  letterDelay: number;
  layoutOrder: number;
  textSize: number;
  onComplete: () -> ();
  lineHeight: number;
  client: Client;
}

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

  local client = properties.client;
  local dialogue = client.dialogue;
  local conversation = client.conversation;

  local textLabelRef = React.useRef(nil :: TextLabel?);
  React.useEffect(function(): ()
  
    local textLabel = textLabelRef.current;
    local typewriterSoundTemplate = dialogue.settings.typewriter.soundTemplate or conversation.settings.typewriter.soundTemplate or client.settings.typewriter.soundTemplate;
    if textLabel and typewriterSoundTemplate then

      local typewriterSound = typewriterSoundTemplate:Clone();
      typewriterSound.Parent = textLabel;
      typewriterSound.Ended:Once(function()
        
        typewriterSound:Destroy();

      end);
      typewriterSound:Play();

      return function()

        typewriterSound:Destroy();

      end;

    end;

  end, {maxVisibleGraphemes :: unknown, client, dialogue, conversation});

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
    ref = textLabelRef;
  }, {
    LineHeightConstraint = if text ~= "" then
      React.createElement("UISizeConstraint", {
        MinSize = Vector2.new(0, minimumHeight);
      })
    else nil;
  });

end;

return TextSegment;