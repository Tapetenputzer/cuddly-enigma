-- Grow a Garden Script - Mobile Edition
-- Optimized for mobile devices with touch controls

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local sellInventoryEvent = ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("Sell_Inventory")
local buySeedEvent = ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("BuySeedStock")

local SELL_POSITION = Vector3.new(86, 2, 0)

local settings = {
    movementSpeed = 16,
    flyEnabled = false,
    autoCollectPlant = false,
    autoSellInventory = false,
    autoBuySeeds = false,
    selectedSeeds = {"Apple"},
    buyInterval = 5,
    buyMode = "Sequential"
}

local availableSeeds = {
    "Apple", "Bamboo", "Beanstalk", "Blueberry", "Carrot", "Cherry",
    "Coconut", "Corn", "Cotton", "Grape", "Lemon", "Orange",
    "Pear", "Potato", "Pumpkin", "Strawberry", "Tomato", "Watermelon", "Wheat"
}

-- Simplified theme
local theme = {
    primary = Color3.fromRGB(25, 25, 30),
    secondary = Color3.fromRGB(35, 35, 40),
    accent = Color3.fromRGB(70, 130, 255),
    text = Color3.fromRGB(255, 255, 255),
    textSecondary = Color3.fromRGB(170, 170, 170),
    success = Color3.fromRGB(34, 197, 94),
    error = Color3.fromRGB(239, 68, 68),
    border = Color3.fromRGB(60, 60, 65)
}

-- Mobile detection
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- Global variables
local flyBodyVelocity = nil
local autoCollectConnection = nil
local autoBuyConnection = nil
local currentSeedIndex = 1

-- Create mobile-optimized GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MobileGardenGui"
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

-- Mobile toggle button (always visible)
local mobileToggle = Instance.new("TextButton")
mobileToggle.Name = "MobileToggle"
mobileToggle.Size = UDim2.new(0, 60, 0, 60)
mobileToggle.Position = UDim2.new(1, -80, 0, 20)
mobileToggle.BackgroundColor3 = theme.accent
mobileToggle.BorderSizePixel = 0
mobileToggle.Text = "Menu"
mobileToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
mobileToggle.TextSize = 14
mobileToggle.Font = Enum.Font.GothamBold
mobileToggle.Parent = screenGui

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 30)
toggleCorner.Parent = mobileToggle

-- Main container (smaller for mobile)
local mainContainer = Instance.new("Frame")
mainContainer.Name = "MainContainer"
mainContainer.Size = isMobile and UDim2.new(0.9, 0, 0.8, 0) or UDim2.new(0, 400, 0, 600)
mainContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
mainContainer.AnchorPoint = Vector2.new(0.5, 0.5)
mainContainer.BackgroundColor3 = theme.primary
mainContainer.BorderSizePixel = 0
mainContainer.Visible = false
mainContainer.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = mainContainer

-- Title bar
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 50)
titleBar.BackgroundColor3 = theme.secondary
titleBar.BorderSizePixel = 0
titleBar.Parent = mainContainer

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = titleBar

local titleFix = Instance.new("Frame")
titleFix.Size = UDim2.new(1, 0, 0, 12)
titleFix.Position = UDim2.new(0, 0, 1, -12)
titleFix.BackgroundColor3 = theme.secondary
titleFix.BorderSizePixel = 0
titleFix.Parent = titleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -60, 1, 0)
titleLabel.Position = UDim2.new(0, 15, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Garden Script"
titleLabel.TextColor3 = theme.text
titleLabel.TextSize = 16
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.TextYAlignment = Enum.TextYAlignment.Center
titleLabel.Parent = titleBar

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 35, 0, 35)
closeButton.Position = UDim2.new(1, -45, 0, 7.5)
closeButton.BackgroundColor3 = theme.error
closeButton.BorderSizePixel = 0
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextSize = 14
closeButton.Font = Enum.Font.GothamBold
closeButton.Parent = titleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = closeButton

-- Scrolling content frame
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, 0, 1, -50)
scrollFrame.Position = UDim2.new(0, 0, 0, 50)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 6
scrollFrame.ScrollBarImageColor3 = theme.accent
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
scrollFrame.Parent = mainContainer

-- Helper functions
local function createCard(parent, title, yPos)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, -20, 0, 120)
    card.Position = UDim2.new(0, 10, 0, yPos)
    card.BackgroundColor3 = theme.secondary
    card.BorderSizePixel = 0
    card.Parent = parent
    
    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 8)
    cardCorner.Parent = card
    
    local cardTitle = Instance.new("TextLabel")
    cardTitle.Size = UDim2.new(1, -20, 0, 30)
    cardTitle.Position = UDim2.new(0, 10, 0, 10)
    cardTitle.BackgroundTransparency = 1
    cardTitle.Text = title
    cardTitle.TextColor3 = theme.text
    cardTitle.TextSize = 14
    cardTitle.Font = Enum.Font.GothamBold
    cardTitle.TextXAlignment = Enum.TextXAlignment.Left
    cardTitle.Parent = card
    
    return card
end

local function createButton(parent, text, position, size, color)
    local button = Instance.new("TextButton")
    button.Size = size or UDim2.new(0, 100, 0, 35)
    button.Position = position
    button.BackgroundColor3 = color or theme.accent
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 12
    button.Font = Enum.Font.GothamSemibold
    button.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = button
    
    return button
end

local function createToggle(parent, text, position, isOn)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -20, 0, 40)
    container.Position = position
    container.BackgroundTransparency = 1
    container.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -70, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = theme.text
    label.TextSize = 12
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.Parent = container
    
    local toggleBg = Instance.new("Frame")
    toggleBg.Size = UDim2.new(0, 50, 0, 25)
    toggleBg.Position = UDim2.new(1, -50, 0.5, -12.5)
    toggleBg.BackgroundColor3 = isOn and theme.success or theme.border
    toggleBg.BorderSizePixel = 0
    toggleBg.Parent = container
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 12.5)
    toggleCorner.Parent = toggleBg
    
    local toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(0, 21, 0, 21)
    toggleButton.Position = isOn and UDim2.new(0, 27, 0, 2) or UDim2.new(0, 2, 0, 2)
    toggleButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    toggleButton.BorderSizePixel = 0
    toggleButton.Text = ""
    toggleButton.Parent = toggleBg
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 10.5)
    buttonCorner.Parent = toggleButton
    
    return container, toggleBg, toggleButton
end

-- Create UI sections
local yPos = 10

-- Movement Speed Card
local speedCard = createCard(scrollFrame, "Movement Speed", yPos)
local speedSlider = Instance.new("Frame")
speedSlider.Size = UDim2.new(1, -20, 0, 30)
speedSlider.Position = UDim2.new(0, 10, 0, 50)
speedSlider.BackgroundColor3 = theme.border
speedSlider.BorderSizePixel = 0
speedSlider.Parent = speedCard

local sliderCorner = Instance.new("UICorner")
sliderCorner.CornerRadius = UDim.new(0, 4)
sliderCorner.Parent = speedSlider

local speedValue = Instance.new("TextLabel")
speedValue.Size = UDim2.new(1, -20, 0, 20)
speedValue.Position = UDim2.new(0, 10, 0, 85)
speedValue.BackgroundTransparency = 1
speedValue.Text = "Speed: " .. settings.movementSpeed
speedValue.TextColor3 = theme.textSecondary
speedValue.TextSize = 10
speedValue.Font = Enum.Font.Gotham
speedValue.TextXAlignment = Enum.TextXAlignment.Left
speedValue.Parent = speedCard

yPos = yPos + 140

-- Flight Card
local flightCard = createCard(scrollFrame, "Flight System", yPos)
local flyContainer, flyBg, flyButton = createToggle(flightCard, "Enable Flight", UDim2.new(0, 10, 0, 50), settings.flyEnabled)

yPos = yPos + 140

-- Auto Collect Card
local collectCard = createCard(scrollFrame, "Auto Collection", yPos)
local collectContainer, collectBg, collectButton = createToggle(collectCard, "Auto Collect Plants", UDim2.new(0, 10, 0, 50), settings.autoCollectPlant)

yPos = yPos + 140

-- Auto Sell Card
local autoSellCard = createCard(scrollFrame, "Auto Selling", yPos)
local autoSellContainer, autoSellBg, autoSellButton = createToggle(autoSellCard, "Auto Sell Inventory", UDim2.new(0, 10, 0, 50), settings.autoSellInventory)

yPos = yPos + 140

-- Quick Actions Card
local actionsCard = createCard(scrollFrame, "Quick Actions", yPos)
local sellBtn = createButton(actionsCard, "Sell Inventory", UDim2.new(0, 10, 0, 50), UDim2.new(0, 120, 0, 35), theme.success)
local buyBtn = createButton(actionsCard, "Buy Seeds", UDim2.new(1, -130, 0, 50), UDim2.new(0, 120, 0, 35), theme.accent)

yPos = yPos + 140

-- Auto Buy Card
local autoBuyCard = createCard(scrollFrame, "Auto Buy Seeds", yPos)
local autoBuyContainer, autoBuyBg, autoBuyToggle = createToggle(autoBuyCard, "Auto Buy: " .. settings.selectedSeeds[1], UDim2.new(0, 10, 0, 50), settings.autoBuySeeds)

-- Core Functions
local function updateMovementSpeed()
    local character = player.Character
    if character and character:FindFirstChild("Humanoid") then
        character.Humanoid.WalkSpeed = settings.movementSpeed
    end
end

local function animateToggle(bg, button, isOn)
    local targetBgColor = isOn and theme.success or theme.border
    local targetPos = isOn and UDim2.new(0, 27, 0, 2) or UDim2.new(0, 2, 0, 2)
    
    TweenService:Create(bg, TweenInfo.new(0.2), {BackgroundColor3 = targetBgColor}):Play()
    TweenService:Create(button, TweenInfo.new(0.2), {Position = targetPos}):Play()
end

local function buySeed(seedName)
    local success = pcall(function()
        buySeedEvent:FireServer(seedName)
        wait(0.1)
        buySeedEvent:FireServer(seedName, 1)
        wait(0.1)
        buySeedEvent:FireServer("sheckles", seedName, 1)
    end)
    return success
end

local function sellInventoryWithTeleport()
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local humanoidRootPart = character.HumanoidRootPart
    local originalPosition = humanoidRootPart.CFrame
    
    sellBtn.Text = "Selling..."
    humanoidRootPart.CFrame = CFrame.new(SELL_POSITION)
    wait(0.5)
    sellInventoryEvent:FireServer()
    wait(1)
    humanoidRootPart.CFrame = originalPosition
    sellBtn.Text = "Sell Inventory"
end

local function getAllPlants()
    local mainFarm = workspace:FindFirstChild("Farm")
    if not mainFarm then return {} end
    
    local plants = {}
    for _, farmFolder in pairs(mainFarm:GetChildren()) do
        if farmFolder.Name == "Farm" then
            local importantFolder = farmFolder:FindFirstChild("Important")
            if importantFolder then
                local plantsFolder = importantFolder:FindFirstChild("Plants_Physical")
                if plantsFolder then
                    for _, plant in pairs(plantsFolder:GetChildren()) do
                        local fruitSpawn = plant:FindFirstChild("Fruit_Spawn")
                        if fruitSpawn then
                            local spawnPoint = fruitSpawn:FindFirstChild("Spawn_Point")
                            if spawnPoint then
                                table.insert(plants, {name = plant.Name, spawnPoint = spawnPoint})
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
    if not character or not character:FindFirstChild("HumanoidRootPart") then return false end
    
    local humanoidRootPart = character.HumanoidRootPart
    local spawnPoint = plant.spawnPoint
    
    if spawnPoint and spawnPoint.CFrame then
        humanoidRootPart.CFrame = spawnPoint.CFrame + Vector3.new(0, 5, 0)
        wait(0.1)
        
        local virtualInputManager = game:GetService("VirtualInputManager")
        for i = 1, 10 do
            virtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
            wait(0.05)
            virtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
            wait(0.05)
        end
        return true
    end
    return false
end

local function autoCollectLoop()
    local plantIndex = 1
    while settings.autoCollectPlant do
        local plants = getAllPlants()
        if #plants > 0 then
            if plantIndex > #plants then plantIndex = 1 end
            collectFromPlant(plants[plantIndex])
            plantIndex = plantIndex + 1
        end
        wait(1)
    end
end

local function autoBuyLoop()
    while settings.autoBuySeeds do
        if #settings.selectedSeeds > 0 then
            local seedName = settings.selectedSeeds[currentSeedIndex]
            buySeed(seedName)
            
            currentSeedIndex = currentSeedIndex + 1
            if currentSeedIndex > #settings.selectedSeeds then
                currentSeedIndex = 1
            end
        end
        wait(settings.buyInterval)
    end
end

-- Event Handlers
mobileToggle.MouseButton1Click:Connect(function()
    mainContainer.Visible = not mainContainer.Visible
    if mainContainer.Visible then
        mainContainer:TweenSize(
            isMobile and UDim2.new(0.9, 0, 0.8, 0) or UDim2.new(0, 400, 0, 600),
            "Out", "Back", 0.3, true
        )
    end
end)

closeButton.MouseButton1Click:Connect(function()
    mainContainer.Visible = false
end)

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
    else
        if flyBodyVelocity then flyBodyVelocity:Destroy() end
    end
end)

collectButton.MouseButton1Click:Connect(function()
    settings.autoCollectPlant = not settings.autoCollectPlant
    animateToggle(collectBg, collectButton, settings.autoCollectPlant)
    
    if settings.autoCollectPlant then
        if autoCollectConnection then task.cancel(autoCollectConnection) end
        autoCollectConnection = task.spawn(autoCollectLoop)
    else
        if autoCollectConnection then
            task.cancel(autoCollectConnection)
            autoCollectConnection = nil
        end
    end
end)

autoSellButton.MouseButton1Click:Connect(function()
    settings.autoSellInventory = not settings.autoSellInventory
    animateToggle(autoSellBg, autoSellButton, settings.autoSellInventory)
end)

autoBuyToggle.MouseButton1Click:Connect(function()
    settings.autoBuySeeds = not settings.autoBuySeeds
    animateToggle(autoBuyBg, autoBuyToggle, settings.autoBuySeeds)
    
    if settings.autoBuySeeds then
        if autoBuyConnection then task.cancel(autoBuyConnection) end
        autoBuyConnection = task.spawn(autoBuyLoop)
    else
        if autoBuyConnection then
            task.cancel(autoBuyConnection)
            autoBuyConnection = nil
        end
    end
end)

sellBtn.MouseButton1Click:Connect(function()
    sellInventoryWithTeleport()
end)

buyBtn.MouseButton1Click:Connect(function()
    buySeed(settings.selectedSeeds[1])
end)

-- Speed slider for mobile
if isMobile then
    speedSlider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            local function updateSpeed(input)
                local sliderPos = speedSlider.AbsolutePosition.X
                local sliderSize = speedSlider.AbsoluteSize.X
                local touchPos = input.Position.X
                local percentage = math.clamp((touchPos - sliderPos) / sliderSize, 0, 1)
                
                settings.movementSpeed = math.floor(16 + (percentage * 84))
                speedValue.Text = "Speed: " .. settings.movementSpeed
                updateMovementSpeed()
            end
            
            updateSpeed(input)
            
            local connection
            connection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    connection:Disconnect()
                else
                    updateSpeed(input)
                end
            end)
        end
    end)
end

-- Fly controls for mobile
if isMobile and settings.flyEnabled then
    local flyControls = Instance.new("Frame")
    flyControls.Size = UDim2.new(0, 120, 0, 120)
    flyControls.Position = UDim2.new(0, 20, 1, -140)
    flyControls.BackgroundColor3 = theme.secondary
    flyControls.BorderSizePixel = 0
    flyControls.Visible = false
    flyControls.Parent = screenGui
    
    local flyCorner = Instance.new("UICorner")
    flyCorner.CornerRadius = UDim.new(0, 8)
    flyCorner.Parent = flyControls
end

-- Initialize
updateMovementSpeed()

-- Character respawn handling
player.CharacterAdded:Connect(function(character)
    character:WaitForChild("Humanoid")
    updateMovementSpeed()
end)

print("Garden Script loaded - Tap 'Menu' button to open")
