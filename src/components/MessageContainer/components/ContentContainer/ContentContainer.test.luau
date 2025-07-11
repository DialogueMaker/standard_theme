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

    local function createMockClient(page: Page?, characterDelaySeconds: number?)

      local mockClient = {
        settings = {
          typewriter = {
            characterDelaySeconds = 0;
          };
        };
        dialogue = {
          settings = {
            typewriter = {
              characterDelaySeconds = if characterDelaySeconds then characterDelaySeconds else 0;
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
        type = "Effect" :: "Effect";
        run = function(self, properties)

          properties.onCompleted();

          return React.createElement("TextLabel", {
            Text = text;
            LayoutOrder = properties.layoutOrder;
          });

        end;
      } :: Effect

    end;

    local function MockComponent(properties: any)

      local isTypingFinished, setIsTypingFinished = React.useState(false);
      local onRendered = properties.onRendered;

      React.useEffect(function()
      
        if onRendered then

          onRendered();

        end;

      end, {onRendered});

      React.useEffect(function()

        if isTypingFinished then

          properties.continueEvent:Fire();

        end;

      end, {isTypingFinished});

      return React.createElement(ContentContainer, {
        client = properties.client;
        skipPageEvent = properties.skipPageEvent or Instance.new("BindableEvent");
        onTypingFinished = function()
        
          setIsTypingFinished(true);

        end;
      });

    end;

    return {

      it("can render text", function()

        assert(screenGui, "ScreenGui should be initialized.");
        assert(reactRoot, "React root should be initialized.");

        -- Render the ContentContainer.
        local mockClient = createMockClient({"Hello world!"});
        local continueEvent = Instance.new("BindableEvent");

        reactRoot:render(React.createElement(MockComponent, {
          client = mockClient;
          continueEvent = continueEvent;
        }));

        -- Wait for the typing to finish.
        continueEvent.Event:Wait();

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
        local mockClient = createMockClient({mockEffect});
        local continueEvent = Instance.new("BindableEvent");

        reactRoot:render(React.createElement(MockComponent, {
          client = mockClient;
          continueEvent = continueEvent;
        }));

        -- Wait for the typing to finish.
        continueEvent.Event:Wait();

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

        reactRoot:render(React.createElement(MockComponent, {
          client = mockClient;
          continueEvent = continueEvent;
        }));

        -- Wait for the typing to finish.
        continueEvent.Event:Wait();
        
        -- Check if the text is on screen.
        local contentContainer = screenGui:FindFirstChildOfClass("Frame");
        assert(contentContainer, "ContentContainer should be created.");

        local textLabels = {};
        for _, child in contentContainer:GetChildren() do

          if child:IsA("TextLabel") then

            expect(child.Text).toBe(`{child.LayoutOrder}`);
            table.insert(textLabels, child);

          end;

        end;

        expect(#textLabels).toBe(4);

      end);

      it("can immediately reveal message on request", function()

        assert(screenGui, "ScreenGui should be initialized.");
        assert(reactRoot, "React root should be initialized.");

        -- Render the ContentContainer.
        local mockClient = createMockClient({"Lorem ipsum dolor sit amet", " consectetur adipiscing elit"}, 9999);
        local continueEvent = Instance.new("BindableEvent");
        local skipPageEvent = Instance.new("BindableEvent");

        reactRoot:render(React.createElement(MockComponent, {
          client = mockClient;
          continueEvent = continueEvent;
          skipPageEvent = skipPageEvent;
          onRendered = function()
            
            -- Realistically, the user can click at any time to skip the typing.
            skipPageEvent:Fire();

          end;
        }));

        -- Wait for the typing to finish.
        continueEvent.Event:Wait();

        -- Check if the text is on screen.
        local contentContainer = screenGui:FindFirstChildOfClass("Frame");
        assert(contentContainer, "ContentContainer should be created.");

        local textLabels = {};
        for _, child in contentContainer:GetChildren() do

          if child:IsA("TextLabel") then

            expect(child.MaxVisibleGraphemes).toBe(-1);
            table.insert(textLabels, child);

          end;

        end;

        expect(#textLabels).toBe(2);

      end);

    };

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