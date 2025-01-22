-- Required Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

-- Mobile Optimization Setup
local screenWidth = Workspace.CurrentCamera.ViewportSize.X
local OptimizeForMobile = screenWidth < 800  -- Detect mobile screen width

-- Core Setup for VesperaGUI (starting with Rayfield-like system)
local VesperaGUI = {}
VesperaGUI.__index = VesperaGUI

-- Function to Create a Window with Drag and Resize
function VesperaGUI:CreateWindow(WindowDetails)
    local Window = Instance.new("ScreenGui")
    Window.Name = WindowDetails.Name
    Window.Parent = PlayerGui

    -- Window Setup
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = OptimizeForMobile and UDim2.new(0.7, 0, 0.7, 0) or UDim2.new(0.8, 0, 0.8, 0)
    MainFrame.Position = UDim2.new(0.15, 0, 0.15, 0)
    MainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    MainFrame.Parent = Window

    -- Draggable Functionality
    local dragging = false
    local dragInput, mousePos, framePos

    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            mousePos = input.Position
            framePos = MainFrame.Position
        end
    end)

    MainFrame.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - mousePos
            MainFrame.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
        end
    end)

    MainFrame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    -- Window Header
    local Header = Instance.new("TextLabel")
    Header.Text = WindowDetails.LoadingTitle
    Header.Size = UDim2.new(1, 0, 0.1, 0)
    Header.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Header.TextColor3 = Color3.fromRGB(255, 255, 255)
    Header.Font = Enum.Font.GothamBold
    Header.TextSize = 24
    Header.Parent = MainFrame

    -- Loading Subtitle
    local Subtitle = Instance.new("TextLabel")
    Subtitle.Text = WindowDetails.LoadingSubtitle
    Subtitle.Size = UDim2.new(1, 0, 0.1, 0)
    Subtitle.Position = UDim2.new(0, 0, 0.1, 0)
    Subtitle.BackgroundTransparency = 1
    Subtitle.TextColor3 = Color3.fromRGB(150, 150, 150)
    Subtitle.Font = Enum.Font.Gotham
    Subtitle.TextSize = 16
    Subtitle.Parent = MainFrame

    -- Toggle Window Visibility
    local isWindowVisible = true
    Header.MouseButton1Click:Connect(function()
        if isWindowVisible then
            isWindowVisible = false
            MainFrame.Visible = false
        else
            isWindowVisible = true
            MainFrame.Visible = true
        end
    end)

    return Window
end

-- Function to Create Tabs
function VesperaGUI:CreateTab(TabName, IconId)
    local Tab = Instance.new("Frame")
    Tab.Name = TabName
    Tab.Size = UDim2.new(1, 0, 1, 0)
    Tab.BackgroundTransparency = 1
    Tab.Parent = PlayerGui

    local TabLabel = Instance.new("TextLabel")
    TabLabel.Text = TabName
    TabLabel.Size = UDim2.new(1, 0, 0.1, 0)
    TabLabel.BackgroundTransparency = 1
    TabLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TabLabel.Font = Enum.Font.Gotham
    TabLabel.TextSize = 18
    TabLabel.Parent = Tab

    -- Tab Switching Logic
    local TabPages = {}  -- To hold all the tabs' content
    local ActiveTab
    local function switchTab(selectedTab)
        -- Hide the currently active tab's content
        if ActiveTab then
            ActiveTab.Visible = false
        end
        -- Show the selected tab's content
        ActiveTab = TabPages[selectedTab]
        ActiveTab.Visible = true
    end

    TabLabel.MouseButton1Click:Connect(function()
        switchTab(TabName)
    end)

    -- Store the tab content
    TabPages[TabName] = Tab

    return Tab
end

-- Function to Create Button
function VesperaGUI:CreateButton(ButtonName, ParentTab, Callback)
    local Button = Instance.new("TextButton")
    Button.Text = ButtonName
    Button.Size = UDim2.new(0.8, 0, 0.1, 0)
    Button.Position = UDim2.new(0.1, 0, 0.2, 0)
    Button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.Font = Enum.Font.Gotham
    Button.TextSize = 18
    Button.Parent = ParentTab

    Button.MouseButton1Click:Connect(function()
        Callback()
    end)

    return Button
end

-- Function to Create Slider
function VesperaGUI:CreateSlider(SliderName, MinValue, MaxValue, ParentTab, Callback)
    local Slider = Instance.new("Frame")
    Slider.Size = UDim2.new(0.8, 0, 0.1, 0)
    Slider.Position = UDim2.new(0.1, 0, 0.2, 0)
    Slider.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Slider.Parent = ParentTab

    local SliderBar = Instance.new("TextButton")
    SliderBar.Size = UDim2.new(1, 0, 0.2, 0)
    SliderBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SliderBar.TextTransparency = 1
    SliderBar.Parent = Slider

    -- Add Slider Functionality
    local SliderValue = MinValue
    local SliderIndicator = Instance.new("Frame")
    SliderIndicator.Size = UDim2.new(0, 0, 1, 0)
    SliderIndicator.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    SliderIndicator.Parent = SliderBar

    SliderBar.MouseButton1Down:Connect(function()
        local function updateSlider()
            local mousePos = UserInputService:GetMouseLocation().X
            local pos = math.clamp((mousePos - Slider.AbsolutePosition.X) / Slider.AbsoluteSize.X, 0, 1)
            SliderValue = math.floor(MinValue + (MaxValue - MinValue) * pos)
            SliderIndicator.Size = UDim2.new(pos, 0, 1, 0)
            Callback(SliderValue)
        end

        updateSlider()
    end)

    return Slider
end

-- Function to Send Notifications
function VesperaGUI:SendNotification(Title, Content)
    local Notification = Instance.new("Frame")
    Notification.Size = UDim2.new(0.8, 0, 0.1, 0)
    Notification.Position = UDim2.new(0.1, 0, 0.7, 0)
    Notification.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Notification.Parent = PlayerGui

    local NotificationText = Instance.new("TextLabel")
    NotificationText.Text = Title .. ": " .. Content
    NotificationText.Size = UDim2.new(1, 0, 1, 0)
    NotificationText.TextColor3 = Color3.fromRGB(255, 255, 255)
    NotificationText.Font = Enum.Font.Gotham
    NotificationText.TextSize = 14
    NotificationText.Parent = Notification

    -- Tween for notification pop-in effect
    local Tween = TweenService:Create(Notification, TweenInfo.new(0.5), {Position = UDim2.new(0.1, 0, 0.6, 0)})
    Tween:Play()
end

-- Button to Hide/Show the GUI
local HideShowButton = Instance.new("TextButton")
HideShowButton.Size = UDim2.new(0, 200, 0, 50)
HideShowButton.Position = UDim2.new(0.5, 0, 0.9, 0)  -- Position outside of the window
HideShowButton.Text = "Hide/Show GUI"
HideShowButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
HideShowButton.TextColor3 = Color3.fromRGB(255, 255, 255)
HideShowButton.Font = Enum.Font.Gotham
HideShowButton.TextSize = 20
HideShowButton.Parent = PlayerGui

HideShowButton.MouseButton1Click:Connect(function()
    Window.Visible = not Window.Visible
end)

-- Return VesperaGUI for external use
return VesperaGUI
