--!strict
-- BareBonesTheme is the first theme that was created for Dialogue Maker.
-- As the name describes, it is a barebones theme that priorities function over form.
-- Developers can use this theme as a template for creating their own.
--
-- Programmer: Christian Toney (Christian_Toney)

local packages = script.Parent.roblox_packages;
local React = require(packages.react);
local ITheme = require(packages.theme_types);

local MessageContainer = require(script.MessageContainer);
local ResponseContainer = require(script.ResponseContainer);
local useMaximumDistance = require(packages.use_maximum_distance);
local useResponses = require(packages.use_responses);
local useDynamicSize = require(packages.use_dynamic_size);
local usePages = require(packages.use_pages);

type ThemeProperties = ITheme.ThemeProperties;

local skipPageEvent = Instance.new("BindableEvent");

local function StandardTheme(properties: ThemeProperties)

  local npc = properties.npc;
  local conversation = properties.conversation;
  local textSize = 20;
  local lineHeight = 1.25;
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
  local currentPageIndex, setCurrentPageIndex = React.useState(1);
  local dialogueSettings, dialogueContent = React.useMemo(function()
    
    return properties.dialogue:getSettings(), properties.dialogue:getContent();

  end, {properties.dialogue});
  local messageContainerHeight = 75;
  local messageContainerPadding = 15;
  local pageFittingProperties = React.useMemo(function()

    return {
      containerSize = UDim2.new(0, size.width - (2 * messageContainerPadding) - 30, 0, messageContainerHeight - (2 * messageContainerPadding));
      fontFace = Font.fromName("BuilderSans", Enum.FontWeight.Regular);
      textSize = textSize;
      lineHeight = lineHeight;
    };

  end, {size :: unknown, textSize, lineHeight});
  local pages = usePages(dialogueContent, pageFittingProperties);

  React.useEffect(function()

    setCurrentPageIndex(1);

  end, {pages :: unknown});

  local responses = useResponses(properties.dialogue);
  local isTypingFinished, setIsTypingFinished = React.useState(false);
  useMaximumDistance(npc, conversation, properties.onTimeout);
  
  React.useEffect(function()
  
    setIsTypingFinished(false);

  end, {pages :: unknown, currentPageIndex});

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
      dialogue = properties.dialogue;
      pages = pages;
      currentPageIndex = currentPageIndex; 
      skipPageEvent = skipPageEvent;
      themeProperties = properties;
      responses = responses;
      isTypingFinished = isTypingFinished;
      themeWidth = size.width;
      lineHeight = lineHeight;
      dialogueSettings = dialogueSettings;
      textSize = textSize;
      height = messageContainerHeight;
      padding = messageContainerPadding;
      onTypingFinished = function()

        setIsTypingFinished(true);

      end;
      setCurrentPageIndex = setCurrentPageIndex;
    });
    ResponseContainer = if #responses > 0 and (not dialogueSettings.typewriter.shouldShowResponseWhileTyping or isTypingFinished) then React.createElement(ResponseContainer, {
      responses = responses;
      onComplete = function(newParent)

        properties.onComplete(newParent);

      end;
    }) else nil;
  })

end;

return StandardTheme;