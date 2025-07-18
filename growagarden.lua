-- LocalScript (must be placed in StarterGui or StarterPlayerScripts)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Wait for Remote Events
local sellInventoryEvent = ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("Sell_Inventory")
local sellItemEvent = ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("Sell_Item")

-- Target coordinates for selling
local SELL_POSITION = Vector3.new(86, 2, 0)

-- Settings
local settings = {
    hotkey = Enum.KeyCode.F1,
    theme = "Dark", -- "Dark" or "Light"
    movementSpeed = 16,
    flyEnabled = false,
    autoCollectPlant = false,
    autoSellInventory = false
}

-- Themes
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

-- Variables for fly
local flyBodyVelocity = nil
local flyBodyAngularVelocity = nil

-- Variables for auto collect
local autoCollectConnection = nil
local plantIndex = 1
local collectDelay = 2 -- seconds between collections

-- Variables for auto sell
local autoSellConnection = nil
local sellDelay = 30 -- seconds between auto sells

-- Create main GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "GameMenuGui"
screenGui.Parent = playerGui

-- Create draggable menu frame
local menuFrame = Instance.new("Frame")
menuFrame.Name = "MenuFrame"
menuFrame.Size = UDim2.new(0, 400, 0, 500)
menuFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
menuFrame.BackgroundColor3 = themes[settings.theme].primary
menuFrame.BorderSizePixel = 3
menuFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
menuFrame.Parent = screenGui

-- Create title bar for dragging
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 50)
titleBar.Position = UDim2.new(0, 0, 0, 0)
titleBar.BackgroundColor3 = themes[settings.theme].secondary
titleBar.BorderSizePixel = 0
titleBar.Parent = menuFrame

-- Create title label
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleLabel"
titleLabel.Size = UDim2.new(0.8, 0, 1, 0)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Game Menu"
titleLabel.TextColor3 = themes[settings.theme].text
titleLabel.TextScaled = true
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.Parent = titleBar

-- Create close button
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

-- Create tab buttons container
local tabContainer = Instance.new("Frame")
tabContainer.Name = "TabContainer"
tabContainer.Size = UDim2.new(1, 0, 0, 40)
tabContainer.Position = UDim2.new(0, 0, 0, 50)
tabContainer.BackgroundColor3 = themes[settings.theme].secondary
tabContainer.BorderSizePixel = 0
tabContainer.Parent = menuFrame

-- Tab buttons
local tabs = {"Player", "Sell", "AutoFarm", "Settings"}
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

-- Create content frame
local contentFrame = Instance.new("Frame")
contentFrame.Name = "ContentFrame"
contentFrame.Size = UDim2.new(1, 0, 1, -90)
contentFrame.Position = UDim2.new(0, 0, 0, 90)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = menuFrame

-- Create tab frames
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

-- Player Tab Content
local playerFrame = tabFrames["Player"]

-- Movement Speed Slider
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
speedHandle.Position = UDim2.new((settings.movementSpeed - 16) / 84, -10, 0, 0) -- 16-100 range
speedHandle.BackgroundColor3 = themes[settings.theme].accent
speedHandle.BorderSizePixel = 1
speedHandle.BorderColor3 = Color3.fromRGB(0, 0, 0)
speedHandle.Text = ""
speedHandle.Parent = speedSlider

-- Fly Toggle
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

-- Sell Tab Content
local sellFrame = tabFrames["Sell"]

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
sellInventoryButton.Parent = sellFrame

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
sellItemButton.Parent = sellFrame

-- AutoFarm Tab Content
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

-- Settings Tab Content
local settingsFrame = tabFrames["Settings"]

-- Theme Selector
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

-- Hotkey Selector
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
hotkeyButton.Parent = settingsFrame

-- Functions
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

-- Auto Collect Functions
local function getAllPlants()
    local mainFarm = workspace:FindFirstChild("Farm")
    if not mainFarm then 
        print("Debug: Main Farm folder not found in workspace")
        return {} 
    end
    
    local plants = {}
    
    -- Look through all Farm folders in the main Farm
    for _, farmFolder in pairs(mainFarm:GetChildren()) do
        if farmFolder.Name == "Farm" and (farmFolder:IsA("Folder") or farmFolder:IsA("Model")) then
            print("Debug: Checking Farm folder:", farmFolder.Name)
            
            local importantFolder = farmFolder:FindFirstChild("Important")
            if importantFolder then
                local plantsFolder = importantFolder:FindFirstChild("Plants_Physical")
                if plantsFolder then
                    print("Debug: Found Plants_Physical in", farmFolder.Name)
                    
                    -- Go through all plants in this Plants_Physical folder
                    for _, plant in pairs(plantsFolder:GetChildren()) do
                        if plant:IsA("Model") or plant:IsA("Folder") then
                            local fruitSpawn = plant:FindFirstChild("Fruit_Spawn")
                            if fruitSpawn then
                                -- Get the first Spawn_Point (in case there are multiple)
                                local spawnPoint = fruitSpawn:FindFirstChild("Spawn_Point")
                                if spawnPoint then
                                    print("Debug: Found plant:", plant.Name, "with spawn point:", spawnPoint.Name, "Type:", spawnPoint.ClassName)
                                    table.insert(plants, {
                                        name = plant.Name,
                                        spawnPoint = spawnPoint
                                    })
                                else
                                    print("Debug: No Spawn_Point found in", plant.Name, "Fruit_Spawn")
                                end
                            else
                                print("Debug: No Fruit_Spawn found in", plant.Name)
                            end
                        end
                    end
                else
                    print("Debug: No Plants_Physical found in", farmFolder.Name, "Important")
                end
            else
                print("Debug: No Important folder found in", farmFolder.Name)
            end
        end
    end
    
    print("Debug: Total plants found across all Farm folders:", #plants)
    return plants
end

local function collectFromPlant(plant)
    local character = player.Character
    if not character then
        print("Debug: No character found")
        return false
    end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then
        print("Debug: No HumanoidRootPart found")
        return false
    end
    
    local spawnPoint = plant.spawnPoint
    if not spawnPoint then
        print("Debug: SpawnPoint is nil for plant:", plant.name)
        return false
    end
    
    print("Debug: Teleporting to plant:", plant.name, "SpawnPoint type:", spawnPoint.ClassName)
    
    -- Teleport to plant spawn point with better error handling - ON TOP of the part
    local success, error = pcall(function()
        if spawnPoint:IsA("Part") then
            if spawnPoint.CFrame then
                -- Teleport on top of the part
                local partSize = spawnPoint.Size
                humanoidRootPart.CFrame = spawnPoint.CFrame + Vector3.new(0, partSize.Y/2 + 3, 0)
                print("Debug: Teleported on top of Part")
            else
                print("Debug: Part has no CFrame")
                return false
            end
        elseif spawnPoint:IsA("Model") then
            if spawnPoint.PrimaryPart and spawnPoint.PrimaryPart.CFrame then
                local partSize = spawnPoint.PrimaryPart.Size
                humanoidRootPart.CFrame = spawnPoint.PrimaryPart.CFrame + Vector3.new(0, partSize.Y/2 + 3, 0)
                print("Debug: Teleported on top of Model PrimaryPart")
            else
                print("Debug: Model has no PrimaryPart or PrimaryPart has no CFrame")
                return false
            end
        elseif spawnPoint:IsA("MeshPart") then
            if spawnPoint.CFrame then
                local partSize = spawnPoint.Size
                humanoidRootPart.CFrame = spawnPoint.CFrame + Vector3.new(0, partSize.Y/2 + 3, 0)
                print("Debug: Teleported on top of MeshPart")
            else
                print("Debug: MeshPart has no CFrame")
                return false
            end
        else
            -- Try to get position from the object - add safe offset
            if spawnPoint.Position then
                humanoidRootPart.CFrame = CFrame.new(spawnPoint.Position + Vector3.new(0, 5, 0))
                print("Debug: Teleported using Position property with offset")
            elseif spawnPoint.CFrame then
                humanoidRootPart.CFrame = spawnPoint.CFrame + Vector3.new(0, 5, 0)
                print("Debug: Teleported using CFrame property with offset")
            else
                print("Debug: SpawnPoint has no Position or CFrame property, type:", spawnPoint.ClassName)
                return false
            end
        end
    end)
    
    if not success then
        print("Debug: Error teleporting to plant:", error)
        return false
    end
    
    print("Debug: Successfully teleported to", plant.name)
    
    -- Press E to collect
    wait(0.2) -- Short delay after teleport
    print("Debug: Pressing E to collect from", plant.name)
    
    -- Simulate E key press
    local virtualInputManager = game:GetService("VirtualInputManager")
    virtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
    wait(0.1)
    virtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
    
    wait(0.3) -- Wait for collection to complete
    return true
end

local function autoCollectLoop()
    while settings.autoCollectPlant do
        local plants = getAllPlants()
        
        if #plants == 0 then
            print("Debug: No plants found, waiting 5 seconds")
            wait(5) -- Wait longer if no plants found
            continue
        end
        
        print("Debug: Starting collection cycle with", #plants, "plants")
        
        -- Cycle through plants
        if plantIndex > #plants then
            plantIndex = 1
            print("Debug: Resetting plant index to 1")
        end
        
        local currentPlant = plants[plantIndex]
        if currentPlant then
            print("Debug: Attempting to collect from plant", plantIndex, ":", currentPlant.name)
            local success = collectFromPlant(currentPlant)
            
            if success then
                plantIndex = plantIndex + 1
                print("Debug: Successfully collected, moving to next plant")
            else
                print("Debug: Failed to collect from plant:", currentPlant.name)
                plantIndex = plantIndex + 1 -- Move to next plant even if failed
            end
        else
            print("Debug: Current plant is nil, resetting index")
            plantIndex = 1
        end
        
        wait(collectDelay)
    end
    
    print("Debug: Auto collect loop ended")
end

local function startAutoCollect()
    print("Debug: Starting auto collect")
    
    if autoCollectConnection then
        task.cancel(autoCollectConnection)
        autoCollectConnection = nil
    end
    
    plantIndex = 1
    print("Debug: Auto collect started successfully")
    
    -- Start the auto collect loop in a new thread
    autoCollectConnection = task.spawn(autoCollectLoop)
end

local function stopAutoCollect()
    print("Debug: Stopping auto collect")
    
    if autoCollectConnection then
        task.cancel(autoCollectConnection)
        autoCollectConnection = nil
    end
    
    print("Debug: Auto collect stopped successfully")
end

-- Event connections
-- Tab switching
for tabName, button in pairs(tabButtons) do
    button.MouseButton1Click:Connect(function()
        switchTab(tabName)
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
        local sliderPos = speedSlider.AbsolutePosition.X
        local sliderSize = speedSlider.AbsoluteSize.X
        local percentage = math.clamp((mousePos - sliderPos) / sliderSize, 0, 1)
        
        settings.movementSpeed = math.floor(16 + (percentage * 84)) -- 16-100 range
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

-- Fly toggle
flyToggle.MouseButton1Click:Connect(function()
    toggleFly()
end)

-- Auto collect toggle
autoCollectToggle.MouseButton1Click:Connect(function()
    settings.autoCollectPlant = not settings.autoCollectPlant
    autoCollectToggle.Text = "Auto Collect Plant: " .. (settings.autoCollectPlant and "ON" or "OFF")
    autoCollectToggle.BackgroundColor3 = settings.autoCollectPlant and themes[settings.theme].success or themes[settings.theme].error
    
    if settings.autoCollectPlant then
        startAutoCollect()
    else
        stopAutoCollect()
    end
end)

-- Theme selector
themeButton.MouseButton1Click:Connect(function()
    settings.theme = settings.theme == "Dark" and "Light" or "Dark"
    themeButton.Text = "Theme: " .. settings.theme
    updateTheme()
end)

-- Hotkey selector (simplified - cycles through common keys)
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

-- Selling functions
local function sellInventoryWithTeleport()
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        print("Error: No character found!")
        return
    end
    
    local humanoidRootPart = character.HumanoidRootPart
    local originalPosition = humanoidRootPart.CFrame
    
    sellInventoryButton.Text = "Selling..."
    print("Teleporting to sell point...")
    
    humanoidRootPart.CFrame = CFrame.new(SELL_POSITION)
    wait(0.5)
    
    print("Selling inventory...")
    sellInventoryEvent:FireServer()
    wait(1)
    
    print("Teleporting back...")
    humanoidRootPart.CFrame = originalPosition
    wait(0.5)
    
    sellInventoryButton.Text = "Sell Inventory"
    print("Inventory sold!")
    
    wait(3)
    print("Ready")
end

local function sellItemWithTeleport()
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        print("Error: No character found!")
        return
    end
    
    local humanoidRootPart = character.HumanoidRootPart
    local originalPosition = humanoidRootPart.CFrame
    
    sellItemButton.Text = "Selling..."
    print("Teleporting to sell point...")
    
    humanoidRootPart.CFrame = CFrame.new(SELL_POSITION)
    wait(0.5)
    
    print("Selling item...")
    sellItemEvent:FireServer()
    wait(1)
    
    print("Teleporting back...")
    humanoidRootPart.CFrame = originalPosition
    wait(0.5)
    
    sellItemButton.Text = "Sell Item"
    print("Item sold!")
    
    wait(3)
    print("Ready")
end

-- Sell button events
sellInventoryButton.MouseButton1Click:Connect(function()
    sellInventoryWithTeleport()
end)

sellItemButton.MouseButton1Click:Connect(function()
    sellItemWithTeleport()
end)

-- Dragging functionality
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

-- Close button
closeButton.MouseButton1Click:Connect(function()
    local closeTween = TweenService:Create(menuFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Size = UDim2.new(0, 0, 0, 0)})
    closeTween:Play()
    closeTween.Completed:Connect(function()
        screenGui.Enabled = false
    end)
end)

-- Fly controls
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

-- Toggle menu with hotkey
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

-- Update movement speed when character spawns
player.CharacterAdded:Connect(function(character)
    character:WaitForChild("Humanoid")
    updateMovementSpeed()
end)

-- Initial setup
updateTheme()
if player.Character then
    updateMovementSpeed()
end
