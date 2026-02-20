local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local isLagging = false
local uuid = "d80e2217-36b8-4bdc-9a46-2281c6f70b28"
local power = 50

local target = nil
local fireLoop = nil

local function findTarget()
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("RemoteEvent") and v.Name ~= "friendmain" and v.Name ~= "ping" then
            return v
        end
    end
    return nil
end

target = findTarget()

-- ========== SPEED BOOSTER ==========
local SpeedBooster = {}
do
    SpeedBooster.running = false
    SpeedBooster.connection = nil
    SpeedBooster.speedValue = 50

    local character, humanoid, hrp
    
    local function updateCharRefs()
        character = player.Character or player.CharacterAdded:Wait()
        humanoid = character:FindFirstChildOfClass("Humanoid")
        hrp = character:FindFirstChild("HumanoidRootPart")
    end

    updateCharRefs()
    player.CharacterAdded:Connect(updateCharRefs)

    function SpeedBooster:Start()
        if self.running then return end
        self.running = true

        if self.connection then self.connection:Disconnect() end

        self.connection = RunService.Heartbeat:Connect(function()
            if not (character and humanoid and hrp) then
                updateCharRefs()
                if not (humanoid and hrp) then return end
            end

            local moveDir = humanoid.MoveDirection
            if moveDir.Magnitude == 0 then return end

            hrp.AssemblyLinearVelocity = Vector3.new(
                moveDir.X * self.speedValue,
                hrp.AssemblyLinearVelocity.Y,
                moveDir.Z * self.speedValue
            )
        end)
    end

    function SpeedBooster:Stop()
        self.running = false
        if self.connection then
            self.connection:Disconnect()
            self.connection = nil
        end
        if humanoid then
            humanoid.WalkSpeed = 16
        end
    end

    player.CharacterAdded:Connect(function()
        self:Stop()
        task.delay(0.5, function()
            updateCharRefs()
        end)
    end)
end

-- ========== GUI CREATION ==========
local gui = Instance.new("ScreenGui")
gui.Name = "El1teUI"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

-- Main Frame (Draggable)
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.fromOffset(260, 380)
frame.Position = UDim2.fromScale(0.5, 0.5)
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.ClipsDescendants = true

local frameCorner = Instance.new("UICorner", frame)
frameCorner.CornerRadius = UDim.new(0, 16)

-- Gradient Background
local gradient = Instance.new("UIGradient", frame)
gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 25, 35)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 20))
}
gradient.Rotation = 45

-- Border Glow
local border = Instance.new("UIStroke", frame)
border.Color = Color3.fromRGB(80, 120, 255)
border.Thickness = 2
border.Transparency = 0.3

task.spawn(function()
    while frame and frame.Parent do
        for i = 0, 360, 2 do
            if not frame or not frame.Parent then break end
            local hue = i / 360
            border.Color = Color3.fromHSV(hue, 0.7, 1)
            task.wait(0.03)
        end
    end
end)

-- Shadow Effect
local shadow = Instance.new("ImageLabel", frame)
shadow.Size = UDim2.new(1, 40, 1, 40)
shadow.Position = UDim2.fromOffset(-20, -20)
shadow.BackgroundTransparency = 1
shadow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
shadow.ImageTransparency = 0.7
shadow.ZIndex = 0

-- Title Bar
local titleBar = Instance.new("Frame", frame)
titleBar.Size = UDim2.new(1, 0, 0, 50)
titleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
titleBar.BorderSizePixel = 0
titleBar.ZIndex = 2

local titleCorner = Instance.new("UICorner", titleBar)
titleCorner.CornerRadius = UDim.new(0, 16)

local titleBarBottom = Instance.new("Frame", titleBar)
titleBarBottom.Size = UDim2.new(1, 0, 0, 16)
titleBarBottom.Position = UDim2.fromScale(0, 1)
titleBarBottom.AnchorPoint = Vector2.new(0, 1)
titleBarBottom.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
titleBarBottom.BorderSizePixel = 0

-- Title Text
local title = Instance.new("TextLabel", titleBar)
title.Size = UDim2.new(1, -80, 1, 0)
title.Position = UDim2.fromOffset(20, 0)
title.BackgroundTransparency = 1
title.Text = "⚡ EL1TE TOOLS"
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextXAlignment = Enum.TextXAlignment.Left

-- Animated title
task.spawn(function()
    while title and title.Parent do
        TweenService:Create(title, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
            TextColor3 = Color3.fromRGB(120, 180, 255)
        }):Play()
        task.wait(2)
        TweenService:Create(title, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
            TextColor3 = Color3.fromRGB(255, 255, 255)
        }):Play()
        task.wait(2)
    end
end)

-- Minimize Button
local minimizeBtn = Instance.new("TextButton", titleBar)
minimizeBtn.Size = UDim2.fromOffset(30, 30)
minimizeBtn.Position = UDim2.new(1, -40, 0.5, -15)
minimizeBtn.Text = "−"
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.TextSize = 20
minimizeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
minimizeBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
minimizeBtn.AutoButtonColor = false
minimizeBtn.BorderSizePixel = 0

local minCorner = Instance.new("UICorner", minimizeBtn)
minCorner.CornerRadius = UDim.new(0, 8)

minimizeBtn.MouseEnter:Connect(function()
    TweenService:Create(minimizeBtn, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    }):Play()
end)

minimizeBtn.MouseLeave:Connect(function()
    TweenService:Create(minimizeBtn, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    }):Play()
end)

minimizeBtn.MouseButton1Click:Connect(function()
    TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        Size = UDim2.fromOffset(0, 0)
    }):Play()
    
    task.wait(0.3)
    frame.Visible = false
    
    if playerGui:FindFirstChild("El1teMinimizeBtn") then return end
    
    local btn = Instance.new("TextButton", playerGui)
    btn.Name = "El1teMinimizeBtn"
    btn.Size = UDim2.fromOffset(120, 40)
    btn.Position = UDim2.fromScale(0.02, 0.5)
    btn.AnchorPoint = Vector2.new(0, 0.5)
    btn.Text = "▶ EL1TE"
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 16
    btn.BorderSizePixel = 0
    
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
    local btnStroke = Instance.new("UIStroke", btn)
    btnStroke.Color = Color3.fromRGB(80, 120, 255)
    btnStroke.Thickness = 2
    
    btn.MouseButton1Click:Connect(function()
        frame.Visible = true
        frame.Size = UDim2.fromOffset(0, 0)
        TweenService:Create(frame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.fromOffset(260, 380)
        }):Play()
        btn:Destroy()
    end)
end)

-- Status Label
local status = Instance.new("TextLabel", frame)
status.Size = UDim2.new(1, -40, 0, 30)
status.Position = UDim2.fromOffset(20, 60)
status.BackgroundTransparency = 1
status.Text = "🟢 Ready"
status.Font = Enum.Font.GothamMedium
status.TextSize = 14
status.TextColor3 = Color3.fromRGB(100, 255, 150)
status.TextXAlignment = Enum.TextXAlignment.Center

-- Content Container
local content = Instance.new("Frame", frame)
content.Size = UDim2.new(1, -40, 1, -100)
content.Position = UDim2.fromOffset(20, 100)
content.BackgroundTransparency = 1

-- Function to create modern buttons
local function makeButton(text, layoutOrder)
    local b = Instance.new("TextButton", content)
    b.Size = UDim2.new(1, 0, 0, 42)
    b.BackgroundColor3 = Color3.fromRGB(30, 35, 45)
    b.BorderSizePixel = 0
    b.Text = text
    b.Font = Enum.Font.GothamBold
    b.TextSize = 15
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.AutoButtonColor = false
    b.LayoutOrder = layoutOrder
    
    local corner = Instance.new("UICorner", b)
    corner.CornerRadius = UDim.new(0, 10)
    
    local stroke = Instance.new("UIStroke", b)
    stroke.Color = Color3.fromRGB(60, 80, 120)
    stroke.Thickness = 1
    stroke.Transparency = 0.5
    
    b.MouseEnter:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(45, 55, 75)
        }):Play()
        TweenService:Create(stroke, TweenInfo.new(0.2), {
            Color = Color3.fromRGB(100, 150, 255),
            Transparency = 0
        }):Play()
    end)
    
    b.MouseLeave:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(30, 35, 45)
        }):Play()
        TweenService:Create(stroke, TweenInfo.new(0.2), {
            Color = Color3.fromRGB(60, 80, 120),
            Transparency = 0.5
        }):Play()
    end)
    
    return b
end

-- UI Layout
local layout = Instance.new("UIListLayout", content)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 10)

-- LAG Toggle Button
local toggleBtn = makeButton("🔴 LAG: OFF", 1)
toggleBtn.MouseButton1Click:Connect(function()
    local origSize = toggleBtn.Size
    TweenService:Create(toggleBtn, TweenInfo.new(0.1), {
        Size = UDim2.new(origSize.X.Scale, origSize.X.Offset, origSize.Y.Scale, origSize.Y.Offset - 4)
    }):Play()
    task.wait(0.1)
    TweenService:Create(toggleBtn, TweenInfo.new(0.1), {Size = origSize}):Play()
    
    isLagging = not isLagging
    if isLagging then
        if not target then
            target = findTarget()
            if not target then
                isLagging = false
                status.Text = "❌ No target!"
                status.TextColor3 = Color3.fromRGB(255, 100, 100)
                return
            end
        end
        fireLoop = task.spawn(function()
            while isLagging and target do
                local payload = string.rep("z", power * 200)
                pcall(function() target:FireServer(uuid, payload) end)
                task.wait(0.05)
            end
        end)
        status.Text = "⚡ Lagging..."
        status.TextColor3 = Color3.fromRGB(255, 200, 100)
        toggleBtn.Text = "🟢 LAG: ON"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 80, 40)
    else
        status.Text = "🔴 Stopped"
        status.TextColor3 = Color3.fromRGB(255, 100, 100)
        toggleBtn.Text = "🔴 LAG: OFF"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(30, 35, 45)
    end
end)

-- Power Section
local powerSection = Instance.new("Frame", content)
powerSection.Size = UDim2.new(1, 0, 0, 60)
powerSection.BackgroundColor3 = Color3.fromRGB(25, 28, 35)
powerSection.BorderSizePixel = 0
powerSection.LayoutOrder = 2

Instance.new("UICorner", powerSection).CornerRadius = UDim.new(0, 10)

local powerLabel = Instance.new("TextLabel", powerSection)
powerLabel.Size = UDim2.new(1, -20, 0, 25)
powerLabel.Position = UDim2.fromOffset(10, 5)
powerLabel.BackgroundTransparency = 1
powerLabel.Text = "⚙️ Power: 50"
powerLabel.TextColor3 = Color3.fromRGB(200, 220, 255)
powerLabel.Font = Enum.Font.GothamBold
powerLabel.TextSize = 14
powerLabel.TextXAlignment = Enum.TextXAlignment.Left

local sliderBg = Instance.new("Frame", powerSection)
sliderBg.Size = UDim2.new(1, -20, 0, 8)
sliderBg.Position = UDim2.fromOffset(10, 35)
sliderBg.BackgroundColor3 = Color3.fromRGB(40, 45, 55)
sliderBg.BorderSizePixel = 0

Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(1, 0)

local sliderFill = Instance.new("Frame", sliderBg)
sliderFill.Size = UDim2.new(0.5, 0, 1, 0)
sliderFill.BackgroundColor3 = Color3.fromRGB(80, 150, 255)
sliderFill.BorderSizePixel = 0
sliderFill.ZIndex = 2

Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(1, 0)

local sliderKnob = Instance.new("Frame", sliderBg)
sliderKnob.Size = UDim2.fromOffset(18, 18)
sliderKnob.Position = UDim2.new(0.5, -9, 0.5, -9)
sliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
sliderKnob.BorderSizePixel = 0
sliderKnob.ZIndex = 3

Instance.new("UICorner", sliderKnob).CornerRadius = UDim.new(1, 0)

local knobStroke = Instance.new("UIStroke", sliderKnob)
knobStroke.Color = Color3.fromRGB(80, 150, 255)
knobStroke.Thickness = 2

local draggingSlider = false

local function updateSliderFromPower()
    local pos = ((power - 1) / 199)
    sliderKnob.Position = UDim2.new(pos, -9, 0.5, -9)
    sliderFill.Size = UDim2.new(pos, 0, 1, 0)
    powerLabel.Text = "⚙️ Power: " .. power
end

local function updateSliderFromInput(input)
    if sliderBg.AbsoluteSize.X > 0 then
        local rel = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
        power = math.floor(1 + rel * 199)
        updateSliderFromPower()
    end
end

sliderBg.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingSlider = true
        updateSliderFromInput(input)
    end
end)

sliderKnob.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingSlider = true
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        updateSliderFromInput(input)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingSlider = false
    end
end)

-- Speed Section
local speedSection = Instance.new("Frame", content)
speedSection.Size = UDim2.new(1, 0, 0, 80)
speedSection.BackgroundColor3 = Color3.fromRGB(25, 28, 35)
speedSection.BorderSizePixel = 0
speedSection.LayoutOrder = 3

Instance.new("UICorner", speedSection).CornerRadius = UDim.new(0, 10)

local speedLabel = Instance.new("TextLabel", speedSection)
speedLabel.Size = UDim2.new(1, -20, 0, 25)
speedLabel.Position = UDim2.fromOffset(10, 5)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "🏃 Speed Value"
speedLabel.TextColor3 = Color3.fromRGB(200, 220, 255)
speedLabel.Font = Enum.Font.GothamBold
speedLabel.TextSize = 14
speedLabel.TextXAlignment = Enum.TextXAlignment.Left

local speedBox = Instance.new("TextBox", speedSection)
speedBox.Size = UDim2.new(1, -20, 0, 35)
speedBox.Position = UDim2.fromOffset(10, 35)
speedBox.BackgroundColor3 = Color3.fromRGB(35, 40, 50)
speedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
speedBox.Font = Enum.Font.GothamBold
speedBox.TextSize = 16
speedBox.PlaceholderText = "Enter speed (16-200)"
speedBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 140)
speedBox.Text = tostring(SpeedBooster.speedValue)
speedBox.ClearTextOnFocus = false
speedBox.BorderSizePixel = 0

Instance.new("UICorner", speedBox).CornerRadius = UDim.new(0, 8)

local speedBoxStroke = Instance.new("UIStroke", speedBox)
speedBoxStroke.Color = Color3.fromRGB(60, 80, 120)
speedBoxStroke.Thickness = 1

speedBox:GetPropertyChangedSignal("Text"):Connect(function()
    local num = tonumber(speedBox.Text)
    if num and num >= 16 and num <= 200 then
        SpeedBooster.speedValue = num
        speedLabel.Text = "🏃 Speed Value: " .. num
    end
end)

speedBox.FocusLost:Connect(function()
    local num = tonumber(speedBox.Text)
    if not num or num < 16 or num > 200 then
        speedBox.Text = tostring(SpeedBooster.speedValue)
    else
        SpeedBooster.speedValue = num
        speedLabel.Text = "🏃 Speed Value: " .. num
    end
end)

-- Speed Toggle Button
local speedToggle = makeButton("🔴 SPEED: OFF", 4)
speedToggle.MouseButton1Click:Connect(function()
    local origSize = speedToggle.Size
    TweenService:Create(speedToggle, TweenInfo.new(0.1), {
        Size = UDim2.new(origSize.X.Scale, origSize.X.Offset, origSize.Y.Scale, origSize.Y.Offset - 4)
    }):Play()
    task.wait(0.1)
    TweenService:Create(speedToggle, TweenInfo.new(0.1), {Size = origSize}):Play()
    
    if SpeedBooster.running then
        SpeedBooster:Stop()
        speedToggle.Text = "🔴 SPEED: OFF"
        speedToggle.BackgroundColor3 = Color3.fromRGB(30, 35, 45)
        status.Text = "🔴 Speed disabled"
        status.TextColor3 = Color3.fromRGB(255, 100, 100)
    else
        SpeedBooster:Start()
        speedToggle.Text = "🟢 SPEED: ON"
        speedToggle.BackgroundColor3 = Color3.fromRGB(40, 80, 40)
        status.Text = "⚡ Speed active"
        status.TextColor3 = Color3.fromRGB(100, 255, 150)
    end
end)

-- Auto-find target loop
task.spawn(function()
    while frame and frame.Parent do
        if not target then
            target = findTarget()
        end
        task.wait(5)
    end
end)

-- Hotkey
UserInputService.InputBegan:Connect(function(input, proc)
    if not proc and input.KeyCode == Enum.KeyCode.R then
        toggleBtn.MouseButton1Click:Invoke()
    end
end)

updateSliderFromPower()

-- Entry animation
frame.Size = UDim2.fromOffset(0, 0)
task.wait(0.1)
TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Size = UDim2.fromOffset(260, 380)
}):Play()
