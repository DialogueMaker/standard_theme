--!strict

local packages = script.Parent.Parent.roblox_packages;
local React = require(packages.react);
local IDialogue = require(packages.dialogue_types);
local IEffect = require(packages.effect_types);
local ITheme = require(packages.theme_types);

local ContentContainer = require(script.ContentContainer);
local useKeybindContinue = require(packages.use_keybind_continue);
local useContinueDialogue = require(packages.use_continue_dialogue);

type Page = IEffect.Page;
type Dialogue = IDialogue.Dialogue;
type ThemeProperties = ITheme.ThemeProperties;
type DialogueSettings = IDialogue.DialogueSettings;

export type MessageContainerProperties = {
  dialogue: Dialogue;
  currentPageIndex: number;
  skipPageEvent: BindableEvent;
  setCurrentPageIndex: (number) -> ();
  onTypingFinished: () -> ();
  isTypingFinished: boolean;
  themeProperties: ThemeProperties;
  responses: {Dialogue};
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

  local continueDialogue = useContinueDialogue({
    pages = properties.pages;
    allowPlayerToSkipDelay = properties.dialogueSettings.typewriter.canPlayerSkipDelay;
    currentPageIndex = currentPageIndex;
    setCurrentPageIndex = properties.setCurrentPageIndex;
    onComplete = properties.themeProperties.onComplete;
    skipPageEvent = skipPageEvent;
    isNPCTalking = not properties.isTypingFinished;
    hasResponses = #properties.responses > 0;
  });
  useKeybindContinue(properties.themeProperties.client, continueDialogue);

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
  });

end;

return MessageContainer;
