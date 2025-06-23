--!strict

local packages = script.Parent.Parent.Parent.Parent.Parent.Parent.roblox_packages;
local NameTag = require(script.Parent);
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

return {

  describe("NameTag", function()

    local function MockParentComponent(properties: any)

      local onRendered = properties.onRendered;

      React.useEffect(function()

        if onRendered then
          onRendered();
        end

      end, {onRendered});

      return React.createElement(NameTag, {
        speakerName = properties.speakerName;
        parentPadding = properties.parentPadding or 0;
      });

    end

    return {

      it("should render with a given name", function()

        local screenGui = Instance.new("ScreenGui");
        local reactRoot = ReactRoblox.createRoot(screenGui);
        local continueEvent = Instance.new("BindableEvent");
        local speakerName = "Test Name";
        local element = React.createElement(MockParentComponent, {
          speakerName = speakerName;
          onRendered = function()

            continueEvent:Fire();

          end;
        });

        reactRoot:render(element);
        continueEvent.Event:Wait();

        local nameTag = screenGui:FindFirstChildOfClass("TextLabel");
        assert(nameTag, "NameTag should be created");
        expect(nameTag.Text).toBe(speakerName);

      end)

    }

  end);

}