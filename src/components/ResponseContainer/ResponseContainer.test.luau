--!strict

local packages = script.Parent.Parent.Parent.Parent.roblox_packages;
local ResponseContainer = require(script.Parent);
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

      local onRendered = properties.onRendered;

      React.useEffect(function()
      
        if onRendered then

          onRendered();

        end;

      end, {onRendered});

      return React.createElement(ResponseContainer, {
        responses = properties.responses;
        onComplete = function() end;
      });

    end;

    return {

      it("can render responses in the correct order", function()

        assert(screenGui, "ScreenGui should be initialized.");
        assert(reactRoot, "React root should be initialized.");

        -- Render the ContentContainer.
        local mockResponses = {
          {
            getContent = function()
              return {"1"};
            end;
          }, {
            getContent = function()
              return {"2"};
            end;
          }
        };
        local continueEvent = Instance.new("BindableEvent");

        reactRoot:render(React.createElement(MockComponent, {
          responses = mockResponses;
          onRendered = function()
            continueEvent:Fire();
          end;
        }));

        -- Wait for the typing to finish.
        continueEvent.Event:Wait();
        
        -- Check if the text is on screen.
        local responseContainer = screenGui:FindFirstChildOfClass("Frame");
        assert(responseContainer, "ResponseContainer should be created.");

        local textButtons = {};
        for _, child in responseContainer:GetChildren() do

          if child:IsA("TextButton") then

            expect(child.Text).toBe(`{child.LayoutOrder}`);
            table.insert(textButtons, child);

          end;

        end;

        expect(#textButtons).toBe(2);

      end);

    }

  end, {
    beforeEach = function()
    
      local newScreenGui = Instance.new("ScreenGui");
      screenGui = newScreenGui;
      reactRoot = ReactRoblox.createRoot(newScreenGui);

    end;
    afterEach = function()

      if reactRoot then

        reactRoot:unmount();

      end;

      if screenGui then

        screenGui:Destroy();

      end;

    end;
  });

};