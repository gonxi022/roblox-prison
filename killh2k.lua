-- Prison Life - Kill All + God Mode FUNCIONAL
-- TP persona por persona + meleeEvent agresivo
-- God Mode inmortal + Botones arrastrables

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Variables
local godModeEnabled = false
local godConnection = nil
local killAllEnabled = false
local killAllConnection = nil
local currentTargetIndex = 1

-- Crear GUI
local gui = Instance.new("ScreenGui")
gui.Name = "PrisonLifeHackGui"
gui.ResetOnSpawn = false
gui.Parent = PlayerGui

-- Función para hacer botones arrastrables (MEJORADA)
local function makeDraggable(frame)
    local dragging = false
    local dragInput = nil
    local dragStart = nil
    local startPos = nil

    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

-- Botón Kill All
local killButton = Instance.new("TextButton")
killButton.Name = "KillAllButton"
killButton.Size = UDim2.new(0, 200, 0, 60)
killButton.Position = UDim2.new(0, 20, 0, 60)
killButton.BackgroundColor3 = Color3.fromRGB(220, 20, 20)
killButton.BorderSizePixel = 0
killButton.Text = "🔫 Kill All: OFF"
killButton.TextColor3 = Color3.fromRGB(255, 255, 255)
killButton.TextScaled = true
killButton.Font = Enum.Font.GothamBold
killButton.Parent = gui

local killCorner = Instance.new("UICorner")
killCorner.CornerRadius = UDim.new(0, 12)
killCorner.Parent = killButton

-- Botón God Mode
local godButton = Instance.new("TextButton")
godButton.Name = "GodModeButton"
godButton.Size = UDim2.new(0, 200, 0, 60)
godButton.Position = UDim2.new(0, 20, 0, 130)
godButton.BackgroundColor3 = Color3.fromRGB(20, 120, 20)
godButton.BorderSizePixel = 0
godButton.Text = "🛡️ God Mode: OFF"
godButton.TextColor3 = Color3.fromRGB(255, 255, 255)
godButton.TextScaled = true
godButton.Font = Enum.Font.GothamBold
godButton.Parent = gui

local godCorner = Instance.new("UICorner")
godCorner.CornerRadius = UDim.new(0, 12)
godCorner.Parent = godButton

-- Hacer botones arrastrables
makeDraggable(killButton)
makeDraggable(godButton)

-- Función para obtener todos los jugadores enemigos
local function getTargets()
    local targets = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") then
            if player.Character.Humanoid.Health > 0 then
                table.insert(targets, player)
            end
        end
    end
    return targets
end

-- TP seguro y efectivo
local function teleportTo(targetPlayer)
    local myChar = LocalPlayer.Character
    local targetChar = targetPlayer.Character
    
    if myChar and myChar:FindFirstChild("HumanoidRootPart") and targetChar and targetChar:FindFirstChild("HumanoidRootPart") then
        local targetPos = targetChar.HumanoidRootPart.Position
        myChar.HumanoidRootPart.CFrame = CFrame.new(targetPos + Vector3.new(0, 3, 2))
        return true
    end
    return false
end

-- Kill All MEJORADO - Persona por persona
local function toggleKillAll()
    if not killAllEnabled then
        -- Activar Kill All
        killAllEnabled = true
        killButton.Text = "🔥 Kill All: ON"
        killButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        currentTargetIndex = 1
        
        -- Buscar meleeEvent
        local meleeEvent = ReplicatedStorage:FindFirstChild("meleeEvent")
        if not meleeEvent then
            -- Buscar eventos alternativos
            meleeEvent = ReplicatedStorage:FindFirstChild("RemoteEvent") or 
                        ReplicatedStorage:FindFirstChild("hitEvent") or
                        ReplicatedStorage:FindFirstChild("damageEvent")
        end
        
        if not meleeEvent then
            warn("❌ Ningún evento de daño encontrado!")
            killAllEnabled = false
            killButton.Text = "🔫 Kill All: OFF"
            killButton.BackgroundColor3 = Color3.fromRGB(220, 20, 20)
            return
        end
        
        print("✅ Usando evento:", meleeEvent.Name)
        
        -- Bucle de Kill All - Persona por persona
        killAllConnection = task.spawn(function()
            while killAllEnabled do
                local targets = getTargets()
                
                if #targets > 0 then
                    -- Seleccionar objetivo actual
                    if currentTargetIndex > #targets then
                        currentTargetIndex = 1
                    end
                    
                    local currentTarget = targets[currentTargetIndex]
                    
                    if currentTarget and currentTarget.Character then
                        -- TP al objetivo actual
                        if teleportTo(currentTarget) then
                            task.wait(0.1) -- Esperar a que el TP termine
                            
                            -- Ataque AGRESIVO - múltiples métodos
                            for i = 1, 25 do -- Aumentado a 25 hits
                                -- Método 1: meleeEvent básico
                                pcall(function()
                                    meleeEvent:FireServer(currentTarget)
                                end)
                                
                                -- Método 2: con datos adicionales
                                pcall(function()
                                    meleeEvent:FireServer(currentTarget, "Punch", 50)
                                end)
                                
                                -- Método 3: hit directo
                                pcall(function()
                                    meleeEvent:FireServer(currentTarget.Character.Humanoid, 50)
                                end)
                                
                                task.wait(0.01) -- Pequeño delay entre hits
                            end
                        end
                        
                        -- Pasar al siguiente objetivo
                        currentTargetIndex = currentTargetIndex + 1
                        task.wait(0.2) -- Pausa antes del siguiente objetivo
                    else
                        currentTargetIndex = currentTargetIndex + 1
                    end
                else
                    task.wait(0.5) -- Si no hay objetivos, esperar más
                end
            end
        end)
        
    else
        -- Desactivar Kill All
        killAllEnabled = false
        killButton.Text = "🔫 Kill All: OFF"
        killButton.BackgroundColor3 = Color3.fromRGB(220, 20, 20)
        
        if killAllConnection then
            task.cancel(killAllConnection)
            killAllConnection = nil
        end
    end
end

-- God Mode ULTRA FUNCIONAL
local function toggleGodMode()
    if not godModeEnabled then
        -- Activar God Mode
        godModeEnabled = true
        godButton.Text = "✨ God Mode: ON"
        godButton.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
        
        -- Método 1: Heartbeat constante
        godConnection = RunService.Heartbeat:Connect(function()
            if godModeEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                local humanoid = LocalPlayer.Character.Humanoid
                if humanoid.Health < humanoid.MaxHealth then
                    humanoid.Health = humanoid.MaxHealth
                end
                -- Prevenir que la salud baje
                if humanoid.MaxHealth ~= math.huge then
                    humanoid.MaxHealth = math.huge
                    humanoid.Health = math.huge
                end
            end
        end)
        
        -- Método 2: Protección adicional
        task.spawn(function()
            while godModeEnabled do
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    local humanoid = LocalPlayer.Character.Humanoid
                    humanoid.Health = math.huge
                    humanoid.MaxHealth = math.huge
                    
                    -- Prevenir caídas
                    if LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
                    end
                end
                task.wait(0.1)
            end
        end)
        
    else
        -- Desactivar God Mode
        godModeEnabled = false
        godButton.Text = "🛡️ God Mode: OFF"
        godButton.BackgroundColor3 = Color3.fromRGB(20, 120, 20)
        
        if godConnection then
            godConnection:Disconnect()
            godConnection = nil
        end
        
        -- Restaurar salud normal
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.MaxHealth = 100
            LocalPlayer.Character.Humanoid.Health = 100
        end
    end
end

-- Auto-reactivar cuando spawnes
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(2) -- Esperar más tiempo
    
    if godModeEnabled then
        local wasEnabled = godModeEnabled
        godModeEnabled = false
        if godConnection then godConnection:Disconnect() end
        task.wait(0.5)
        if wasEnabled then
            toggleGodMode()
        end
    end
    
    if killAllEnabled then
        local wasEnabled = killAllEnabled
        killAllEnabled = false
        if killAllConnection then task.cancel(killAllConnection) end
        task.wait(0.5)
        if wasEnabled then
            toggleKillAll()
        end
    end
end)

-- Conectar botones
killButton.MouseButton1Click:Connect(toggleKillAll)
godButton.MouseButton1Click:Connect(toggleGodMode)

-- Información
print("🚀 Prison Life Hack FUNCIONAL cargado!")
print("🔫 Kill All: TP persona por persona + 25 hits agresivos")
print("🛡️ God Mode: Salud infinita real")
print("📱 Botones arrastrables para móvil")