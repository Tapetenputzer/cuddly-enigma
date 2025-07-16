local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local Lighting = game:GetService("Lighting")

local Window = Fluent:CreateWindow({
    Title = "Banana Eats Script",
    SubTitle = "by Tapetenputzer",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    ESP = Window:AddTab({ Title = "ESP", Icon = "eye" }),
    Player = Window:AddTab({ Title = "Player", Icon = "user" }),
    Visual = Window:AddTab({ Title = "Visual", Icon = "sun" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local cakeEspActive, cakeEspLoop = false, nil
local cakeEspColor = Color3.fromRGB(255, 255, 0)

local coinEspActive, coinEspLoop = false, nil
local coinEspColor = Color3.fromRGB(0, 255, 0)

local chamsActive, chamsLoop = false, nil
local enemyChamColor = Color3.fromRGB(255, 0, 0)
local teamChamColor = Color3.fromRGB(0, 255, 0)

local nametagActive, nametagLoop = false, nil

local valveEspActive, valveEspLoop = false, nil
local valveEspColor = Color3.fromRGB(0, 255, 255)

local puzzleNumberEspActive, puzzleNumberEspLoop = false, nil
local puzzleNumberEspColor = Color3.fromRGB(255, 255, 255)
local puzzleNumbers = {["23"] = true, ["34"] = true, ["31"] = true}

local puzzleEspActive, puzzleEspLoop = false, nil
local puzzleEspColor = Color3.fromRGB(0, 255, 0)

local speedLoop = nil
local currentSpeed = 16

local flyActive = false
local flySpeed = 50
local flyBodyVelocity, flyBodyGyro, flyConnection = nil, nil, nil

local fullbrightActive = false
local noFogActive, noFogLoop = false, nil

local autoDeletePeelsActive, autoDeletePeelsThread = false, nil
local autoCollectCoinsActive, autoCollectCoinsThread = false, nil
local autoDeleteLockersActive, autoDeleteLockersThread = false, nil
local antiKickConnection = nil

local antiAfkConnection = nil
local function enableAntiAfk()
    if antiAfkConnection then return end
    antiAfkConnection = Players.LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0, 0))
    end)
end

local function disableAntiAfk()
    if antiAfkConnection then
        antiAfkConnection:Disconnect()
        antiAfkConnection = nil
    end
end

local ccActive = false
local ccEffect = nil
local ccBrightness = 0
local ccContrast = 0
local ccSaturation = 1

local function enableColorCorrection()
    if not Lighting:FindFirstChild("ColorCorrectionEffect") then
        ccEffect = Instance.new("ColorCorrectionEffect")
        ccEffect.Parent = Lighting
    else
        ccEffect = Lighting:FindFirstChild("ColorCorrectionEffect")
    end
    ccEffect.Brightness = ccBrightness
    ccEffect.Contrast = ccContrast
    ccEffect.Saturation = ccSaturation
end

local function disableColorCorrection()
    if ccEffect then
        ccEffect:Destroy()
        ccEffect = nil
    end
end

local sunRaysActive = false
local sunRaysEffect = nil
local sunRaysIntensity = 0.3

local function enableSunRays()
    if not Lighting:FindFirstChild("SunRaysEffect") then
        sunRaysEffect = Instance.new("SunRaysEffect")
        sunRaysEffect.Parent = Lighting
    else
        sunRaysEffect = Lighting:FindFirstChild("SunRaysEffect")
    end
    sunRaysEffect.Intensity = sunRaysIntensity
end

local function disableSunRays()
    if sunRaysEffect then
        sunRaysEffect:Destroy()
        sunRaysEffect = nil
    end
end

local function createBillboard(text, isNametag)
    local billboard = Instance.new("BillboardGui")
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0, 150, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = text
    textLabel.TextScaled = true
    textLabel.Font = Enum.Font.GothamBold
    textLabel.TextColor3 = Color3.new(1, 1, 1)
    textLabel.TextStrokeTransparency = 0
    textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    textLabel.Parent = billboard

    return billboard
end

local function removeCakeEsp()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            if obj:FindFirstChild("CakeESP") then obj.CakeESP:Destroy() end
            if obj:FindFirstChild("CakeLabel") then obj.CakeLabel:Destroy() end
        end
    end
end

local function removeCoinEsp()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            if obj:FindFirstChild("CoinESP") then obj.CoinESP:Destroy() end
            if obj:FindFirstChild("CoinLabel") then obj.CoinLabel:Destroy() end
        end
    end
end

local function removeChams()
    for _, plyr in pairs(Players:GetPlayers()) do
        if plyr.Character then
            for _, part in pairs(plyr.Character:GetDescendants()) do
                if part:IsA("BasePart") and part:FindFirstChild("Cham") then
                    part.Cham:Destroy()
                end
            end
        end
    end
end

local function removeNametags()
    for _, plyr in pairs(Players:GetPlayers()) do
        if plyr.Character and plyr.Character:FindFirstChild("Head") then
            local tag = plyr.Character.Head:FindFirstChild("Nametag")
            if tag then tag:Destroy() end
        end
    end
end

local function removeValveEsp()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            if obj:FindFirstChild("ValveESP") then obj.ValveESP:Destroy() end
            if obj:FindFirstChild("ValveLabel") then obj.ValveLabel:Destroy() end
        end
    end
end

local function removePuzzleNumberEsp()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Parent and obj.Parent.Name == "Buttons" and puzzleNumbers[obj.Name] then
            if obj:FindFirstChild("PuzzleNumberESP") then obj.PuzzleNumberESP:Destroy() end
            if obj:FindFirstChild("PuzzleNumberLabel") then obj.PuzzleNumberLabel:Destroy() end
        end
    end
end

local function removePuzzleEsp()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            if obj:FindFirstChild("PuzzleLabel") then obj.PuzzleLabel:Destroy() end
        end
    end
end

local function cakeEspLoopFunction()
    while cakeEspActive do
        pcall(function()
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") and ((obj.Parent and obj.Parent.Name == "Cake" and tonumber(obj.Name)) or (obj.Parent and obj.Parent.Name == "CakePlate" and obj.Name == "Plate")) then
                    if not obj:FindFirstChild("CakeESP") then
                        local esp = Instance.new("BoxHandleAdornment")
                        esp.Name = "CakeESP"
                        esp.Adornee = obj
                        esp.AlwaysOnTop = true
                        esp.ZIndex = 10
                        esp.Size = obj.Size + Vector3.new(0.2, 0.2, 0.2)
                        esp.Transparency = 0.5
                        esp.Color3 = cakeEspColor
                        esp.Parent = obj
                    end
                    if not obj:FindFirstChild("CakeLabel") then
                        local billboard = createBillboard("Cake Plate")
                        billboard.Name = "CakeLabel"
                        billboard.Parent = obj
                    end
                end
            end
        end)
        task.wait(3)
    end
end

local function coinEspLoopFunction()
    while coinEspActive do
        pcall(function()
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") and obj.Parent and obj.Parent.Name == "Tokens" and obj.Name == "Token" then
                    if not obj:FindFirstChild("CoinESP") then
                        local esp = Instance.new("BoxHandleAdornment")
                        esp.Name = "CoinESP"
                        esp.Adornee = obj
                        esp.AlwaysOnTop = true
                        esp.ZIndex = 10
                        esp.Size = obj.Size + Vector3.new(0.2, 0.2, 0.2)
                        esp.Transparency = 0.5
                        esp.Color3 = coinEspColor
                        esp.Parent = obj
                    end
                    if not obj:FindFirstChild("CoinLabel") then
                        local billboard = createBillboard("Coin")
                        billboard.Name = "CoinLabel"
                        billboard.Parent = obj
                    end
                end
            end
        end)
        task.wait(3)
    end
end

local function chamsLoopFunction()
    while chamsActive do
        pcall(function()
            for _, plyr in pairs(Players:GetPlayers()) do
                if plyr ~= Players.LocalPlayer and plyr.Character then
                    local sameTeam = (plyr.TeamColor == Players.LocalPlayer.TeamColor)
                    local color = sameTeam and teamChamColor or enemyChamColor
                    for _, part in pairs(plyr.Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            local cham = part:FindFirstChild("Cham")
                            if not cham then
                                cham = Instance.new("BoxHandleAdornment")
                                cham.Name = "Cham"
                                cham.Adornee = part
                                cham.AlwaysOnTop = true
                                cham.ZIndex = 10
                                cham.Size = part.Size + Vector3.new(0.1, 0.1, 0.1)
                                cham.Transparency = 0.5
                                cham.Color3 = color
                                cham.Parent = part
                            else
                                cham.Color3 = color
                            end
                        end
                    end
                end
            end
        end)
        task.wait(4)
    end
end

local function nametagLoopFunction()
    while nametagActive do
        pcall(function()
            for _, plyr in pairs(Players:GetPlayers()) do
                if plyr ~= Players.LocalPlayer and plyr.Character and plyr.Character:FindFirstChild("Head") then
                    local sameTeam = (plyr.TeamColor == Players.LocalPlayer.TeamColor)
                    local color = sameTeam and teamChamColor or enemyChamColor
                    local head = plyr.Character.Head
                    local existingTag = head:FindFirstChild("Nametag")
                    if not existingTag then
                        local billboard = createBillboard(plyr.Name)
                        billboard.Name = "Nametag"
                        billboard.Parent = head
                    end
                end
            end
        end)
        task.wait(4)
    end
end

local function valveEspLoopFunction()
    while valveEspActive do
        pcall(function()
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") then
                    local parent = obj.Parent
                    if parent and ((parent.Name == "Valve" or parent.Name == "ValvePuzzle") or (parent.Name == "Buttons" and obj.Name == "ValveButton")) then
                        local basePart = obj
                        if parent:IsA("Model") and parent.PrimaryPart then
                            basePart = parent.PrimaryPart
                        end
                        if not basePart:FindFirstChild("ValveESP") then
                            local esp = Instance.new("BoxHandleAdornment")
                            esp.Name = "ValveESP"
                            esp.Adornee = basePart
                            esp.AlwaysOnTop = true
                            esp.ZIndex = 10
                            esp.Size = basePart.Size + Vector3.new(0.2, 0.2, 0.2)
                            esp.Transparency = 0.5
                            esp.Color3 = valveEspColor
                            esp.Parent = basePart
                        end
                        if not basePart:FindFirstChild("ValveLabel") then
                            local billboard = createBillboard("Valve")
                            billboard.Name = "ValveLabel"
                            billboard.Parent = basePart
                        end
                    end
                end
            end
        end)
        task.wait(4)
    end
end

local function puzzleNumberEspLoopFunction()
    while puzzleNumberEspActive do
        pcall(function()
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") and obj.Parent and obj.Parent.Name == "Buttons" and puzzleNumbers[obj.Name] then
                    if not obj:FindFirstChild("PuzzleNumberESP") then
                        local esp = Instance.new("BoxHandleAdornment")
                        esp.Name = "PuzzleNumberESP"
                        esp.Adornee = obj
                        esp.AlwaysOnTop = true
                        esp.ZIndex = 10
                        esp.Size = obj.Size + Vector3.new(0.2, 0.2, 0.2)
                        esp.Transparency = 0.5
                        esp.Color3 = puzzleNumberEspColor
                        esp.Parent = obj
                    end
                    if not obj:FindFirstChild("PuzzleNumberLabel") then
                        local billboard = createBillboard("Cube Puzzle")
                        billboard.Name = "PuzzleNumberLabel"
                        billboard.Parent = obj
                    end
                end
            end
        end)
        task.wait(4)
    end
end

local function codePuzzleEspLoopFunction()
    while puzzleEspActive do
        pcall(function()
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") then
                    local fullname = obj:GetFullName():lower()
                    if fullname:find("combinationpuzzle") then
                        if not obj:FindFirstChild("PuzzleLabel") then
                            local billboard = createBillboard("Code Puzzle")
                            billboard.Name = "PuzzleLabel"
                            billboard.Parent = obj
                        end
                    end
                end
            end
        end)
        task.wait(5)
    end
end

local function noFogLoopFunction()
    while noFogActive do
        Lighting.FogStart = 0
        Lighting.FogEnd = 1e9
        task.wait(1)
    end
end

local function enableFly()
    local character = Players.LocalPlayer.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        local root = character.HumanoidRootPart
        flyBodyVelocity = Instance.new("BodyVelocity", root)
        flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
        flyBodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        flyBodyGyro = Instance.new("BodyGyro", root)
        flyBodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
        flyBodyGyro.CFrame = root.CFrame
        flyActive = true

        flyConnection = RunService.RenderStepped:Connect(function()
            local direction = Vector3.new(0, 0, 0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                direction = direction + workspace.CurrentCamera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                direction = direction - workspace.CurrentCamera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                direction = direction - workspace.CurrentCamera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                direction = direction + workspace.CurrentCamera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                direction = direction + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                direction = direction - Vector3.new(0, 1, 0)
            end

            if direction.Magnitude > 0 then
                flyBodyVelocity.Velocity = direction.Unit * flySpeed
            else
                flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
            end
            flyBodyGyro.CFrame = workspace.CurrentCamera.CFrame
        end)
    end
end

local function disableFly()
    flyActive = false
    if flyBodyVelocity then
        flyBodyVelocity:Destroy()
        flyBodyVelocity = nil
    end
    if flyBodyGyro then
        flyBodyGyro:Destroy()
        flyBodyGyro = nil
    end
    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end
end

local function startAntiKick()
    if not antiKickConnection then
        antiKickConnection = Players.LocalPlayer.Idled:Connect(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new(0, 0))
        end)
    end
end

local function stopAntiKick()
    if antiKickConnection then
        antiKickConnection:Disconnect()
        antiKickConnection = nil
    end
end

local function autoDeletePeelsFunc()
    while autoDeletePeelsActive do
        pcall(function()
            local peelsFolder = (workspace:FindFirstChild("GameKeeper") and workspace.GameKeeper:FindFirstChild("Map") and workspace.GameKeeper.Map:FindFirstChild("Peels")) or workspace:FindFirstChild("Peels")
            if peelsFolder then
                for _, peel in ipairs(peelsFolder:GetChildren()) do
                    if peel and peel.Name:lower():find("peel") then
                        peel:Destroy()
                    end
                end
            end
        end)
        task.wait(4)
    end
end

local function autoCollectCoinsFunc()
    while autoCollectCoinsActive do
        pcall(function()
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj and obj.Name:lower():find("token") and obj:IsA("BasePart") then
                    local char = Players.LocalPlayer.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if hrp and obj.Parent then
                        hrp.CFrame = CFrame.new(obj.Position + Vector3.new(0, 2, 0))
                        task.wait(0.3)
                    end
                end
            end
        end)
        task.wait(3)
    end
end

local function autoDeleteLockersFunc()
    while autoDeleteLockersActive do
        pcall(function()
            for _, desc in ipairs(workspace:GetDescendants()) do
                if desc and desc.Name:lower():find("locker") then
                    desc:Destroy()
                end
            end
        end)
        task.wait(5)
    end
end

local ESPSection = Tabs.ESP:AddSection("ESP Toggles")
local ESPColorsSection = Tabs.ESP:AddSection("ESP Colors")

ESPSection:AddToggle("CakeEspToggle", {
    Title = "Cake ESP",
    Default = false,
    Callback = function(state)
        cakeEspActive = state
        if state then
            if cakeEspLoop then task.cancel(cakeEspLoop) end
            cakeEspLoop = task.spawn(cakeEspLoopFunction)
        else
            if cakeEspLoop then task.cancel(cakeEspLoop) end
            cakeEspLoop = nil
            removeCakeEsp()
        end
    end
})

ESPSection:AddToggle("CoinEspToggle", {
    Title = "Coin ESP",
    Default = false,
    Callback = function(state)
        coinEspActive = state
        if state then
            if coinEspLoop then task.cancel(coinEspLoop) end
            coinEspLoop = task.spawn(coinEspLoopFunction)
        else
            if coinEspLoop then task.cancel(coinEspLoop) end
            coinEspLoop = nil
            removeCoinEsp()
        end
    end
})

ESPSection:AddToggle("ChamsToggle", {
    Title = "Player Chams",
    Default = false,
    Callback = function(state)
        chamsActive = state
        if state then
            if chamsLoop then task.cancel(chamsLoop) end
            chamsLoop = task.spawn(chamsLoopFunction)
        else
            if chamsLoop then task.cancel(chamsLoop) end
            chamsLoop = nil
            removeChams()
        end
    end
})

ESPSection:AddToggle("NametagToggle", {
    Title = "Nametags",
    Default = false,
    Callback = function(state)
        nametagActive = state
        if state then
            if nametagLoop then task.cancel(nametagLoop) end
            nametagLoop = task.spawn(nametagLoopFunction)
        else
            if nametagLoop then task.cancel(nametagLoop) end
            nametagLoop = nil
            removeNametags()
        end
    end
})

ESPSection:AddToggle("ValveEspToggle", {
    Title = "Valve ESP",
    Default = false,
    Callback = function(state)
        valveEspActive = state
        if state then
            if valveEspLoop then task.cancel(valveEspLoop) end
            valveEspLoop = task.spawn(valveEspLoopFunction)
        else
            if valveEspLoop then task.cancel(valveEspLoop) end
            valveEspLoop = nil
            removeValveEsp()
        end
    end
})

ESPSection:AddToggle("CubePuzzleEspToggle", {
    Title = "Cube Puzzle ESP",
    Default = false,
    Callback = function(state)
        puzzleNumberEspActive = state
        if state then
            if puzzleNumberEspLoop then task.cancel(puzzleNumberEspLoop) end
            puzzleNumberEspLoop = task.spawn(puzzleNumberEspLoopFunction)
        else
            if puzzleNumberEspLoop then task.cancel(puzzleNumberEspLoop) end
            puzzleNumberEspLoop = nil
            removePuzzleNumberEsp()
        end
    end
})

ESPSection:AddToggle("CodePuzzleEspToggle", {
    Title = "Code Puzzle ESP",
    Default = false,
    Callback = function(state)
        puzzleEspActive = state
        if state then
            if puzzleEspLoop then task.cancel(puzzleEspLoop) end
            puzzleEspLoop = task.spawn(codePuzzleEspLoopFunction)
        else
            if puzzleEspLoop then task.cancel(puzzleEspLoop) end
            puzzleEspLoop = nil
            removePuzzleEsp()
        end
    end
})

ESPColorsSection:AddColorpicker("CakeEspColor", {
    Title = "Cake ESP",
    Default = cakeEspColor,
    Callback = function(color)
        cakeEspColor = color
    end
})

ESPColorsSection:AddColorpicker("CoinEspColor", {
    Title = "Coin ESP",
    Default = coinEspColor,
    Callback = function(color)
        coinEspColor = color
    end
})

ESPColorsSection:AddColorpicker("EnemyChamsColor", {
    Title = "Enemy Chams",
    Default = enemyChamColor,
    Callback = function(color)
        enemyChamColor = color
    end
})

ESPColorsSection:AddColorpicker("TeamChamsColor", {
    Title = "Team Chams",
    Default = teamChamColor,
    Callback = function(color)
        teamChamColor = color
    end
})

ESPColorsSection:AddColorpicker("ValveEspColor", {
    Title = "Valve ESP",
    Default = valveEspColor,
    Callback = function(color)
        valveEspColor = color
    end
})

ESPColorsSection:AddColorpicker("PuzzleNumberEspColor", {
    Title = "Cube Puzzle ESP",
    Default = puzzleNumberEspColor,
    Callback = function(color)
        puzzleNumberEspColor = color
    end
})

ESPColorsSection:AddColorpicker("PuzzleObjectEspColor", {
    Title = "Code Puzzle ESP",
    Default = puzzleEspColor,
    Callback = function(color)
        puzzleEspColor = color
    end
})

Tabs.Player:AddSlider("WalkSpeedSlider", {
    Title = "Walk Speed",
    Description = "Adjust your walking speed",
    Default = 16,
    Min = 0,
    Max = 200,
    Rounding = 0,
    Callback = function(value)
        currentSpeed = value
        local char = Players.LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = currentSpeed
        end
        
        if value ~= 16 then
            if speedLoop then task.cancel(speedLoop) end
            speedLoop = task.spawn(function()
                while currentSpeed ~= 16 do
                    local c = Players.LocalPlayer.Character
                    if c and c:FindFirstChild("Humanoid") then
                        c.Humanoid.WalkSpeed = currentSpeed
                    end
                    task.wait(0.1)
                end
            end)
        else
            if speedLoop then
                task.cancel(speedLoop)
                speedLoop = nil
            end
        end
    end
})

Tabs.Player:AddButton({
    Title = "Reset Speed",
    Description = "Reset speed to default",
    Callback = function()
        currentSpeed = 16
        local char = Players.LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = 16
        end
        if speedLoop then
            task.cancel(speedLoop)
            speedLoop = nil
        end
    end
})

local SpeedPresetsSection = Tabs.Player:AddSection("Speed Presets")

SpeedPresetsSection:AddButton({
    Title = "Normal (16)",
    Callback = function()
        currentSpeed = 16
        local char = Players.LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = 16
        end
        if speedLoop then task.cancel(speedLoop); speedLoop = nil end
    end
})

SpeedPresetsSection:AddButton({
    Title = "Fast (50)",
    Callback = function()
        currentSpeed = 50
        local char = Players.LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = 50
        end
        if speedLoop then task.cancel(speedLoop) end
        speedLoop = task.spawn(function()
            while currentSpeed == 50 do
                local c = Players.LocalPlayer.Character
                if c and c:FindFirstChild("Humanoid") then
                    c.Humanoid.WalkSpeed = 50
                end
                task.wait(0.1)
            end
        end)
    end
})

SpeedPresetsSection:AddButton({
    Title = "Super Fast (100)",
    Callback = function()
        currentSpeed = 100
        local char = Players.LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = 100
        end
        if speedLoop then task.cancel(speedLoop) end
        speedLoop = task.spawn(function()
            while currentSpeed == 100 do
                local c = Players.LocalPlayer.Character
                if c and c:FindFirstChild("Humanoid") then
                    c.Humanoid.WalkSpeed = 100
                end
                task.wait(0.1)
            end
        end)
    end
})

SpeedPresetsSection:AddButton({
    Title = "Sonic (200)",
    Callback = function()
        currentSpeed = 200
        local char = Players.LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = 200
        end
        if speedLoop then task.cancel(speedLoop) end
        speedLoop = task.spawn(function()
            while currentSpeed == 200 do
                local c = Players.LocalPlayer.Character
                if c and c:FindFirstChild("Humanoid") then
                    c.Humanoid.WalkSpeed = 200
                end
                task.wait(0.1)
            end
        end)
    end
})

Tabs.Player:AddToggle("FlyToggle", {
    Title = "Fly (Local)",
    Default = false,
    Callback = function(state)
        if state then
            enableFly()
        else
            disableFly()
        end
    end
})

Tabs.Player:AddSlider("FlySpeedSlider", {
    Title = "Fly Speed",
    Description = "Adjust your flying speed",
    Default = 50,
    Min = 1,
    Max = 200,
    Rounding = 0,
    Callback = function(value)
        flySpeed = value
    end
})

Tabs.Player:AddToggle("AntiAFKToggle", {
    Title = "Anti-AFK",
    Default = false,
    Callback = function(state)
        if state then
            enableAntiAfk()
        else
            disableAntiAfk()
        end
    end
})

local AutoSection = Tabs.Player:AddSection("Auto Features")

AutoSection:AddToggle("AutoCollectCoins", {
    Title = "Auto Collect Coins",
    Default = false,
    Callback = function(state)
        autoCollectCoinsActive = state
        if state then
            if autoCollectCoinsThread then task.cancel(autoCollectCoinsThread) end
            autoCollectCoinsThread = task.spawn(autoCollectCoinsFunc)
        else
            if autoCollectCoinsThread then task.cancel(autoCollectCoinsThread) end
            autoCollectCoinsThread = nil
        end
    end
})

AutoSection:AddToggle("AutoDeletePeels", {
    Title = "Auto Delete Peels",
    Default = false,
    Callback = function(state)
        autoDeletePeelsActive = state
        if state then
            if autoDeletePeelsThread then task.cancel(autoDeletePeelsThread) end
            autoDeletePeelsThread = task.spawn(autoDeletePeelsFunc)
        else
            if autoDeletePeelsThread then task.cancel(autoDeletePeelsThread) end
            autoDeletePeelsThread = nil
        end
    end
})

AutoSection:AddToggle("AutoDeleteLockers", {
    Title = "Auto Delete Lockers",
    Default = false,
    Callback = function(state)
        autoDeleteLockersActive = state
        if state then
            if autoDeleteLockersThread then task.cancel(autoDeleteLockersThread) end
            autoDeleteLockersThread = task.spawn(autoDeleteLockersFunc)
        else
            if autoDeleteLockersThread then task.cancel(autoDeleteLockersThread) end
            autoDeleteLockersThread = nil
        end
    end
})

AutoSection:AddToggle("AntiKickBypass", {
    Title = "Anti Kick Bypass",
    Default = false,
    Callback = function(state)
        if state then
            startAntiKick()
        else
            stopAntiKick()
        end
    end
})

local VisualSection = Tabs.Visual

VisualSection:AddToggle("FullbrightToggle", {
    Title = "Fullbright",
    Description = "Makes everything bright",
    Default = false,
    Callback = function(state)
        fullbrightActive = state
        if state then
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = false
            Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        else
            Lighting.Brightness = 1
            Lighting.ClockTime = 14
            Lighting.FogEnd = 1000
            Lighting.GlobalShadows = true
            Lighting.OutdoorAmbient = Color3.fromRGB(70, 70, 70)
        end
    end
})

VisualSection:AddToggle("NoFogToggle", {
    Title = "No Fog",
    Description = "Removes all fog effects",
    Default = false,
    Callback = function(state)
        noFogActive = state
        if state then
            if noFogLoop then task.cancel(noFogLoop) end
            noFogLoop = task.spawn(noFogLoopFunction)
        else
            if noFogLoop then task.cancel(noFogLoop) end
            noFogLoop = nil
            Lighting.FogStart = 0
            Lighting.FogEnd = 1000
        end
    end
})

VisualSection:AddToggle("ColorCorrectionToggle", {
    Title = "Color Correction",
    Description = "Enhances game colors",
    Default = false,
    Callback = function(state)
        ccActive = state
        if state then
            enableColorCorrection()
        else
            disableColorCorrection()
        end
    end
})

VisualSection:AddSlider("BrightnessSlider", {
    Title = "Brightness",
    Description = "Adjust color brightness",
    Default = 0,
    Min = -1,
    Max = 1,
    Rounding = 2,
    Callback = function(value)
        ccBrightness = value
        if ccActive and ccEffect then
            ccEffect.Brightness = value
        end
    end
})

VisualSection:AddSlider("ContrastSlider", {
    Title = "Contrast",
    Description = "Adjust color contrast",
    Default = 0,
    Min = -2,
    Max = 2,
    Rounding = 2,
    Callback = function(value)
        ccContrast = value
        if ccActive and ccEffect then
            ccEffect.Contrast = value
        end
    end
})

VisualSection:AddSlider("SaturationSlider", {
    Title = "Saturation",
    Description = "Adjust color saturation",
    Default = 1,
    Min = 0,
    Max = 3,
    Rounding = 2,
    Callback = function(value)
        ccSaturation = value
        if ccActive and ccEffect then
            ccEffect.Saturation = value
        end
    end
})

VisualSection:AddToggle("SunRaysToggle", {
    Title = "Sun Rays",
    Description = "Adds atmospheric sun rays",
    Default = false,
    Callback = function(state)
        sunRaysActive = state
        if state then
            enableSunRays()
        else
            disableSunRays()
        end
    end
})

VisualSection:AddSlider("SunRaysIntensitySlider", {
    Title = "Sun Rays Intensity",
    Description = "Adjust sun rays strength",
    Default = 0.3,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Callback = function(value)
        sunRaysIntensity = value
        if sunRaysActive and sunRaysEffect then
            sunRaysEffect.Intensity = value
        end
    end
})

local LightingSection = Tabs.Visual:AddSection("Lighting Controls")

LightingSection:AddSlider("ClockTimeSlider", {
    Title = "Time of Day",
    Description = "Change game time",
    Default = 14,
    Min = 0,
    Max = 24,
    Rounding = 1,
    Callback = function(value)
        Lighting.ClockTime = value
    end
})

LightingSection:AddSlider("ExposureSlider", {
    Title = "Exposure",
    Description = "Adjust lighting exposure",
    Default = 0,
    Min = -3,
    Max = 3,
    Rounding = 2,
    Callback = function(value)
        Lighting.ExposureCompensation = value
    end
})

LightingSection:AddToggle("ShadowsToggle", {
    Title = "Shadows",
    Description = "Enable/disable shadows",
    Default = true,
    Callback = function(state)
        Lighting.GlobalShadows = state
    end
})

local UtilitySection = Tabs.Visual:AddSection("Utility")

UtilitySection:AddButton({
    Title = "Reset All Visual",
    Description = "Reset all visual settings to default",
    Callback = function()
        Lighting.Brightness = 1
        Lighting.ClockTime = 14
        Lighting.FogStart = 0
        Lighting.FogEnd = 1000
        Lighting.GlobalShadows = true
        Lighting.OutdoorAmbient = Color3.fromRGB(70, 70, 70)
        Lighting.ExposureCompensation = 0
        
        if ccEffect then ccEffect:Destroy(); ccEffect = nil end
        if sunRaysEffect then sunRaysEffect:Destroy(); sunRaysEffect = nil end
        
        ccActive = false
        sunRaysActive = false
        fullbrightActive = false
        
        if noFogLoop then
            task.cancel(noFogLoop)
            noFogLoop = nil
            noFogActive = false
        end
        
        Fluent:Notify({
            Title = "Visual Reset",
            Content = "All visual settings reset to default",
            Duration = 3
        })
    end
})

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/specific-game")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)
SaveManager:LoadAutoloadConfig()

Players.LocalPlayer.CharacterAdded:Connect(function(character)
    character:WaitForChild("HumanoidRootPart")
    task.wait(0.5)
    
    if speedLoop and currentSpeed ~= 16 then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = currentSpeed
        end
    end
    
    if flyActive then
        task.wait(0.5)
        disableFly()
        task.wait(0.5)
        enableFly()
    end
end)

Fluent:Notify({
    Title = "Tapetenputzer",
    Content = "Script Loaded Successfully!",
    Duration = 5
})

Window:SelectTab(1)
print("Banana Eats Script Loaded!")
