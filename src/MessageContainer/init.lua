--!strict

local packages = script.Parent.Parent.roblox_packages;
local React = require(packages.react);
local DialogueMakerTypes = require(packages.DialogueMakerTypes);

local ContinueIndicator = require(script.ContinueIndicator);
local NameTag = require(script.NameTag);
local ContentContainer = require(script.ContentContainer);
local useKeybindContinue = require(packages.useKeybindContinue);

type Client = DialogueMakerTypes.Client;
type Page = DialogueMakerTypes.Page;
type Dialogue = DialogueMakerTypes.Dialogue;
type DialogueSettings = DialogueMakerTypes.DialogueSettings;

export type MessageContainerProperties = {
  currentPageIndex: number;
  skipPageEvent: BindableEvent;
  onPageFinished: () -> ();
  onTypingFinished: () -> ();
  isTypingFinished: boolean;
  client: Client;
  themeWidth: number;
  pages: {Page};
  lineHeight: number;
  textSize: number;
  height: number;
  padding: number;
}

local function MessageContainer(properties: MessageContainerProperties)

  local currentPageIndex = properties.currentPageIndex;
  local skipPageEvent = properties.skipPageEvent;
  local isTypingFinished = properties.isTypingFinished;
  local client = properties.client;
  local dialogue = client.dialogue;
  local conversation = client.conversation;
  local onPageFinished = properties.onPageFinished;

  -- Allow external scripts to skip pages and continue the dialogue outside of the theme.
  local canPlayerSkipDelay = dialogue.settings.typewriter.canPlayerSkipDelay;

  local continueDialogue = React.useCallback(function()

    if isTypingFinished then

      onPageFinished();

    elseif canPlayerSkipDelay then

      skipPageEvent:Fire();

    end;

  end, {isTypingFinished :: unknown, canPlayerSkipDelay, skipPageEvent, onPageFinished});

  React.useEffect(function()
  
    client.continueDialogueBindableFunction.OnInvoke = continueDialogue;

    return function()

      client.continueDialogueBindableFunction.OnInvoke = function() end;

    end;

  end, {client});
  
  -- Outsource keybind support.
  useKeybindContinue(client, continueDialogue);

  local doesNextDialogueExist = React.useMemo(function()
    
    local nextDialogue = dialogue:findNextVerifiedDialogue();
    return nextDialogue ~= nil;
    
  end, {dialogue});
  
  local speakerName = dialogue.settings.speaker.name or conversation.settings.speaker.name;

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
    NameTag = if speakerName then React.createElement(NameTag, {
      speakerName = speakerName;
      parentPadding = properties.padding;
    }) else nil;
    ContentContainer = React.createElement(ContentContainer, {
      client = client;
      conversation = conversation;
      pages = properties.pages;
      currentPageIndex = currentPageIndex;
      skipPageEvent = skipPageEvent;
      themeWidth = properties.themeWidth;
      onTypingFinished = properties.onTypingFinished;
      lineHeight = properties.lineHeight;
      textSize = properties.textSize;
    });
    ContinueIndicator = if properties.isTypingFinished and (properties.currentPageIndex < #properties.pages or doesNextDialogueExist) then
      React.createElement(ContinueIndicator)
    else nil;
  });

end;

return MessageContainer;
