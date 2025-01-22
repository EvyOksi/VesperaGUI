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

-- Default Theme (Dark Mode)
local theme = {
    BackgroundColor = Color3.fromRGB(40, 40, 40),
    TextColor = Color3.fromRGB(255, 255, 255),
    ButtonBackgroundColor = Color3.fromRGB(50, 50, 50),
    ButtonTextColor = Color3.fromRGB(255, 255, 255),
    TextInputBackgroundColor = Color3.fromRGB(60, 60, 60),
    TextInputTextColor = Color3.fromRGB(255, 255, 255),
}

-- Notification System
local function createNotification(message, duration)
    local notification = Instance.new("Frame")
    notification.Size = UDim2.new(0.5, 0, 0.1, 0)
    notification.Position = UDim2.new(0.25, 0, 0.9, 0)
    notification.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    notification.BackgroundTransparency = 0.5
    notification.Parent = PlayerGui

    local notificationText = Instance.new("TextLabel")
    notificationText.Text = message
    notificationText.Size = UDim2.new(1, 0, 1, 0)
    notificationText.BackgroundTransparency = 1
    notificationText.TextColor3 = Color3.fromRGB(255, 255, 255)
    notificationText.TextSize = 18
    notificationText.Font = Enum.Font.Gotham
    notificationText.Parent = notification

    -- Fade out and remove notification
    TweenService:Create(notification, TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {Transparency = 1}):Play()
    wait(duration)
    notification:Destroy()
end

-- Function to Change Theme (Light/Dark)
function VesperaGUI:SetTheme(newTheme)
    theme = newTheme
end

-- Function to Create a Window with Drag and Resize
function VesperaGUI:CreateWindow(WindowDetails)
    local Window = Instance.new("ScreenGui")
    Window.Name = WindowDetails.Name
    Window.Parent = PlayerGui

    -- Window Setup
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = OptimizeForMobile and UDim2.new(0.7, 0, 0.7, 0) or UDim2.new(0.8, 0, 0.8, 0)
    MainFrame.Position = UDim2.new(0.15, 0, 0.15, 0)
    MainFrame.BackgroundColor3 = theme.BackgroundColor
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
    Header.BackgroundColor3 = theme.BackgroundColor
    Header.TextColor3 = theme.TextColor
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
    TabLabel.TextColor3 = theme.TextColor
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
    Button.BackgroundColor3 = theme.ButtonBackgroundColor
    Button.TextColor3 = theme.ButtonTextColor
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
    Slider.BackgroundColor3 = theme.ButtonBackgroundColor
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

-- Function to Create a Text Input Field
function VesperaGUI:CreateTextInput(InputName, PlaceholderText, ParentTab, Callback)
    local TextInput = Instance.new("TextBox")
    TextInput.Size = UDim2.new(0.8, 0, 0.1, 0)
    TextInput.Position = UDim2.new(0.1, 0, 0.2, 0)
    TextInput.BackgroundColor3 = theme.TextInputBackgroundColor
    TextInput.TextColor3 = theme.TextInputTextColor
    TextInput.PlaceholderText = PlaceholderText
    TextInput.Font = Enum.Font.Gotham
    TextInput.TextSize = 18
    TextInput.Parent = ParentTab

    TextInput.FocusLost:Connect(function()
        Callback(TextInput.Text)
    end)

    return TextInput
end

-- Function to Create a Settings Panel
function VesperaGUI:CreateSettingsPanel()
    local SettingsPanel = Instance.new("Frame")
    SettingsPanel.Size = UDim2.new(0.6, 0, 0.8, 0)
    SettingsPanel.Position = UDim2.new(0.2, 0, 0.1, 0)
    SettingsPanel.BackgroundColor3 = theme.BackgroundColor
    SettingsPanel.Parent = PlayerGui

    -- Add Title
    local Title = Instance.new("TextLabel")
    Title.Text = "Settings"
    Title.Size = UDim2.new(1, 0, 0.1, 0)
    Title.BackgroundColor3 = theme.BackgroundColor
    Title.TextColor3 = theme.TextColor
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 24
    Title.Parent = SettingsPanel

    -- Add Theme Toggle Button
    local ToggleThemeButton = Instance.new("TextButton")
    ToggleThemeButton.Text = "Switch Theme"
    ToggleThemeButton.Size = UDim2.new(0.8, 0, 0.1, 0)
    ToggleThemeButton.Position = UDim2.new(0.1, 0, 0.2, 0)
    ToggleThemeButton.BackgroundColor3 = theme.ButtonBackgroundColor
    ToggleThemeButton.TextColor3 = theme.ButtonTextColor
    ToggleThemeButton.Font = Enum.Font.Gotham
    ToggleThemeButton.TextSize = 18
    ToggleThemeButton.Parent = SettingsPanel

    ToggleThemeButton.MouseButton1Click:Connect(function()
        if theme == theme then
            VesperaGUI:SetTheme({
                BackgroundColor = Color3.fromRGB(255, 255, 255),
                TextColor = Color3.fromRGB(0, 0, 0),
                ButtonBackgroundColor = Color3.fromRGB(200, 200, 200),
                ButtonTextColor = Color3.fromRGB(0, 0, 0),
                TextInputBackgroundColor = Color3.fromRGB(240, 240, 240),
                TextInputTextColor = Color3.fromRGB(0, 0, 0),
            })
        else
            VesperaGUI:SetTheme({
                BackgroundColor = Color3.fromRGB(40, 40, 40),
                TextColor = Color3.fromRGB(255, 255, 255),
                ButtonBackgroundColor = Color3.fromRGB(50, 50, 50),
                ButtonTextColor = Color3.fromRGB(255, 255, 255),
                TextInputBackgroundColor = Color3.fromRGB(60, 60, 60),
                TextInputTextColor = Color3.fromRGB(255, 255, 255),
            })
        end
    end)

    return SettingsPanel
end

-- Return VesperaGUI for external use
return VesperaGUI
