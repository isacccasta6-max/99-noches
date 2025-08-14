-- ====================================
-- Script 99 Nights in the Forest con GUI y Anti-Cheat Bypass
-- ====================================

local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Estados
local killAura = false
local autoRecoger = false
local autoFarm = false
local espEnabled = false
local hambreInfinitaOn = false
local destinoPersonalizado = nil
local modoSeleccionDestino = false

-- Filtros de recolección
local recogerRecursos = true
local recogerPelts = true
local recogerScrap = true
local recogerCuracion = true

-- Listas exactas del juego
local ENEMIGOS = {
    "Wolves", "Alpha Wolves", "Cultists", "Bears",
    "Polar Bears", "Aliens", "The Deer"
}

local OBJETOS = {
    "Logs", "Chair", "Coal", "Oil Barrel", "Biofuel",
    "Wolf Pelt", "Alpha Wolf Pelt", "Bear Pelt",
    "Arctic Fox Pelt", "Polar Bear Pelt",
    "Bolt", "Sheet Metal", "Broken Fan", "Mossy Coin",
    "Cultist Gem", "Bandage", "Medkit", "Cake"
}

-- ====================================
-- GUI
-- ====================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.IgnoreGuiInset = true
ScreenGui.ResetOnSpawn = false

-- Frame principal
local frame = Instance.new("Frame", ScreenGui)
frame.Size = UDim2.new(0, 200, 0, 300)
frame.Position = UDim2.new(0.05, 0, 0.2, 0)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
frame.Active = true
frame.Draggable = true

-- Función para crear botones
local function crearBoton(texto, posY, accion)
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(1, 0, 0, 25)
    btn.Position = UDim2.new(0, 0, 0, posY)
    btn.Text = texto
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.MouseButton1Click:Connect(accion)
    return btn
end

-- Botones principales
crearBoton("Kill Aura", 0, function() killAura = not killAura end)
crearBoton("Auto Recolectar", 30, function() autoRecoger = not autoRecoger end)
crearBoton("Auto Farm AFK", 60, function() autoFarm = not autoFarm end)
crearBoton("ESP", 90, function() espEnabled = not espEnabled end)
crearBoton("Hambre Infinita", 120, function() hambreInfinitaOn = not hambreInfinitaOn end)
crearBoton("Elegir destino", 150, function() modoSeleccionDestino = true end)

-- Botones de filtros
crearBoton("Recursos ON/OFF", 180, function() recogerRecursos = not recogerRecursos end)
crearBoton("Pelts ON/OFF", 210, function() recogerPelts = not recogerPelts end)
crearBoton("Scrap ON/OFF", 240, function() recogerScrap = not recogerScrap end)
crearBoton("Curación ON/OFF", 270, function() recogerCuracion = not recogerCuracion end)

-- Log de acción
local logLabel = Instance.new("TextLabel", ScreenGui)
logLabel.Size = UDim2.new(0, 400, 0, 25)
logLabel.Position = UDim2.new(0.5, -200, 0.05, 0)
logLabel.BackgroundTransparency = 0.5
logLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
logLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
logLabel.TextScaled = true
logLabel.Text = "Esperando acción..."

-- ====================================
-- FUNCIONES
-- ====================================

-- Kill Aura
local function activarKillAura()
    for _, enemigo in pairs(workspace:GetDescendants()) do
        if enemigo:IsA("Model") and enemigo:FindFirstChild("Humanoid") and enemigo ~= player.Character then
            if table.find(ENEMIGOS, enemigo.Name) then
                local root = enemigo:FindFirstChild("HumanoidRootPart")
                if root and (root.Position - player.Character.HumanoidRootPart.Position).Magnitude < 15 then
                    for _, tool in pairs(player.Character:GetChildren()) do
                        if tool:IsA("Tool") then
                            tool:Activate()
                        end
                    end
                end
            end
        end
    end
end

-- Recolectar con filtros y destino
local function recogerYEnviar()
    for _, item in pairs(workspace:GetDescendants()) do
        if item:IsA("Part") and table.find(OBJETOS, item.Name) then
            if not (recogerRecursos or recogerPelts or recogerScrap or recogerCuracion) then return end
            
            if table.find({"Logs","Chair","Coal","Oil Barrel","Biofuel"}, item.Name) and not recogerRecursos then continue end
            if table.find({"Wolf Pelt","Alpha Wolf Pelt","Bear Pelt","Arctic Fox Pelt","Polar Bear Pelt"}, item.Name) and not recogerPelts then continue end
            if table.find({"Bolt","Sheet Metal","Broken Fan","Mossy Coin","Cultist Gem"}, item.Name) and not recogerScrap then continue end
            if table.find({"Bandage","Medkit","Cake"}, item.Name) and not recogerCuracion then continue end

            logLabel.Text = "Recogiendo: " .. item.Name

            firetouchinterest(player.Character.HumanoidRootPart, item, 0)
            firetouchinterest(player.Character.HumanoidRootPart, item, 1)

            if destinoPersonalizado then
                item.CFrame = CFrame.new(destinoPersonalizado)
            end
        end
    end
end

-- Auto Farm
local function farmAFK()
    for _, tool in pairs(player.Character:GetChildren()) do
        if tool:IsA("Tool") then
            tool:Activate()
        end
    end
end

-- ESP
local function activarESP()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (table.find(OBJETOS, obj.Name) or table.find(ENEMIGOS, obj.Name)) then
            if not obj:FindFirstChild("ESPBox") then
                local box = Instance.new("BoxHandleAdornment", obj)
                box.Name = "ESPBox"
                box.Adornee = obj
                box.Size = obj.Size + Vector3.new(0.1, 0.1, 0.1)
                box.Color3 = table.find(ENEMIGOS, obj.Name) and Color3.new(1, 0, 0) or Color3.new(0, 1, 0)
                box.AlwaysOnTop = true
            end
        end
    end
end

-- Hambre infinita
local function hambreInfinita()
    local stats = player:FindFirstChild("Stats") or player:FindFirstChild("leaderstats") or player:FindFirstChild("PlayerStats")
    if stats then
        local hambre = stats:FindFirstChild("Hunger") or stats:FindFirstChild("Hambre")
        if hambre and hambre:IsA("NumberValue") then
            hambre.Value = 100
        end
    end
end

-- Guardar destino
mouse.Button1Down:Connect(function()
    if modoSeleccionDestino then
        destinoPersonalizado = mouse.Hit.p
        modoSeleccionDestino = false
        logLabel.Text = "Destino configurado en: " ..
            math.floor(destinoPersonalizado.X) .. ", " ..
            math.floor(destinoPersonalizado.Y) .. ", " ..
            math.floor(destinoPersonalizado.Z)
    end
end)

-- ====================================
-- Anti-Cheat Bypass
-- ====================================
ScreenGui.Parent = game:GetService("CoreGui") -- evita detección en PlayerGui

-- Hook de RemoteEvents para suavizar TP bruscos
for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
    if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
        local oldFire = obj.FireServer
        obj.FireServer = function(self, ...)
            local args = {...}
            if typeof(args[1]) == "Vector3" then
                local dist = (args[1] - player.Character.HumanoidRootPart.Position).Magnitude
                if dist > 20 then
                    args[1] = player.Character.HumanoidRootPart.Position + (args[1] - player.Character.HumanoidRootPart.Position).Unit * 20
                end
            end
            return oldFire(self, unpack(args))
        end
    end
end

-- ====================================
-- Bucle principal
-- ====================================
RunService.RenderStepped:Connect(function()
    if killAura then activarKillAura() end
    if autoRecoger then recogerYEnviar() end
    if autoFarm then farmAFK() end
    if espEnabled then activarESP() end
    if hambreInfinitaOn then hambreInfinita() end
end)
