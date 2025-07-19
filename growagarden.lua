-- Grow a Garden Script - Professional Edition with Auto Seed Purchase
-- Made by massivendurchfall

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local sellInventoryEvent = ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("Sell_Inventory")
local sellItemEvent = ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("Sell_Item")
local buySeedEvent = ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("BuySeedStock")

local SELL_POSITION = Vector3.new(86, 2, 0)

local settings = {
    hotkey = Enum.KeyCode.F1,
    theme = "Dark",
    movementSpeed = 16,
    flyEnabled = false,
    autoCollectPlant = false,
    autoSellInventory = false,
    antiAFK = false,
    autoBuySeeds = false,
    selectedSeed = "Apple",
    buyInterval = 5
}

-- Seed list (expanded based on the screenshot)
local availableSeeds = {
    "Apple",
    "Bamboo", 
    "Beanstalk",
    "Blueberry",
    "BurningBud",
    "Carrot",
    "Cherry",
    "Coconut",
    "Corn",
    "Cotton",
    "Grape",
    "Lemon",
    "Orange",
    "Pear",
    "Potato",
    "Pumpkin",
    "Strawberry",
    "Tomato",
    "Watermelon",
    "Wheat"
}

-- Modern Professional Themes
local themes = {
    Dark = {
        primary = Color3.fromRGB(18, 18, 20),
        secondary = Color3.fromRGB(28, 28, 32),
        tertiary = Color3.fromRGB(38, 38, 42),
        accent = Color3.fromRGB(88, 166, 255),
        accentHover = Color3.fromRGB(108, 186, 255),
        text = Color3.fromRGB(255, 255, 255),
        textSecondary = Color3.fromRGB(180, 180, 180),
        success = Color3.fromRGB(34, 197, 94),
        warning = Color3.fromRGB(234, 179, 8),
        error = Color3.fromRGB(239, 68, 68),
        border = Color3.fromRGB(55, 55, 60),
        shadow = Color3.fromRGB(0, 0, 0)
    },
    Light = {
        primary = Color3.fromRGB(255, 255, 255),
        secondary = Color3.fromRGB(248, 250, 252),
        tertiary = Color3.fromRGB(241, 245, 249),
        accent = Color3.fromRGB(59, 130, 246),
        accentHover = Color3.fromRGB(79, 150, 266),
        text = Color3.fromRGB(15, 23, 42),
        textSecondary = Color3.fromRGB(100, 116, 139),
        success = Color3.fromRGB(34, 197, 94),
        warning = Color3.fromRGB(234, 179, 8),
        error = Color3.fromRGB(239, 68, 68),
        border = Color3.fromRGB(226, 232, 240),
        shadow = Color3.fromRGB(0, 0, 0)
    }
}

local flyBodyVelocity = nil
local flyBodyAngularVelocity = nil
local autoCollectConnection = nil
local plantIndex = 1
local collectDelay = 1
local autoSellConnection = nil
local autoSellTimer = 0
local antiAFKConnection = nil
local autoBuyConnection = nil
local waitingForHotkey = false

-- Create modern GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ModernGameMenuGui"
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

-- Main container with modern styling
local mainContainer = Instance.new("Frame")
mainContainer.Name = "MainContainer"
mainContainer.Size = UDim2.new(0, 480, 0, 680)
mainContainer.Position = UDim2.new(0.5, -240, 0.5, -340)
mainContainer.BackgroundColor3 = themes[settings.theme].primary
mainContainer.BorderSizePixel = 0
mainContainer.ClipsDescendants = true
mainContainer.Parent = screenGui

-- Modern corner radius
local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 16)
mainCorner.Parent = mainContainer

-- Modern title bar
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 64)
titleBar.Position = UDim2.new(0, 0, 0, 0)
titleBar.BackgroundColor3 = themes[settings.theme].secondary
titleBar.BorderSizePixel = 0
titleBar.Parent = mainContainer

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 16)
titleCorner.Parent = titleBar

-- Fix corner clipping for title bar
local titleFix = Instance.new("Frame")
titleFix.Size = UDim2.new(1, 0, 0, 16)
titleFix.Position = UDim2.new(0, 0, 1, -16)
titleFix.BackgroundColor3 = themes[settings.theme].secondary
titleFix.BorderSizePixel = 0
titleFix.Parent = titleBar

-- Title with modern typography
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleLabel"
titleLabel.Size = UDim2.new(1, -120, 1, 0)
titleLabel.Position = UDim2.new(0, 24, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Grow a Garden Script"
titleLabel.TextColor3 = themes[settings.theme].text
titleLabel.TextSize = 20
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.TextYAlignment = Enum.TextYAlignment.Center
titleLabel.Parent = titleBar

-- Modern close button
local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 40, 0, 40)
closeButton.Position = UDim2.new(1, -52, 0, 12)
closeButton.BackgroundColor3 = themes[settings.theme].error
closeButton.BorderSizePixel = 0
closeButton.Text = "✕"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextSize = 16
closeButton.Font = Enum.Font.GothamBold
closeButton.Parent = titleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeButton

-- Minimize button
local minimizeButton = Instance.new("TextButton")
minimizeButton.Name = "MinimizeButton"
minimizeButton.Size = UDim2.new(0, 40, 0, 40)
minimizeButton.Position = UDim2.new(1, -100, 0, 12)
minimizeButton.BackgroundColor3 = themes[settings.theme].tertiary
minimizeButton.BorderSizePixel = 0
minimizeButton.Text = "–"
minimizeButton.TextColor3 = themes[settings.theme].text
minimizeButton.TextSize = 16
minimizeButton.Font = Enum.Font.GothamBold
minimizeButton.Parent = titleBar

local minimizeCorner = Instance.new("UICorner")
minimizeCorner.CornerRadius = UDim.new(0, 8)
minimizeCorner.Parent = minimizeButton

-- Modern tab system
local tabContainer = Instance.new("Frame")
tabContainer.Name = "TabContainer"
tabContainer.Size = UDim2.new(1, 0, 0, 60)
tabContainer.Position = UDim2.new(0, 0, 0, 64)
tabContainer.BackgroundColor3 = themes[settings.theme].tertiary
tabContainer.BorderSizePixel = 0
tabContainer.Parent = mainContainer

-- Tab content area
local contentFrame = Instance.new("Frame")
contentFrame.Name = "ContentFrame"
contentFrame.Size = UDim2.new(1, 0, 1, -124)
contentFrame.Position = UDim2.new(0, 0, 0, 124)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainContainer

-- Create modern tabs
local tabs = {
    {name = "Player", icon = "👤"},
    {name = "Remote", icon = "🔧"},
    {name = "AutoFarm", icon = "🌱"},
    {name = "AutoBuy", icon = "🛒"},
    {name = "Settings", icon = "⚙️"}
}

local tabButtons = {}
local tabFrames = {}
local currentTab = "Player"

for i, tab in ipairs(tabs) do
    local tabButton = Instance.new("TextButton")
    tabButton.Name = tab.name .. "Tab"
    tabButton.Size = UDim2.new(0.2, -2, 1, -16)
    tabButton.Position = UDim2.new((i-1) * 0.2, 1, 0, 8)
    tabButton.BackgroundColor3 = tab.name == currentTab and themes[settings.theme].accent or Color3.fromRGB(0, 0, 0, 0)
    tabButton.BackgroundTransparency = tab.name == currentTab and 0 or 1
    tabButton.BorderSizePixel = 0
    tabButton.Text = tab.icon .. " " .. tab.name
    tabButton.TextColor3 = tab.name == currentTab and Color3.fromRGB(255, 255, 255) or themes[settings.theme].textSecondary
    tabButton.TextSize = 12
    tabButton.Font = Enum.Font.GothamSemibold
    tabButton.Parent = tabContainer
    
    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 8)
    tabCorner.Parent = tabButton
    
    tabButtons[tab.name] = tabButton
    
    -- Create content frame for each tab
    local frame = Instance.new("ScrollingFrame")
    frame.Name = tab.name .. "Frame"
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.Position = UDim2.new(0, 0, 0, 0)
    frame.BackgroundTransparency = 1
    frame.BorderSizePixel = 0
    frame.ScrollBarThickness = 4
    frame.ScrollBarImageColor3 = themes[settings.theme].accent
    frame.Visible = tab.name == currentTab
    frame.CanvasSize = UDim2.new(0, 0, 0, 0)
    frame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    frame.Parent = contentFrame
    
    tabFrames[tab.name] = frame
end

-- Helper function to create modern cards
local function createCard(parent, title, yPos, height)
    local card = Instance.new("Frame")
    card.Name = title .. "Card"
    card.Size = UDim2.new(1, -32, 0, height or 120)
    card.Position = UDim2.new(0, 16, 0, yPos)
    card.BackgroundColor3 = themes[settings.theme].secondary
    card.BorderSizePixel = 0
    card.Parent = parent
    
    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 12)
    cardCorner.Parent = card
    
    local cardTitle = Instance.new("TextLabel")
    cardTitle.Name = "CardTitle"
    cardTitle.Size = UDim2.new(1, -32, 0, 24)
    cardTitle.Position = UDim2.new(0, 16, 0, 16)
    cardTitle.BackgroundTransparency = 1
    cardTitle.Text = title
    cardTitle.TextColor3 = themes[settings.theme].text
    cardTitle.TextSize = 16
    cardTitle.Font = Enum.Font.GothamBold
    cardTitle.TextXAlignment = Enum.TextXAlignment.Left
    cardTitle.Parent = card
    
    return card
end

-- Helper function to create modern buttons
local function createModernButton(parent, text, position, size, color, textColor)
    local button = Instance.new("TextButton")
    button.Size = size or UDim2.new(0, 120, 0, 36)
    button.Position = position
    button.BackgroundColor3 = color or themes[settings.theme].accent
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = textColor or Color3.fromRGB(255, 255, 255)
    button.TextSize = 14
    button.Font = Enum.Font.GothamSemibold
    button.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button
    
    -- Hover effect
    button.MouseEnter:Connect(function()
        local hoverTween = TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = themes[settings.theme].accentHover
        })
        hoverTween:Play()
    end)
    
    button.MouseLeave:Connect(function()
        local leaveTween = TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = color or themes[settings.theme].accent
        })
        leaveTween:Play()
    end)
    
    return button
end

-- Helper function to create modern toggles
local function createModernToggle(parent, text, position, isOn, onColor, offColor)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -32, 0, 48)
    container.Position = position
    container.BackgroundTransparency = 1
    container.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -80, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = themes[settings.theme].text
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.Parent = container
    
    local toggleBg = Instance.new("Frame")
    toggleBg.Size = UDim2.new(0, 60, 0, 32)
    toggleBg.Position = UDim2.new(1, -60, 0.5, -16)
    toggleBg.BackgroundColor3 = isOn and (onColor or themes[settings.theme].success) or (offColor or themes[settings.theme].tertiary)
    toggleBg.BorderSizePixel = 0
    toggleBg.Parent = container
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 16)
    toggleCorner.Parent = toggleBg
    
    local toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(0, 28, 0, 28)
    toggleButton.Position = isOn and UDim2.new(0, 30, 0, 2) or UDim2.new(0, 2, 0, 2)
    toggleButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    toggleButton.BorderSizePixel = 0
    toggleButton.Text = ""
    toggleButton.Parent = toggleBg
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 14)
    buttonCorner.Parent = toggleButton
    
    return container, toggleBg, toggleButton
end

-- Helper function to create modern dropdown
local function createModernDropdown(parent, text, items, selectedItem, position)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -32, 0, 48)
    container.Position = position
    container.BackgroundTransparency = 1
    container.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -200, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = themes[settings.theme].text
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.Parent = container
    
    local dropdown = Instance.new("TextButton")
    dropdown.Size = UDim2.new(0, 180, 0, 36)
    dropdown.Position = UDim2.new(1, -180, 0.5, -18)
    dropdown.BackgroundColor3 = themes[settings.theme].tertiary
    dropdown.BorderSizePixel = 0
    dropdown.Text = selectedItem .. " ▼"
    dropdown.TextColor3 = themes[settings.theme].text
    dropdown.TextSize = 12
    dropdown.Font = Enum.Font.Gotham
    dropdown.Parent = container
    
    local dropdownCorner = Instance.new("UICorner")
    dropdownCorner.CornerRadius = UDim.new(0, 8)
    dropdownCorner.Parent = dropdown
    
    -- Create dropdown menu as a child of the main ScreenGui for maximum Z-index
    local dropdownMenu = Instance.new("Frame")
    dropdownMenu.Size = UDim2.new(0, 180, 0, math.min(#items * 32, 200)) -- Limit height for many items
    dropdownMenu.BackgroundColor3 = themes[settings.theme].secondary
    dropdownMenu.BorderSizePixel = 0
    dropdownMenu.Visible = false
    dropdownMenu.ZIndex = 50  -- Very high Z-Index
    dropdownMenu.Parent = screenGui -- Parent to main ScreenGui instead of dropdown
    
    local menuCorner = Instance.new("UICorner")
    menuCorner.CornerRadius = UDim.new(0, 8)
    menuCorner.Parent = dropdownMenu
    
    -- Add scrolling frame for many items
    local scrollingFrame = Instance.new("ScrollingFrame")
    scrollingFrame.Size = UDim2.new(1, 0, 1, 0)
    scrollingFrame.Position = UDim2.new(0, 0, 0, 0)
    scrollingFrame.BackgroundTransparency = 1
    scrollingFrame.BorderSizePixel = 0
    scrollingFrame.ScrollBarThickness = 4
    scrollingFrame.ScrollBarImageColor3 = themes[settings.theme].accent
    scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, #items * 32)
    scrollingFrame.ZIndex = 51
    scrollingFrame.Parent = dropdownMenu
    
    -- Add a shadow for better visibility
    local shadowFrame = Instance.new("Frame")
    shadowFrame.Size = UDim2.new(1, 6, 1, 6)
    shadowFrame.Position = UDim2.new(0, 3, 0, 3)
    shadowFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    shadowFrame.BackgroundTransparency = 0.8
    shadowFrame.ZIndex = 49
    shadowFrame.Visible = false
    shadowFrame.Parent = screenGui
    
    local shadowCorner = Instance.new("UICorner")
    shadowCorner.CornerRadius = UDim.new(0, 8)
    shadowCorner.Parent = shadowFrame
    
    -- Create item buttons with proper event handlers
    local itemButtons = {}
    for i, item in ipairs(items) do
        local itemButton = Instance.new("TextButton")
        itemButton.Size = UDim2.new(1, 0, 0, 32)
        itemButton.Position = UDim2.new(0, 0, 0, (i-1) * 32)
        itemButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0, 0)
        itemButton.BackgroundTransparency = 1
        itemButton.BorderSizePixel = 0
        itemButton.Text = item
        itemButton.TextColor3 = themes[settings.theme].text
        itemButton.TextSize = 12
        itemButton.Font = Enum.Font.Gotham
        itemButton.ZIndex = 52  -- Higher than scrolling frame
        itemButton.Parent = scrollingFrame
        
        itemButton.MouseEnter:Connect(function()
            itemButton.BackgroundTransparency = 0
            itemButton.BackgroundColor3 = themes[settings.theme].accent
        end)
        
        itemButton.MouseLeave:Connect(function()
            itemButton.BackgroundTransparency = 1
        end)
        
        -- Store the button for later event connection
        itemButtons[item] = itemButton
    end
    
    -- Function to update dropdown position
    local function updateDropdownPosition()
        local dropdownAbsPos = dropdown.AbsolutePosition
        local dropdownAbsSize = dropdown.AbsoluteSize
        dropdownMenu.Position = UDim2.new(0, dropdownAbsPos.X, 0, dropdownAbsPos.Y + dropdownAbsSize.Y + 4)
        shadowFrame.Position = UDim2.new(0, dropdownAbsPos.X + 3, 0, dropdownAbsPos.Y + dropdownAbsSize.Y + 7)
    end
    
    dropdown.MouseButton1Click:Connect(function()
        dropdownMenu.Visible = not dropdownMenu.Visible
        shadowFrame.Visible = dropdownMenu.Visible
        if dropdownMenu.Visible then
            updateDropdownPosition()
        end
    end)
    
    -- Update position when parent moves
    container.AncestryChanged:Connect(updateDropdownPosition)
    
    return container, dropdown, dropdownMenu, itemButtons, shadowFrame
end

-- Helper function to create modern sliders
local function createModernSlider(parent, text, value, minVal, maxVal, position)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -32, 0, 64)
    container.Position = position
    container.BackgroundTransparency = 1
    container.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 24)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text .. ": " .. value
    label.TextColor3 = themes[settings.theme].text
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(1, 0, 0, 6)
    sliderBg.Position = UDim2.new(0, 0, 0, 40)
    sliderBg.BackgroundColor3 = themes[settings.theme].tertiary
    sliderBg.BorderSizePixel = 0
    sliderBg.Parent = container
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(0, 3)
    sliderCorner.Parent = sliderBg
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new((value - minVal) / (maxVal - minVal), 0, 1, 0)
    sliderFill.Position = UDim2.new(0, 0, 0, 0)
    sliderFill.BackgroundColor3 = themes[settings.theme].accent
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderBg
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 3)
    fillCorner.Parent = sliderFill
    
    local handle = Instance.new("TextButton")
    handle.Size = UDim2.new(0, 20, 0, 20)
    handle.Position = UDim2.new((value - minVal) / (maxVal - minVal), -10, 0, -7)
    handle.BackgroundColor3 = themes[settings.theme].accent
    handle.BorderSizePixel = 0
    handle.Text = ""
    handle.Parent = sliderBg
    
    local handleCorner = Instance.new("UICorner")
    handleCorner.CornerRadius = UDim.new(0, 10)
    handleCorner.Parent = handle
    
    return container, label, sliderBg, sliderFill, handle
end

-- Build Player Tab
local playerFrame = tabFrames["Player"]

-- Movement Speed Card
local speedCard = createCard(playerFrame, "Movement Speed", 16)
local speedContainer, speedLabel, speedSliderBg, speedFill, speedHandle = createModernSlider(
    speedCard, "Speed", settings.movementSpeed, 16, 100, UDim2.new(0, 16, 0, 48)
)

-- Flight Card
local flightCard = createCard(playerFrame, "Flight System", 152)
local flyContainer, flyBg, flyButton = createModernToggle(
    flightCard, "Enable Flight", UDim2.new(0, 16, 0, 48), settings.flyEnabled
)

-- Anti-AFK Card
local afkCard = createCard(playerFrame, "Anti-AFK System", 288)
local afkContainer, afkBg, afkToggleButton = createModernToggle(
    afkCard, "Prevent AFK Kick", UDim2.new(0, 16, 0, 48), settings.antiAFK
)

-- Build Remote Tab
local remoteFrame = tabFrames["Remote"]

-- Quick Actions Card
local actionsCard = createCard(remoteFrame, "Quick Actions", 16)
local sellInventoryBtn = createModernButton(
    actionsCard, "💰 Sell Inventory", UDim2.new(0, 16, 0, 52), UDim2.new(0, 180, 0, 40), themes[settings.theme].success
)
local sellItemBtn = createModernButton(
    actionsCard, "🎯 Sell Item", UDim2.new(0, 212, 0, 52), UDim2.new(0, 180, 0, 40), themes[settings.theme].accent
)

-- Seed Shop Card
local seedCard = createCard(remoteFrame, "Seed Management", 152)
local seedShopBtn = createModernButton(
    seedCard, "🏪 Open Seed Shop", UDim2.new(0, 16, 0, 52), UDim2.new(0, 180, 0, 40), themes[settings.theme].warning
)

-- Build AutoFarm Tab
local autoFarmFrame = tabFrames["AutoFarm"]

-- Auto Collect Card
local collectCard = createCard(autoFarmFrame, "Auto Collection", 16)
local collectContainer, collectBg, collectToggleButton = createModernToggle(
    collectCard, "Auto Collect Plants", UDim2.new(0, 16, 0, 48), settings.autoCollectPlant
)

-- Auto Sell Card
local autoSellCard = createCard(autoFarmFrame, "Auto Selling", 152)
local autoSellContainer, autoSellBg, autoSellToggleButton = createModernToggle(
    autoSellCard, "Auto Sell Inventory", UDim2.new(0, 16, 0, 48), settings.autoSellInventory
)

-- Status indicator
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -32, 0, 20)
statusLabel.Position = UDim2.new(0, 16, 0, 88)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: Idle"
statusLabel.TextColor3 = themes[settings.theme].textSecondary
statusLabel.TextSize = 12
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = autoSellCard

-- Build AutoBuy Tab
local autoBuyFrame = tabFrames["AutoBuy"]

-- Seed Selection Card
local seedSelectionCard = createCard(autoBuyFrame, "Seed Selection", 16, 160)
local seedDropdownContainer, seedDropdown, seedDropdownMenu, seedDropdownItems, seedDropdownShadow = createModernDropdown(
    seedSelectionCard, "Selected Seed:", availableSeeds, settings.selectedSeed, UDim2.new(0, 16, 0, 48)
)

-- Buy interval slider
local buyIntervalContainer, buyIntervalLabel, buyIntervalSliderBg, buyIntervalFill, buyIntervalHandle = createModernSlider(
    seedSelectionCard, "Buy Interval (seconds)", settings.buyInterval, 1, 30, UDim2.new(0, 16, 0, 96)
)

-- Auto Buy Card
local autoBuyCard = createCard(autoBuyFrame, "Auto Purchase", 192)
local autoBuyContainer, autoBuyBg, autoBuyToggleButton = createModernToggle(
    autoBuyCard, "Auto Buy Seeds", UDim2.new(0, 16, 0, 48), settings.autoBuySeeds
)

-- Manual buy button
local manualBuyBtn = createModernButton(
    autoBuyCard, "🛒 Buy " .. settings.selectedSeed, UDim2.new(0, 16, 0, 84), UDim2.new(0, 180, 0, 40), themes[settings.theme].warning
)

-- Buy status label
local buyStatusLabel = Instance.new("TextLabel")
buyStatusLabel.Size = UDim2.new(1, -32, 0, 20)
buyStatusLabel.Position = UDim2.new(0, 212, 0, 94)
buyStatusLabel.BackgroundTransparency = 1
buyStatusLabel.Text = "Status: Ready"
buyStatusLabel.TextColor3 = themes[settings.theme].textSecondary
buyStatusLabel.TextSize = 12
buyStatusLabel.Font = Enum.Font.Gotham
buyStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
buyStatusLabel.Parent = autoBuyCard

-- Build Settings Tab
local settingsFrame = tabFrames["Settings"]

-- Theme Card
local themeCard = createCard(settingsFrame, "Appearance", 16)
local themeBtn = createModernButton(
    themeCard, "🎨 Theme: " .. settings.theme, UDim2.new(0, 16, 0, 52), UDim2.new(0, 180, 0, 40)
)

-- Hotkey Card
local hotkeyCard = createCard(settingsFrame, "Controls", 152)
local hotkeyBtn = createModernButton(
    hotkeyCard, "⌨️ Hotkey: " .. settings.hotkey.Name, UDim2.new(0, 16, 0, 52), UDim2.new(0, 180, 0, 40)
)

-- About Card
local aboutCard = createCard(settingsFrame, "About", 288)
local aboutText = Instance.new("TextLabel")
aboutText.Size = UDim2.new(1, -32, 1, -48)
aboutText.Position = UDim2.new(0, 16, 0, 48)
aboutText.BackgroundTransparency = 1
aboutText.Text = "Grow a Garden Script v2.1\nAdvanced automation for farming\nNow with Auto Seed Purchase!\n\nMade with ❤️ by massivendurchfall"
aboutText.TextColor3 = themes[settings.theme].textSecondary
aboutText.TextSize = 12
aboutText.Font = Enum.Font.Gotham
aboutText.TextXAlignment = Enum.TextXAlignment.Left
aboutText.TextYAlignment = Enum.TextYAlignment.Top
aboutText.Parent = aboutCard

-- Auto Buy Functions
local function buySeed(seedName)
    -- Try to fire the BuySeedStock remote event directly
    local success, error = pcall(function()
        -- Method 1: Fire with just the seed name
        buySeedEvent:FireServer(seedName)
        
        -- Wait a bit to see if it worked
        wait(0.1)
        
        -- Method 2: Try with additional parameters that might be expected
        -- Some games require quantity or other parameters
        buySeedEvent:FireServer(seedName, 1) -- Try with quantity 1
        wait(0.1)
        
        -- Method 3: Try with different formatting
        buySeedEvent:FireServer(seedName .. " Seed") -- Try with " Seed" suffix
        wait(0.1)
        
        -- Method 4: Try with table format (some games use this)
        buySeedEvent:FireServer({
            seedType = seedName,
            quantity = 1,
            buyType = "sheckles" -- or "money" or "coins"
        })
        wait(0.1)
        
        -- Method 5: Try different parameter combinations
        buySeedEvent:FireServer("sheckles", seedName, 1)
        wait(0.1)
        
        buySeedEvent:FireServer(player, seedName)
        wait(0.1)
        
        return true
    end)
    
    if success then
        buyStatusLabel.Text = "Status: Purchase request sent for " .. seedName
        buyStatusLabel.TextColor3 = themes[settings.theme].success
        print("Successfully sent purchase request for " .. seedName)
        return true
    else
        buyStatusLabel.Text = "Status: Failed to send request for " .. seedName
        buyStatusLabel.TextColor3 = themes[settings.theme].error
        print("Failed to send purchase request for " .. seedName .. ": " .. tostring(error))
        return false
    end
end

-- Alternative function to try GUI method as backup
local function buySeedGUI(seedName)
    local seedShopGui = playerGui:FindFirstChild("Seed_Shop")
    if not seedShopGui then
        return false
    end
    
    local frameContainer = seedShopGui:FindFirstChild("Frame")
    if not frameContainer then return false end
    
    local scrollingFrame = frameContainer:FindFirstChild("ScrollingFrame")
    if not scrollingFrame then return false end
    
    local seedFrame = scrollingFrame:FindFirstChild(seedName)
    if not seedFrame then return false end
    
    local innerFrame = seedFrame:FindFirstChild("Frame")
    if not innerFrame then return false end
    
    local buyButton = innerFrame:FindFirstChild("Sheckles_Buy")
    if not buyButton then return false end
    
    local success, error = pcall(function()
        if buyButton:IsA("GuiButton") or buyButton:IsA("TextButton") or buyButton:IsA("ImageButton") then
            local VirtualInputManager = game:GetService("VirtualInputManager")
            
            if buyButton.Visible and (buyButton.Active == nil or buyButton.Active == true) then
                local buttonPos = buyButton.AbsolutePosition
                local buttonSize = buyButton.AbsoluteSize
                local clickX = buttonPos.X + buttonSize.X / 2
                local clickY = buttonPos.Y + buttonSize.Y / 2
                
                VirtualInputManager:SendMouseButtonEvent(clickX, clickY, 0, true, game, 1)
                wait(0.05)
                VirtualInputManager:SendMouseButtonEvent(clickX, clickY, 0, false, game, 1)
                return true
            end
        end
        
        if buyButton.MouseButton1Click then
            local connections = getconnections(buyButton.MouseButton1Click)
            if #connections > 0 then
                for _, connection in pairs(connections) do
                    connection:Fire()
                end
                return true
            end
        end
        
        return false
    end)
    
    return success
end

-- Enhanced buy function that tries both methods
local function buySeedEnhanced(seedName)
    -- First try the professional Remote Event method
    local remoteSuccess = buySeed(seedName)
    
    if remoteSuccess then
        return true
    end
    
    -- If remote method fails, try GUI method as backup
    wait(0.5)
    local guiSuccess = buySeedGUI(seedName)
    
    if guiSuccess then
        buyStatusLabel.Text = "Status: GUI purchase successful for " .. seedName
        buyStatusLabel.TextColor3 = themes[settings.theme].success
        return true
    else
        buyStatusLabel.Text = "Status: All methods failed for " .. seedName
        buyStatusLabel.TextColor3 = themes[settings.theme].error
        return false
    end
end

-- Enhanced auto buy system that works without shop being open
local function autoBuyLoop()
    while settings.autoBuySeeds do
        if settings.selectedSeed and settings.selectedSeed ~= "" then
            buyStatusLabel.Text = "Status: Auto-buying " .. settings.selectedSeed
            buyStatusLabel.TextColor3 = themes[settings.theme].warning
            
            -- Direct remote event call - no need for shop to be open
            local success = buySeedEnhanced(settings.selectedSeed)
            
            if success then
                buyStatusLabel.Text = "Status: Auto-buy successful - " .. settings.selectedSeed
                buyStatusLabel.TextColor3 = themes[settings.theme].success
            else
                buyStatusLabel.Text = "Status: Auto-buy failed - " .. settings.selectedSeed
                buyStatusLabel.TextColor3 = themes[settings.theme].error
            end
            
            -- Wait for the specified interval
            wait(settings.buyInterval)
        else
            buyStatusLabel.Text = "Status: No seed selected"
            buyStatusLabel.TextColor3 = themes[settings.theme].error
            wait(1)
        end
        
        wait(0.1) -- Small delay to prevent excessive server calls
    end
end

local function startAutoBuy()
    if autoBuyConnection then
        task.cancel(autoBuyConnection)
    end
    
    autoBuyConnection = task.spawn(autoBuyLoop)
end

local function stopAutoBuy()
    if autoBuyConnection then
        task.cancel(autoBuyConnection)
        autoBuyConnection = nil
    end
    buyStatusLabel.Text = "Status: Stopped"
    buyStatusLabel.TextColor3 = themes[settings.theme].textSecondary
end

-- Functions
local function updateTheme()
    local theme = themes[settings.theme]
    
    -- Update main colors
    mainContainer.BackgroundColor3 = theme.primary
    titleBar.BackgroundColor3 = theme.secondary
    titleFix.BackgroundColor3 = theme.secondary
    titleLabel.TextColor3 = theme.text
    tabContainer.BackgroundColor3 = theme.tertiary
    
    -- Update all cards
    for _, frame in pairs(tabFrames) do
        for _, child in pairs(frame:GetChildren()) do
            if child.Name:find("Card") then
                child.BackgroundColor3 = theme.secondary
                local title = child:FindFirstChild("CardTitle")
                if title then
                    title.TextColor3 = theme.text
                end
            end
        end
    end
    
    -- Update tabs
    for tabName, button in pairs(tabButtons) do
        if tabName == currentTab then
            button.BackgroundColor3 = theme.accent
            button.BackgroundTransparency = 0
            button.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            button.BackgroundTransparency = 1
            button.TextColor3 = theme.textSecondary
        end
    end
    
    -- Update theme button text
    themeBtn.Text = "🎨 Theme: " .. settings.theme
end

local function switchTab(tabName)
    currentTab = tabName
    for name, frame in pairs(tabFrames) do
        frame.Visible = name == tabName
    end
    
    -- Update tab button colors
    for name, button in pairs(tabButtons) do
        if name == tabName then
            button.BackgroundColor3 = themes[settings.theme].accent
            button.BackgroundTransparency = 0
            button.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            button.BackgroundTransparency = 1
            button.TextColor3 = themes[settings.theme].textSecondary
        end
    end
end

local function updateMovementSpeed()
    local character = player.Character
    if character and character:FindFirstChild("Humanoid") then
        character.Humanoid.WalkSpeed = settings.movementSpeed
    end
end

local function animateToggle(bg, button, isOn, onColor, offColor)
    local targetBgColor = isOn and (onColor or themes[settings.theme].success) or (offColor or themes[settings.theme].tertiary)
    local targetPos = isOn and UDim2.new(0, 30, 0, 2) or UDim2.new(0, 2, 0, 2)
    
    local bgTween = TweenService:Create(bg, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
        BackgroundColor3 = targetBgColor
    })
    
    local buttonTween = TweenService:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
        Position = targetPos
    })
    
    bgTween:Play()
    buttonTween:Play()
end

-- Event handlers
closeButton.MouseButton1Click:Connect(function()
    local closeTween = TweenService:Create(mainContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0)
    })
    closeTween:Play()
    closeTween.Completed:Connect(function()
        screenGui:Destroy()
    end)
end)

minimizeButton.MouseButton1Click:Connect(function()
    screenGui.Enabled = false
end)

for tabName, button in pairs(tabButtons) do
    button.MouseButton1Click:Connect(function()
        switchTab(tabName)
    end)
end

-- Seed dropdown handling - NOW WITH PROPER EVENT CONNECTIONS
for seedName, itemButton in pairs(seedDropdownItems) do
    itemButton.MouseButton1Click:Connect(function()
        settings.selectedSeed = seedName
        seedDropdown.Text = seedName .. " ▼"
        seedDropdownMenu.Visible = false
        seedDropdownShadow.Visible = false
        manualBuyBtn.Text = "🛒 Buy " .. seedName
        print("Selected seed changed to: " .. seedName)
    end)
end

-- Speed slider
local draggingSpeed = false
speedHandle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingSpeed = true
    end
end)

speedHandle.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and draggingSpeed then
        local mousePos = UserInputService:GetMouseLocation().X
        local sliderPos = speedSliderBg.AbsolutePosition.X
        local sliderSize = speedSliderBg.AbsoluteSize.X
        local percentage = math.clamp((mousePos - sliderPos) / sliderSize, 0, 1)
        
        settings.movementSpeed = math.floor(16 + (percentage * 84))
        speedHandle.Position = UDim2.new(percentage, -10, 0, -7)
        speedFill.Size = UDim2.new(percentage, 0, 1, 0)
        speedLabel.Text = "Speed: " .. settings.movementSpeed
        updateMovementSpeed()
    end
end)

speedHandle.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingSpeed = false
    end
end)

-- Buy interval slider
local draggingBuyInterval = false
buyIntervalHandle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingBuyInterval = true
    end
end)

buyIntervalHandle.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and draggingBuyInterval then
        local mousePos = UserInputService:GetMouseLocation().X
        local sliderPos = buyIntervalSliderBg.AbsolutePosition.X
        local sliderSize = buyIntervalSliderBg.AbsoluteSize.X
        local percentage = math.clamp((mousePos - sliderPos) / sliderSize, 0, 1)
        
        settings.buyInterval = math.floor(1 + (percentage * 29))
        buyIntervalHandle.Position = UDim2.new(percentage, -10, 0, -7)
        buyIntervalFill.Size = UDim2.new(percentage, 0, 1, 0)
        buyIntervalLabel.Text = "Buy Interval (seconds): " .. settings.buyInterval
    end
end)

buyIntervalHandle.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingBuyInterval = false
    end
end)

-- Toggle handlers
flyButton.MouseButton1Click:Connect(function()
    settings.flyEnabled = not settings.flyEnabled
    animateToggle(flyBg, flyButton, settings.flyEnabled)
    
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    if settings.flyEnabled then
        local humanoidRootPart = character.HumanoidRootPart
        flyBodyVelocity = Instance.new("BodyVelocity")
        flyBodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
        flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
        flyBodyVelocity.Parent = humanoidRootPart
        
        flyBodyAngularVelocity = Instance.new("BodyAngularVelocity")
        flyBodyAngularVelocity.MaxTorque = Vector3.new(4000, 4000, 4000)
        flyBodyAngularVelocity.AngularVelocity = Vector3.new(0, 0, 0)
        flyBodyAngularVelocity.Parent = humanoidRootPart
    else
        if flyBodyVelocity then flyBodyVelocity:Destroy() end
        if flyBodyAngularVelocity then flyBodyAngularVelocity:Destroy() end
    end
end)

afkToggleButton.MouseButton1Click:Connect(function()
    settings.antiAFK = not settings.antiAFK
    animateToggle(afkBg, afkToggleButton, settings.antiAFK)
    
    if settings.antiAFK then
        local VirtualInputManager = game:GetService("VirtualInputManager")
        
        antiAFKConnection = task.spawn(function()
            while settings.antiAFK do
                wait(60)
                if settings.antiAFK then
                    VirtualInputManager:SendMouseMoveEvent(1, 1, game)
                    wait(0.1)
                    VirtualInputManager:SendMouseMoveEvent(-1, -1, game)
                end
            end
        end)
    else
        if antiAFKConnection then
            task.cancel(antiAFKConnection)
            antiAFKConnection = nil
        end
    end
end)

autoBuyToggleButton.MouseButton1Click:Connect(function()
    settings.autoBuySeeds = not settings.autoBuySeeds
    animateToggle(autoBuyBg, autoBuyToggleButton, settings.autoBuySeeds)
    
    if settings.autoBuySeeds then
        buyStatusLabel.Text = "Status: Starting auto buy..."
        buyStatusLabel.TextColor3 = themes[settings.theme].success
        startAutoBuy()
    else
        stopAutoBuy()
    end
end)

collectToggleButton.MouseButton1Click:Connect(function()
    settings.autoCollectPlant = not settings.autoCollectPlant
    animateToggle(collectBg, collectToggleButton, settings.autoCollectPlant)
    
    if settings.autoCollectPlant then
        statusLabel.Text = "Status: Collecting plants..."
        statusLabel.TextColor3 = themes[settings.theme].success
        
        if not settings.flyEnabled then
            settings.flyEnabled = true
            animateToggle(flyBg, flyButton, settings.flyEnabled)
            
            local character = player.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                local humanoidRootPart = character.HumanoidRootPart
                flyBodyVelocity = Instance.new("BodyVelocity")
                flyBodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
                flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
                flyBodyVelocity.Parent = humanoidRootPart
                
                flyBodyAngularVelocity = Instance.new("BodyAngularVelocity")
                flyBodyAngularVelocity.MaxTorque = Vector3.new(4000, 4000, 4000)
                flyBodyAngularVelocity.AngularVelocity = Vector3.new(0, 0, 0)
                flyBodyAngularVelocity.Parent = humanoidRootPart
            end
        end
        startAutoCollect()
    else
        statusLabel.Text = "Status: Idle"
        statusLabel.TextColor3 = themes[settings.theme].textSecondary
        
        if settings.autoSellInventory then
            settings.autoSellInventory = false
            animateToggle(autoSellBg, autoSellToggleButton, settings.autoSellInventory)
            stopAutoSell()
        end
        
        stopAutoCollect()
    end
end)

autoSellToggleButton.MouseButton1Click:Connect(function()
    if not settings.autoCollectPlant then
        return
    end
    
    settings.autoSellInventory = not settings.autoSellInventory
    animateToggle(autoSellBg, autoSellToggleButton, settings.autoSellInventory)
    
    if settings.autoSellInventory then
        statusLabel.Text = "Status: Auto farming + selling..."
        statusLabel.TextColor3 = themes[settings.theme].warning
        startAutoSell()
    else
        statusLabel.Text = "Status: Collecting plants..."
        statusLabel.TextColor3 = themes[settings.theme].success
        stopAutoSell()
    end
end)

-- Button handlers
sellInventoryBtn.MouseButton1Click:Connect(function()
    sellInventoryWithTeleport()
end)

sellItemBtn.MouseButton1Click:Connect(function()
    sellItemWithTeleport()
end)

seedShopBtn.MouseButton1Click:Connect(function()
    local seedShopGui = player.PlayerGui:FindFirstChild("Seed_Shop")
    if seedShopGui then
        seedShopGui.Enabled = not seedShopGui.Enabled
        seedShopBtn.Text = seedShopGui.Enabled and "🏪 Close Seed Shop" or "🏪 Open Seed Shop"
    end
end)

manualBuyBtn.MouseButton1Click:Connect(function()
    if settings.selectedSeed and settings.selectedSeed ~= "" then
        manualBuyBtn.Text = "🛒 Buying..."
        local success = buySeedEnhanced(settings.selectedSeed)
        wait(1)
        manualBuyBtn.Text = "🛒 Buy " .. settings.selectedSeed
    end
end)

themeBtn.MouseButton1Click:Connect(function()
    settings.theme = settings.theme == "Dark" and "Light" or "Dark"
    themeBtn.Text = "🎨 Theme: " .. settings.theme
    updateTheme()
end)

hotkeyBtn.MouseButton1Click:Connect(function()
    if waitingForHotkey then return end
    
    waitingForHotkey = true
    hotkeyBtn.Text = "⌨️ Press any key..."
    hotkeyBtn.BackgroundColor3 = themes[settings.theme].warning
    
    local connection
    connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if input.UserInputType == Enum.UserInputType.Keyboard then
            settings.hotkey = input.KeyCode
            hotkeyBtn.Text = "⌨️ Hotkey: " .. settings.hotkey.Name
            hotkeyBtn.BackgroundColor3 = themes[settings.theme].accent
            waitingForHotkey = false
            connection:Disconnect()
        end
    end)
end)

-- Dragging functionality
local dragging = false
local dragStart = nil
local startPos = nil

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainContainer.Position
    end
end)

titleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
        local delta = input.Position - dragStart
        mainContainer.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

titleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- Auto-farming functions (existing code remains the same)
local function getAllPlants()
    local mainFarm = workspace:FindFirstChild("Farm")
    if not mainFarm then 
        return {} 
    end
    
    local plants = {}
    
    for _, farmFolder in pairs(mainFarm:GetChildren()) do
        if farmFolder.Name == "Farm" and (farmFolder:IsA("Folder") or farmFolder:IsA("Model")) then
            local importantFolder = farmFolder:FindFirstChild("Important")
            if importantFolder then
                local plantsFolder = importantFolder:FindFirstChild("Plants_Physical")
                if plantsFolder then
                    for _, plant in pairs(plantsFolder:GetChildren()) do
                        if plant:IsA("Model") or plant:IsA("Folder") then
                            local fruitSpawn = plant:FindFirstChild("Fruit_Spawn")
                            if fruitSpawn then
                                local spawnPoint = fruitSpawn:FindFirstChild("Spawn_Point")
                                if spawnPoint then
                                    table.insert(plants, {
                                        name = plant.Name,
                                        spawnPoint = spawnPoint
                                    })
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    return plants
end

local function collectFromPlant(plant)
    local character = player.Character
    if not character then
        return false
    end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then
        return false
    end
    
    local spawnPoint = plant.spawnPoint
    if not spawnPoint then
        return false
    end
    
    local success, error = pcall(function()
        if spawnPoint:IsA("Part") then
            if spawnPoint.CFrame then
                local partSize = spawnPoint.Size
                humanoidRootPart.CFrame = spawnPoint.CFrame + Vector3.new(0, partSize.Y/2 + 3, 0)
            else
                return false
            end
        elseif spawnPoint:IsA("Model") then
            if spawnPoint.PrimaryPart and spawnPoint.PrimaryPart.CFrame then
                local partSize = spawnPoint.PrimaryPart.Size
                humanoidRootPart.CFrame = spawnPoint.PrimaryPart.CFrame + Vector3.new(0, partSize.Y/2 + 3, 0)
            else
                return false
            end
        elseif spawnPoint:IsA("MeshPart") then
            if spawnPoint.CFrame then
                local partSize = spawnPoint.Size
                humanoidRootPart.CFrame = spawnPoint.CFrame + Vector3.new(0, partSize.Y/2 + 3, 0)
            else
                return false
            end
        else
            if spawnPoint.Position then
                humanoidRootPart.CFrame = CFrame.new(spawnPoint.Position + Vector3.new(0, 5, 0))
            elseif spawnPoint.CFrame then
                humanoidRootPart.CFrame = spawnPoint.CFrame + Vector3.new(0, 5, 0)
            else
                return false
            end
        end
    end)
    
    if not success then
        return false
    end
    
    wait(0.1)
    
    local virtualInputManager = game:GetService("VirtualInputManager")
    for i = 1, 30 do
        virtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
        wait(0.05)
        virtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
        wait(0.05)
    end
    
    wait(0.1)
    return true
end

local function autoCollectLoop()
    while settings.autoCollectPlant do
        local plants = getAllPlants()
        
        if #plants == 0 then
            wait(5)
            continue
        end
        
        if plantIndex > #plants then
            plantIndex = 1
        end
        
        local currentPlant = plants[plantIndex]
        if currentPlant then
            local success = collectFromPlant(currentPlant)
            plantIndex = plantIndex + 1
        else
            plantIndex = 1
        end
        
        wait(collectDelay)
    end
end

local function autoSellLoop()
    while settings.autoSellInventory do
        wait(1)
        autoSellTimer = autoSellTimer + 1
        
        if autoSellTimer >= 30 then
            autoSellTimer = 0
            
            if settings.autoCollectPlant then
                settings.autoCollectPlant = false
                animateToggle(collectBg, collectToggleButton, settings.autoCollectPlant)
                
                if autoCollectConnection then
                    task.cancel(autoCollectConnection)
                    autoCollectConnection = nil
                end
            end
            
            local character = player.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                local humanoidRootPart = character.HumanoidRootPart
                local originalPosition = humanoidRootPart.CFrame
                
                humanoidRootPart.CFrame = CFrame.new(SELL_POSITION)
                wait(0.5)
                
                sellInventoryEvent:FireServer()
                wait(1)
                
                humanoidRootPart.CFrame = originalPosition
                wait(0.5)
            end
            
            settings.autoCollectPlant = true
            animateToggle(collectBg, collectToggleButton, settings.autoCollectPlant)
            
            autoCollectConnection = task.spawn(autoCollectLoop)
        end
    end
end

function startAutoCollect()
    if autoCollectConnection then
        task.cancel(autoCollectConnection)
    end
    
    plantIndex = 1
    autoCollectConnection = task.spawn(autoCollectLoop)
end

function stopAutoCollect()
    if autoCollectConnection then
        task.cancel(autoCollectConnection)
        autoCollectConnection = nil
    end
end

function startAutoSell()
    if autoSellConnection then
        task.cancel(autoSellConnection)
    end
    
    autoSellTimer = 0
    autoSellConnection = task.spawn(autoSellLoop)
end

function stopAutoSell()
    if autoSellConnection then
        task.cancel(autoSellConnection)
        autoSellConnection = nil
    end
    autoSellTimer = 0
end

function sellInventoryWithTeleport()
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        return
    end
    
    local humanoidRootPart = character.HumanoidRootPart
    local originalPosition = humanoidRootPart.CFrame
    
    sellInventoryBtn.Text = "💰 Selling..."
    
    humanoidRootPart.CFrame = CFrame.new(SELL_POSITION)
    wait(0.5)
    
    sellInventoryEvent:FireServer()
    wait(1)
    
    humanoidRootPart.CFrame = originalPosition
    wait(0.5)
    
    sellInventoryBtn.Text = "💰 Sell Inventory"
end

function sellItemWithTeleport()
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        return
    end
    
    local humanoidRootPart = character.HumanoidRootPart
    local originalPosition = humanoidRootPart.CFrame
    
    sellItemBtn.Text = "🎯 Selling..."
    
    humanoidRootPart.CFrame = CFrame.new(SELL_POSITION)
    wait(0.5)
    
    sellItemEvent:FireServer()
    wait(1)
    
    humanoidRootPart.CFrame = originalPosition
    wait(0.5)
    
    sellItemBtn.Text = "🎯 Sell Item"
end

-- Fly movement system
local flyConnection
local function updateFly()
    if not settings.flyEnabled or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        return
    end
    
    local camera = workspace.CurrentCamera
    local humanoidRootPart = player.Character.HumanoidRootPart
    local moveVector = Vector3.new(0, 0, 0)
    
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
        moveVector = moveVector + camera.CFrame.LookVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
        moveVector = moveVector - camera.CFrame.LookVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
        moveVector = moveVector - camera.CFrame.RightVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
        moveVector = moveVector + camera.CFrame.RightVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        moveVector = moveVector + Vector3.new(0, 1, 0)
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
        moveVector = moveVector - Vector3.new(0, 1, 0)
    end
    
    if flyBodyVelocity then
        flyBodyVelocity.Velocity = moveVector * 50
    end
end

flyConnection = RunService.Heartbeat:Connect(updateFly)

-- Hotkey system for menu toggle
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed or waitingForHotkey then return end
    
    if input.KeyCode == settings.hotkey then
        screenGui.Enabled = not screenGui.Enabled
        if screenGui.Enabled then
            mainContainer.Size = UDim2.new(0, 0, 0, 0)
            local openTween = TweenService:Create(mainContainer, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
                Size = UDim2.new(0, 480, 0, 680)
            })
            openTween:Play()
        end
    end
end)

-- Character respawn handling
player.CharacterAdded:Connect(function(character)
    character:WaitForChild("Humanoid")
    updateMovementSpeed()
end)

-- Initialize
updateTheme()
if player.Character then
    updateMovementSpeed()
end

-- Startup animation
mainContainer.Size = UDim2.new(0, 0, 0, 0)

wait(0.1)

local startupTween = TweenService:Create(mainContainer, TweenInfo.new(0.5, Enum.EasingStyle.Back), {
    Size = UDim2.new(0, 480, 0, 680)
})

startupTween:Play()
