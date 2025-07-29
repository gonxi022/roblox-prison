-- Prison Life - Kill All Spoof + God Mode (Android)
-- By Gonxi + GPT, version full

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local Root = Character:WaitForChild("HumanoidRootPart")

local meleeEvent = ReplicatedStorage:FindFirstChild("meleeEvent") or ReplicatedStorage:FindFirstChildWhichIsA("RemoteEvent", true)

-- Botones flotantes
local screenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
screenGui.ResetOnSpawn = false

local function crearBoton(nombre, posicion, callback)
    local boton = Instance.new("TextButton")
    boton.Size = UDim2.new(0, 120, 0, 40)
    boton.Position = posicion
    boton.Text = nombre
    boton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    boton.TextColor3 = Color3.fromRGB(255, 255, 255)
    boton.TextScaled = true
    boton.Draggable = true
    boton.Active = true
    boton.Parent = screenGui
    boton.MouseButton1Click:Connect(callback)
end

-- Kill All Spoof sin moverte
local function killAll()
    local originalPos = Root.CFrame
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local targetPos = player.Character.HumanoidRootPart.Position + Vector3.new(0, 0, 1)
            Root.CFrame = CFrame.new(targetPos)
            task.wait(0.05)
            for i = 1, 40 do
                meleeEvent:FireServer(player)
            end
            task.wait(0.05)
        end
    end
    Root.CFrame = originalPos
end

-- God Mode
local godActive = false

local function godMode()
    godActive = not godActive
    if godActive then
        crearNoti("GOD MODE ACTIVADO")
    else
        crearNoti("GOD MODE DESACTIVADO")
    end
end

RunService.Heartbeat:Connect(function()
    if godActive and Humanoid then
        Humanoid.Health = math.huge
        Humanoid.MaxHealth = math.huge
        if Humanoid.RootPart and Humanoid.RootPart.Velocity.Y < -100 then
            Humanoid.RootPart.Velocity = Vector3.new(0, 0, 0)
        end
    end
end)

-- Notificación rápida
function crearNoti(texto)
    local notif = Instance.new("TextLabel", screenGui)
    notif.Size = UDim2.new(0, 300, 0, 50)
    notif.Position = UDim2.new(0.5, -150, 0, 10)
    notif.BackgroundTransparency = 0.3
    notif.BackgroundColor3 = Color3.new(0, 0, 0)
    notif.Text = texto
    notif.TextColor3 = Color3.new(1, 1, 1)
    notif.TextScaled = true
    game:GetService("Debris"):AddItem(notif, 2)
end

-- Botones
crearBoton("⚔️ Kill All", UDim2.new(0, 50, 0, 150), killAll)
crearBoton("🛡️ God Mode", UDim2.new(0, 50, 0, 200), godMode)