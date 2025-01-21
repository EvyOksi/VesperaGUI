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
    MainFrame.Size = UDim2.new(0.8, 0, 0.8, 0)
    MainFrame.Position = UDim2.new(0.1, 0, 0.1, 0)
    MainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    MainFrame.Parent = Window

    -- Drag functionality
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

    -- Example: Implement responsive resizing (not yet implemented)
    if OptimizeForMobile then
        MainFrame.Size = UDim2.new(1, 0, 1, 0)
    end

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

    -- Context Menu (Right-click functionality)
    local contextMenu = Instance.new("Frame")
    contextMenu.Size = UDim2.new(0, 150, 0, 100)
    contextMenu.Position = UDim2.new(0, 0, 0, 0)
    contextMenu.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    contextMenu.Visible = false
    contextMenu.Parent = PlayerGui

    local menuItem1 = Instance.new("TextButton")
    menuItem1.Text = "Option 1"
    menuItem1.Size = UDim2.new(1, 0, 0.5, 0)
    menuItem1.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    menuItem1.TextColor3 = Color3.fromRGB(255, 255, 255)
    menuItem1.Font = Enum.Font.Gotham
    menuItem1.TextSize = 14
    menuItem1.Parent = contextMenu

    menuItem1.MouseButton1Click:Connect(function()
        print("Option 1 clicked!")
        contextMenu.Visible = false
    end)

    local menuItem2 = Instance.new("TextButton")
    menuItem2.Text = "Option 2"
    menuItem2.Size = UDim2.new(1, 0, 0.5, 0)
    menuItem2.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    menuItem2.TextColor3 = Color3.fromRGB(255, 255, 255)
    menuItem2.Font = Enum.Font.Gotham
    menuItem2.TextSize = 14
    menuItem2.Parent = contextMenu

    menuItem2.MouseButton1Click:Connect(function()
        print("Option 2 clicked!")
        contextMenu.Visible = false
    end)

    Tab.MouseButton2Click:Connect(function()
        contextMenu.Position = UDim2.new(0, UserInputService:GetMouseLocation().X, 0, UserInputService:GetMouseLocation().Y)
        contextMenu.Visible = true
    end)

    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            contextMenu.Visible = false
        end
    end)

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

    -- Play sound effect on button click
    local clickSound = Instance.new("Sound")
    clickSound.SoundId = "rbxassetid://12345678"  -- Replace with an actual sound asset ID
    clickSound.Parent = Button

    Button.MouseButton1Click:Connect(function()
        clickSound:Play()
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
    SliderBar.MouseMoved:Connect(function(_, y)
        local pos = math.clamp(y / Slider.AbsoluteSize.Y, 0, 1)
        SliderValue = math.floor(MinValue + (MaxValue - MinValue) * pos)
        Callback(SliderValue)
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

-- Setup VesperaGUI
local Vespera = setmetatable({}, VesperaGUI)

-- Example: Creating a Window with a Tab and Button
local MyWindow = Vespera:CreateWindow({
    Name = "VesperaGUI Example Window",
    LoadingTitle = "VesperaGUI Interface Suite",
    LoadingSubtitle = "by Your Name"
})

local MyTab = Vespera:CreateTab("Main Tab", "rewind")  -- You can replace "rewind" with any icon

-- Add Button
Vespera:CreateButton("Test Button", MyTab, function()
    print("Button Clicked!")
end)

-- Add Slider
Vespera:CreateSlider("Volume Slider", 0, 100, MyTab, function(value)
    print("Slider Value: " .. value)
end)

-- Check if the screen is mobile
if OptimizeForMobile then
    -- Mobile Adjustments: Bigger UI elements
    MyWindow.Size = UDim2.new(1, 0, 1, 0)
    MyTab.Size = UDim2.new(1, 0, 1, 0)
end

-- Example Usage of Notification
Vespera:SendNotification("VesperaGUI", "This is a test notification.")

-- Return VesperaGUI to allow access to the library
return VesperaGUI
