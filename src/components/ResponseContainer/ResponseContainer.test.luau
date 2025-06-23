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

  describe("ResponseContainer", function()

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

      it("can render responses in the correct order", function()

        error("Not implemented");

      end);

    }

  end);

};