--!strict

local packages = script.Parent.Parent.Parent.Parent.Parent.Parent.roblox_packages;
local ContentContainer = require(script.Parent);
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
  describe("ContentContainer", function()

    local function createMockClient(page: Page?)

      local mockClient = {
        settings = {
          typewriter = {
            characterDelaySeconds = 0;
          };
        };
        dialogue = {
          settings = {
            typewriter = {
              characterDelaySeconds = 0;
            };
          } :: DialogueMakerTypes.DialogueSettings;
          getContent = if page then function()

            return page;

          end :: unknown else nil;
        };
        conversation = {
          settings = {
            typewriter = {
              characterDelaySeconds = 0;
            };
          } :: DialogueMakerTypes.ConversationSettings;
        };
      } :: Client

      return mockClient;

    end;

    local function createMockEffect(text: string)

      return {
        run = function(self, properties)

          properties.onCompleted();

          return React.createElement("TextLabel", {
            Text = text;
          });

        end;
      } :: Effect

    end;

    local function preventRaceCondition(continueEvent: BindableEvent)

      local timeoutTask = task.delay(1, function()

        continueEvent:Fire();

      end);

      continueEvent.Event:Wait();
        
      task.cancel(timeoutTask);
      
    end;

    return {

      it("can render text", function()

        assert(screenGui, "ScreenGui should be initialized.");
        assert(reactRoot, "React root should be initialized.");

        -- Render the ContentContainer.
        local mockClient = createMockClient({"Hello world!"});
        local continueEvent = Instance.new("BindableEvent");

        reactRoot:render(React.createElement(ContentContainer, {
          client = mockClient;
          skipPageEvent = Instance.new("BindableEvent");
          onTypingFinished = function() 
            
            continueEvent:Fire();

          end;
        }));

        -- Wait for the typing to finish.
        -- Multithreading may cause the typing to finish before we hook to the event,
        -- so we use a timeout to force the execution to continue.
        preventRaceCondition(continueEvent);

        -- Check if the text is on screen.
        local contentContainer = screenGui:FindFirstChildOfClass("Frame");
        assert(contentContainer, "ContentContainer should be created.");

        local textElement = contentContainer:FindFirstChildOfClass("TextLabel");
        assert(textElement, "TextLabel should be created.");
        expect(textElement.Text).toBe("Hello world!");

      end);

      it("can render effects", function()
      
        assert(screenGui, "ScreenGui should be initialized.");
        assert(reactRoot, "React root should be initialized.");

        -- Render the ContentContainer.
        local mockEffect = createMockEffect("This was created by an effect.");
        local mockClient = createMockClient(mockEffect);
        local continueEvent = Instance.new("BindableEvent");

        reactRoot:render(React.createElement(ContentContainer, {
          client = mockClient;
          skipPageEvent = Instance.new("BindableEvent");
          onTypingFinished = function() 
            
            continueEvent:Fire();

          end;
        }));

        -- Wait for the typing to finish.
        -- Multithreading may cause the typing to finish before we hook to the event,
        -- so we use a timeout to force the execution to continue.
        preventRaceCondition(continueEvent);

        -- Check if the text is on screen.
        local contentContainer = screenGui:FindFirstChildOfClass("Frame");
        assert(contentContainer, "ContentContainer should be created.");

        local textElement = contentContainer:FindFirstChildOfClass("TextLabel");
        assert(textElement, "TextLabel should be created.");
        expect(textElement.Text).toBe("This was created by an effect.");

      end);

      it("can render content in the correct order", function()

        assert(screenGui, "ScreenGui should be initialized.");
        assert(reactRoot, "React root should be initialized.");

        -- Render the ContentContainer.
        local mockClient = createMockClient({"1", "2", createMockEffect("3"), "4"} :: Page);
        local continueEvent = Instance.new("BindableEvent");

        reactRoot:render(React.createElement(ContentContainer, {
          client = mockClient;
          skipPageEvent = Instance.new("BindableEvent");
          onTypingFinished = function() 
            
            continueEvent:Fire();

          end;
        }));

        -- Wait for the typing to finish.
        -- Multithreading may cause the typing to finish before we hook to the event,
        -- so we use a timeout to force the execution to continue.
        preventRaceCondition(continueEvent);
        
        -- Check if the text is on screen.
        local contentContainer = screenGui:FindFirstChildOfClass("Frame");
        assert(contentContainer, "ContentContainer should be created.");
        expect(#contentContainer:GetChildren()).toBe(4);

        for _, child in contentContainer:GetChildren() do

          if child:IsA("TextLabel") then

            expect(child.Text).toBe(`{child.LayoutOrder}`);

          end;

        end;

      end);

    };

  end, {
    beforeAll = function()
    
      local newScreenGui = Instance.new("ScreenGui");
      screenGui = newScreenGui;
      reactRoot = ReactRoblox.createRoot(newScreenGui);

    end;
    afterEach = function()

      if reactRoot then

        reactRoot:unmount();

      end;

    end;
    afterAll = function()
    
      if screenGui then

        screenGui:Destroy();

      end;

    end;
  });
};