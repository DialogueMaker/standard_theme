--!strict

local packages = script.Parent.Parent.Parent.roblox_packages;
local React = require(packages.react);
local MessageTextSegment = require(script.MessageTextSegment);

local IDialogue = require(packages.dialogue_types);
local IEffect = require(packages.effect_types);

type Dialogue = IDialogue.Dialogue;
type DialogueSettings = IDialogue.DialogueSettings;
type Page = IEffect.Page;

export type ContentContainerProperties = {
  dialogue: Dialogue;
  dialogueSettings: DialogueSettings;
  pages: {Page};
  skipPageEvent: BindableEvent;
  currentPageIndex: number;
  themeWidth: number;
  onTypingFinished: () -> ();
  lineHeight: number;
  textSize: number;
}

local function ContentContainer(properties: ContentContainerProperties)

  local contentContainerWidth = properties.themeWidth - 30;
  local shouldSkip, setShouldSkip = React.useState(false);
  local componentIndex, setComponentIndex = React.useState(1);
  local skipPageEvent = properties.skipPageEvent;
  local pages = properties.pages;
  local currentPageIndex = properties.currentPageIndex;

  React.useEffect(function(): ()

    if skipPageEvent then

      local skipPageSignal = skipPageEvent.Event:Once(function()

        setShouldSkip(true);

      end);

      return function()

        skipPageSignal:Disconnect();

      end;

    end;

  end, {pages :: unknown, skipPageEvent, currentPageIndex});

  React.useEffect(function(): ()

    setComponentIndex(1);

  end, {pages :: unknown, currentPageIndex});

  local messageComponentList = {};

  local page = pages[currentPageIndex];
  if page then

    for index, dialogueContentItem in page do

      if index > componentIndex then

        break;

      end;

      local function onComplete()

        if index == #page then

          setShouldSkip(false);
          properties.onTypingFinished();

        elseif index == componentIndex then

          setComponentIndex(componentIndex + 1);

        end;

      end;

      local dialogueModuleScriptFullName = properties.dialogue.moduleScript:GetFullName();
      if typeof(dialogueContentItem) == "string" then
        
        local textSegment = React.createElement(MessageTextSegment, {
          text = dialogueContentItem;
          skipPageSignal = if skipPageEvent then skipPageEvent.Event else nil;
          layoutOrder = index;
          textSize = properties.textSize;
          contentContainerWidth = contentContainerWidth;
          key = `{dialogueModuleScriptFullName}.{currentPageIndex}.{index}`;
          lineHeight = properties.lineHeight;
          letterDelay = if shouldSkip then 0 else properties.dialogueSettings.typewriter.characterDelaySeconds;
          onComplete = onComplete;
        });

        table.insert(messageComponentList, textSegment);

      else

        local possibleComponent = dialogueContentItem:run({
          shouldSkip = shouldSkip or componentIndex > index;
          skipPageSignal = if skipPageEvent then skipPageEvent.Event else nil;
          continuePage = onComplete;
          textComponent = MessageTextSegment;
          textComponentProperties = {
            layoutOrder = index;
            letterDelay = if shouldSkip then 0 else properties.dialogueSettings.typewriter.characterDelaySeconds;
            textSize = properties.textSize;
            contentContainerWidth = contentContainerWidth;
          };
          key = `{dialogueModuleScriptFullName}.{currentPageIndex}.{index}`;
        });

        if possibleComponent then

          table.insert(messageComponentList, possibleComponent);

        end;

      end;

    end;

  end;

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
    MessageComponentList = React.createElement(React.Fragment, {}, messageComponentList);
  });

end;

return ContentContainer;