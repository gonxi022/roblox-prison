local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local oldNamecall = nil

-- Filtro inteligente
local function isUseful(remote, method)
    local name = remote.Name:lower()
    return remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction")
       and (name:find("hit") or name:find("parry") or name:find("attack") or name:find("ability") or name:find("event"))
end

oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    
    if not checkcaller() and isUseful(self, method) then
        print("🛰️ Remote detectado:")
        print("🧩 Nombre:", self:GetFullName())
        print("📦 Método:", method)
        print("📤 Argumentos:")
        for i, v in ipairs(args) do
            print("   [" .. i .. "]", typeof(v), v)
        end
        print("-----------------------------")
    end

    return oldNamecall(self, unpack(args))
end)

print("✅ Remote Spy filtrado activado (solo remotes útiles mostrados)")