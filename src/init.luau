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

type ThemeProperties = DialogueMakerTypes.ThemeProperties;

local function StandardTheme(properties: ThemeProperties)

  local client = properties.client;
  local dialogue = client.dialogue;
  
  local skipPageEvent = React.useMemo(function()

    return Instance.new("BindableEvent");

  end, {});
  
  -- Split the dialogue into pages based on the canvas and device size.
  local sizes = React.useMemo(function()

    return {
      {
        width = 500;
      },
      {
        width = 310;
      }
    };

  end, {});
  local dynamicSizeIndex = useDynamicSize({
    {
      minimumWidth = 736;
    }
  });
  local size = sizes[dynamicSizeIndex or #sizes];

  local isTypingFinished, setIsTypingFinished = React.useState(false);
  
  React.useEffect(function()
  
    setIsTypingFinished(false);

  end, {dialogue});

  local didRunInitializationAction = useInitializationAction(client);
  local message = useMessage(client);
  local responses = useResponses(dialogue); -- TODO: Update this with memoization.

  if not didRunInitializationAction or not message then

    return React.createElement(React.Fragment);

  end;

  return React.createElement("Frame", {
    AnchorPoint = Vector2.new(0.5, 1);
    Position = UDim2.new(0.5, 0, 1, -15);
    AutomaticSize = Enum.AutomaticSize.Y;
    Size = UDim2.fromOffset(size.width, 0);
    BackgroundTransparency = 1;
  }, {
    UIListLayout = React.createElement("UIListLayout", {
      SortOrder = Enum.SortOrder.LayoutOrder;
      Padding = UDim.new(0, 5);
      FillDirection = Enum.FillDirection.Vertical;
    });
    MessageContainer = React.createElement(MessageContainer, {
      skipPageEvent = skipPageEvent;
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
    ResponseContainer = if #responses > 0 and (not dialogue.settings.typewriter.shouldShowResponseWhileTyping or isTypingFinished) then 
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