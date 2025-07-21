-- Mod Menu Murder Mystery 2 - Impostores en rojo, buenos en verde, TP Kill y Noclip
-- Autor: ChatGPT

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Variables estado
local noclipEnabled = false
local tpKillEnabled = false

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MM2ModMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 280, 0, 350)
Frame.Position = UDim2.new(0, 10, 0, 50)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui
Frame.Active = true
Frame.Draggable = true

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Title.BorderSizePixel = 0
Title.Text = "🔪 MM2 Mod Menu"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextScaled = true
Title.Parent = Frame

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
MinimizeBtn.Position = UDim2.new(1, -35, 0, 5)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
MinimizeBtn.Text = "—"
MinimizeBtn.TextColor3 = Color3.new(1,1,1)
MinimizeBtn.TextScaled = true
MinimizeBtn.Parent = Frame

local contentVisible = true
MinimizeBtn.MouseButton1Click:Connect(function()
    contentVisible = not contentVisible
    if contentVisible then
        Frame.Size = UDim2.new(0, 280, 0, 350)
        for _, child in pairs(Frame:GetChildren()) do
            if child ~= Title and child ~= MinimizeBtn then
                child.Visible = true
            end
        end
    else
        Frame.Size = UDim2.new(0, 280, 0, 40)
        for _, child in pairs(Frame:GetChildren()) do
            if child ~= Title and child ~= MinimizeBtn then
                child.Visible = false
            end
        end
    end
end)

-- Listado de jugadores
local PlayersList = Instance.new("ScrollingFrame")
PlayersList.Size = UDim2.new(1, -20, 0, 200)
PlayersList.Position = UDim2.new(0, 10, 0, 45)
PlayersList.BackgroundColor3 = Color3.fromRGB(40,40,40)
PlayersList.BorderSizePixel = 0
PlayersList.CanvasSize = UDim2.new(0, 0, 0, 0)
PlayersList.ScrollBarThickness = 6
PlayersList.Parent = Frame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = PlayersList
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 3)

-- Estado de botones
local tpKillBtn = Instance.new("TextButton")
tpKillBtn.Size = UDim2.new(0, 260, 0, 40)
tpKillBtn.Position = UDim2.new(0, 10, 0, 260)
tpKillBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
tpKillBtn.TextColor3 = Color3.new(1, 1, 1)
tpKillBtn.TextScaled = true
tpKillBtn.Text = "TP Kill: OFF"
tpKillBtn.Parent = Frame

local noclipBtn = Instance.new("TextButton")
noclipBtn.Size = UDim2.new(0, 260, 0, 40)
noclipBtn.Position = UDim2.new(0, 10, 0, 310)
noclipBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
noclipBtn.TextColor3 = Color3.new(1, 1, 1)
noclipBtn.TextScaled = true
noclipBtn.Text = "Noclip: OFF"
noclipBtn.Parent = Frame

-- Función para identificar roles en MM2 (depende de nombres en el juego)
-- IMPORTANTE: Ajustar según cómo se llamen los roles en tu servidor si varía.
local function getPlayerRole(player)
    -- En MM2 los roles son: "Murderer", "Sheriff", "Innocent"
    local roleValue = player:FindFirstChild("leaderstats")
    if roleValue and roleValue:FindFirstChild("Role") then
        local role = roleValue.Role.Value
        return role
    end
    -- Si no existe, intenta con variables del personaje o similares (depende del servidor)
    return nil
end

-- Para hacer TP Kill, necesitamos la parte HumanoidRootPart de LocalPlayer y del target
local function tpKill(targetPlayer)
    if not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    local targetHRP = targetPlayer.Character.HumanoidRootPart
    local localChar = LocalPlayer.Character
    if not localChar or not localChar:FindFirstChild("HumanoidRootPart") then return end
    local localHRP = localChar.HumanoidRootPart

    -- Teletransportar local player detrás del objetivo (para atacar)
    localHRP.CFrame = targetHRP.CFrame * CFrame.new(0, 0, 2)
end

-- Noclip
local function setNoclip(state)
    noclipEnabled = state
    if noclipEnabled then
        noclipBtn.Text = "Noclip: ON"
    else
        noclipBtn.Text = "Noclip: OFF"
        -- Restablecer colisiones
        if LocalPlayer.Character then
            for _, part in pairs(LocalPlayer.Character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end

-- Actualizar lista de jugadores
local function updatePlayersList()
    PlayersList:ClearAllChildren()
    local count = 0
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            count = count + 1
            local role = getPlayerRole(plr)
            local color = Color3.new(1,1,1) -- blanco por defecto
            if role == "Murderer" then
                color = Color3.fromRGB(255, 50, 50) -- rojo
            elseif role == "Sheriff" or role == "Innocent" then
                color = Color3.fromRGB(50, 255, 50) -- verde
            end

            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 30)
            btn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
            btn.BorderSizePixel = 0
            btn.TextColor3 = color
            btn.TextScaled = true
            btn.Text = plr.Name
            btn.Parent = PlayersList

            btn.MouseButton1Click:Connect(function()
                if tpKillEnabled and getPlayerRole(LocalPlayer) == "Murderer" then
                    tpKill(plr)
                end
            end)
        end
    end
    PlayersList.CanvasSize = UDim2.new(0, 0, 0, count * 33)
end

-- Conectar eventos para actualizar lista dinámicamente
Players.PlayerAdded:Connect(updatePlayersList)
Players.PlayerRemoving:Connect(updatePlayersList)

-- Botones toggle
tpKillBtn.MouseButton1Click:Connect(function()
    tpKillEnabled = not tpKillEnabled
    if tpKillEnabled then
        tpKillBtn.Text = "TP Kill: ON"
        tpKillBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    else
        tpKillBtn.Text = "TP Kill: OFF"
        tpKillBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    end
end)

noclipBtn.MouseButton1Click:Connect(function()
    setNoclip(not noclipEnabled)
end)

-- Loop noclip (mantener activo)
RunService.Stepped:Connect(function()
    if noclipEnabled and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- Actualizar la lista al inicio y periódicamente
updatePlayersList()
while true do
    wait(5)
    updatePlayersList()
end