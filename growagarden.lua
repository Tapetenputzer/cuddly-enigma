-- Grow a Garden Script
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

local SELL_POSITION = Vector3.new(86, 2, 0)

local settings = {
    hotkey = Enum.KeyCode.F1,
    theme = "Dark",
    movementSpeed = 16,
    flyEnabled = false,
    autoCollectPlant = false,
    autoSellInventory = false,
    antiAFK = false
}

local themes = {
    Dark = {
        primary = Color3.fromRGB(45, 45, 45),
        secondary = Color3.fromRGB(25, 25, 25),
        accent = Color3.fromRGB(70, 130, 180),
        text = Color3.fromRGB(255, 255, 255),
        success = Color3.fromRGB(85, 170, 85),
        warning = Color3.fromRGB(255, 165, 0),
        error = Color3.fromRGB(170, 85, 85)
    },
    Light = {
        primary = Color3.fromRGB(240, 240, 240),
        secondary = Color3.fromRGB(220, 220, 220),
        accent = Color3.fromRGB(70, 130, 180),
        text = Color3.fromRGB(0, 0, 0),
        success = Color3.fromRGB(85, 170, 85),
        warning = Color3.fromRGB(255, 165, 0),
        error = Color3.fromRGB(170, 85, 85)
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

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "GameMenuGui"
screenGui.Parent = playerGui

local menuFrame = Instance.new("Frame")
menuFrame.Name = "MenuFrame"
menuFrame.Size = UDim2.new(0, 400, 0, 500)
menuFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
menuFrame.BackgroundColor3 = themes[settings.theme].primary
menuFrame.BorderSizePixel = 3
menuFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
menuFrame.Parent = screenGui

local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 50)
titleBar.Position = UDim2.new(0, 0, 0, 0)
titleBar.BackgroundColor3 = themes[settings.theme].secondary
titleBar.BorderSizePixel = 0
titleBar.Parent = menuFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleLabel"
titleLabel.Size = UDim2.new(0.8, 0, 1, 0)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Grow a Garden Script"
titleLabel.TextColor3 = themes[settings.theme].text
titleLabel.TextScaled = true
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.Parent = titleBar

local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 40, 0, 40)
closeButton.Position = UDim2.new(1, -45, 0, 5)
closeButton.BackgroundColor3 = themes[settings.theme].error
closeButton.BorderSizePixel = 1
closeButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextScaled = true
closeButton.Font = Enum.Font.SourceSansBold
closeButton.Parent = titleBar

local tabContainer = Instance.new("Frame")
tabContainer.Name = "TabContainer"
tabContainer.Size = UDim2.new(1, 0, 0, 40)
tabContainer.Position = UDim2.new(0, 0, 0, 50)
tabContainer.BackgroundColor3 = themes[settings.theme].secondary
tabContainer.BorderSizePixel = 0
tabContainer.Parent = menuFrame

local tabs = {"Player", "RE", "AutoFarm", "Settings"}
local tabButtons = {}
local currentTab = "Player"

for i, tabName in ipairs(tabs) do
    local tabButton = Instance.new("TextButton")
    tabButton.Name = tabName .. "Tab"
    tabButton.Size = UDim2.new(0.25, -2, 1, 0)
    tabButton.Position = UDim2.new((i-1) * 0.25, 1, 0, 0)
    tabButton.BackgroundColor3 = tabName == currentTab and themes[settings.theme].accent or themes[settings.theme].secondary
    tabButton.BorderSizePixel = 1
    tabButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
    tabButton.Text = tabName
    tabButton.TextColor3 = themes[settings.theme].text
    tabButton.TextScaled = true
    tabButton.Font = Enum.Font.SourceSans
    tabButton.Parent = tabContainer
    tabButtons[tabName] = tabButton
end

local contentFrame = Instance.new("Frame")
contentFrame.Name = "ContentFrame"
contentFrame.Size = UDim2.new(1, 0, 1, -90)
contentFrame.Position = UDim2.new(0, 0, 0, 90)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = menuFrame

local tabFrames = {}
for _, tabName in ipairs(tabs) do
    local frame = Instance.new("Frame")
    frame.Name = tabName .. "Frame"
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.Position = UDim2.new(0, 0, 0, 0)
    frame.BackgroundTransparency = 1
    frame.Visible = tabName == currentTab
    frame.Parent = contentFrame
    tabFrames[tabName] = frame
end

local playerFrame = tabFrames["Player"]

local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0.9, 0, 0, 30)
speedLabel.Position = UDim2.new(0.05, 0, 0, 10)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "Movement Speed: " .. settings.movementSpeed
speedLabel.TextColor3 = themes[settings.theme].text
speedLabel.TextScaled = true
speedLabel.Font = Enum.Font.SourceSans
speedLabel.Parent = playerFrame

local speedSlider = Instance.new("Frame")
speedSlider.Size = UDim2.new(0.9, 0, 0, 20)
speedSlider.Position = UDim2.new(0.05, 0, 0, 50)
speedSlider.BackgroundColor3 = themes[settings.theme].secondary
speedSlider.BorderSizePixel = 1
speedSlider.BorderColor3 = Color3.fromRGB(0, 0, 0)
speedSlider.Parent = playerFrame

local speedHandle = Instance.new("TextButton")
speedHandle.Size = UDim2.new(0, 20, 1, 0)
speedHandle.Position = UDim2.new((settings.movementSpeed - 16) / 84, -10, 0, 0)
speedHandle.BackgroundColor3 = themes[settings.theme].accent
speedHandle.BorderSizePixel = 1
speedHandle.BorderColor3 = Color3.fromRGB(0, 0, 0)
speedHandle.Text = ""
speedHandle.Parent = speedSlider

local flyToggle = Instance.new("TextButton")
flyToggle.Size = UDim2.new(0.9, 0, 0, 40)
flyToggle.Position = UDim2.new(0.05, 0, 0, 90)
flyToggle.BackgroundColor3 = settings.flyEnabled and themes[settings.theme].success or themes[settings.theme].error
flyToggle.BorderSizePixel = 2
flyToggle.BorderColor3 = Color3.fromRGB(0, 0, 0)
flyToggle.Text = "Fly: " .. (settings.flyEnabled and "ON" or "OFF")
flyToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
flyToggle.TextScaled = true
flyToggle.Font = Enum.Font.SourceSansBold
flyToggle.Parent = playerFrame

local antiAFKToggle = Instance.new("TextButton")
antiAFKToggle.Size = UDim2.new(0.9, 0, 0, 40)
antiAFKToggle.Position = UDim2.new(0.05, 0, 0, 140)
antiAFKToggle.BackgroundColor3 = Color3.fromRGB(170, 85, 85)
antiAFKToggle.BorderSizePixel = 2
antiAFKToggle.BorderColor3 = Color3.fromRGB(0, 0, 0)
antiAFKToggle.Text = "Anti AFK: OFF"
antiAFKToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
antiAFKToggle.TextScaled = true
antiAFKToggle.Font = Enum.Font.SourceSansBold
antiAFKToggle.Parent = playerFrame

local reFrame = tabFrames["RE"]

local sellInventoryButton = Instance.new("TextButton")
sellInventoryButton.Size = UDim2.new(0.9, 0, 0, 60)
sellInventoryButton.Position = UDim2.new(0.05, 0, 0, 20)
sellInventoryButton.BackgroundColor3 = themes[settings.theme].success
sellInventoryButton.BorderSizePixel = 2
sellInventoryButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
sellInventoryButton.Text = "Sell Inventory"
sellInventoryButton.TextColor3 = Color3.fromRGB(255, 255, 255)
sellInventoryButton.TextScaled = true
sellInventoryButton.Font = Enum.Font.SourceSansBold
sellInventoryButton.Parent = reFrame

local sellItemButton = Instance.new("TextButton")
sellItemButton.Size = UDim2.new(0.9, 0, 0, 60)
sellItemButton.Position = UDim2.new(0.05, 0, 0, 100)
sellItemButton.BackgroundColor3 = Color3.fromRGB(85, 85, 170)
sellItemButton.BorderSizePixel = 2
sellItemButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
sellItemButton.Text = "Sell Item"
sellItemButton.TextColor3 = Color3.fromRGB(255, 255, 255)
sellItemButton.TextScaled = true
sellItemButton.Font = Enum.Font.SourceSansBold
sellItemButton.Parent = reFrame

local guiButton = Instance.new("TextButton")
guiButton.Size = UDim2.new(0.9, 0, 0, 60)
guiButton.Position = UDim2.new(0.05, 0, 0, 180)
guiButton.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
guiButton.BorderSizePixel = 2
guiButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
local seedDropdown = Instance.new("TextButton")
seedDropdown.Size = UDim2.new(0.9, 0, 0, 40)
seedDropdown.Position = UDim2.new(0.05, 0, 0, 260)
seedDropdown.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
seedDropdown.BorderSizePixel = 2
seedDropdown.BorderColor3 = Color3.fromRGB(0, 0, 0)
seedDropdown.Text = "Select Seed"
seedDropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
seedDropdown.TextScaled = true
seedDropdown.Font = Enum.Font.SourceSans
seedDropdown.Parent = reFrame

local dropdownFrame = Instance.new("Frame")
dropdownFrame.Size = UDim2.new(0.9, 0, 0, 0)
dropdownFrame.Position = UDim2.new(0.05, 0, 0, 300)
dropdownFrame.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
dropdownFrame.BorderSizePixel = 2
dropdownFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
dropdownFrame.Visible = false
dropdownFrame.ClipsDescendants = true
dropdownFrame.Parent = reFrame

local scrollingFrame = Instance.new("ScrollingFrame")
scrollingFrame.Size = UDim2.new(1, 0, 1, 0)
scrollingFrame.Position = UDim2.new(0, 0, 0, 0)
scrollingFrame.BackgroundTransparency = 1
scrollingFrame.ScrollBarThickness = 6
scrollingFrame.Parent = dropdownFrame

local buySeedButton = Instance.new("TextButton")
buySeedButton.Size = UDim2.new(0.9, 0, 0, 40)
buySeedButton.Position = UDim2.new(0.05, 0, 0, 310)
buySeedButton.BackgroundColor3 = Color3.fromRGB(85, 170, 85)
buySeedButton.BorderSizePixel = 2
buySeedButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
buySeedButton.Text = "Buy Selected Seed"
buySeedButton.TextColor3 = Color3.fromRGB(255, 255, 255)
buySeedButton.TextScaled = true
buySeedButton.Font = Enum.Font.SourceSansBold
buySeedButton.Parent = reFrame

local selectedSeed = nil
local selectedSeedButton = nil

local function getAvailableSeeds()
    local seedShopGui = player.PlayerGui:FindFirstChild("Seed_Shop")
    if not seedShopGui then return {} end
    
    local frame = seedShopGui:FindFirstChild("Frame")
    if not frame then return {} end
    
    local scrollingFrame = frame:FindFirstChild("ScrollingFrame")
    if not scrollingFrame then return {} end
    
    local availableSeeds = {}
    
    for _, child in pairs(scrollingFrame:GetChildren()) do
        if child:IsA("Frame") and child.Name ~= "UIListLayout" and not child.Name:find("_Padding") then
            local seedName = child.Name
            if seedName and seedName ~= "" then
                table.insert(availableSeeds, {
                    name = seedName,
                    frame = child
                })
            end
        end
    end
    
    return availableSeeds
end

local function updateDropdown()
    for _, child in pairs(scrollingFrame:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    local seeds = getAvailableSeeds()
    local yPos = 0
    
    for _, seed in pairs(seeds) do
        local seedButton = Instance.new("TextButton")
        seedButton.Size = UDim2.new(1, 0, 0, 30)
        seedButton.Position = UDim2.new(0, 0, 0, yPos)
        seedButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        seedButton.BorderSizePixel = 1
        seedButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
        seedButton.Text = seed.name
        seedButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        seedButton.TextScaled = true
        seedButton.Font = Enum.Font.SourceSans
        seedButton.Parent = scrollingFrame
        
        seedButton.MouseButton1Click:Connect(function()
            selectedSeed = seed
            selectedSeedButton = seed.frame
            seedDropdown.Text = seed.name
            dropdownFrame.Visible = false
            dropdownFrame.Size = UDim2.new(0.9, 0, 0, 0)
        end)
        
        yPos = yPos + 30
    end
    
    scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, yPos)
end

seedDropdown.MouseButton1Click:Connect(function()
    if dropdownFrame.Visible then
        dropdownFrame.Visible = false
        dropdownFrame.Size = UDim2.new(0.9, 0, 0, 0)
    else
        updateDropdown()
        local seeds = getAvailableSeeds()
        local dropdownHeight = math.min(#seeds * 30, 150)
        
        dropdownFrame.Size = UDim2.new(0.9, 0, 0, dropdownHeight)
        dropdownFrame.Visible = true
    end
end)

buySeedButton.MouseButton1Click:Connect(function()
    if selectedSeedButton then
        -- Look for the Frame inside the selected seed
        local seedFrame = selectedSeedButton:FindFirstChild("Frame")
        if seedFrame then
            -- Try to find Sheckles_Buy button first (regular currency)
            local shecklesBuy = seedFrame:FindFirstChild("Sheckles_Buy")
            local robuxBuy = seedFrame:FindFirstChild("Robux_Buy")
            
            local buyElement = shecklesBuy or robuxBuy -- Prefer Sheckles over Robux
            
            if buyElement then
                print("Found buy element:", buyElement.Name, "Type:", buyElement.ClassName)
                
                -- Try to find a clickable element inside
                local clickableButton = nil
                
                -- Check if it's directly clickable
                if buyElement:IsA("GuiButton") then
                    clickableButton = buyElement
                else
                    -- Look for TextButton or ImageButton inside
                    for _, child in pairs(buyElement:GetDescendants()) do
                        if child:IsA("GuiButton") then
                            clickableButton = child
                            break
                        end
                    end
                end
                
                if clickableButton then
                    print("Found clickable button:", clickableButton.Name)
                    
                    -- Try different methods to click
                    local success = false
                    
                    -- Method 1: Direct Fire
                    pcall(function()
                        clickableButton.MouseButton1Click:Fire()
                        success = true
                        print("Method 1 (Fire) successful")
                    end)
                    
                    -- Method 2: getconnections
                    if not success then
                        pcall(function()
                            for i, connection in pairs(getconnections(clickableButton.MouseButton1Click)) do
                                connection:Fire()
                                success = true
                                print("Method 2 (getconnections) successful")
                                break
                            end
                        end)
                    end
                    
                    -- Method 3: Virtual click
                    if not success then
                        pcall(function()
                            local VirtualInputManager = game:GetService("VirtualInputManager")
                            local buttonPos = clickableButton.AbsolutePosition
                            local buttonSize = clickableButton.AbsoluteSize
                            VirtualInputManager:SendMouseButtonEvent(
                                buttonPos.X + buttonSize.X/2, 
                                buttonPos.Y + buttonSize.Y/2, 
                                0, true, game, 1
                            )
                            wait(0.1)
                            VirtualInputManager:SendMouseButtonEvent(
                                buttonPos.X + buttonSize.X/2, 
                                buttonPos.Y + buttonSize.Y/2, 
                                0, false, game, 1
                            )
                            success = true
                            print("Method 3 (VirtualInput) successful")
                        end)
                    end
                    
                    if not success then
                        print("All methods failed")
                    end
                else
                    print("No clickable button found inside", buyElement.Name)
                end
            else
                print("Buy element not found")
            end
        else
            print("Frame not found in seed")
        end
    else
        print("No seed selected")
    end
end)

guiButton.Text = "Open Seed Shop"
guiButton.TextColor3 = Color3.fromRGB(255, 255, 255)
guiButton.TextScaled = true
guiButton.Font = Enum.Font.SourceSansBold
guiButton.Parent = reFrame

local autoFarmFrame = tabFrames["AutoFarm"]

local autoCollectToggle = Instance.new("TextButton")
autoCollectToggle.Size = UDim2.new(0.9, 0, 0, 60)
autoCollectToggle.Position = UDim2.new(0.05, 0, 0, 20)
autoCollectToggle.BackgroundColor3 = settings.autoCollectPlant and themes[settings.theme].success or themes[settings.theme].error
autoCollectToggle.BorderSizePixel = 2
autoCollectToggle.BorderColor3 = Color3.fromRGB(0, 0, 0)
autoCollectToggle.Text = "Auto Collect Plant: " .. (settings.autoCollectPlant and "ON" or "OFF")
autoCollectToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
autoCollectToggle.TextScaled = true
autoCollectToggle.Font = Enum.Font.SourceSansBold
autoCollectToggle.Parent = autoFarmFrame

local autoSellToggle = Instance.new("TextButton")
autoSellToggle.Size = UDim2.new(0.9, 0, 0, 60)
autoSellToggle.Position = UDim2.new(0.05, 0, 0, 100)
autoSellToggle.BackgroundColor3 = settings.autoSellInventory and themes[settings.theme].success or themes[settings.theme].error
autoSellToggle.BorderSizePixel = 2
autoSellToggle.BorderColor3 = Color3.fromRGB(0, 0, 0)
autoSellToggle.Text = "Auto Sell Inventory: " .. (settings.autoSellInventory and "ON" or "OFF")
autoSellToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
autoSellToggle.TextScaled = true
autoSellToggle.Font = Enum.Font.SourceSansBold
autoSellToggle.Parent = autoFarmFrame

local settingsFrame = tabFrames["Settings"]

local themeLabel = Instance.new("TextLabel")
themeLabel.Size = UDim2.new(0.9, 0, 0, 30)
themeLabel.Position = UDim2.new(0.05, 0, 0, 10)
themeLabel.BackgroundTransparency = 1
themeLabel.Text = "Theme:"
themeLabel.TextColor3 = themes[settings.theme].text
themeLabel.TextScaled = true
themeLabel.Font = Enum.Font.SourceSans
themeLabel.Parent = settingsFrame

local themeButton = Instance.new("TextButton")
themeButton.Size = UDim2.new(0.9, 0, 0, 40)
themeButton.Position = UDim2.new(0.05, 0, 0, 50)
themeButton.BackgroundColor3 = themes[settings.theme].accent
themeButton.BorderSizePixel = 2
themeButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
themeButton.Text = "Theme: " .. settings.theme
themeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
themeButton.TextScaled = true
themeButton.Font = Enum.Font.SourceSansBold
themeButton.Parent = settingsFrame

local hotkeyLabel = Instance.new("TextLabel")
hotkeyLabel.Size = UDim2.new(0.9, 0, 0, 30)
hotkeyLabel.Position = UDim2.new(0.05, 0, 0, 110)
hotkeyLabel.BackgroundTransparency = 1
hotkeyLabel.Text = "Menu Hotkey:"
hotkeyLabel.TextColor3 = themes[settings.theme].text
hotkeyLabel.TextScaled = true
hotkeyLabel.Font = Enum.Font.SourceSans
hotkeyLabel.Parent = settingsFrame

local hotkeyButton = Instance.new("TextButton")
hotkeyButton.Size = UDim2.new(0.9, 0, 0, 40)
hotkeyButton.Position = UDim2.new(0.05, 0, 0, 150)
hotkeyButton.BackgroundColor3 = themes[settings.theme].accent
hotkeyButton.BorderSizePixel = 2
hotkeyButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
hotkeyButton.Text = "Hotkey: " .. settings.hotkey.Name
hotkeyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
hotkeyButton.TextScaled = true
hotkeyButton.Font = Enum.Font.SourceSansBold
local creditsLabel = Instance.new("TextLabel")
creditsLabel.Size = UDim2.new(0.9, 0, 0, 25)
creditsLabel.Position = UDim2.new(0.05, 0, 0, 200)
creditsLabel.BackgroundTransparency = 1
creditsLabel.Text = "Made by massivendurchfall"
creditsLabel.TextColor3 = themes[settings.theme].text
creditsLabel.TextScaled = true
creditsLabel.Font = Enum.Font.SourceSansItalic
creditsLabel.TextTransparency = 0.5
creditsLabel.Parent = settingsFrame

local function updateTheme()
    local theme = themes[settings.theme]
    menuFrame.BackgroundColor3 = theme.primary
    titleBar.BackgroundColor3 = theme.secondary
    tabContainer.BackgroundColor3 = theme.secondary
    titleLabel.TextColor3 = theme.text
    speedLabel.TextColor3 = theme.text
    speedSlider.BackgroundColor3 = theme.secondary
    speedHandle.BackgroundColor3 = theme.accent
    themeLabel.TextColor3 = theme.text
    themeButton.BackgroundColor3 = theme.accent
    hotkeyLabel.TextColor3 = theme.text
    hotkeyButton.BackgroundColor3 = theme.accent
    
    for tabName, button in pairs(tabButtons) do
        button.BackgroundColor3 = tabName == currentTab and theme.accent or theme.secondary
        button.TextColor3 = theme.text
    end
end

local function switchTab(tabName)
    currentTab = tabName
    for name, frame in pairs(tabFrames) do
        frame.Visible = name == tabName
    end
    updateTheme()
end

local function updateMovementSpeed()
    local character = player.Character
    if character and character:FindFirstChild("Humanoid") then
        character.Humanoid.WalkSpeed = settings.movementSpeed
    end
end

local function toggleFly()
    settings.flyEnabled = not settings.flyEnabled
    flyToggle.Text = "Fly: " .. (settings.flyEnabled and "ON" or "OFF")
    flyToggle.BackgroundColor3 = settings.flyEnabled and themes[settings.theme].success or themes[settings.theme].error
    
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
end

local function toggleAntiAFK()
    settings.antiAFK = not settings.antiAFK
    antiAFKToggle.Text = "Anti AFK: " .. (settings.antiAFK and "ON" or "OFF")
    antiAFKToggle.BackgroundColor3 = settings.antiAFK and Color3.fromRGB(85, 170, 85) or Color3.fromRGB(170, 85, 85)
    
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
end

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
            
            if success then
                plantIndex = plantIndex + 1
            else
                plantIndex = plantIndex + 1
            end
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
        
        if autoSellTimer >= 10 then
            autoSellTimer = 0
            
            if settings.autoCollectPlant then
                settings.autoCollectPlant = false
                autoCollectToggle.Text = "Auto Collect Plant: OFF"
                autoCollectToggle.BackgroundColor3 = themes[settings.theme].error
                
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
            autoCollectToggle.Text = "Auto Collect Plant: ON"
            autoCollectToggle.BackgroundColor3 = themes[settings.theme].success
            
            autoCollectConnection = task.spawn(autoCollectLoop)
        end
    end
end

local function startAutoCollect()
    if autoCollectConnection then
        task.cancel(autoCollectConnection)
    end
    
    plantIndex = 1
    autoCollectConnection = task.spawn(autoCollectLoop)
end

local function stopAutoCollect()
    if autoCollectConnection then
        task.cancel(autoCollectConnection)
        autoCollectConnection = nil
    end
end

local function startAutoSell()
    if autoSellConnection then
        task.cancel(autoSellConnection)
    end
    
    autoSellTimer = 0
    autoSellConnection = task.spawn(autoSellLoop)
end

local function stopAutoSell()
    if autoSellConnection then
        task.cancel(autoSellConnection)
        autoSellConnection = nil
    end
    autoSellTimer = 0
end

local function sellInventoryWithTeleport()
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        return
    end
    
    local humanoidRootPart = character.HumanoidRootPart
    local originalPosition = humanoidRootPart.CFrame
    
    sellInventoryButton.Text = "Selling..."
    
    humanoidRootPart.CFrame = CFrame.new(SELL_POSITION)
    wait(0.5)
    
    sellInventoryEvent:FireServer()
    wait(1)
    
    humanoidRootPart.CFrame = originalPosition
    wait(0.5)
    
    sellInventoryButton.Text = "Sell Inventory"
end

local function sellItemWithTeleport()
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        return
    end
    
    local humanoidRootPart = character.HumanoidRootPart
    local originalPosition = humanoidRootPart.CFrame
    
    sellItemButton.Text = "Selling..."
    
    humanoidRootPart.CFrame = CFrame.new(SELL_POSITION)
    wait(0.5)
    
    sellItemEvent:FireServer()
    wait(1)
    
    humanoidRootPart.CFrame = originalPosition
    wait(0.5)
    
    sellItemButton.Text = "Sell Item"
end

for tabName, button in pairs(tabButtons) do
    button.MouseButton1Click:Connect(function()
        switchTab(tabName)
    end)
end

local draggingSpeed = false
speedHandle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingSpeed = true
    end
end)

speedHandle.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and draggingSpeed then
        local mousePos = UserInputService:GetMouseLocation().X
        local sliderPos = speedSlider.AbsolutePosition.X
        local sliderSize = speedSlider.AbsoluteSize.X
        local percentage = math.clamp((mousePos - sliderPos) / sliderSize, 0, 1)
        
        settings.movementSpeed = math.floor(16 + (percentage * 84))
        speedHandle.Position = UDim2.new(percentage, -10, 0, 0)
        speedLabel.Text = "Movement Speed: " .. settings.movementSpeed
        updateMovementSpeed()
    end
end)

speedHandle.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingSpeed = false
    end
end)

flyToggle.MouseButton1Click:Connect(function()
    toggleFly()
end)

antiAFKToggle.MouseButton1Click:Connect(function()
    toggleAntiAFK()
end)

autoCollectToggle.MouseButton1Click:Connect(function()
    settings.autoCollectPlant = not settings.autoCollectPlant
    autoCollectToggle.Text = "Auto Collect Plant: " .. (settings.autoCollectPlant and "ON" or "OFF")
    autoCollectToggle.BackgroundColor3 = settings.autoCollectPlant and themes[settings.theme].success or themes[settings.theme].error
    
    if not settings.autoCollectPlant and settings.autoSellInventory then
        settings.autoSellInventory = false
        autoSellToggle.Text = "Auto Sell Inventory: OFF"
        autoSellToggle.BackgroundColor3 = themes[settings.theme].error
        stopAutoSell()
    end
    
    if settings.autoCollectPlant then
        if not settings.flyEnabled then
            settings.flyEnabled = true
            flyToggle.Text = "Fly: ON"
            flyToggle.BackgroundColor3 = themes[settings.theme].success
            
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
        if settings.flyEnabled then
            settings.flyEnabled = false
            flyToggle.Text = "Fly: OFF"
            flyToggle.BackgroundColor3 = themes[settings.theme].error
            
            if flyBodyVelocity then flyBodyVelocity:Destroy() end
            if flyBodyAngularVelocity then flyBodyAngularVelocity:Destroy() end
        end
        stopAutoCollect()
    end
end)

autoSellToggle.MouseButton1Click:Connect(function()
    if not settings.autoCollectPlant then
        return
    end
    
    settings.autoSellInventory = not settings.autoSellInventory
    autoSellToggle.Text = "Auto Sell Inventory: " .. (settings.autoSellInventory and "ON" or "OFF")
    autoSellToggle.BackgroundColor3 = settings.autoSellInventory and themes[settings.theme].success or themes[settings.theme].error
    
    if settings.autoSellInventory then
        startAutoSell()
    else
        stopAutoSell()
    end
end)

themeButton.MouseButton1Click:Connect(function()
    settings.theme = settings.theme == "Dark" and "Light" or "Dark"
    themeButton.Text = "Theme: " .. settings.theme
    updateTheme()
end)

local hotkeys = {Enum.KeyCode.F1, Enum.KeyCode.F2, Enum.KeyCode.F3, Enum.KeyCode.Insert, Enum.KeyCode.Home}
hotkeyButton.MouseButton1Click:Connect(function()
    local currentIndex = 1
    for i, key in ipairs(hotkeys) do
        if key == settings.hotkey then
            currentIndex = i
            break
        end
    end
    currentIndex = currentIndex % #hotkeys + 1
    settings.hotkey = hotkeys[currentIndex]
    hotkeyButton.Text = "Hotkey: " .. settings.hotkey.Name
end)

guiButton.MouseButton1Click:Connect(function()
    local seedShopGui = player.PlayerGui:FindFirstChild("Seed_Shop")
    if seedShopGui then
        seedShopGui.Enabled = not seedShopGui.Enabled
        guiButton.Text = seedShopGui.Enabled and "Close Seed Shop" or "Open Seed Shop"
    end
end)

sellInventoryButton.MouseButton1Click:Connect(function()
    sellInventoryWithTeleport()
end)

sellItemButton.MouseButton1Click:Connect(function()
    sellItemWithTeleport()
end)

local dragging = false
local dragStart = nil
local startPos = nil

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = menuFrame.Position
    end
end)

titleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
        local delta = input.Position - dragStart
        menuFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

titleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

closeButton.MouseButton1Click:Connect(function()
    local closeTween = TweenService:Create(menuFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Size = UDim2.new(0, 0, 0, 0)})
    closeTween:Play()
    closeTween.Completed:Connect(function()
        screenGui.Enabled = false
    end)
end)

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

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == settings.hotkey then
        screenGui.Enabled = not screenGui.Enabled
        if screenGui.Enabled then
            menuFrame.Size = UDim2.new(0, 0, 0, 0)
            local openTween = TweenService:Create(menuFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Size = UDim2.new(0, 400, 0, 500)})
            openTween:Play()
        end
    end
end)

player.CharacterAdded:Connect(function(character)
    character:WaitForChild("Humanoid")
    updateMovementSpeed()
end)

updateTheme()
if player.Character then
    updateMovementSpeed()
end
