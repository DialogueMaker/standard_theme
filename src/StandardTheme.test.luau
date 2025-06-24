--!strict

local packages = script.Parent.Parent.roblox_packages;
local StandardTheme = require(script.Parent);
local DialogueMakerTypes = require(packages.DialogueMakerTypes);
local ijw = require(packages.ijw);
local ReactRoblox = require(packages["react-roblox"]);
local React = require(packages.react);
local describe = ijw.describe;
local it = ijw.it;
local expect = ijw.expect;

type Client = DialogueMakerTypes.Client;
type Dialogue = DialogueMakerTypes.Dialogue;
type Page = DialogueMakerTypes.Page;
type Effect = DialogueMakerTypes.Effect;

local screenGui: ScreenGui?;
local reactRoot: ReactRoblox.RootType?;

return {

  describe("StandardTheme", function()

    local function createMockClient(dialogueGUI: GuiBase2d | GuiBase3d, onInitializationAction: (() -> ())?, onCompletionAction: ((self: Dialogue) -> ())?, onCleanupAction: (() -> ())?)

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
        cleanup = function(self)

          return;

        end :: (self: Client) -> ();
        clone = function(self)

          return self;

        end :: (self: Client) -> Client;
        dialogue = {
          type = "Message" :: unknown;
          settings = {
            speaker = {};
            typewriter = {
              characterDelaySeconds = if onCompletionAction then 9999 else 0;
              canPlayerSkipDelay = true;
            };
          } :: DialogueMakerTypes.DialogueSettings;
          getContent = function()

            if onCompletionAction then

              return {"This is a mock dialogue content."};

            end;

            return {};

          end :: any;
          getChildren = function()

            return {};

          end :: any;
          runInitializationAction = function()

            if onInitializationAction then

              onInitializationAction();

            end;

            return;

          end :: DialogueMakerTypes.RunInitializationActionFunction;
          runCompletionAction = function(self)

            if onCompletionAction then

              onCompletionAction(self);

            end;

            return;

          end :: DialogueMakerTypes.RunCompletionActionFunction;
          runCleanupAction = function()

            if onCleanupAction then

              onCleanupAction();

            end;

            return;

          end :: DialogueMakerTypes.RunCleanupActionFunction;
          findNextVerifiedDialogue = function(self)

            return nil;

          end :: DialogueMakerTypes.DialogueFindNextVerifiedDialogueFunction;
        } :: DialogueMakerTypes.Dialogue;
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

      local client = properties.client;
      local onRendered = properties.onRendered;

      React.useEffect(function()
      
        if onRendered then

          onRendered();

        end;

      end, {onRendered});

      return React.createElement(StandardTheme, {
        client = client;
      });

    end;

    return {

      it("has a full size if the dialogue GUI is not a ScreenGui", function()

        expect(function()

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

          local standardTheme = billboardGui:FindFirstChildOfClass("Frame");
          assert(standardTheme, "StandardTheme should be rendered");
          expect(standardTheme.Size).toBe(UDim2.fromScale(1, 1));

          reactRoot:unmount();
          billboardGui:Destroy();
        
        end).toFinishBeforeSeconds(1);

      end);

      it("has a fixed size if the dialogue GUI is a ScreenGui", function()

        expect(function()

          assert(screenGui, "screenGui should be initialized");
          assert(reactRoot, "reactRoot should be initialized");

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

          local standardTheme = screenGui:FindFirstChildOfClass("Frame");
          assert(standardTheme, "StandardTheme should be rendered");
          expect(standardTheme.Size).toNotBe(UDim2.fromScale(1, 1));
        
        end).toFinishBeforeSeconds(1);

      end);

      it("can run dialogue initialization action immediately", function()

        expect(function()

          assert(screenGui, "screenGui should be initialized");
          assert(reactRoot, "reactRoot should be initialized");

          local continueEvent = Instance.new("BindableEvent");
          local mockClient = createMockClient(screenGui, function()

            continueEvent:Fire();

          end);
          local element = React.createElement(MockComponent, {
            client = mockClient;
          });

          reactRoot:render(element);
          continueEvent.Event:Wait();
        
        end).toFinishBeforeSeconds(1);

      end);

      it("can run dialogue completion action when typewriting is finished", function()

        expect(function()

          assert(screenGui, "screenGui should be initialized");
          assert(reactRoot, "reactRoot should be initialized");

          local continueEvent = Instance.new("BindableEvent");
          local mockClient = createMockClient(screenGui, nil, function()

            continueEvent:Fire();

          end);
          local element = React.createElement(MockComponent, {
            client = mockClient;
            onRendered = function()

              mockClient:continueDialogue();
            
            end;
          });

          reactRoot:render(element);
          continueEvent.Event:Wait();
        
        end).toFinishBeforeSeconds(1);

      end);

      it("can run dialogue cleanup action before moving to the next page", function()

        expect(function()

          assert(screenGui, "screenGui should be initialized");
          assert(reactRoot, "reactRoot should be initialized");

          local continueEvent = Instance.new("BindableEvent");
          local mockClient = createMockClient(screenGui, nil, function(dialogue)
            
            dialogue:runCleanupAction({} :: Client);

          end, function()

            continueEvent:Fire();

          end);
          local element = React.createElement(MockComponent, {
            client = mockClient;
            onRendered = function()

              mockClient:continueDialogue();
            
            end;
          });

          reactRoot:render(element);
          continueEvent.Event:Wait();
        
        end).toFinishBeforeSeconds(1);

      end);

      -- Not testable right now, as we can't change the screen size in the test environment yet.
      -- it("can resize if screen size changes", function()

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