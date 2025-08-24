local Library = {}
Library.__index = Library

local DefaultSettings = {
    WindowName = "Window",
    WindowSize = UDim2.new(0, 650, 0, 300)
}

local Window = {}
Window.__index = Window

local Tab = {}
Tab.__index = Tab

function Library.new()
    local self = setmetatable({}, Library)
    return self
end

function Library:CreateWindow(settings)
    settings = settings or DefaultSettings
    local window = setmetatable({}, Window)
    
    if not game or not game.Players or not game.Players.LocalPlayer or not game.Players.LocalPlayer.PlayerGui then
        warn("Cannot initialize UI: PlayerGui not accessible")
        return nil
    end
    
    window.MainFrame = Instance.new("ScreenGui")
    window.MainFrame.Name = settings.WindowName or DefaultSettings.WindowName
    window.MainFrame.Parent = game.Players.LocalPlayer.PlayerGui
    window.MainFrame.ResetOnSpawn = false
    
    window.Frame = Instance.new("Frame")
    window.Frame.Size = settings.WindowSize or DefaultSettings.WindowSize
    window.Frame.Position = UDim2.new(0.5, -settings.WindowSize.X.Offset/2, 0.5, -settings.WindowSize.Y.Offset/2)
    window.Frame.BackgroundColor3 = Color3.fromRGB(33, 150, 243)
    window.Frame.BackgroundTransparency = 0.3
    window.Frame.BorderSizePixel = 0
    window.Frame.Parent = window.MainFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = window.Frame
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -10, 0, 30)
    title.Position = UDim2.new(0, 5, 0, 5)
    title.BackgroundTransparency = 1
    title.Text = settings.WindowName
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 16
    title.Font = Enum.Font.RobotoMono
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = window.Frame
    
    window.TabFrame = Instance.new("Frame")
    window.TabFrame.Size = UDim2.new(1, -10, 0, 30)
    window.TabFrame.Position = UDim2.new(0, 5, 0, 35)
    window.TabFrame.BackgroundTransparency = 1
    window.TabFrame.Parent = window.Frame
    
    window.TabList = Instance.new("UIListLayout")
    window.TabList.FillDirection = Enum.FillDirection.Horizontal
    window.TabList.SortOrder = Enum.SortOrder.LayoutOrder
    window.TabList.Padding = UDim.new(0, 5)
    window.TabList.Parent = window.TabFrame
    
    window.ContentFrame = Instance.new("Frame")
    window.ContentFrame.Size = UDim2.new(1, -10, 1, -75)
    window.ContentFrame.Position = UDim2.new(0, 5, 0, 70)
    window.ContentFrame.BackgroundTransparency = 1
    window.ContentFrame.ClipsDescendants = true
    window.ContentFrame.Parent = window.Frame
    
    window:MakeDraggable()
    
    window.Tabs = {}
    window.Elements = {}
    window.YOffset = 10
    
    window.Frame.BackgroundTransparency = 1
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = game:GetService("TweenService"):Create(window.Frame, tweenInfo, {BackgroundTransparency = 0.3})
    tween:Play()
    
    return window
end

function Window:MakeDraggable()
    local dragging = false
    local dragInput, dragStart, startPos
    
    local function updateInput(input)
        local delta = input.Position - dragStart
        local targetPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Linear)
        local tween = game:GetService("TweenService"):Create(self.Frame, tweenInfo, {Position = targetPos})
        tween:Play()
    end
    
    self.Frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = self.Frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    self.Frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            updateInput(input)
        end
    end)
end

function Window:AddTab(settings)
    settings = settings or {}
    local tab = setmetatable({}, Tab)
    
    tab.Button = Instance.new("TextButton")
    tab.Button.Size = UDim2.new(0, 100, 1, 0)
    tab.Button.BackgroundColor3 = Color3.fromRGB(66, 165, 245)
    tab.Button.Text = settings.Text or "Tab"
    tab.Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    tab.Button.TextSize = 14
    tab.Button.Font = Enum.Font.RobotoMono
    tab.Button.BackgroundTransparency = 1
    tab.Button.Parent = self.TabFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = tab.Button
    
    tab.Container = Instance.new("Frame")
    tab.Container.Size = UDim2.new(1, 0, 1, 0)
    tab.Container.BackgroundTransparency = 1
    tab.Container.Visible = false
    tab.Container.Parent = self.ContentFrame
    
    tab.Elements = {}
    tab.YOffset = 10
    
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = game:GetService("TweenService"):Create(tab.Button, tweenInfo, {BackgroundTransparency = 0})
    tween:Play()
    
    tab.Button.MouseButton1Click:Connect(function()
        for _, otherTab in pairs(self.Tabs) do
            otherTab.Container.Visible = false
            local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            local tween = game:GetService("TweenService"):Create(otherTab.Button, tweenInfo, {BackgroundColor3 = Color3.fromRGB(66, 165, 245)})
            tween:Play()
        end
        tab.Container.Visible = true
        local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = game:GetService("TweenService"):Create(tab.Button, tweenInfo, {BackgroundColor3 = Color3.fromRGB(100, 181, 246)})
        tween:Play()
    end)
    
    table.insert(self.Tabs, tab)
    if #self.Tabs == 1 then
        tab.Button:MouseButton1Click()
    end
    return tab
end

function Tab:AddToggle(settings)
    settings = settings or {}
    local toggle = {}
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 30)
    frame.Position = UDim2.new(0, 5, 0, self.YOffset)
    frame.BackgroundColor3 = Color3.fromRGB(66, 165, 245)
    frame.BorderSizePixel = 0
    frame.BackgroundTransparency = 1
    frame.Parent = self.Container
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = frame
    
    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(0.8, 0, 1, 0)
    text.Position = UDim2.new(0, 5, 0, 0)
    text.BackgroundTransparency = 1
    text.Text = settings.Text or "Toggle"
    text.TextColor3 = Color3.fromRGB(255, 255, 255)
    text.TextSize = 14
    text.Font = Enum.Font.RobotoMono
    text.TextXAlignment = Enum.TextXAlignment.Left
    text.Parent = frame
    
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 20, 0, 20)
    toggleBtn.Position = UDim2.new(1, -25, 0, 5)
    toggleBtn.BackgroundColor3 = settings.Value and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    toggleBtn.BorderSizePixel = 0
    toggleBtn.Text = ""
    toggleBtn.Parent = frame
    
    local cornerBtn = Instance.new("UICorner")
    cornerBtn.CornerRadius = UDim.new(0, 4)
    cornerBtn.Parent = toggleBtn
    
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = game:GetService("TweenService"):Create(frame, tweenInfo, {BackgroundTransparency = 0})
    tween:Play()
    
    toggleBtn.MouseButton1Click:Connect(function()
        settings.Value = not settings.Value
        local targetColor = settings.Value and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = game:GetService("TweenService"):Create(toggleBtn, tweenInfo, {BackgroundColor3 = targetColor})
        tween:Play()
        if settings.Callback then
            settings.Callback(settings.Value)
        end
    end)
    
    self.YOffset = self.YOffset + 40
    table.insert(self.Elements, toggle)
    return toggle
end

function Tab:AddButton(settings)
    settings = settings or {}
    local button = {}
    
    local btnFrame = Instance.new("TextButton")
    btnFrame.Size = UDim2.new(1, -10, 0, 30)
    btnFrame.Position = UDim2.new(0, 5, 0, self.YOffset)
    btnFrame.BackgroundColor3 = Color3.fromRGB(66, 165, 245)
    btnFrame.BorderSizePixel = 0
    btnFrame.Text = settings.Text or "Button"
    btnFrame.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnFrame.TextSize = 14
    btnFrame.Font = Enum.Font.RobotoMono
    btnFrame.BackgroundTransparency = 1
    btnFrame.Parent = self.Container
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = btnFrame
    
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = game:GetService("TweenService"):Create(btnFrame, tweenInfo, {BackgroundTransparency = 0})
    tween:Play()
    
    btnFrame.MouseButton1Click:Connect(function()
        local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
        local tween = game:GetService("TweenService"):Create(btnFrame, tweenInfo, {BackgroundColor3 = Color3.fromRGB(100, 181, 246)})
        tween:Play()
        tween.Completed:Connect(function()
            local resetTween = game:GetService("TweenService"):Create(btnFrame, tweenInfo, {BackgroundColor3 = Color3.fromRGB(66, 165, 245)})
            resetTween:Play()
        end)
        if settings.Callback then
            settings.Callback(true)
        end
    end)
    
    self.YOffset = self.YOffset + 40
    table.insert(self.Elements, button)
    return button
end

function Tab:AddSlider(settings)
    settings = settings or {}
    local slider = {}
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 50)
    frame.Position = UDim2.new(0, 5, 0, self.YOffset)
    frame.BackgroundColor3 = Color3.fromRGB(66, 165, 245)
    frame.BorderSizePixel = 0
    frame.BackgroundTransparency = 1
    frame.Parent = self.Container
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = frame
    
    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, 0, 0, 20)
    text.Position = UDim2.new(0, 5, 0, 5)
    text.BackgroundTransparency = 1
    text.Text = settings.Text or "Slider"
    text.TextColor3 = Color3.fromRGB(255, 255, 255)
    text.TextSize = 14
    text.Font = Enum.Font.RobotoMono
    text.TextXAlignment = Enum.TextXAlignment.Left
    text.Parent = frame
    
    local sliderBar = Instance.new("Frame")
    sliderBar.Size = UDim2.new(1, -10, 0, 10)
    sliderBar.Position = UDim2.new(0, 5, 0, 30)
    sliderBar.BackgroundColor3 = Color3.fromRGB(100, 181, 246)
    sliderBar.BorderSizePixel = 0
    sliderBar.Parent = frame
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(33, 150, 243)
    fill.BorderSizePixel = 0
    fill.Parent = sliderBar
    
    local cornerFill = Instance.new("UICorner")
    cornerFill.CornerRadius = UDim.new(0, 4)
    cornerFill.Parent = sliderBar
    
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = game:GetService("TweenService"):Create(frame, tweenInfo, {BackgroundTransparency = 0})
    tween:Play()
    
    local value = settings.Value or 0
    local min = settings.Min or 0
    local max = settings.Max or 100
    
    local function updateSlider(input)
        local relativeX = math.clamp((input.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1)
        value = min + (max - min) * relativeX
        local targetSize = UDim2.new(relativeX, 0, 1, 0)
        local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = game:GetService("TweenService"):Create(fill, tweenInfo, {Size = targetSize})
        tween:Play()
        if settings.Callback then
            settings.Callback(value)
        end
    end
    
    sliderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            updateSlider(input)
        end
    end)
    
    sliderBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            if game:GetService("UserInputService"):IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                updateSlider(input)
            end
        end
    end)
    
    self.YOffset = self.YOffset + 60
    table.insert(self.Elements, slider)
    return slider
end

function Tab:AddDropdown(settings)
    settings = settings or {}
    local dropdown = {}
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 30)
    frame.Position = UDim2.new(0, 5, 0, self.YOffset)
    frame.BackgroundColor3 = Color3.fromRGB(66, 165, 245)
    frame.BorderSizePixel = 0
    frame.BackgroundTransparency = 1
    frame.Parent = self.Container
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = frame
    
    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(0.8, 0, 1, 0)
    text.Position = UDim2.new(0, 5, 0, 0)
    text.BackgroundTransparency = 1
    text.Text = settings.Text or "Dropdown"
    text.TextColor3 = Color3.fromRGB(255, 255, 255)
    text.TextSize = 14
    text.Font = Enum.Font.RobotoMono
    text.TextXAlignment = Enum.TextXAlignment.Left
    text.Parent = frame
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 20, 0, 20)
    button.Position = UDim2.new(1, -25, 0, 5)
    button.BackgroundColor3 = Color3.fromRGB(100, 181, 246)
    button.Text = "▼"
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 12
    button.Font = Enum.Font.RobotoMono
    button.Parent = frame
    
    local dropdownFrame = Instance.new("Frame")
    dropdownFrame.Size = UDim2.new(1, -10, 0, 0)
    dropdownFrame.Position = UDim2.new(0, 5, 0, self.YOffset + 30)
    dropdownFrame.BackgroundColor3 = Color3.fromRGB(66, 165, 245)
    dropdownFrame.BorderSizePixel = 0
    dropdownFrame.Visible = false
    dropdownFrame.Parent = self.Container
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = dropdownFrame
    
    local values = settings.Values or {1, 2, 3}
    for i, v in ipairs(values) do
        local option = Instance.new("TextButton")
        option.Size = UDim2.new(1, 0, 0, 20)
        option.BackgroundColor3 = Color3.fromRGB(100, 181, 246)
        option.Text = tostring(v)
        option.TextColor3 = Color3.fromRGB(255, 255, 255)
        option.TextSize = 14
        option.Font = Enum.Font.RobotoMono
        option.Parent = dropdownFrame
        
        option.MouseButton1Click:Connect(function()
            settings.Value = v
            text.Text = settings.Text .. ": " .. tostring(v)
            local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            local tween = game:GetService("TweenService"):Create(dropdownFrame, tweenInfo, {Size = UDim2.new(1, -10, 0, 0)})
            tween:Play()
            tween.Completed:Connect(function()
                dropdownFrame.Visible = false
            end)
            if settings.Callback then
                settings.Callback(v)
            end
        end)
    end
    
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = game:GetService("TweenService"):Create(frame, tweenInfo, {BackgroundTransparency = 0})
    tween:Play()
    
    button.MouseButton1Click:Connect(function()
        dropdownFrame.Visible = not dropdownFrame.Visible
        local targetSize = dropdownFrame.Visible and UDim2.new(1, -10, 0, #values * 20) or UDim2.new(1, -10, 0, 0)
        local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = game:GetService("TweenService"):Create(dropdownFrame, tweenInfo, {Size = targetSize})
        tween:Play()
    end)
    
    self.YOffset = self.YOffset + 40
    table.insert(self.Elements, dropdown)
    return dropdown
end

function Tab:AddLabel(settings)
    settings = settings or {}
    local label = {}
    
    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, -10, 0, 20)
    text.Position = UDim2.new(0, 5, 0, self.YOffset)
    text.BackgroundTransparency = 1
    text.Text = settings.Text or "Label"
    text.TextColor3 = Color3.fromRGB(255, 255, 255)
    text.TextSize = 14
    text.Font = Enum.Font.RobotoMono
    text.TextXAlignment = Enum.TextXAlignment.Left
    text.Parent = self.Container
    
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = game:GetService("TweenService"):Create(text, tweenInfo, {TextTransparency = 0})
    tween:Play()
    
    self.YOffset = self.YOffset + 30
    table.insert(self.Elements, label)
    return label
end

function Tab:AddTextBox(settings)
    settings = settings or {}
    local textBox = {}
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 30)
    frame.Position = UDim2.new(0, 5, 0, self.YOffset)
    frame.BackgroundColor3 = Color3.fromRGB(66, 165, 245)
    frame.BorderSizePixel = 0
    frame.BackgroundTransparency = 1
    frame.Parent = self.Container
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = frame
    
    local input = Instance.new("TextBox")
    input.Size = UDim2.new(1, -10, 1, -10)
    input.Position = UDim2.new(0, 5, 0, 5)
    input.BackgroundTransparency = 1
    input.Text = settings.Text or ""
    input.TextColor3 = Color3.fromRGB(255, 255, 255)
    input.TextSize = 14
    input.Font = Enum.Font.RobotoMono
    input.TextXAlignment = Enum.TextXAlignment.Left
    input.Parent = frame
    
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = game:GetService("TweenService"):Create(frame, tweenInfo, {BackgroundTransparency = 0})
    tween:Play()
    
    input.FocusLost:Connect(function(enterPressed)
        if enterPressed and settings.Callback then
            settings.Callback(input.Text)
        end
    end)
    
    self.YOffset = self.YOffset + 40
    table.insert(self.Elements, textBox)
    return textBox
end

function Window:SetKeybind(settings)
    settings = settings or {}
    local keybind = settings.Key or Enum.KeyCode.F
    local connection
    
    local function toggleGui()
        if not self.MainFrame then return end
        self.MainFrame.Enabled = not self.MainFrame.Enabled
        local targetTransparency = self.MainFrame.Enabled and 0.3 or 1
        local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = game:GetService("TweenService"):Create(self.Frame, tweenInfo, {BackgroundTransparency = targetTransparency})
        tween:Play()
        for _, tab in pairs(self.Tabs) do
            tab.Container.Visible = self.MainFrame.Enabled and tab.Button.BackgroundColor3 == Color3.fromRGB(100, 181, 246)
        end
    end
    
    connection = game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == keybind then
            toggleGui()
        end
    end)
    
    return {
        ChangeKey = function(newKey)
            keybind = newKey
        end,
        Disconnect = function()
            if connection then
                connection:Disconnect()
            end
        end
    }
end

return Library
