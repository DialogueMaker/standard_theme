--!strict
-- StandardTheme is a barebones theme that priorities function over form.
-- It is designed to be simple, general purpose, and work out of the box.
-- Developers can use this theme as a template for creating their own themes.
--
-- Programmer: Christian Toney (Christian_Toney)
-- © 2023 – 2025 Dialogue Maker Group

local packages = script.Parent.roblox_packages;
local React = require(packages.react);
local DialogueMakerTypes = require(packages.DialogueMakerTypes);
local MessageContainer = require(script.components.MessageContainer);
local ResponseContainer = require(script.components.ResponseContainer);
local useResponses = require(packages.useResponses);
local useDynamicSize = require(packages.useDynamicSize);
local useInitializationAction = require(script.hooks.useInitializationAction);
local useMessage = require(script.hooks.useMessage);
local useSetting = require(script.hooks.useSetting);

type ThemeProperties = DialogueMakerTypes.ThemeProperties;

local function StandardTheme(properties: ThemeProperties)

  local client = properties.client;
  local dialogue = client.dialogue;
  
  -- Choose a width based on the device type.
  local anchorPoint = Vector2.zero;
  local automaticSize = Enum.AutomaticSize.None;
  local position = UDim2.new();
  local size = UDim2.fromScale(1, 1);

  if client.dialogueGUI:IsA("ScreenGui") then

    anchorPoint = Vector2.new(0.5, 1);
    position = UDim2.new(0.5, 0, 1, -15);
    automaticSize = Enum.AutomaticSize.Y;

    local phoneWidth = 310;
    local tabletWidth = 500;
    local canUseTabletWidth = useDynamicSize(client.dialogueGUI, 736);
    local width = if canUseTabletWidth then tabletWidth else phoneWidth;
    size = UDim2.fromOffset(width, 0);

  end;

  local isTypingFinished, setIsTypingFinished = React.useState(false);
  React.useEffect(function()
  
    setIsTypingFinished(false);

  end, {dialogue});

  local didRunInitializationAction = useInitializationAction(client);
  local message = useMessage(client);
  local responses = useResponses(dialogue);
  local conversation = client.conversation;
  local shouldShowResponseWhileTyping = useSetting(dialogue.settings.typewriter.shouldShowResponseWhileTyping, conversation.settings.typewriter.shouldShowResponseWhileTyping, client.settings.typewriter.shouldShowResponseWhileTyping) :: boolean;

  if not didRunInitializationAction or not message then

    return React.createElement(React.Fragment);

  end;

  return React.createElement("Frame", {
    AnchorPoint = anchorPoint;
    AutomaticSize = automaticSize;
    Position = position;
    Size = size;
    BackgroundTransparency = 1;
  }, {
    UIListLayout = React.createElement("UIListLayout", {
      SortOrder = Enum.SortOrder.LayoutOrder;
      Padding = UDim.new(0, 5);
      FillDirection = Enum.FillDirection.Vertical;
    });
    MessageContainer = React.createElement(MessageContainer, {
      isTypingFinished = isTypingFinished;
      client = client;
      onTypingFinished = function()

        setIsTypingFinished(true);
        dialogue:runCompletionAction(client);

      end;
      onPageFinished = function()

        if #responses == 0 then

          dialogue:runCleanupAction(client);

        end;

      end;
    });
    ResponseContainer = if #responses > 0 and (not shouldShowResponseWhileTyping or isTypingFinished) then 
      React.createElement(ResponseContainer, {
        responses = responses;
        onComplete = function(requestedDialogue)

          dialogue:runCleanupAction(client, requestedDialogue);

        end;
      }) 
    else nil;
  });

end;

return React.memo(StandardTheme);