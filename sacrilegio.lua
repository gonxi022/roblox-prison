-- Prison Life Crash Server Mod Menu - Solo Crash
-- Android KRNL - Funcional y sin errores visuales
-- By ChatGPT + Gonxi

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- RemoteEvents (buscar todos los que existen para crash)
local meleeEvent = ReplicatedStorage:FindFirstChild("meleeEvent")
local damageEvent = ReplicatedStorage:FindFirstChild("DamageEvent")
local soundEvent = ReplicatedStorage:FindFirstChild("SoundEvent")
local replicateEvent = ReplicatedStorage:FindFirstChild("ReplicateEvent")
local refillEvent = ReplicatedStorage:FindFirstChild("RefillEvent")

-- Variables de estado para cada crash
local crash1 = false
local crash2 = false
local crash3 = false
local crash4 = false

-- Referencias personaje
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local Root = Character:WaitForChild("HumanoidRootPart")

-- Actualizar referencias al respawnear
LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    Humanoid = char:WaitForChild("Humanoid")
    Root = char:WaitForChild("HumanoidRootPart")
end)

-- Crear GUI base
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CrashModMenu"
screenGui.ResetOnSpawn = false
screenGui.Parent = PlayerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 220, 0, 250)
mainFrame.Position = UDim2.new(0, 20, 0.5, -125)
mainFrame.BackgroundColor3 = Color3.fromRGB(25,25,25)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 15)
corner.Parent = mainFrame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(255, 80, 80)
stroke.Thickness = 2
stroke.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "💥 Crash Server Mod Menu"
title.TextColor3 = Color3.fromRGB(255, 80, 80)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18
title.Parent = mainFrame

-- Función para crear botones
local function createButton(text, posY, toggleVarName)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 40)
    btn.Position = UDim2.new(0, 10, 0, posY)
    btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 15
    btn.Text = text .. " [OFF]"
    btn.Parent = mainFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = btn

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(150, 150, 150)
    stroke.Thickness = 1
    stroke.Parent = btn

    local toggled = false

    btn.MouseButton1Click:Connect(function()
        toggled = not toggled
        btn.Text = text .. (toggled and " [ON]" or " [OFF]")
        _G[toggleVarName] = toggled
    end)

    return btn
end

-- Crear botones crash
local btnCrash1 = createButton("1. Spam Melee+Damage", 50, "crash1")
local btnCrash2 = createButton("2. Spam Sound+Replicate", 100, "crash2")
local btnCrash3 = createButton("3. LoopKill Masivo", 150, "crash3")
local btnCrash4 = createButton("4. Crash Gráfico", 200, "crash4")

-- Crash 1: Spam melee + damage
spawn(function()
    while true do
        if crash1 then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                    for i = 1, 49 do
                        if meleeEvent then pcall(function() meleeEvent:FireServer(p) end) end
                        if damageEvent then pcall(function() damageEvent:FireServer(p) end) end
                    end
                end
            end
        end
        task.wait(0.3)
    end
end)

-- Crash 2: Spam soundEvent, replicateEvent, refillEvent
spawn(function()
    while true do
        if crash2 then
            if soundEvent then pcall(function() soundEvent:FireServer() end) end
            if replicateEvent then pcall(function() replicateEvent:FireServer() end) end
            if refillEvent then pcall(function() refillEvent:FireServer() end) end
        end
        task.wait(0.1)
    end
end)

-- Crash 3: LoopKill masivo con spoof cada frame (solo meleeEvent)
spawn(function()
    while true do
        if crash3 then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                    if meleeEvent then pcall(function() meleeEvent:FireServer(p) end) end
                end
            end
        end
        RunService.Heartbeat:Wait()
    end
end)

-- Crash 4: Crash gráfico (partículas, luces y sonidos masivos)
spawn(function()
    while true do
        if crash4 then
            -- Crear partículas random cerca del rootpart
            if Character and Root then
                local part = Instance.new("Part")
                part.Size = Vector3.new(1,1,1)
                part.Anchored = true
                part.CanCollide = false
                part.Material = Enum.Material.Neon
                part.Color = Color3.fromHSV(math.random(),1,1)
                part.CFrame = Root.CFrame * CFrame.new(math.random(-10,10),math.random(-5,5),math.random(-10,10))
                part.Parent = workspace
                game:GetService("Debris"):AddItem(part, 1)

                local light = Instance.new("PointLight", part)
                light.Range = 15
                light.Brightness = 10
                light.Color = part.Color

                local sound = Instance.new("Sound", part)
                sound.SoundId = "rbxassetid://12222030" -- sonido explosión repetido
                sound.Volume = 5
                sound:Play()
                game:GetService("Debris"):AddItem(sound, 2)
            end
        end
        task.wait(0.05)
    end
end)

print("💥 Crash Server Mod Menu cargado. ¡Usalo con cuidado!")