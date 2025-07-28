-- Prison Life Kill Aura + Noclip + Speed - Android KRNL
-- Kill Aura real como los exploiters actuales usan

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")
local playerGui = player:WaitForChild("PlayerGui")

-- Variables globales
local killAuraEnabled = false
local noclipEnabled = false
local speedEnabled = false
local killAuraRadius = 20
local normalSpeed = 16
local speedMultiplier = 5

-- Buscar remotes importantes
local meleeEvent = ReplicatedStorage:FindFirstChild("meleeEvent")
local replicateEvent = ReplicatedStorage:FindFirstChild("ReplicateEvent") 
local damageEvent = ReplicatedStorage:FindFirstChild("DamageEvent")

-- Crear GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PrisonLifeKillAura"
screenGui.Parent = playerGui
screenGui.ResetOnSpawn = false

-- Frame principal
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 160)
mainFrame.Position = UDim2.new(0, 10, 0, 10)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = mainFrame

-- Título
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 35)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
titleLabel.Text = "🔥 Prison Life Kill Aura"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextScaled = true
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = titleLabel

-- Kill Aura Button (más grande)
local killAuraBtn = Instance.new("TextButton")
killAuraBtn.Size = UDim2.new(0.9, 0, 0, 40)
killAuraBtn.Position = UDim2.new(0.05, 0, 0, 45)
killAuraBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
killAuraBtn.Text = "⚡ KILL AURA OFF"
killAuraBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
killAuraBtn.TextScaled = true
killAuraBtn.Font = Enum.Font.GothamBold
killAuraBtn.Parent = mainFrame

local auraCorner = Instance.new("UICorner")
auraCorner.CornerRadius = UDim.new(0, 8)
auraCorner.Parent = killAuraBtn

-- Noclip Button
local noclipBtn = Instance.new("TextButton")
noclipBtn.Size = UDim2.new(0.44, 0, 0, 30)
noclipBtn.Position = UDim2.new(0.05, 0, 0, 95)
noclipBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 200)
noclipBtn.Text = "👻 NOCLIP"
noclipBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
noclipBtn.TextScaled = true
noclipBtn.Font = Enum.Font.Gotham
noclipBtn.Parent = mainFrame

local noclipCorner = Instance.new("UICorner")
noclipCorner.CornerRadius = UDim.new(0, 6)
noclipCorner.Parent = noclipBtn

-- Speed Button
local speedBtn = Instance.new("TextButton")
speedBtn.Size = UDim2.new(0.44, 0, 0, 30)
speedBtn.Position = UDim2.new(0.51, 0, 0, 95)
speedBtn.BackgroundColor3 = Color3.fromRGB(200, 150, 50)
speedBtn.Text = "💨 SPEED x5"
speedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
speedBtn.TextScaled = true
speedBtn.Font = Enum.Font.Gotham
speedBtn.Parent = mainFrame

local speedCorner = Instance.new("UICorner")
speedCorner.CornerRadius = UDim.new(0, 6)
speedCorner.Parent = speedBtn

-- Status Label
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -10, 0, 25)
statusLabel.Position = UDim2.new(0, 5, 0, 130)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "👮 Listo para eliminar TODOS los jugadores | Radio: " .. killAuraRadius .. " studs"
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.TextScaled = true
statusLabel.Font = Enum.Font.Gotham
statusLabel.Parent = mainFrame

-- Crear indicador visual del radio (opcional)
local radiusIndicator = Instance.new("Part")
radiusIndicator.Name = "AuraRadius"
radiusIndicator.Size = Vector3.new(killAuraRadius * 2, 0.1, killAuraRadius * 2)
radiusIndicator.Material = Enum.Material.Neon
radiusIndicator.BrickColor = BrickColor.new("Really red")
radiusIndicator.Anchored = true
radiusIndicator.CanCollide = false
radiusIndicator.Transparency = 0.8
radiusIndicator.Shape = Enum.PartType.Cylinder
radiusIndicator.Parent = nil

-- Funciones principales

-- Kill Aura principal (como los exploiters reales lo hacen)
local killAuraConnection = nil
local function startKillAura()
    local killedCount = 0
    
    killAuraConnection = RunService.Heartbeat:Connect(function()
        if not killAuraEnabled or not character or not rootPart then return end
        
        -- Buscar todos los players cercanos
        for _, targetPlayer in pairs(Players:GetPlayers()) do
            if targetPlayer ~= player and targetPlayer.Character then
                local targetCharacter = targetPlayer.Character
                local targetHumanoid = targetCharacter:FindFirstChild("Humanoid")
                local targetRoot = targetCharacter:FindFirstChild("HumanoidRootPart")
                local targetHead = targetCharacter:FindFirstChild("Head")
                
                if targetHumanoid and targetRoot and targetHead and targetHumanoid.Health > 0 then
                    -- Calcular distancia
                    local distance = (rootPart.Position - targetRoot.Position).Magnitude
                    
                    -- Si está dentro del radio de kill aura
                    if distance <= killAuraRadius then
                        -- Kill Aura mata a TODOS los jugadores (criminales, policías, guardias, etc.)
                        -- Sin filtros de team - mata a cualquiera que se acerque
                        if true then -- Siempre es target
                            -- Múltiples métodos de kill (como los exploits reales)
                            
                            -- Método 1: meleeEvent (más confiable)
                            pcall(function()
                                if meleeEvent then
                                    meleeEvent:FireServer(targetCharacter)
                                    meleeEvent:FireServer(targetHumanoid)
                                    meleeEvent:FireServer(targetHead)
                                end
                            end)
                            
                            -- Método 2: ReplicateEvent con diferentes parámetros
                            pcall(function()
                                if replicateEvent then
                                    replicateEvent:FireServer(targetCharacter)
                                    replicateEvent:FireServer("Damage", targetHumanoid, 100)
                                    replicateEvent:FireServer("Kill", targetCharacter)
                                end
                            end)
                            
                            -- Método 3: DamageEvent directo
                            pcall(function()
                                if damageEvent then
                                    damageEvent:FireServer(targetHumanoid, 100)
                                end
                            end)
                            
                            -- Método 4: Health manipulation (backup)
                            pcall(function()
                                targetHumanoid:TakeDamage(100)
                                targetHumanoid.Health = 0
                            end)
                            
                            killedCount = killedCount + 1
                            
                            -- Efecto visual opcional
                            if targetHead then
                                local effect = Instance.new("Explosion")
                                effect.Position = targetHead.Position
                                effect.BlastRadius = 5
                                effect.BlastPressure = 0
                                effect.Parent = Workspace
                            end
                        end
                    end
                end
            end
        end
        
        -- Actualizar contador cada 30 frames
        if killedCount > 0 and killedCount % 5 == 0 then
            statusLabel.Text = "⚡ Kill Aura: " .. killedCount .. " eliminados | Radio: " .. killAuraRadius
        end
    end)
end

local function stopKillAura()
    if killAuraConnection then
        killAuraConnection:Disconnect()
        killAuraConnection = nil
    end
end

-- Noclip Function
local noclipConnection = nil
local function toggleNoclip()
    noclipEnabled = not noclipEnabled
    
    if noclipEnabled then
        noclipBtn.BackgroundColor3 = Color3.fromRGB(100, 255, 150)
        noclipBtn.Text = "👻 ON"
        
        noclipConnection = RunService.Stepped:Connect(function()
            if character then
                for _, part in pairs(character:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        noclipBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 200)
        noclipBtn.Text = "👻 NOCLIP"
        
        if noclipConnection then
            noclipConnection:Disconnect()
        end
        
        if character then
            for _, part in pairs(character:GetChildren()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.CanCollide = true
                end
            end
        end
    end
end

-- Speed Function
local function toggleSpeed()
    speedEnabled = not speedEnabled
    
    if speedEnabled then
        speedBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 100)
        speedBtn.Text = "💨 ON"
        if humanoid then
            humanoid.WalkSpeed = normalSpeed * speedMultiplier
        end
    else
        speedBtn.BackgroundColor3 = Color3.fromRGB(200, 150, 50)
        speedBtn.Text = "💨 SPEED x5"
        if humanoid then
            humanoid.WalkSpeed = normalSpeed
        end
    end
end

-- Event Connections

-- Kill Aura Toggle
killAuraBtn.MouseButton1Click:Connect(function()
    killAuraEnabled = not killAuraEnabled
    
    if killAuraEnabled then
        killAuraBtn.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
        killAuraBtn.Text = "⚡ KILL AURA ON"
        statusLabel.Text = "⚡ Kill Aura ACTIVO | Matando a TODOS los jugadores cercanos..."
        
        -- Mostrar indicador visual
        if radiusIndicator then
            radiusIndicator.Parent = Workspace
            radiusIndicator.CFrame = rootPart.CFrame * CFrame.new(0, -3, 0)
        end
        
        startKillAura()
        
        -- Mover el indicador con el player
        spawn(function()
            while killAuraEnabled and radiusIndicator.Parent do
                if rootPart then
                    radiusIndicator.CFrame = rootPart.CFrame * CFrame.new(0, -3, 0)
                end
                wait(0.1)
            end
        end)
        
    else
        killAuraBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
        killAuraBtn.Text = "⚡ KILL AURA OFF"
        statusLabel.Text = "👮 Kill Aura desactivado | Radio: " .. killAuraRadius .. " studs"
        
        -- Ocultar indicador
        if radiusIndicator then
            radiusIndicator.Parent = nil
        end
        
        stopKillAura()
    end
end)

-- Otros botones
noclipBtn.MouseButton1Click:Connect(toggleNoclip)
speedBtn.MouseButton1Click:Connect(toggleSpeed)

-- Cambio de radio con toque largo en Kill Aura button
local touchTime = 0
local touching = false

killAuraBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        touching = true
        touchTime = 0
        
        spawn(function()
            while touching do
                wait(0.1)
                touchTime = touchTime + 0.1
                
                if touchTime >= 1.5 and touching then
                    -- Cambiar radio
                    killAuraRadius = killAuraRadius + 5
                    if killAuraRadius > 50 then killAuraRadius = 10 end
                    
                    statusLabel.Text = "📏 Radio cambiado a: " .. killAuraRadius .. " studs"
                    
                    -- Actualizar indicador visual
                    if radiusIndicator then
                        radiusIndicator.Size = Vector3.new(killAuraRadius * 2, 0.1, killAuraRadius * 2)
                    end
                    
                    -- Efecto visual
                    local tween = TweenService:Create(killAuraBtn, TweenInfo.new(0.2), {Size = UDim2.new(0.95, 0, 0, 45)})
                    tween:Play()
                    tween.Completed:Connect(function()
                        TweenService:Create(killAuraBtn, TweenInfo.new(0.2), {Size = UDim2.new(0.9, 0, 0, 40)}):Play()
                    end)
                    
                    break
                end
            end
        end)
    end
end)

killAuraBtn.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        touching = false
    end
end)

-- Drag functionality
local dragging = false
local dragStart = nil
local startPos = nil

titleLabel.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- Character respawn handler
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoid = character:WaitForChild("Humanoid")
    rootPart = character:WaitForChild("HumanoidRootPart")
    
    -- Restaurar configuraciones
    if speedEnabled then
        humanoid.WalkSpeed = normalSpeed * speedMultiplier
    end
    
    -- Reiniciar kill aura si estaba activo
    if killAuraEnabled then
        stopKillAura()
        wait(1)
        startKillAura()
    end
end)

-- Cleanup al salir
game:GetService("Players").PlayerRemoving:Connect(function(plr)
    if plr == player then
        if radiusIndicator then
            radiusIndicator:Destroy()
        end
    end
end)

print("🔥 Prison Life Kill Aura cargado")
print("⚡ Kill Aura automático activado")
print("👻 Noclip + Speed incluidos")
print("📱 Optimizado para Android KRNL")
print("💀 TODOS los jugadores que se acerquen morirán instantáneamente")