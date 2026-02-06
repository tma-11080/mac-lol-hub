-- =================================================================
-- mac lol Hub : ORIGINAL RESTORED FULL SCRIPT
-- =================================================================

local Library = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/tlredz/Library/refs/heads/main/redz-V5-remake/main.luau"
))()

-- Window
local Window = Library:MakeWindow({
    Title = "mac lol Hub : Cool Game",
    SubTitle = "by real_redz",
    ScriptFolder = "redz-library-V5"
})

-- Minimizer
local Minimizer = Window:NewMinimizer({
    KeyCode = Enum.KeyCode.LeftControl
})

local MobileButton = Minimizer:CreateMobileMinimizer({
    Image = "rbxassetid://74521750290358",
    BackgroundColor3 = Color3.fromRGB(0, 0, 0),
    Size = UDim2.fromOffset(50, 50)
})

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 12)
Corner.Parent = MobileButton

-- Variables
local player = game.Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StatsService = game:GetService("Stats")
local playerGui = player:WaitForChild("PlayerGui")
local coreGui = game:GetService("CoreGui")

local fastAttack = false  -- Kill Aura用
local speedValue = 100
local defaultWalkSpeed = 16
local toggleEnabled = false
local espEnabled = false
local currentFontMode = "Default"
local darkMode = false
local effectMono = false

-- ==========================================
-- 提示された攻撃関数（一切変更なし）
-- ==========================================
local function IsEntityAlive(entity)
    if not entity then return false end
    local humanoid = entity:FindFirstChild("Humanoid")
    return humanoid and humanoid.Health > 0
end

local function GetEnemiesInRange(character, range)
    local enemies = game:GetService("Workspace").Enemies:GetChildren()
    local players = game:GetService("Players"):GetPlayers()
    local targets = {}
    local playerPos = character:GetPivot().Position

    for _, enemy in ipairs(enemies) do
        local rootPart = enemy:FindFirstChild("HumanoidRootPart")
        if rootPart and IsEntityAlive(enemy) then
            local distance = (rootPart.Position - playerPos).Magnitude
            if distance <= range then
                table.insert(targets, enemy)
            end
        end
    end

    for _, otherPlayer in ipairs(players) do
        if otherPlayer ~= player and otherPlayer.Character then
            local rootPart = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
            if rootPart and IsEntityAlive(otherPlayer.Character) then
                local distance = (rootPart.Position - playerPos).Magnitude
                if distance <= range then
                    table.insert(targets, otherPlayer.Character)
                    return targets
                end
            end
        end
    end
    return targets
end

local function attackNoCoolDown()
    local character = player.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local equippedWeapon
    for _, item in ipairs(character:GetChildren()) do
        if item:IsA("Tool") then
            equippedWeapon = item
            break
        end
    end
    if not equippedWeapon then return end

    local attackRange = 50
    if hrp:FindFirstChild("Buddha") then
        attackRange = 150
    end

    local enemiesInRange = GetEnemiesInRange(character, attackRange)

    if equippedWeapon:FindFirstChild("LeftClickRemote") then
        local attackCount = 1
        for _, enemy in ipairs(enemiesInRange) do
            local rootPart = enemy:FindFirstChild("HumanoidRootPart")
            if rootPart then
                local direction = (rootPart.Position - character:GetPivot().Position).Unit
                equippedWeapon.LeftClickRemote:FireServer(direction, attackCount)
                attackCount = attackCount + 1
            end
        end
    else
        local targets, mainTarget = {}, nil
        for _, enemy in ipairs(enemiesInRange) do
            if not enemy:GetAttribute("IsBoat") then
                local head = enemy:FindFirstChild("Head")
                if head then
                    table.insert(targets, { enemy, head })
                    mainTarget = head
                end
            end
        end

        if mainTarget then
            local net = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Net")
            local attackEvent = net:WaitForChild("RE/RegisterAttack")
            local hitEvent = net:WaitForChild("RE/RegisterHit")
            pcall(function()
                attackEvent:FireServer(0.05)
                hitEvent:FireServer(mainTarget, targets)
            end)
        end
    end
end

-- ==========================================
-- Font Logic (アイコン保護)
-- ==========================================
local function applyFont(obj)
    if not (obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox")) then return end
    -- アイコン（丸・矢印等）を保護: テキストが丸や特定記号、ライブラリのパスを含む場合は除外
    if obj.Text:match("rbxassetid") or obj.Name:lower():find("icon") or obj.Name:lower():find("image") then return end
    
    if currentFontMode == "Arcade" then
        obj.Font = Enum.Font.Arcade
    elseif currentFontMode == "Minecraft" then
        obj.FontFace = Font.new("rbxassetid://12187371840")
    else
        obj.Font = Enum.Font.SourceSans
    end
end

-- ==========================================
-- Tabs
-- ==========================================

-- 1. test farm Tab
local FarmTab = Window:MakeTab({ Title = "test farm Tab", Icon = "Home" })
FarmTab:AddDropdown({
    Name = "Scarlet Tool",
    MultiSelect = false,
    Options = {"Melee", "Blox fruits", "Sword", "gen"},
    Default = "Melee",
    Callback = function(Value) print("選択:", Value) end
})

-- 2. Visual Tab
local VisualTab = Window:MakeTab({ Title = "Visual", Icon = "eye" })
VisualTab:AddToggle({
    Name = "Enemy ESP",
    Default = false,
    Callback = function(Value) espEnabled = Value end
})

-- 3. Font Tab
local FontTab = Window:MakeTab({ Title = "Font", Icon = "pencil" })
FontTab:AddToggle({
    Name = "Arcade font",
    Default = false,
    Callback = function(Value)
        currentFontMode = Value and "Arcade" or "Default"
        for _, v in pairs(game:GetDescendants()) do pcall(function() applyFont(v) end) end
    end
})
FontTab:AddToggle({
    Name = "Minecraft font",
    Default = false,
    Callback = function(Value)
        currentFontMode = Value and "Minecraft" or "Default"
        for _, v in pairs(game:GetDescendants()) do pcall(function() applyFont(v) end) end
    end
})

-- 4. misc Tab
local MiscTab = Window:MakeTab({ Title = "misc Tab", Icon = "settings" })
MiscTab:AddToggle({
    Name = "Fast attack (kill aura)",
    Default = false,
    Callback = function(Value) fastAttack = Value end
})

local statsGui = nil
MiscTab:AddToggle({
    Name = "Show FPS / Ping",
    Default = false,
    Callback = function(Value)
        if Value then
            statsGui = Instance.new("ScreenGui", playerGui)
            local label = Instance.new("TextLabel", statsGui)
            label.Size, label.Position, label.BackgroundTransparency = UDim2.new(0, 200, 0, 30), UDim2.new(0, 20, 0, 20), 1
            label.TextColor3, label.Font, label.TextSize = Color3.new(1, 1, 1), Enum.Font.Code, 16
            label.TextXAlignment, label.Active, label.Draggable = Enum.TextXAlignment.Left, true, true
            task.spawn(function()
                local fps, fCount, lastS = 0, 0, tick()
                local conn = RunService.RenderStepped:Connect(function() fCount = fCount + 1 end)
                while statsGui do
                    local now = tick()
                    if now - lastS >= 1 then fps, fCount, lastS = fCount, 0, now end
                    local ping = math.floor(StatsService.PerformanceStats.Ping:GetValue())
                    label.Text = string.format("FPS: %d  Ping: %d", fps, ping)
                    label.TextColor3 = Color3.fromHSV((now % 5) / 5, 1, 1)
                    task.wait(0.1)
                end
                conn:Disconnect()
            end)
        elseif statsGui then statsGui:Destroy() statsGui = nil end
    end
})

MiscTab:AddButton({
    Name = "Shader",
    Callback = function() loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-pshade-ultimate-25505"))() end
})

MiscTab:AddToggle({
    Name = "Speed(歩く)",
    Default = false,
    Callback = function(Value) toggleEnabled = Value end
})

MiscTab:AddSlider({
    Name = "Speed Slider",
    Min = 1, Max = 300, Increment = 1, Default = 100,
    Callback = function(Value) speedValue = Value end
})

-- 5. Misc 2 Tab
local Misc2Tab = Window:MakeTab({ Title = "Misc 2", Icon = "plus" })
Misc2Tab:AddToggle({
    Name = "Dark Mode",
    Default = false,
    Callback = function(Value) darkMode = Value end
})
Misc2Tab:AddToggle({
    Name = "Effect dark&white",
    Default = false,
    Callback = function(Value) effectMono = Value end
})

-- ==========================================
-- Main Loops
-- ==========================================
RunService.RenderStepped:Connect(function()
    -- Speed
    if toggleEnabled and player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = speedValue
    end
    -- Kill Aura
    if fastAttack then
        attackNoCoolDown()
    end
    -- Dark Mode
    if darkMode then
        for _, v in pairs(coreGui:GetDescendants()) do
            if v:IsA("Frame") then v.BackgroundColor3 = Color3.fromRGB(30,30,30) end
        end
    end
    -- ESP
    if espEnabled then
        for _, e in pairs(workspace.Enemies:GetChildren()) do
            if e:FindFirstChild("HumanoidRootPart") and not e.HumanoidRootPart:FindFirstChild("Highlight") then
                Instance.new("Highlight", e.HumanoidRootPart).FillColor = Color3.new(1,0,0)
            end
        end
    end
end)

workspace.DescendantAdded:Connect(function(obj)
    if effectMono and (obj:IsA("ParticleEmitter") or obj:IsA("Trail")) then
        obj.Color = ColorSequence.new(Color3.new(0,0,0), Color3.new(1,1,1))
    end
end)
