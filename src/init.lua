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

local MessageContainer = require(script.MessageContainer);
local ResponseContainer = require(script.ResponseContainer);
local useResponses = require(packages.use_responses);
local useDynamicSize = require(packages.use_dynamic_size);
local usePages = require(packages.use_pages);

type ThemeProperties = DialogueMakerTypes.ThemeProperties;

local function StandardTheme(properties: ThemeProperties)

  local client = properties.client;
  local dialogue = client.dialogue;
  local textSize = 20;
  local lineHeight = 1.25;
  local messageContainerHeight = 75;
  local messageContainerPadding = 15;
  
  local currentPageIndex, setCurrentPageIndex = React.useState(1);
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
  local pageFittingProperties = React.useMemo(function()

    return {
      containerSize = UDim2.new(0, size.width - (2 * messageContainerPadding) - 30, 0, messageContainerHeight - (2 * messageContainerPadding));
      fontFace = Font.fromName("BuilderSans", Enum.FontWeight.Regular);
      textSize = textSize;
      lineHeight = lineHeight;
    };

  end, {size :: unknown, textSize, lineHeight});
  local dialogueContent = React.useMemo(function()
    
    return dialogue:getContent();

  end, {dialogue});
  local pages = usePages(dialogueContent, pageFittingProperties);

  -- Run the initialization action for the dialogue if necessary.
  local didRunInitializationAction, setDidRunInitializationAction = React.useState(false);
  local oldClient, setOldClient = React.useState(client);
  React.useEffect(function()

    if oldClient ~= client then

      setOldClient(client);
      setDidRunInitializationAction(false);

    end;

  end, {client, oldClient});

  -- Reset the current page index when the page list changes.
  React.useEffect(function()

    setCurrentPageIndex(1);

  end, {pages :: unknown});

  local isTypingFinished, setIsTypingFinished = React.useState(false);
  
  React.useEffect(function()
  
    setIsTypingFinished(false);

  end, {pages :: unknown, currentPageIndex});

  local responses = useResponses(dialogue); -- TODO: Update this with memoization.

  if not didRunInitializationAction then

    dialogue:runInitializationAction(client);
    setDidRunInitializationAction(true);

    if dialogue.type ~= "Message" then

      local nextDialogue = dialogue:findNextVerifiedDialogue();
      client:clone({
        dialogue = nextDialogue;
      });

    end;

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
      pages = pages;
      currentPageIndex = currentPageIndex; 
      skipPageEvent = skipPageEvent;
      isTypingFinished = isTypingFinished;
      client = client;
      themeWidth = size.width;
      lineHeight = lineHeight;
      textSize = textSize;
      height = messageContainerHeight;
      padding = messageContainerPadding;
      onTypingFinished = function()

        setIsTypingFinished(true);
        dialogue:runCompletionAction(client);

      end;
      onPageFinished = function()

        if #pages > currentPageIndex then
          
          setCurrentPageIndex(currentPageIndex + 1);
        
        elseif #responses == 0 then

          dialogue:runCleanupAction(client);

        end;

      end;
      setCurrentPageIndex = setCurrentPageIndex;
    });
    ResponseContainer = if #responses > 0 and currentPageIndex == #pages and (not dialogue.settings.typewriter.shouldShowResponseWhileTyping or isTypingFinished) then 
      React.createElement(ResponseContainer, {
        responses = responses;
        onComplete = function(requestedDialogue)

          dialogue:runCleanupAction(client, requestedDialogue);

        end;
      }) 
    else nil;
  });

end;

return StandardTheme;