-- Komplettes Auto Farm & Sell Script für Roblox
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Konfiguration
local NPC_COORDINATES = Vector3.new(86.7493362426758, 3, -1.40232193470001)
local SELL_CLICK_COORDINATES = {x = 962, y = 242} -- Standard-Koordinaten
local isSettingSellPosition = false -- Flag für Position setzen

-- Script Status
local isFarmingFruits = false
local isSelling = false
local gui

-- === FRUIT FARMING FUNKTIONEN ===

-- Holt alle Spawn_Points unter Fruit_Spawn
local function getAllFruitSpawnPoints()
    local spawnPoints = {}
    for _, plant in pairs(workspace.Farm.Farm.Important.Plants_Physical:GetChildren()) do
        local fruitSpawn = plant:FindFirstChild("Fruit_Spawn")
        if fruitSpawn then
            for _, spawn in pairs(fruitSpawn:GetChildren()) do
                if spawn:IsA("BasePart") then
                    table.insert(spawnPoints, spawn)
                end
            end
        end
    end
    return spawnPoints
end

-- Teleportiert zu einem Punkt
local function teleportTo(position)
    if humanoidRootPart then
        humanoidRootPart.CFrame = CFrame.new(position)
    end
end

-- Sammelt Items mit verschiedenen Methoden
local function collectItem(part)
    -- Methode 1: ProximityPrompt suchen und feuern
    for _, descendant in pairs(part:GetDescendants()) do
        if descendant:IsA("ProximityPrompt") then
            if fireproximityprompt then
                fireproximityprompt(descendant)
                return true
            else
                descendant:InputHoldBegin()
                task.wait(0.1)
                descendant:InputHoldEnd()
                return true
            end
        end
    end
    
    -- Methode 2: E-Taste drücken
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
        task.wait(0.1)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
    end)
    
    return false
end

-- Hauptfunktion für Fruit Farming
local function autoFarmFruits()
    while isFarmingFruits do
        local spawnPoints = getAllFruitSpawnPoints()
        
        if #spawnPoints == 0 then
            print("Keine Spawn_Points gefunden!")
            task.wait(5)
            continue
        end
        
        for i, spawnPoint in ipairs(spawnPoints) do
            if not isFarmingFruits then break end
            
            -- Teleportiere zum Spawn_Point
            teleportTo(spawnPoint.Position + Vector3.new(0, 3, 0))
            task.wait(0.5)
            
            -- Versuche zu sammeln
            collectItem(spawnPoint)
            task.wait(0.5)
        end
        
        task.wait(2) -- Pause zwischen Runden
    end
end

-- === AUTO SELL FUNKTIONEN ===

-- Klickt an bestimmten Koordinaten mit Multi-Monitor Support
local function clickAtCoordinates(x, y, description)
    description = description or "Position"
    print("🖱️ Versuche zu klicken:", description, "bei Koordinaten (" .. x .. ", " .. y .. ")")
    print("🖥️ Multi-Monitor Setup erkannt - teste verschiedene Koordinaten-Systeme")
    
    -- Hole aktuelle Mausposition für Referenz
    local mouse = player:GetMouse()
    print("📍 Aktuelle Mausposition: X=" .. mouse.X .. " Y=" .. mouse.Y)
    
    -- Methode 1: Originale Koordinaten
    pcall(function()
        if mousemoveabs and mouse1click then
            mousemoveabs(x, y)
            task.wait(0.1)
            mouse1click()
            print("✓ mousemoveabs (original coords) ausgeführt")
        end
    end)
    task.wait(0.2)
    
    -- Methode 2: VirtualUser mit originalen Koordinaten
    pcall(function()
        local VirtualUser = game:GetService("VirtualUser")
        VirtualUser:ClickButton1(Vector2.new(x, y))
        print("✓ VirtualUser (original coords) ausgeführt")
    end)
    task.wait(0.2)
    
    -- Methode 3: Relative Koordinaten (falls Roblox-Fenster nicht bei 0,0 startet)
    pcall(function()
        local camera = workspace.CurrentCamera
        local screenSize = camera.ViewportSize
        local relativeX = x
        local relativeY = y
        
        -- Falls die Koordinaten außerhalb des sichtbaren Bereichs liegen, anpassen
        if x > screenSize.X then
            relativeX = x - screenSize.X
        end
        if y > screenSize.Y then
            relativeY = y - screenSize.Y
        end
        
        if mousemoveabs and mouse1click and (relativeX ~= x or relativeY ~= y) then
            mousemoveabs(relativeX, relativeY)
            task.wait(0.1)
            mouse1click()
            print("✓ mousemoveabs (relative coords) X=" .. relativeX .. " Y=" .. relativeY)
        end
    end)
    task.wait(0.2)
    
    -- Methode 4: Mouse.Hit basierter Ansatz (nutzt Roblox's eigenes Koordinatensystem)
    pcall(function()
        local screenGui = player.PlayerGui:FindFirstChild("AutoFarmSellGUI")
        if screenGui then
            local testFrame = Instance.new("Frame")
            testFrame.Size = UDim2.new(0, 1, 0, 1)
            testFrame.Position = UDim2.new(0, x, 0, y)
            testFrame.BackgroundTransparency = 1
            testFrame.Parent = screenGui
            
            -- Simuliere Klick auf diesem Frame
            if firesignal then
                firesignal(testFrame.InputBegan, {
                    UserInputType = Enum.UserInputType.MouseButton1
                })
                task.wait(0.05)
                firesignal(testFrame.InputEnded, {
                    UserInputType = Enum.UserInputType.MouseButton1
                })
            end
            
            testFrame:Destroy()
            print("✓ GUI Frame click simulation ausgeführt")
        end
    end)
    task.wait(0.2)
    
    -- Methode 5: Suche GUI Element an Position (am zuverlässigsten für Multi-Monitor)
    pcall(function()
        local playerGui = player:WaitForChild("PlayerGui")
        local foundElement = false
        
        for _, screenGui in pairs(playerGui:GetChildren()) do
            if screenGui:IsA("ScreenGui") then
                for _, element in pairs(screenGui:GetDescendants()) do
                    if element:IsA("GuiButton") or element:IsA("TextButton") or element:IsA("ImageButton") then
                        local pos = element.AbsolutePosition
                        local size = element.AbsoluteSize
                        
                        -- Erweiterte Suche - auch nahe Koordinaten prüfen
                        local tolerance = 20 -- Pixel-Toleranz
                        if math.abs(x - (pos.X + size.X/2)) <= tolerance and 
                           math.abs(y - (pos.Y + size.Y/2)) <= tolerance then
                            
                            print("🎯 GUI Element gefunden! Text:", element.Text or "Kein Text")
                            print("📍 Element Position: X=" .. pos.X .. " Y=" .. pos.Y .. " Größe: " .. size.X .. "x" .. size.Y)
                            
                            -- Versuche Element zu aktivieren
                            if element.Activated then
                                element.Activated:Fire()
                                print("✓ element.Activated gefeuert")
                                foundElement = true
                            end
                            
                            if firesignal and element.MouseButton1Click then
                                firesignal(element.MouseButton1Click)
                                print("✓ MouseButton1Click signal gefeuert")
                                foundElement = true
                            end
                            
                            return
                        end
                    end
                end
            end
        end
        
        if not foundElement then
            print("❌ Kein GUI Element in der Nähe der Koordinaten gefunden")
            print("💡 Tipp: Überprüfe ob das Verkaufsmenü geöffnet ist")
        end
    end)
    
    task.wait(0.3)
    
    -- Methode 6: VirtualInputManager mit verschiedenen Offsets
    local offsets = {{0,0}, {-1920,0}, {1920,0}, {0,-1080}, {0,1080}} -- Typische Monitor-Offsets
    for _, offset in pairs(offsets) do
        pcall(function()
            local newX = x + offset[1]
            local newY = y + offset[2]
            if newX >= 0 and newY >= 0 then
                VirtualInputManager:SendMouseButtonEvent(newX, newY, 0, true, game, 0)
                task.wait(0.05)
                VirtualInputManager:SendMouseButtonEvent(newX, newY, 0, false, game, 0)
                if offset[1] ~= 0 or offset[2] ~= 0 then
                    print("✓ VirtualInputManager mit Offset (" .. offset[1] .. "," .. offset[2] .. ") ausgeführt")
                end
            end
        end)
        task.wait(0.1)
    end
    
    print("🔚 Alle Multi-Monitor Klick-Methoden versucht")
end

-- Interagiert mit NPC (E drücken)
local function interactWithNPC()
    print("🗣️ Drücke E um mit NPC zu interagieren...")
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
        task.wait(0.1)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
        print("✓ E-Taste gedrückt")
    end)
    task.wait(1)
end
local function autoSell()
    print("=== 💰 Starte Verkaufsvorgang ===")
    
    -- Schritt 1: Zum NPC teleportieren
    print("📍 Teleportiere zum NPC...")
    teleportTo(NPC_COORDINATES)
    task.wait(1.5) -- Längere Wartezeit
    
    -- Schritt 2: Mit NPC interagieren
    print("🗣️ Interagiere mit NPC (E drücken)...")
    interactWithNPC()
    task.wait(2) -- Warten dass das Menü erscheint
    
    -- Schritt 3: Mehrere Klick-Versuche
    print("🖱️ Klicke auf Verkaufsoption...")
    
    -- Erster Versuch
    clickAtCoordinates(SELL_CLICK_COORDINATES.x, SELL_CLICK_COORDINATES.y, "Verkaufsoption")
    
    -- Zweiter Versuch mit leicht anderen Koordinaten (falls UI sich verschoben hat)
    clickAtCoordinates(SELL_CLICK_COORDINATES.x - 10, SELL_CLICK_COORDINATES.y, "Verkaufsoption (Links)")
    clickAtCoordinates(SELL_CLICK_COORDINATES.x + 10, SELL_CLICK_COORDINATES.y, "Verkaufsoption (Rechts)")
    
    -- Schritt 4: Bestätigung versuchen
    print("✅ Versuche Bestätigung...")
    task.wait(1)
    
    -- E-Taste zur Bestätigung
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
        task.wait(0.1)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
        print("✓ E-Taste zur Bestätigung gedrückt")
    end)
    
    -- Alternative: Nochmal an gleicher Stelle klicken für Bestätigung
    task.wait(0.5)
    clickAtCoordinates(SELL_CLICK_COORDINATES.x, SELL_CLICK_COORDINATES.y, "Bestätigung")
    
    print("=== ✅ Verkaufsvorgang abgeschlossen ===")
end

-- Funktion um Sell-Position zu setzen
local function startSettingSellPosition()
    isSettingSellPosition = true
    print("🎯 POSITION SETZEN MODUS AKTIVIERT!")
    print("📝 Anweisungen:")
    print("1. Öffne das NPC-Verkaufsmenü (geh zum NPC, drücke E)")
    print("2. Klicke GENAU auf 'I want to sell my inventory'")
    print("3. Die Position wird automatisch gespeichert!")
    print("❌ Drücke ESC um abzubrechen")
    
    -- GUI Button Text ändern
    if gui then
        local setSellButton = gui:FindFirstChild("MainFrame"):FindFirstChild("SetSellButton")
        if setSellButton then
            setSellButton.Text = "KLICKE JETZT AUF TEXT!"
            setSellButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0) -- Rot während aktiv
        end
    end
end

local function stopSettingSellPosition()
    isSettingSellPosition = false
    print("❌ Position setzen abgebrochen")
    
    -- GUI Button zurücksetzen
    if gui then
        local setSellButton = gui:FindFirstChild("MainFrame"):FindFirstChild("SetSellButton")
        if setSellButton then
            setSellButton.Text = "SET SELL POSITION"
            setSellButton.BackgroundColor3 = Color3.fromRGB(100, 150, 200)
        end
    end
end

-- === STEUERUNGSFUNKTIONEN ===

local function startFruitFarming()
    if isFarmingFruits then return end
    
    isFarmingFruits = true
    print("🍎 Fruit Farming gestartet!")
    
    -- GUI Status updaten
    if gui then
        local farmButton = gui:FindFirstChild("MainFrame"):FindFirstChild("FarmToggleButton")
        if farmButton then
            farmButton.Text = "STOP FARMING"
            farmButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
        end
    end
    
    task.spawn(autoFarmFruits)
end

local function stopFruitFarming()
    isFarmingFruits = false
    print("🛑 Fruit Farming gestoppt!")
    
    -- GUI Status updaten
    if gui then
        local farmButton = gui:FindFirstChild("MainFrame"):FindFirstChild("FarmToggleButton")
        if farmButton then
            farmButton.Text = "START FARMING"
            farmButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        end
    end
end

local function toggleFruitFarming()
    if isFarmingFruits then
        stopFruitFarming()
    else
        startFruitFarming()
    end
end

local function executeSell()
    if isSelling then return end
    
    isSelling = true
    print("💰 Einmaliger Verkauf gestartet!")
    
    task.spawn(function()
        autoSell()
        isSelling = false
    end)
end

-- === GUI ERSTELLUNG ===

local function createGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AutoFarmSellGUI"
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    -- Hauptframe
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 280, 0, 220)
    mainFrame.Position = UDim2.new(0, 50, 0, 50)
    mainFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = mainFrame
    
    -- Titel
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "TitleLabel"
    titleLabel.Size = UDim2.new(1, 0, 0, 35)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "Auto Farm & Sell"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.Parent = mainFrame
    
    -- Farm Status
    local farmStatusLabel = Instance.new("TextLabel")
    farmStatusLabel.Name = "FarmStatusLabel"
    farmStatusLabel.Size = UDim2.new(1, -20, 0, 20)
    farmStatusLabel.Position = UDim2.new(0, 10, 0, 40)
    farmStatusLabel.BackgroundTransparency = 1
    farmStatusLabel.Text = "Farming: Gestoppt"
    farmStatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    farmStatusLabel.TextScaled = true
    farmStatusLabel.Font = Enum.Font.SourceSans
    farmStatusLabel.Parent = mainFrame
    
    -- Koordinaten Info
    local coordLabel = Instance.new("TextLabel")
    coordLabel.Name = "CoordLabel"
    coordLabel.Size = UDim2.new(1, -20, 0, 15)
    coordLabel.Position = UDim2.new(0, 10, 0, 65)
    coordLabel.BackgroundTransparency = 1
    coordLabel.Text = "Sell Click: (" .. SELL_CLICK_COORDINATES.x .. ", " .. SELL_CLICK_COORDINATES.y .. ")"
    coordLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    coordLabel.TextScaled = true
    coordLabel.Font = Enum.Font.SourceSans
    coordLabel.Parent = mainFrame
    
    -- Farm Toggle Button
    local farmToggleButton = Instance.new("TextButton")
    farmToggleButton.Name = "FarmToggleButton"
    farmToggleButton.Size = UDim2.new(1, -40, 0, 40)
    farmToggleButton.Position = UDim2.new(0, 20, 0, 90)
    farmToggleButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    farmToggleButton.Text = "START FARMING"
    farmToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    farmToggleButton.TextScaled = true
    farmToggleButton.Font = Enum.Font.SourceSansBold
    farmToggleButton.Parent = mainFrame
    
    local farmCorner = Instance.new("UICorner")
    farmCorner.CornerRadius = UDim.new(0, 8)
    farmCorner.Parent = farmToggleButton
    
    -- Auto Sell Button
    local autoSellButton = Instance.new("TextButton")
    autoSellButton.Name = "AutoSellButton"
    autoSellButton.Size = UDim2.new(1, -40, 0, 40)
    autoSellButton.Position = UDim2.new(0, 20, 0, 140)
    autoSellButton.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
    autoSellButton.Text = "AUTO SELL"
    autoSellButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    autoSellButton.TextScaled = true
    autoSellButton.Font = Enum.Font.SourceSansBold
    autoSellButton.Parent = mainFrame
    
    local sellCorner = Instance.new("UICorner")
    sellCorner.CornerRadius = UDim.new(0, 8)
    sellCorner.Parent = autoSellButton
    
    -- Draggable functionality
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    mainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end)
    
    mainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    mainFrame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    -- Set Sell Position Button Event
    setSellButton.MouseButton1Click:Connect(function()
        if isSettingSellPosition then
            stopSettingSellPosition()
        else
            startSettingSellPosition()
        end
    end)
    
    farmToggleButton.MouseButton1Click:Connect(function()
        toggleFruitFarming()
        -- Update Status Label
        if isFarmingFruits then
            farmStatusLabel.Text = "Farming: Läuft"
            farmStatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        else
            farmStatusLabel.Text = "Farming: Gestoppt"
            farmStatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
    end)
    
    autoSellButton.MouseButton1Click:Connect(function()
        executeSell()
    end)
    
    -- Hover Effects
    farmToggleButton.MouseEnter:Connect(function()
        if isFarmingFruits then
            farmToggleButton.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
        else
            farmToggleButton.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
        end
    end)
    
    farmToggleButton.MouseLeave:Connect(function()
        if isFarmingFruits then
            farmToggleButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
        else
            farmToggleButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        end
    end)
    
    autoSellButton.MouseEnter:Connect(function()
        autoSellButton.BackgroundColor3 = Color3.fromRGB(255, 160, 0)
    end)
    
    -- Test Koordinaten Button (für Debugging)
    local testClickButton = Instance.new("TextButton")
    testClickButton.Name = "TestClickButton"
    testClickButton.Size = UDim2.new(1, -40, 0, 25)
    testClickButton.Position = UDim2.new(0, 20, 0, 190)
    testClickButton.BackgroundColor3 = Color3.fromRGB(100, 100, 150)
    testClickButton.Text = "TEST KLICK"
    testClickButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    testClickButton.TextScaled = true
    testClickButton.Font = Enum.Font.SourceSans
    testClickButton.Parent = mainFrame
    
    local testClickCorner = Instance.new("UICorner")
    testClickCorner.CornerRadius = UDim.new(0, 5)
    testClickCorner.Parent = testClickButton
    
    autoSellButton.MouseLeave:Connect(function()
        autoSellButton.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
    end)
    
    -- Test Click Button Event
    testClickButton.MouseButton1Click:Connect(function()
        print("🧪 Teste Klick an Koordinaten...")
        clickAtCoordinates(SELL_CLICK_COORDINATES.x, SELL_CLICK_COORDINATES.y, "TEST KLICK")
    end)
    
    -- Executor Check Button Event
    executorInfoButton.MouseButton1Click:Connect(function()
        print("=== 🔍 EXECUTOR FUNKTIONEN CHECK ===")
        
        -- Check VirtualInputManager
        if VirtualInputManager then
            print("✓ VirtualInputManager: Verfügbar")
        else
            print("❌ VirtualInputManager: Nicht verfügbar")
        end
        
        -- Check VirtualUser
        pcall(function()
            local VirtualUser = game:GetService("VirtualUser")
            if VirtualUser and VirtualUser.ClickButton1 then
                print("✓ VirtualUser.ClickButton1: Verfügbar")
            else
                print("❌ VirtualUser.ClickButton1: Nicht verfügbar")
            end
        end)
        
        -- Check mousemoveabs/mouse1click
        if mousemoveabs and mouse1click then
            print("✓ mousemoveabs + mouse1click: Verfügbar")
        else
            print("❌ mousemoveabs + mouse1click: Nicht verfügbar")
        end
        
        -- Check firesignal
        if firesignal then
            print("✓ firesignal: Verfügbar")
        else
            print("❌ firesignal: Nicht verfügbar")
        end
        
        -- Check getconnections
        if getconnections then
            print("✓ getconnections: Verfügbar")
        else
            print("❌ getconnections: Nicht verfügbar")
        end
        
        print("=== 🔚 CHECK BEENDET ===")
        print("💡 Verwende die verfügbaren Funktionen für Klicks")
    end)
    
    -- GUI größer machen für neue Buttons
    mainFrame.Size = UDim2.new(0, 280, 0, 290)
    
    return screenGui
end

-- === TASTENKOMBINATIONEN & MAUS-EVENTS ===

-- UserInputService für Maus-Klicks verwenden statt mouse.Button1Down
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    -- Maus-Klick abfangen wenn Position gesetzt wird
    if input.UserInputType == Enum.UserInputType.MouseButton1 and isSettingSellPosition and not gameProcessed then
        local mouse = player:GetMouse()
        local x = mouse.X
        local y = mouse.Y
        saveSellPosition(x, y)
        return
    end
    
    -- Tastenkombinationen
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.F then
        toggleFruitFarming()
    elseif input.KeyCode == Enum.KeyCode.G then
        executeSell()
    elseif input.KeyCode == Enum.KeyCode.Escape and isSettingSellPosition then
        stopSettingSellPosition()
    end
end)

-- === CHARACTER RESPAWN HANDLING ===

player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    
    -- GUI neu erstellen
    if gui then
        gui:Destroy()
    end
    gui = createGUI()
    
    -- Farming wieder starten falls es aktiv war
    if isFarmingFruits then
        isFarmingFruits = false
        task.wait(1)
        startFruitFarming()
    end
end)

-- === INITIALISIERUNG ===

gui = createGUI()

print("=== Auto Farm & Sell Script geladen ===")
print("🍎 F-Taste = Fruit Farming an/aus")
print("💰 G-Taste = Einmaliger Verkauf")
print("📍 Sell-Koordinaten:", SELL_CLICK_COORDINATES.x, SELL_CLICK_COORDINATES.y)
print("🎯 NPC-Position:", NPC_COORDINATES)
print("=====================================")

-- Debug Info
task.wait(1)
local testPoints = getAllFruitSpawnPoints()
print("🔍 Gefundene Spawn_Points:", #testPoints)
