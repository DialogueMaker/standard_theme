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

    local function createMockClient(dialogueGUI: GuiBase2d | GuiBase3d, shouldHaveChildren: boolean?)

      local mockClient = {
        dialogueGUI = dialogueGUI;
        settings = {
          keybinds = {};
          typewriter = {
            characterDelaySeconds = 0;
          };
        };
        continueDialogueBindableFunction = Instance.new("BindableFunction");
        continueDialogue = function(self)

          self.continueDialogueBindableFunction:Invoke();
        
        end :: (self: Client) -> ();
        dialogue = {
          settings = {
            speaker = {};
            typewriter = {
              characterDelaySeconds = 0;
            };
          } :: DialogueMakerTypes.DialogueSettings;
          getContent = function()

            return {};

          end :: unknown;
          getChildren = function()

            if shouldHaveChildren then

              return {
                {
                  type = "Message";
                  verifyCondition = function() return true; end;
                }
              };

            end;

            return {};

          end :: unknown;
        };
        conversation = {
          settings = {
            speaker = {};
            typewriter = {
              characterDelaySeconds = 0;
            };
          } :: DialogueMakerTypes.ConversationSettings;
        };
      } :: Client

      return mockClient;

    end;

    local function MockComponent(properties: any)

      local isTypingFinished, setIsTypingFinished = React.useState(false);
      local client = properties.client;
      local onRendered = properties.onRendered;
      local onTypingFinished = properties.onTypingFinished;
      local onPageFinished = properties.onPageFinished or function() end;

      React.useEffect(function()
      
        if onRendered then

          onRendered();

        end;

      end, {onRendered});

      React.useEffect(function()

        if onTypingFinished and isTypingFinished then

          onTypingFinished();

        end;

      end, {onTypingFinished, isTypingFinished});

      return React.createElement(MessageContainer, {
        onPageFinished = onPageFinished;
        onTypingFinished = function() 
          
          setIsTypingFinished(true);
        
        end;
        isTypingFinished = isTypingFinished;
        client = client;
      });

    end;

    return {

      it("has a full height if the dialogue GUI is not a ScreenGui", function()

        local billboardGui = Instance.new("BillboardGui");
        local reactRoot = ReactRoblox.createRoot(billboardGui);

        local continueEvent = Instance.new("BindableEvent");
        local mockClient = createMockClient(billboardGui);
        local element = React.createElement(MockComponent, {
          client = mockClient;
          onRendered = function()

            continueEvent:Fire();

          end;
        });

        reactRoot:render(element);
        continueEvent.Event:Wait();

        local messageContainer = billboardGui:FindFirstChildOfClass("Frame");
        assert(messageContainer, "MessageContainer should be rendered");
        expect(messageContainer.Size.Y.Scale).toBe(1);

        reactRoot:unmount();
        billboardGui:Destroy();

      end);

      it("has a fixed height if the dialogue GUI is a ScreenGui", function()

        expect(function()

          assert(screenGui, "ScreenGui should be initialized");
          assert(reactRoot, "React root should be initialized");

          local continueEvent = Instance.new("BindableEvent");
          local mockClient = createMockClient(screenGui);
          local element = React.createElement(MockComponent, {
            client = mockClient;
            onRendered = function()

              continueEvent:Fire();

            end;
          });

          reactRoot:render(element);
          continueEvent.Event:Wait();

          local messageContainer = screenGui:FindFirstChildOfClass("Frame");
          assert(messageContainer, "MessageContainer should be rendered");
          expect(messageContainer.Size ~= UDim2.fromScale(1, 1)).toBe(true);

        end).toFinishBeforeSeconds(1);

      end);

      it("can continue the conversation with the Dialogue Maker Client API", function()

        expect(function()

          assert(screenGui, "ScreenGui should be initialized");
          assert(reactRoot, "React root should be initialized");

          local continueEvent = Instance.new("BindableEvent");
          local mockClient = createMockClient(screenGui);
          local element = React.createElement(MockComponent, {
            client = mockClient;
            onPageFinished = function()

              continueEvent:Fire();

            end;
            onTypingFinished = function()

              mockClient:continueDialogue();

            end;
          });

          reactRoot:render(element);
          continueEvent.Event:Wait();

        end).toFinishBeforeSeconds(1);

      end);

      it("can have an indicator to continue to the next page", function()

        expect(function()

          assert(screenGui, "ScreenGui should be initialized");
          assert(reactRoot, "React root should be initialized");

          local mockClient = createMockClient(screenGui, true);
          local element = React.createElement(MockComponent, {
            client = mockClient;
          });

          reactRoot:render(element);
          local messageContainer = screenGui:WaitForChild("Frame", 1);
          assert(messageContainer, "MessageContainer should be rendered");
          expect(messageContainer:FindFirstChild("ContinueIndicator")).toExist();

        end).toFinishBeforeSeconds(1);

      end);

      it("hides its next page indicator if there isn't a next page", function()

        expect(function()

          assert(screenGui, "ScreenGui should be initialized");
          assert(reactRoot, "React root should be initialized");

          local mockClient = createMockClient(screenGui);
          local element = React.createElement(MockComponent, {
            client = mockClient;
          });

          reactRoot:render(element);
          local messageContainer = screenGui:WaitForChild("Frame", 1);
          assert(messageContainer, "MessageContainer should be rendered");
          expect(messageContainer:FindFirstChild("ContinueIndicator")).toBeNil();

        end).toFinishBeforeSeconds(1);

      end);

      -- Not directly testable yet, as Roblox doesn't support testing with events like InputBegan.
      -- it("can click to continue to the next dialogue", function()

      -- end);

      -- it("can tap to continue to the next dialogue", function()

      -- end)

      -- it("supports keybinds to continue to the next dialogue", function()

      -- end);

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