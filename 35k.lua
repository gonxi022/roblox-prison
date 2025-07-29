-- Prison Life - Menú Completo Minimizable
-- Kill All, God Mode, Speed x70, Noclip paredes
-- By Gonxi + GPT

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local Root = Character:WaitForChild("HumanoidRootPart")

local meleeEvent = ReplicatedStorage:FindFirstChild("meleeEvent") or ReplicatedStorage:FindFirstChildWhichIsA("RemoteEvent", true)

local screenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
screenGui.ResetOnSpawn = false
screenGui.Name = "GonxiMenu"

-- Variables de estado
local killAllActivo = false
local godModeActivo = false
local speedActivo = false
local noclipActivo = false
local MELEE_DISTANCE = 15

-- Interfaz principal (frame)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 180, 0, 240)
mainFrame.Position = UDim2.new(0, 50, 0, 150)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui
mainFrame.Active = true
mainFrame.Draggable = true

-- Botón minimizar
local minimizarBtn = Instance.new("TextButton")
minimizarBtn.Size = UDim2.new(0, 40, 0, 30)
minimizarBtn.Position = UDim2.new(1, -45, 0, 5)
minimizarBtn.Text = "—"
minimizarBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
minimizarBtn.TextColor3 = Color3.new(1,1,1)
minimizarBtn.TextScaled = true
minimizarBtn.Parent = mainFrame

-- Frame botones (contenedor)
local botonesFrame = Instance.new("Frame")
botonesFrame.Size = UDim2.new(1, -10, 1, -40)
botonesFrame.Position = UDim2.new(0, 5, 0, 35)
botonesFrame.BackgroundTransparency = 1
botonesFrame.Parent = mainFrame

-- Crear botón reutilizable
local function crearBoton(texto, posicion, callback)
    local boton = Instance.new("TextButton")
    boton.Size = UDim2.new(1, 0, 0, 40)
    boton.Position = posicion
    boton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    boton.TextColor3 = Color3.fromRGB(255, 255, 255)
    boton.TextScaled = true
    boton.Text = texto
    boton.Parent = botonesFrame
    boton.MouseButton1Click:Connect(callback)
    return boton
end

local function notificar(texto)
    local notif = Instance.new("TextLabel", screenGui)
    notif.Size = UDim2.new(0, 300, 0, 40)
    notif.Position = UDim2.new(0.5, -150, 0, 100)
    notif.BackgroundColor3 = Color3.new(0, 0, 0)
    notif.BackgroundTransparency = 0.3
    notif.TextColor3 = Color3.new(1, 1, 1)
    notif.TextScaled = true
    notif.Text = texto
    game:GetService("Debris"):AddItem(notif, 2)
end

-- Kill All loop
local function loopKillAll()
    while killAllActivo do
        for _, player in pairs(Players:GetPlayers()) do
            if not killAllActivo then break end
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") then
                local targetRoot = player.Character.HumanoidRootPart
                local dist = (targetRoot.Position - Root.Position).Magnitude
                if dist <= MELEE_DISTANCE and player.Character.Humanoid.Health > 0 then
                    for i = 1, 49 do
                        meleeEvent:FireServer(player)
                    end
                end
            end
        end
        task.wait(0.2)
    end
end

-- Toggle Kill All
local function toggleKillAll()
    killAllActivo = not killAllActivo
    if killAllActivo then
        notificar("Kill All Cercano ACTIVADO")
        spawn(loopKillAll)
    else
        notificar("Kill All Cercano DESACTIVADO")
    end
end

-- Toggle God Mode
local function toggleGodMode()
    godModeActivo = not godModeActivo
    if godModeActivo then
        notificar("God Mode ACTIVADO")
    else
        notificar("God Mode DESACTIVADO")
    end
end

-- Toggle Speed
local speedActivo = false
local function toggleSpeed()
    speedActivo = not speedActivo
    if speedActivo then
        notificar("Speed x70 ACTIVADO")
    else
        notificar("Speed DESACTIVADO")
        if Humanoid then Humanoid.WalkSpeed = 16 end
    end
end

local function aplicarSpeed()
    if Humanoid then
        if speedActivo then
            Humanoid.WalkSpeed = 70
        else
            Humanoid.WalkSpeed = 16
        end
    end
end

-- Noclip solo paredes (no piso)
local function toggleNoclip()
    noclipActivo = not noclipActivo
    if noclipActivo then
        notificar("Noclip paredes ACTIVADO")
    else
        notificar("Noclip paredes DESACTIVADO")
    end
end

-- Detectar colisiones solo con piso (partes con CanCollide true que no sean paredes)
RunService.Stepped:Connect(function()
    if noclipActivo and Character then
        for _, part in pairs(Character:GetChildren()) do
            if part:IsA("BasePart") then
                -- Permitimos colisión con suelo (piso = partes con CanCollide true y Orientation casi 0 en X/Z)
                local touchingParts = part:GetTouchingParts()
                for _, tp in pairs(touchingParts) do
                    if tp.CanCollide then
                        local orientation = tp.Orientation
                        local isPiso = math.abs(orientation.X) < 15 and math.abs(orientation.Z) < 15
                        if isPiso then
                            part.CanCollide = true
                        else
                            part.CanCollide = false
                        end
                    end
                end
            end
        end
    else
        -- Noclip apagado: restaurar CanCollide a true para todo el personaje
        if Character then
            for _, part in pairs(Character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end)

-- God mode loop para salud infinita y caída cancelada
RunService.Heartbeat:Connect(function()
    if godModeActivo and Humanoid then
        Humanoid.Health = math.huge
        Humanoid.MaxHealth = math.huge
        if Root.Velocity.Y < -100 then
            Root.Velocity = Vector3.new(0, 0, 0)
        end
    end
    aplicarSpeed()
end)

-- Reconectar humanoid y root al morir/revivir
LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    Humanoid = char:WaitForChild("Humanoid")
    Root = char:WaitForChild("HumanoidRootPart")
    aplicarSpeed()
    if killAllActivo then
        spawn(loopKillAll)
    end
end)

-- Botones
crearBoton("⚔️ Kill All Cercano", UDim2.new(0, 0, 0, 0), toggleKillAll)
crearBoton("🛡️ God Mode", UDim2.new(0, 0, 0, 50), toggleGodMode)
crearBoton("⚡ Speed x70", UDim2.new(0, 0, 0, 100), toggleSpeed)
crearBoton("🚶 Noclip Paredes", UDim2.new(0, 0, 0, 150), toggleNoclip)

-- Minimizar funcionalidad
local menuVisible = true
minimizarBtn.MouseButton1Click:Connect(function()
    menuVisible = not menuVisible
    botonesFrame.Visible = menuVisible
    minimizarBtn.Text = menuVisible and "—" or "+"
end)