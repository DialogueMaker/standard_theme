--!strict
-- MessageContainer contains the main dialogue text, speaker name, and the continue indicator.
-- It also hosts some logic that is shared between components for skipping pages and continuing the dialogue.
-- 
-- Programmer: Christian Toney (Christian_Toney)
-- © 2023 – 2025 Dialogue Maker Group

local packages = script.Parent.Parent.Parent.roblox_packages;
local React = require(packages.react);
local DialogueMakerTypes = require(packages.DialogueMakerTypes);
local ContinueIndicator = require(script.components.ContinueIndicator);
local NameTag = require(script.components.NameTag);
local ContentContainer = require(script.components.ContentContainer);
local useKeybindContinue = require(packages.useKeybindContinue);
local useContinueDialogueBindableFunction = require(script.hooks.useContinueDialogueBindableFunction);
local useNextMessage = require(script.hooks.useNextMessage);
local useSetting = require(script.Parent.Parent.hooks.useSetting);

type Client = DialogueMakerTypes.Client;
type Page = DialogueMakerTypes.Page;
type Dialogue = DialogueMakerTypes.Dialogue;
type DialogueSettings = DialogueMakerTypes.DialogueSettings;

export type MessageContainerProperties = {
  onPageFinished: () -> ();
  onTypingFinished: () -> ();
  isTypingFinished: boolean;
  client: Client;
}

local function MessageContainer(properties: MessageContainerProperties)

  local isTypingFinished = properties.isTypingFinished;
  local client = properties.client;
  local dialogue = client.dialogue;
  local conversation = client.conversation;
  local onPageFinished = properties.onPageFinished;
  local nextMessage = useNextMessage(dialogue);
  local skipPageEvent = React.useMemo(function()

    -- A BindableEvent ensures that messages can be skipped even during effects.
    -- Some effects like PauseEffect are outside of the React lifecycle.
    return Instance.new("BindableEvent");

  end, {});

  local size = UDim2.fromScale(1, 1);
  local padding = 15;
  local speakerName = useSetting(dialogue.settings.speaker.name, conversation.settings.speaker.name);

  if client.dialogueGUI:IsA("ScreenGui") then

    size = UDim2.new(1, 0, 0, 75);

  end;
  
  local canPlayerSkipDelay = useSetting(dialogue.settings.typewriter.canPlayerSkipDelay, conversation.settings.typewriter.canPlayerSkipDelay, client.settings.typewriter.canPlayerSkipDelay);
  local continueDialogue = React.useCallback(function()

    if isTypingFinished then

      onPageFinished();

    elseif canPlayerSkipDelay then

      skipPageEvent:Fire();

    end;

  end, {isTypingFinished :: unknown, canPlayerSkipDelay, skipPageEvent, onPageFinished});

  useKeybindContinue(client, continueDialogue);
  useContinueDialogueBindableFunction(client, continueDialogue);

  return React.createElement("Frame", {
    Size = size;
    BackgroundColor3 = Color3.fromHex("#202020");
    BackgroundTransparency = 0.2;
    [React.Event.InputBegan] = function(self: Frame, input: InputObject)

      if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then

        continueDialogue();

      end;

    end;
  }, {
    UIPadding = React.createElement("UIPadding", {
      PaddingLeft = UDim.new(0, padding);
      PaddingTop = UDim.new(0, padding);
      PaddingRight = UDim.new(0, padding);
      PaddingBottom = UDim.new(0, padding);
    });
    UICorner = React.createElement("UICorner", {
      CornerRadius = UDim.new(0, 5);
    });
    NameTag = if speakerName then React.createElement(NameTag, {
      speakerName = speakerName;
      parentPadding = padding;
    }) else nil;
    ContentContainer = React.createElement(ContentContainer, {
      client = client;
      skipPageEvent = skipPageEvent;
      onTypingFinished = properties.onTypingFinished;
    });
    ContinueIndicator = if properties.isTypingFinished and nextMessage ~= nil then
      React.createElement(ContinueIndicator)
    else nil;
  });

end;

return React.memo(MessageContainer);
