--!strict
-- ContentContainer is a component that displays the current page of the dialogue.
-- 
-- Programmer: Christian Toney (Christian_Toney)
-- © 2025 Dialogue Maker Group

local packages = script.Parent.Parent.Parent.Parent.Parent.roblox_packages;
local React = require(packages.react);
local DialogueMakerTypes = require(packages.DialogueMakerTypes);
local MessageText = require(script.components.MessageText);
local useSkipPageSignal = require(script.hooks.useSkipPageSignal);
local useIterativeContent = require(packages.useIterativeContent);
local useSetting = require(script.Parent.Parent.Parent.Parent.hooks.useSetting);

type Client = DialogueMakerTypes.Client;
type Conversation = DialogueMakerTypes.Conversation;
type Dialogue = DialogueMakerTypes.Dialogue;
type Page = DialogueMakerTypes.Page;
type MessageTextProperties = MessageText.MessageTextProperties;

export type ContentContainerProperties = {
  client: Client;
  skipPageEvent: BindableEvent;
  onTypingFinished: () -> ();
}

local function ContentContainer(properties: ContentContainerProperties)

  local client = properties.client;
  local dialogue = client.dialogue;
  local conversation = client.conversation;
  local skipPageEvent = properties.skipPageEvent;
  local onTypingFinished = properties.onTypingFinished;

  local lineHeight = 1.25;
  local textSize = 20;

  local shouldSkip, setShouldSkip = React.useState(false);
  useSkipPageSignal(skipPageEvent.Event, setShouldSkip);

  -- Memoize the dialogue content to avoid calling getContent() on every render.
  local dialogueContent = React.useMemo(function()
    
    return dialogue:getContent();
   
  end, {dialogue});

  -- Render the components one by one, starting from the first component.
  -- This prevents the entire page from being rendered at once, which can cause unexpected behavior.
  local typewriterCharacterDelay = useSetting(dialogue.settings.typewriter.characterDelaySeconds, conversation.settings.typewriter.characterDelaySeconds, client.settings.typewriter.characterDelaySeconds) :: number;
  typewriterCharacterDelay = if shouldSkip then 0 else typewriterCharacterDelay;
  local createTextElement = React.useCallback(function(textElementProperties: DialogueMakerTypes.TextElementProperties)

    return React.createElement(MessageText, {
      text = textElementProperties.text;
      client = client;
      skipPageSignal = skipPageEvent.Event;
      layoutOrder = textElementProperties.layoutOrder or 1;
      textSize = textSize;
      key = textElementProperties.key;
      lineHeight = lineHeight;
      letterDelay = typewriterCharacterDelay;
      onCompleted = textElementProperties.onCompleted;
    });

  end, {lineHeight, textSize, typewriterCharacterDelay});

  local continuePage = React.useCallback(function()

    setShouldSkip(false);
    onTypingFinished();

  end, {onTypingFinished});
  
  local iterativeContent = useIterativeContent(dialogueContent, client, skipPageEvent.Event, shouldSkip, createTextElement, continuePage);

  return React.createElement("Frame", {
    AnchorPoint = Vector2.new(0.5, 0);
    BackgroundTransparency = 1;
    Position = UDim2.fromScale(0.5, 0);
    Size = UDim2.new(1, -30, 1, 0);
  }, {
    UIListLayout = React.createElement("UIListLayout", {
      SortOrder = Enum.SortOrder.LayoutOrder;
      FillDirection = Enum.FillDirection.Horizontal;
      Wraps = true;
    });
    MessageComponentList = React.createElement(React.Fragment, {}, iterativeContent);
  });

end;

return React.memo(ContentContainer);