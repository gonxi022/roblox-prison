-- Jailbreak Kill All Mod Menú Android KRNL
-- 2 Botones flotantes Kill All distintos y funcionales

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local UIS = UserInputService
local Player = LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- GUI flotante minimalista
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
ScreenGui.Name = "JailbreakKillAllMenu"

local function createButton(name, position)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0,120,0,40)
    btn.Position = position
    btn.BackgroundColor3 = Color3.fromRGB(30,30,30)
    btn.BorderSizePixel = 0
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Text = name
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 16
    btn.AnchorPoint = Vector2.new(0,0)
    btn.Active = true
    btn.Draggable = true
    btn.Selectable = true
    btn.AutoButtonColor = true
    btn.Parent = ScreenGui
    return btn
end

local KillAllMethod1_Enabled = false
local KillAllMethod2_Enabled = false

-- Método 1: Matar con daño directo a Humanoide (health = 0)
local function KillAllMethod1()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Humanoid") then
            local hum = plr.Character.Humanoid
            if hum.Health > 0 then
                hum.Health = 0
            end
        end
    end
end

-- Método 2: Simular disparos con evento remoto (ejemplo genérico para Jailbreak)
local function KillAllMethod2()
    local repStorage = game:GetService("ReplicatedStorage")
    local shootEvent = repStorage:FindFirstChild("ShootEvent") or repStorage:FindFirstChild("Shoot")
    if not shootEvent then return end

    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local targetPos = plr.Character.HumanoidRootPart.Position
            -- Enviar evento de disparo al servidor hacia la posición del enemigo
            shootEvent:FireServer(targetPos)
        end
    end
end

-- Loop KillAll métodos
spawn(function()
    while true do
        if KillAllMethod1_Enabled then KillAllMethod1() end
        if KillAllMethod2_Enabled then KillAllMethod2() end
        wait(1.5)
    end
end)

-- Crear botones
local btn1 = createButton("Kill All Método 1", UDim2.new(0, 10, 0.3, 0))
local btn2 = createButton("Kill All Método 2", UDim2.new(0, 10, 0.4, 0))

-- Toggle botones
btn1.MouseButton1Click:Connect(function()
    KillAllMethod1_Enabled = not KillAllMethod1_Enabled
    btn1.BackgroundColor3 = KillAllMethod1_Enabled and Color3.fromRGB(0,170,0) or Color3.fromRGB(30,30,30)
end)

btn2.MouseButton1Click:Connect(function()
    KillAllMethod2_Enabled = not KillAllMethod2_Enabled
    btn2.BackgroundColor3 = KillAllMethod2_Enabled and Color3.fromRGB(0,170,0) or Color3.fromRGB(30,30,30)
end)

-- Mensaje inicial
print("Jailbreak Kill All Mod Menú cargado. Usa los botones para activar/desactivar.")