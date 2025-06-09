--!strict

local packages = script.Parent.Parent.Parent.roblox_packages;
local React = require(packages.react);
local DialogueMakerTypes = require(packages.DialogueMakerTypes);

local MessageTextSegment = require(script.MessageTextSegment);

type Client = DialogueMakerTypes.Client;
type Conversation = DialogueMakerTypes.Conversation;
type Dialogue = DialogueMakerTypes.Dialogue;
type Page = DialogueMakerTypes.Page;
type TextComponentProperties = MessageTextSegment.TextComponentProperties;

export type ContentContainerProperties = {
  client: Client;
  pages: {Page};
  skipPageEvent: BindableEvent;
  currentPageIndex: number;
  themeWidth: number;
  onTypingFinished: () -> ();
  lineHeight: number;
  textSize: number;
}

local function ContentContainer(properties: ContentContainerProperties)

  local client = properties.client;
  local dialogue = client.dialogue;
  local conversation = client.conversation;
  local skipPageEvent = properties.skipPageEvent;
  local pages = properties.pages;
  local currentPageIndex = properties.currentPageIndex;

  local shouldSkip, setShouldSkip = React.useState(false);
  local targetComponentIndex, setTargetComponentIndex = React.useState(1);

  React.useEffect(function(): ()

    if skipPageEvent then

      local skipPageSignal = skipPageEvent.Event:Once(function()

        setShouldSkip(true);

      end);

      return function()

        skipPageSignal:Disconnect();

      end;

    end;

  end, {pages :: unknown, skipPageEvent, currentPageIndex});

  React.useEffect(function(): ()

    setTargetComponentIndex(1);

  end, {pages :: unknown, currentPageIndex});

  local visibleComponents = {};

  local page = pages[currentPageIndex];
  if page then

    for currentComponentIndex = 1, targetComponentIndex do

      local component = page[currentComponentIndex];

      local function onComplete()

        if currentComponentIndex == #page then

          setShouldSkip(false);
          properties.onTypingFinished();

        elseif currentComponentIndex == targetComponentIndex then

          setTargetComponentIndex(targetComponentIndex + 1);

        end;

      end;

      local typewriterCharacterDelay = if shouldSkip then 0 else dialogue.settings.typewriter.characterDelaySeconds or conversation.settings.typewriter.characterDelaySeconds or client.settings.typewriter.characterDelaySeconds;
      local componentKey = `{dialogue}.{currentPageIndex}.{currentComponentIndex}`;
      local skipPageSignal = if skipPageEvent then skipPageEvent.Event else nil;

      if typeof(component) == "string" then
        
        local textSegment = React.createElement(MessageTextSegment, {
          text = component;
          client = client;
          skipPageSignal = skipPageSignal;
          layoutOrder = currentComponentIndex;
          textSize = properties.textSize;
          key = componentKey;
          lineHeight = properties.lineHeight;
          letterDelay = typewriterCharacterDelay;
          onComplete = onComplete;
        });

        table.insert(visibleComponents, textSegment);

      else

        local possibleComponent = component:run({
          client = client;
          shouldSkip = shouldSkip or targetComponentIndex > currentComponentIndex;
          skipPageSignal = skipPageSignal;
          key = componentKey;
          textComponentProperties = {
            client = client;
            layoutOrder = currentComponentIndex;
            letterDelay = typewriterCharacterDelay;
            lineHeight = properties.lineHeight;
            textSize = properties.textSize;
          } :: TextComponentProperties;
          continuePage = onComplete;
          textComponent = MessageTextSegment;
        });

        if possibleComponent then

          table.insert(visibleComponents, possibleComponent);

        end;

      end;

    end;

  end;

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
    MessageComponentList = React.createElement(React.Fragment, {}, visibleComponents);
  });

end;

return ContentContainer;