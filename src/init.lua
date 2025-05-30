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
local useKeybindContinue = require(packages.use_keybind_continue);
local useMaximumDistance = require(packages.use_maximum_distance);
local useContinueDialogue = require(packages.use_continue_dialogue);
local useResponses = require(packages.use_responses);
local useDynamicSize = require(packages.use_dynamic_size);

type ThemeProperties = ITheme.ThemeProperties;

local skipPageEvent = Instance.new("BindableEvent");

local function StandardTheme(props: ThemeProperties)

  local npc = props.npc;
  local client = props.client;
  local conversation = props.conversation;
  local conversationSettings = conversation:getSettings();
  local dialogueSettings = props.dialogue:getSettings();
  local npcName = conversationSettings.general.name;

  local clickSoundRef = React.useRef(nil :: Sound?);

  local dynamicSizeIndex = useDynamicSize({
    {
      minimumWidth = 736;
    }
  });
  local sizes = {
    {
      width = 500;
    },
    {
      width = 310;
    }
  };
  local size = sizes[dynamicSizeIndex or #sizes];

  -- States
  local currentPageIndex, setCurrentPageIndex = React.useState(1);

  -- Hooks
  local pages, setPages = React.useState({});
  local responses = useResponses(props.dialogue);
  local isTypingFinished, setIsTypingFinished = React.useState(false);
  local continueDialogue = useContinueDialogue({
    pages = pages;
    clickSoundRef = clickSoundRef;
    allowPlayerToSkipDelay = dialogueSettings.typewriter.canPlayerSkipDelay;
    currentPageIndex = currentPageIndex;
    setCurrentPageIndex = setCurrentPageIndex;
    onComplete = props.onComplete;
    skipPageEvent = skipPageEvent;
    isNPCTalking = not isTypingFinished;
    hasResponses = #responses > 0;
  });
  useKeybindContinue(client, continueDialogue);
  useMaximumDistance(npc, conversation, props.onTimeout);

  -- TODO: Implement timeout.
  
  return React.createElement("Frame", {
    AnchorPoint = Vector2.new(0.5, 1);
    Position = UDim2.new(0.5, 0, 1, -15);
    AutomaticSize = Enum.AutomaticSize.Y;
    Size = UDim2.fromOffset(size.width, 0);
    BackgroundTransparency = 1;
    [React.Event.InputBegan] = function(self: Frame, input: InputObject)

      if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then

        continueDialogue();

      end;

    end;
  }, {
    UIListLayout = React.createElement("UIListLayout", {
      SortOrder = Enum.SortOrder.LayoutOrder;
      Padding = UDim.new(0, 5);
      FillDirection = Enum.FillDirection.Vertical;
    });
    NPCNameTextLabel = if npcName then React.createElement("TextLabel", {
      AutomaticSize = Enum.AutomaticSize.XY;
      Text = npcName;
      LayoutOrder = 1;
    }) else nil;
    MessageContainer = React.createElement(MessageContainer, {
      pages = pages, 
      currentPageIndex = currentPageIndex; 
      skipPageEvent = skipPageEvent;
      continueDialogue = continueDialogue;
      onPagesUpdated = setPages;
      dialogue = props.dialogue;
      setIsTypingFinished = setIsTypingFinished;
      setCurrentPageIndex = setCurrentPageIndex;
    });
    ResponseContainer = if #responses > 0 and (not dialogueSettings.typewriter.shouldShowResponseWhileTyping or isTypingFinished) then React.createElement(ResponseContainer, {
      responses = responses;
      onComplete = function(newParent)

        props.onComplete(newParent);

      end;
    }) else nil;
    -- ContinueButton = React.createElement("ImageButton", {
    --   Size = UDim2.new(0, 20, 0, 20);
    --   LayoutOrder = 3;
    --   Image = "rbxassetid://90966430453504";
    --   BackgroundColor3 = if isNPCTalking and not npcSettings.general.allowPlayerToSkipDelay then Color3.new(0.705882, 0.705882, 0.705882) else Color3.new(1, 1, 1);
    --   ImageColor3 = if isNPCTalking and not npcSettings.general.allowPlayerToSkipDelay then Color3.new(0.486275, 0.486275, 0.486275) else Color3.new(1, 1, 1);
    --   [React.Event.Activated] = if isNPCTalking and not npcSettings.general.allowPlayerToSkipDelay then nil else function()

    --     continueDialogue()

    --   end;
    -- });
    -- ClickSound = if clientSettings.defaultClickSound then React.createElement("Sound", {
    --   SoundId = `rbxassetid://{clientSettings.defaultClickSound}`;
    --   ref = clickSoundRef;
    -- }) else nil;
  })

end;

return StandardTheme;