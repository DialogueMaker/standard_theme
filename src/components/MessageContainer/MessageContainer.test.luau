--!strict

local packages = script.Parent.Parent.Parent.Parent.roblox_packages;
local MessageContainer = require(script.Parent);
local DialogueMakerTypes = require(packages.DialogueMakerTypes);
local ijw = require(packages.ijw);
local ReactRoblox = require(packages["react-roblox"]);
local React = require(packages.react);
local describe = ijw.describe;
local it = ijw.it;
local expect = ijw.expect;

type Client = DialogueMakerTypes.Client;
type Page = DialogueMakerTypes.Page;
type Effect = DialogueMakerTypes.Effect;

local screenGui: ScreenGui?;
local reactRoot: ReactRoblox.RootType?;

return {

  describe("MessageContainer", function()

    local function MockComponent(properties: any)

      -- local isTypingFinished, setIsTypingFinished = React.useState(false);
      -- local onRendered = properties.onRendered;

      -- React.useEffect(function()
      
      --   if onRendered then

      --     onRendered();

      --   end;

      -- end, {onRendered});

      -- React.useEffect(function()

      --   if isTypingFinished then

      --     properties.continueEvent:Fire();

      --   end;

      -- end, {isTypingFinished});

      -- return React.createElement(MessageContainer, {

      -- });

    end;

    return {

      it("has a full height if the dialogue GUI is not a ScreenGui", function()

        error("Not implemented");

      end);

      it("has a fixed height if the dialogue GUI is a ScreenGui", function()

        error("Not implemented");

      end);

      it("can continue the conversation with the Dialogue Maker Client API", function()

        error("Not implemented");

      end);

      it("has an indicator to continue to the next page", function()

        error("Not implemented");

      end);

      it("hides its next page indicator if there isn't a next page", function()

        error("Not implemented");

      end);

      -- Not directly testable yet, as Roblox doesn't support testing with events like InputBegan.
      -- it("can click to continue to the next dialogue", function()

      -- end);

      -- it("can tap to continue to the next dialogue", function()

      -- end)

      -- it("supports keybinds to continue to the next dialogue", function()

      -- end);

    }

  end);

};