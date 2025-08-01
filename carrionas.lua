--// Servicios
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

--// Variables
local ParryActive = false

--// Remoto para parry (asegúrate que el nombre sea correcto según Blade Ball)
local ParryRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("ParryButtonPress")

--// Crear GUI (botón flotante)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoParryGui"
ScreenGui.Parent = Player:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 100, 0, 40)
Frame.Position = UDim2.new(0, 10, 0.5, -20)
Frame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui
Frame.Active = true
Frame.Draggable = true

local TextButton = Instance.new("TextButton")
TextButton.Size = UDim2.new(1, 0, 1, 0)
TextButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
TextButton.BorderSizePixel = 0
TextButton.Text = "Auto Parry: OFF"
TextButton.TextColor3 = Color3.fromRGB(255, 255, 255)
TextButton.Font = Enum.Font.SourceSansBold
TextButton.TextSize = 18
TextButton.Parent = Frame

--// Función para activar/desactivar auto parry
TextButton.MouseButton1Click:Connect(function()
    ParryActive = not ParryActive
    if ParryActive then
        TextButton.Text = "Auto Parry: ON"
    else
        TextButton.Text = "Auto Parry: OFF"
    end
end)

--// Función para hacer parry
local function DoParry()
    if ParryRemote and ParryActive then
        ParryRemote:FireServer()
    end
end

--// Detección de pelota y activación automática
local BallsFolder = workspace:WaitForChild("Balls")

BallsFolder.ChildAdded:Connect(function(ball)
    if not ball:IsA("BasePart") then return end

    local lastPos = ball.Position
    local lastTick = tick()

    ball:GetPropertyChangedSignal("Position"):Connect(function()
        if not ParryActive then return end

        local currentPos = ball.Position
        local velocity = (lastPos - currentPos).Magnitude / (tick() - lastTick)
        lastPos = currentPos
        lastTick = tick()

        -- Distancia desde la pelota a la cámara (jugador)
        local distance = (currentPos - workspace.CurrentCamera.CFrame.Position).Magnitude

        -- Parámetros para detectar cuándo parry
        if distance < 20 and velocity > 5 then
            DoParry()
        end
    end)
end)

--// También puedes agregar un loop para detectar pelotas que ya están en el mapa al empezar el script
for _, ball in pairs(BallsFolder:GetChildren()) do
    if ball:IsA("BasePart") then
        ball:GetPropertyChangedSignal("Position"):Connect(function()
            if not ParryActive then return end

            local distance = (ball.Position - workspace.CurrentCamera.CFrame.Position).Magnitude
            if distance < 20 then
                DoParry()
            end
        end)
    end
end