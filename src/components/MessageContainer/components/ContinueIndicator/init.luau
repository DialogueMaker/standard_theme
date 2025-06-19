--!strict
-- ContinueIndicator is a component that displays a small image in the message container.
-- It indicates that the player can continue the dialogue by clicking or tapping on the container.
--
-- Programmer: Christian Toney (Christian_Toney)
-- © 2025 Dialogue Maker Group

local TweenService = game:GetService("TweenService");

local packages = script.Parent.Parent.Parent.Parent.Parent.roblox_packages;
local React = require(packages.react);

local function ContinueIndicator()

  local ref = React.useRef(nil :: ImageLabel?);

  React.useEffect(function()
  
    local imageLabel = ref.current;
    if not imageLabel then
      
      return;
    
    end;

    local tweenTask = task.spawn(function()
    
      while task.wait() do

        local downTween = TweenService:Create(imageLabel, TweenInfo.new(), {
          Position = UDim2.new(1, 0, 1, 10);
        });

        downTween:Play();
        downTween.Completed:Wait();

        local upTween = TweenService:Create(imageLabel, TweenInfo.new(), {
          Position = UDim2.new(1, 0, 1, 0);
        });
        upTween:Play();
        upTween.Completed:Wait();

      end;

    end);

    return function()
    
      if tweenTask then

        task.cancel(tweenTask);

      end;

    end;

  end, {});

  return React.createElement("ImageLabel", {
    AnchorPoint = Vector2.new(1, 1);
    Position = UDim2.fromScale(1, 1);
    Size = UDim2.new(0, 25, 0, 25);
    Image = "rbxassetid://124370041275317";
    BackgroundTransparency = 1;
    ref = ref;
  });

end;

return React.memo(ContinueIndicator);