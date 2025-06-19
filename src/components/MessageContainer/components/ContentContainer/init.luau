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

  local lineHeight = 1.25;
  local textSize = 20;

  local client = properties.client;
  local dialogue = client.dialogue;
  local conversation = client.conversation;
  local skipPageEvent = properties.skipPageEvent;

  local shouldSkip, setShouldSkip = React.useState(false);
  useSkipPageSignal(skipPageEvent.Event, setShouldSkip);

  -- Reset the target component index when the page changes for a blank slate.
  local targetComponentIndex, setTargetComponentIndex = React.useState(1);

  React.useEffect(function(): ()

    setTargetComponentIndex(1);

  end, {dialogue});

  -- Memoize the dialogue content to avoid calling getContent() on every render.
  local dialogueContent = React.useMemo(function()
    
    return dialogue:getContent();
   
  end, {dialogue});

  local visibleComponents = React.useMemo(function()

    local visibleComponents: {React.ReactNode} = {};

    for currentComponentIndex = 1, targetComponentIndex do
      
      --[[
        Re-renders the content container with a new page or the next component in the current page.
      ]]
      local function continuePage()

        if currentComponentIndex >= #dialogueContent then

          setShouldSkip(false);
          properties.onTypingFinished();

        elseif currentComponentIndex == targetComponentIndex then

          setTargetComponentIndex(targetComponentIndex + 1);

        end;

      end;

      local typewriterCharacterDelay = if shouldSkip then 0 else dialogue.settings.typewriter.characterDelaySeconds or conversation.settings.typewriter.characterDelaySeconds or client.settings.typewriter.characterDelaySeconds;
      local componentKey = `{dialogue}.{currentComponentIndex}`;
      local component = dialogueContent[currentComponentIndex];

      if typeof(component) == "string" then
        
        local textSegment = React.createElement(MessageText, {
          text = component;
          client = client;
          skipPageSignal = skipPageEvent.Event;
          layoutOrder = currentComponentIndex;
          textSize = textSize;
          key = componentKey;
          lineHeight = lineHeight;
          letterDelay = typewriterCharacterDelay;
          onComplete = continuePage;
        });

        table.insert(visibleComponents, textSegment);

      elseif typeof(component) == "table" then

        local possibleComponent = component:run({
          client = client;
          shouldSkip = shouldSkip or targetComponentIndex > currentComponentIndex;
          skipPageSignal = skipPageEvent.Event;
          key = componentKey;
          textComponentProperties = {
            layoutOrder = currentComponentIndex;
            letterDelay = typewriterCharacterDelay;
            lineHeight = lineHeight;
            textSize = textSize;
          } :: MessageTextProperties;
          continuePage = continuePage;
          textComponent = MessageText;
        });

        if possibleComponent then

          table.insert(visibleComponents, possibleComponent);

        end;

      else

        warn(`Unsupported component type at component {currentComponentIndex}. Expected string or table, got {typeof(component)}.`);
        continuePage();

      end;

    end;

    return visibleComponents;

  end, {dialogueContent :: unknown, targetComponentIndex, shouldSkip, dialogue, conversation, client, skipPageEvent});

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

return React.memo(ContentContainer);