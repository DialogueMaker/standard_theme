--!strict

local packages = script.Parent.Parent.roblox_packages;
local React = require(packages.react);
local DialogueMakerTypes = require(packages.dialogue_maker_types);

local ContinueIndicator = require(script.ContinueIndicator);
local ContentContainer = require(script.ContentContainer);
local useKeybindContinue = require(packages.use_keybind_continue);

type Page = DialogueMakerTypes.Page;
type Dialogue = DialogueMakerTypes.Dialogue;
type ThemeProperties = DialogueMakerTypes.ThemeProperties;
type DialogueSettings = DialogueMakerTypes.DialogueSettings;

export type MessageContainerProperties = {
  dialogue: Dialogue;
  currentPageIndex: number;
  skipPageEvent: BindableEvent;
  onPageFinished: () -> ();
  onTypingFinished: () -> ();
  isTypingFinished: boolean;
  themeProperties: ThemeProperties;
  themeWidth: number;
  pages: {Page};
  dialogueSettings: DialogueSettings;
  lineHeight: number;
  textSize: number;
  height: number;
  padding: number;
}

local function MessageContainer(properties: MessageContainerProperties)

  local currentPageIndex = properties.currentPageIndex;
  local skipPageEvent = properties.skipPageEvent;
  local isTypingFinished = properties.isTypingFinished;
  local onPageFinished = properties.onPageFinished;

  local canPlayerSkipDelay = properties.dialogueSettings.typewriter.canPlayerSkipDelay;
  local continueDialogue = React.useCallback(function()

    if isTypingFinished then

      onPageFinished();

    elseif canPlayerSkipDelay then

      skipPageEvent:Fire();

    end;

  end, {currentPageIndex :: unknown, isTypingFinished, canPlayerSkipDelay, skipPageEvent, onPageFinished});

  React.useEffect(function()
  
    properties.themeProperties.client:setContinueDialogueFunction(continueDialogue);

    return function()

      properties.themeProperties.client:setContinueDialogueFunction(nil);

    end;

  end, {properties.themeProperties.client});
  
  useKeybindContinue(properties.themeProperties.client, continueDialogue);
  
  local doesNextDialogueExist = React.useMemo(function()
    
    local nextDialogue = properties.dialogue:findNextVerifiedDialogue();
    return nextDialogue ~= nil;
    
  end, {properties.dialogue});
  
  return React.createElement("Frame", {
    Size = UDim2.new(1, 0, 0, properties.height);
    BackgroundColor3 = Color3.fromHex("#202020");
    BackgroundTransparency = 0.2;
    [React.Event.InputBegan] = function(self: Frame, input: InputObject)

      if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then

        continueDialogue();

      end;

    end;
  }, {
    UIPadding = React.createElement("UIPadding", {
      PaddingLeft = UDim.new(0, properties.padding);
      PaddingTop = UDim.new(0, properties.padding);
      PaddingRight = UDim.new(0, properties.padding);
      PaddingBottom = UDim.new(0, properties.padding);
    });
    UICorner = React.createElement("UICorner", {
      CornerRadius = UDim.new(0, 5);
    });
    ContentContainer = React.createElement(ContentContainer, {
      dialogue = properties.dialogue;
      pages = properties.pages;
      currentPageIndex = currentPageIndex;
      skipPageEvent = skipPageEvent;
      themeWidth = properties.themeWidth;
      onTypingFinished = properties.onTypingFinished;
      lineHeight = properties.lineHeight;
      dialogueSettings = properties.dialogueSettings;
      textSize = properties.textSize;
    });
    ContinueIndicator = if properties.isTypingFinished and (properties.currentPageIndex < #properties.pages or doesNextDialogueExist) then
      React.createElement(ContinueIndicator)
    else nil;
  });

end;

return MessageContainer;
