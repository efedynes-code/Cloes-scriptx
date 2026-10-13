-- ============================================
-- CLOES MENU v15.0 | HACKER EDITION
-- By Cloes
-- ============================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "CLOES MENU v15 | HACKER EDITION",
   LoadingTitle = "Cloes yükleniyor...",
   LoadingSubtitle = "By Cloes",
   ConfigurationSaving = {Enabled = true, FolderName = "CloesV15", FileName = "CloesHack"},
   KeySystem = false
})

local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local humanoid = char:WaitForChild("Humanoid")
local root = char:WaitForChild("HumanoidRootPart")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local camera = workspace.CurrentCamera
local lighting = game:GetService("Lighting")
local rs = game:GetService("ReplicatedStorage")
local vim = game:GetService("VirtualInputManager")
local plrs = game:GetService("Players")

player.CharacterAdded:Connect(function(c)
    char = c
    humanoid = c:WaitForChild("Humanoid")
    root = c:WaitForChild("HumanoidRootPart")
end)

local function safeGetRawMeta(t)
    local ok, mt = pcall(function() return getrawmetatable(t) end)
    if ok and mt then return mt, true end
    return getmetatable(t), false
end

local function findRemoteEvent(...)
    local names = {...}
    local found = {}
    for _, container in ipairs({rs, workspace, game:GetService("ServerScriptService")}) do
        if container then
            for _, v in pairs(container:GetDescendants()) do
                if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") or v:IsA("BindableEvent") then
                    local lower = v.Name:lower()
                    for _, n in ipairs(names) do
                        if lower:find(n:lower()) then table.insert(found, v); break end
                    end
                end
            end
        end
    end
    return found
end

local function fireAll(events, ...)
    for _, e in ipairs(events) do
        pcall(function()
            if e:IsA("RemoteEvent") then e:FireServer(...)
            elseif e:IsA("RemoteFunction") then e:InvokeServer(...)
            elseif e:IsA("BindableEvent") then e:Fire(...) end
        end)
    end
end

local TeleportUtil = {}
function TeleportUtil.getRoot()
    return root or (char and char:FindFirstChild("HumanoidRootPart"))
end
local function cleanName(s) return s:lower():gsub("[%s_%-%.%,]","") end

function TeleportUtil.findPartByName(keyword)
    keyword = cleanName(keyword)
    local best, bestDist = nil, math.huge
    local r = TeleportUtil.getRoot()
    if not r then return nil end
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and not v:FindFirstAncestorOfClass("Tool") then
            local n = cleanName(v.Name)
            if n:find(keyword) then
                local d = (v.Position - r.Position).Magnitude
                if d < bestDist then bestDist = d; best = v end
            end
        end
    end
    return best
end

function TeleportUtil.findModelByName(keyword)
    keyword = cleanName(keyword)
    local best, bestDist = nil, math.huge
    local r = TeleportUtil.getRoot()
    if not r then return nil end
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") then
            local n = cleanName(v.Name)
            if n:find(keyword) then
                local part = v:FindFirstChildWhichIsA("BasePart") or v.PrimaryPart
                if part then
                    local d = (part.Position - r.Position).Magnitude
                    if d < bestDist then bestDist = d; best = part end
                end
            end
        end
    end
    return best
end

function TeleportUtil.teleportTo(keyword, yOffset)
    yOffset = yOffset or 5
    local r = TeleportUtil.getRoot()
    if not r then return false end
    local part = TeleportUtil.findPartByName(keyword) or TeleportUtil.findModelByName(keyword)
    if part then
        r.CFrame = CFrame.new(part.Position + Vector3.new(0, yOffset, 0))
        return true
    end
    return false
end

-- STEALTH
local StealthTab = Window:CreateTab("🛡️ Stealth", 4483362458)
StealthTab:CreateToggle({Name="Anti-Cheat Bypass",CurrentValue=false,Flag="ACB",Callback=function(v)
    if v then
        local mt, isRaw = safeGetRawMeta(game)
        if mt and mt.__namecall then
            local old = mt.__namecall
            if isRaw then pcall(function() setreadonly(mt, false) end) end
            mt.__namecall = newcclosure(function(s, ...)
                local m = getnamecallmethod()
                if m == "Kick" or m == "Ban" then return nil end
                return old(s, ...)
            end)
            if isRaw then pcall(function() setreadonly(mt, true) end) end
            Rayfield:Notify({Title="Stealth", Content="Bypass aktif.", Duration=3})
        end
    end
end})
StealthTab:CreateToggle({Name="Speed Randomizer",CurrentValue=false,Flag="SR",Callback=function(v)
    if v then task.spawn(function() while v do task.wait(2); if humanoid and humanoid.WalkSpeed > 16 then humanoid.WalkSpeed = humanoid.WalkSpeed + math.random(-3,3) end end end) end
end})
StealthTab:CreateToggle({Name="Anti-Void",CurrentValue=false,Flag="AV",Callback=function(v)
    if v then RunService.Stepped:Connect(function() local r = TeleportUtil.getRoot(); if r and r.Position.Y < -50 then r.CFrame = CFrame.new(0,50,0) end end) end
end})
StealthTab:CreateButton({Name="Remove Kick Events",Callback=function()
    for _, x in pairs(rs:GetDescendants()) do if x:IsA("RemoteEvent") and (x.Name:lower():find("kick") or x.Name:lower():find("ban")) then pcall(function() x:Destroy() end) end end
end})
StealthTab:CreateButton({Name="Debug Listele",Callback=function()
    for _, x in pairs(workspace:GetChildren()) do print(x.ClassName.." | "..x.Name) end
    for _, x in pairs(rs:GetChildren()) do print(x.ClassName.." | "..x.Name) end
end})

-- UNIVERSAL
local UniTab = Window:CreateTab("🌐 Universal", 4483362458)
UniTab:CreateSection("Fly")
local flySpeed = 50
local flying = false
local flyConn, flyBG, flyBV
UniTab:CreateInput({Name="Fly Hızı",CurrentValue="50",PlaceholderText="150",RemoveTextAfterFocusLost=false,Flag="FI",
    Callback=function(t) local n = tonumber(t); if n then flySpeed = n end end})
UniTab:CreateToggle({Name="Fly (Mobile+PC)",CurrentValue=false,Flag="FLY",Callback=function(v)
    flying = v
    if v then
        if not root then return end
        flyBG = Instance.new("BodyGyro", root); flyBG.P = 9e4; flyBG.maxTorque = Vector3.new(9e9,9e9,9e9); flyBG.cframe = root.CFrame
        flyBV = Instance.new("BodyVelocity", root); flyBV.velocity = Vector3.new(0,0,0); flyBV.maxForce = Vector3.new(9e9,9e9,9e9)
        local cm; pcall(function() cm = require(player.PlayerScripts:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"):WaitForChild("ControlModule")) end)
        flyConn = RunService.RenderStepped:Connect(function()
            if not flying or not root then return end
            local c = camera.CFrame; local d = Vector3.new(0,0,0)
            if UIS:IsKeyDown(Enum.KeyCode.W) then d += c.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.S) then d -= c.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.A) then d -= c.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.D) then d += c.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.Space) then d += Vector3.new(0,1,0) end
            if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then d -= Vector3.new(0,1,0) end
            if cm then local m = cm:GetMoveVector(); if m.Magnitude > 0 then d += c.LookVector * m.Z; d += c.RightVector * m.X end end
            if d.Magnitude > 0 then flyBV.velocity = d.Unit * flySpeed else flyBV.velocity = Vector3.new(0,0,0) end
            flyBG.cframe = c
        end)
    else
        if flyConn then flyConn:Disconnect() end
        if flyBG then flyBG:Destroy() end
        if flyBV then flyBV:Destroy() end
    end
end})
UniTab:CreateSection("Movement")
UniTab:CreateSlider({Name="WalkSpeed",Range={16,500},Increment=1,Suffix="Speed",CurrentValue=16,Flag="US",
    Callback=function(v) if humanoid then humanoid.WalkSpeed = v end end})
UniTab:CreateSlider({Name="JumpPower",Range={50,500},Increment=1,Suffix="JP",CurrentValue=50,Flag="UJ",
    Callback=function(v) if humanoid then humanoid.UseJumpPower = true; humanoid.JumpPower = v end end})
UniTab:CreateToggle({Name="ESP",CurrentValue=false,Flag="UE",Callback=function(v)
    if v then
        for _, p in pairs(plrs:GetPlayers()) do
            if p ~= player and p.Character then
                local h = Instance.new("Highlight"); h.Name = "CE"; h.Parent = p.Character
                h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                h.FillColor = Color3.fromRGB(255,0,0); h.OutlineColor = Color3.fromRGB(255,255,255); h.FillTransparency = 0.5
            end
        end
    else
        for _, p in pairs(plrs:GetPlayers()) do
            if p.Character then local e = p.Character:FindFirstChild("CE"); if e then e:Destroy() end end
        end
    end
end})
UniTab:CreateToggle({Name="Fullbright",CurrentValue=false,Flag="FB",Callback=function(v)
    if v then lighting.Ambient = Color3.fromRGB(255,255,255); lighting.Brightness = 2; lighting.OutdoorAmbient = Color3.fromRGB(255,255,255)
    else lighting.Ambient = Color3.fromRGB(0,0,0); lighting.Brightness = 1; lighting.OutdoorAmbient = Color3.fromRGB(0,0,0) end
end})
UniTab:CreateSection("Fling")
local flingSpeed = 200
UniTab:CreateInput({Name="Fling Hızı",CurrentValue="200",PlaceholderText="300",RemoveTextAfterFocusLost=false,Flag="FSP",
    Callback=function(t) local n = tonumber(t); if n then flingSpeed = n end end})
UniTab:CreateButton({Name="🔥 FLING ALL",Callback=function()
    task.spawn(function()
        local r = TeleportUtil.getRoot(); if not r then return end
        for _, p in pairs(plrs:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local t = p.Character.HumanoidRootPart
                r.CFrame = t.CFrame + Vector3.new(0,2,0); task.wait(0.05)
                local bv = Instance.new("BodyVelocity", r); bv.MaxForce = Vector3.new(9e9,9e9,9e9)
                bv.Velocity = Vector3.new(math.random(-flingSpeed, flingSpeed), math.random(50, flingSpeed), math.random(-flingSpeed, flingSpeed))
                local bg = Instance.new("BodyGyro", r); bg.P = 9e4; bg.MaxTorque = Vector3.new(9e9,9e9,9e9); bg.CFrame = CFrame.new(r.Position, t.Position)
                task.wait(0.3); bv:Destroy(); bg:Destroy()
            end
        end
        Rayfield:Notify({Title="Fling", Content="Herkes fırlatıldı.", Duration=3})
    end)
end})

-- MM2
local MM2Tab = Window:CreateTab("🔪 MM2", 4483362458)
MM2Tab:CreateToggle({Name="Gun ESP",CurrentValue=false,Flag="GE",Callback=function(v)
    if v then task.spawn(function() while v do task.wait(0.3)
        for _, p in pairs(plrs:GetPlayers()) do
            if p ~= player and p.Character then
                local has = p.Character:FindFirstChild("Gun") or p.Character:FindFirstChild("Revolver") or (p.Backpack and (p.Backpack:FindFirstChild("Gun") or p.Backpack:FindFirstChild("Revolver")))
                local ex = p.Character:FindFirstChild("CGE")
                if has and not ex then
                    local h = Instance.new("Highlight"); h.Name = "CGE"; h.Parent = p.Character
                    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    h.FillColor = Color3.fromRGB(255,230,0); h.OutlineColor = Color3.fromRGB(255,255,0)
                elseif not has and ex then ex:Destroy() end
            end
        end
    end end) end
end})
MM2Tab:CreateToggle({Name="Auto Pickup Gun",CurrentValue=false,Flag="AP",Callback=function(v)
    if v then task.spawn(function() while v do task.wait(0.2)
        for _, x in pairs(workspace:GetDescendants()) do
            if (x:IsA("BasePart") or x:IsA("MeshPart")) and (x.Name:lower():find("gun") or x.Name:lower():find("revolver")) then
                if not x:FindFirstAncestorOfClass("Tool") then
                    local r = TeleportUtil.getRoot()
                    if r and (x.Position - r.Position).Magnitude < 300 then r.CFrame = x.CFrame + Vector3.new(0,3,0); task.wait(0.15) end
                end
            end
        end
    end end) end
end})
MM2Tab:CreateToggle({Name="Auto Shout Murder + Aimbot",CurrentValue=false,Flag="ASM",Callback=function(v)
    if v then task.spawn(function() while v do task.wait(0.2)
        local isS = char:FindFirstChild("Gun") or char:FindFirstChild("Revolver") or (player.Backpack and (player.Backpack:FindFirstChild("Gun") or player.Backpack:FindFirstChild("Revolver")))
        if isS then
            local m = nil
            for _, p in pairs(plrs:GetPlayers()) do
                if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and (p.Character:FindFirstChild("Knife") or (p.Backpack and p.Backpack:FindFirstChild("Knife"))) then m = p; break end
            end
            if m and m.Character and m.Character:FindFirstChild("HumanoidRootPart") then
                local r = TeleportUtil.getRoot(); local t = m.Character.HumanoidRootPart
                if r then
                    r.CFrame = t.CFrame * CFrame.new(0,8,5)
                    local bv = Instance.new("BodyVelocity", r); bv.MaxForce = Vector3.new(9e9,9e9,9e9); bv.Velocity = Vector3.new(0,0,0); bv.P = 1250
                    camera.CFrame = CFrame.new(camera.CFrame.Position, t.Position)
                    local tl = char:FindFirstChildOfClass("Tool"); if tl then pcall(function() tl:Activate() end) end
                    task.wait(0.1); bv:Destroy()
                end
            end
        end
    end end) end
end})
MM2Tab:CreateToggle({Name="Wall Shots",CurrentValue=false,Flag="WS",Callback=function(v)
    if v then task.spawn(function() while v do task.wait(0.15)
        if char:FindFirstChild("Gun") or char:FindFirstChild("Revolver") then
            for _, p in pairs(plrs:GetPlayers()) do
                if p ~= player and p.Character and (p.Character:FindFirstChild("Knife") or (p.Backpack and p.Backpack:FindFirstChild("Knife"))) and p.Character:FindFirstChild("Head") then
                    camera.CFrame = CFrame.new(camera.CFrame.Position, p.Character.Head.Position)
                    local t = char:FindFirstChildOfClass("Tool"); if t then pcall(function() t:Activate() end) end
                    break
                end
            end
        end
    end end) end
end})
MM2Tab:CreateButton({Name="Current Map",Callback=function() TeleportUtil.teleportTo("teleport") or TeleportUtil.teleportTo("map") end})
MM2Tab:CreateButton({Name="Lobby",Callback=function()
    if not TeleportUtil.teleportTo("lobby") then
        for _, x in pairs(workspace:GetDescendants()) do
            if x:IsA("SpawnLocation") then local r = TeleportUtil.getRoot(); if r then r.CFrame = x.CFrame + Vector3.new(0,5,0); break end end
        end
    end
end})
MM2Tab:CreateButton({Name="Gun'a Işınlan",Callback=function() TeleportUtil.teleportTo("gun",3) or TeleportUtil.teleportTo("revolver",3) end})

-- ARSENAL
local ArsenalTab = Window:CreateTab("🔫 Arsenal", 4483362458)
local arsenalAimbot = false
ArsenalTab:CreateToggle({Name="Silent Aimbot",CurrentValue=false,Flag="AA",Callback=function(v) arsenalAimbot = v end})
local mt2, isRaw2 = safeGetRawMeta(game)
if mt2 then
    local oi = mt2.__index
    if isRaw2 then pcall(function() setreadonly(mt2, false) end) end
    mt2.__index = newcclosure(function(s, k)
        if arsenalAimbot and k == "Hit" and s == player:GetMouse() then
            local c, d = nil, math.huge
            for _, p in pairs(plrs:GetPlayers()) do
                if p ~= player and p.Character and p.Character:FindFirstChild("Head") then
                    local dd = (p.Character.Head.Position - camera.CFrame.Position).Magnitude
                    if dd < d then d = dd; c = p.Character.Head end
                end
            end
            if c then return CFrame.new(c.Position) end
        end
        return oi(s, k)
    end)
    if isRaw2 then pcall(function() setreadonly(mt2, true) end) end
end
ArsenalTab:CreateToggle({Name="Rapid Fire",CurrentValue=false,Flag="ARF",Callback=function(v)
    if v then task.spawn(function() while v do task.wait(0.03); local t = char:FindFirstChildOfClass("Tool"); if t then pcall(function() t:Activate() end) end end end) end
end})
ArsenalTab:CreateSlider({Name="WalkSpeed",Range={16,200},Increment=1,Suffix="Speed",CurrentValue=16,Flag="AS",
    Callback=function(v) if humanoid then humanoid.WalkSpeed = v end end})

-- DA HOOD
local DaHoodTab = Window:CreateTab("🏙️ Da Hood", 4483362458)
DaHoodTab:CreateSlider({Name="WalkSpeed",Range={16,200},Increment=1,Suffix="Speed",CurrentValue=16,Flag="DS",
    Callback=function(v) if humanoid then humanoid.WalkSpeed = v end end})
DaHoodTab:CreateToggle({Name="Infinite Jump",CurrentValue=false,Flag="IJ",Callback=function(v) if v then UIS.JumpRequest:Connect(function() humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end) end end})
local noclipOn = false
DaHoodTab:CreateToggle({Name="Noclip",CurrentValue=false,Flag="NC",Callback=function(v)
    noclipOn = v
    if v then RunService.Stepped:Connect(function() if noclipOn and char then for _, x in pairs(char:GetDescendants()) do if x:IsA("BasePart") then x.CanCollide = false end end end end) end
end})
DaHoodTab:CreateToggle({Name="Kill Aura",CurrentValue=false,Flag="KA",Callback=function(v)
    if v then task.spawn(function() while v do task.wait(0.2)
        local r = TeleportUtil.getRoot()
        if r then for _, p in pairs(plrs:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and (p.Character.HumanoidRootPart.Position - r.Position).Magnitude < 20 then
                local t = char:FindFirstChildOfClass("Tool"); if t then pcall(function() t:Activate() end) end
            end
        end end
    end end) end
end})
DaHoodTab:CreateButton({Name="Bank'a Işınlan",Callback=function() TeleportUtil.teleportTo("bank",5) end})

-- BLOX FRUITS
local BloxTab = Window:CreateTab("🍇 Blox Fruits", 4483362458)
local bloxIslands = {"Starter Island","Marine Fortress","Middle Town","Jungle","Pirate Village","Desert","Frozen Village","Colosseum","Prison","Magma Village","Underwater City","Fountain City","Skylands","Upper Skylands","Cursed Ship","Ice Castle","Forgotten Island","Mansion","Haunted Castle","Hydra Island","Great Tree","Castle on the Sea","Floating Turtle","Kingdom of Rose"}
local selectedIsland = "Starter Island"
BloxTab:CreateDropdown({Name="Ada Seç ▼",Options=bloxIslands,CurrentOption={"Starter Island"},MultipleOptions=false,Flag="BI",
    Callback=function(o) selectedIsland = type(o)=="table" and o[1] or o end})
BloxTab:CreateToggle({Name="Auto Farm",CurrentValue=false,Flag="BF",Callback=function(v)
    if v then task.spawn(function() while v do task.wait(0.4)
        local r = TeleportUtil.getRoot()
        if r then for _, x in pairs(workspace:GetDescendants()) do
            if x:IsA("Model") and x:FindFirstChild("Humanoid") and x:FindFirstChild("HumanoidRootPart") and x.Name ~= player.Name and (x.HumanoidRootPart.Position - r.Position).Magnitude < 500 then
                r.CFrame = x.HumanoidRootPart.CFrame + Vector3.new(0,5,0); task.wait(0.05)
                local t = char:FindFirstChildOfClass("Tool"); if t then pcall(function() t:Activate() end) end
            end
        end end
    end end) end
end})
BloxTab:CreateButton({Name="Seçili Adaya Işınlan",Callback=function() TeleportUtil.teleportTo(selectedIsland,10) end})

-- PET SIM
local PetTab = Window:CreateTab("🐾 Pet Sim 99", 4483362458)
local petIslands = {"Spawn","Grasslands","Desert","Volcano","Winter","Fantasy","Rainbow","Tech World","Cat World","Dog World","Pixel World","Heaven","Hell","Candy Land","Cyber City","Pirate Cove"}
local selectedPetIsland = "Spawn"
PetTab:CreateDropdown({Name="Ada Seç ▼",Options=petIslands,CurrentOption={"Spawn"},MultipleOptions=false,Flag="PI",
    Callback=function(o) selectedPetIsland = type(o)=="table" and o[1] or o end})
PetTab:CreateToggle({Name="Auto Farm",CurrentValue=false,Flag="PF",Callback=function(v)
    if v then task.spawn(function() while v do task.wait(0.3)
        local r = TeleportUtil.getRoot()
        if r then for _, x in pairs(workspace:GetDescendants()) do
            if x:IsA("BasePart") then local n = x.Name:lower()
                if n:find("coin") or n:find("breakable") or n:find("chest") or n:find("diamond") then
                    if (x.Position - r.Position).Magnitude < 500 then r.CFrame = x.CFrame + Vector3.new(0,3,0); task.wait(0.05) end
                end
            end
        end end
    end end) end
end})
PetTab:CreateButton({Name="Seçili Adaya Işınlan",Callback=function() TeleportUtil.teleportTo(selectedPetIsland,10) end})
PetTab:CreateButton({Name="Auto Hatch Eggs",Callback=function() task.spawn(function() local r = TeleportUtil.getRoot(); if r then for _, x in pairs(workspace:GetDescendants()) do if x:IsA("BasePart") and x.Name:lower():find("egg") then r.CFrame = x.CFrame + Vector3.new(0,3,0); task.wait(0.3) end end end end) end})

-- MUSCLE LEGENDS
local MLTab = Window:CreateTab("💪 Muscle Legends", 4483362458)
local mlEvents = {dambil=findRemoteEvent("dambil","dumbbell"), sinav=findRemoteEvent("sinav","pushup","push"), mekik=findRemoteEvent("mekik","situp","sit"), rebirth=findRemoteEvent("rebirth","rebi"), punch=findRemoteEvent("punch","hit","attack"), sell=findRemoteEvent("sell")}
MLTab:CreateToggle({Name="Auto Dambil",CurrentValue=false,Flag="AD",Callback=function(v) if v then task.spawn(function() while v do task.wait(0.8); if #mlEvents.dambil>0 then fireAll(mlEvents.dambil,true) else pcall(function() rs.Events.Dambil:FireServer(true) end) end end end) end end})
MLTab:CreateToggle({Name="Auto Sinav",CurrentValue=false,Flag="ASV",Callback=function(v) if v then task.spawn(function() while v do task.wait(0.8); if #mlEvents.sinav>0 then fireAll(mlEvents.sinav,true) else pcall(function() rs.Events.Sinav:FireServer(true) end) end end end) end end})
MLTab:CreateToggle({Name="Auto Mekik",CurrentValue=false,Flag="AM",Callback=function(v) if v then task.spawn(function() while v do task.wait(0.8); if #mlEvents.mekik>0 then fireAll(mlEvents.mekik,true) else pcall(function() rs.Events.Mekik:FireServer(true) end) end end end) end end})
MLTab:CreateToggle({Name="Auto Rebirth",CurrentValue=false,Flag="AR",Callback=function(v) if v then task.spawn(function() while v do task.wait(3); if #mlEvents.rebirth>0 then fireAll(mlEvents.rebirth) else pcall(function() rs.Events.Rebirth:FireServer() end) end end end) end end})
MLTab:CreateToggle({Name="Auto Punch",CurrentValue=false,Flag="AP2",Callback=function(v) if v then task.spawn(function() while v do task.wait(0.1); if #mlEvents.punch>0 then fireAll(mlEvents.punch) end; local t = char:FindFirstChildOfClass("Tool"); if t then pcall(function() t:Activate() end) end end end) end end})
MLTab:CreateSlider({Name="WalkSpeed",Range={16,300},Increment=1,Suffix="Speed",CurrentValue=16,Flag="LS",Callback=function(v) if humanoid then humanoid.WalkSpeed = v end end})
MLTab:CreateSlider({Name="JumpPower",Range={50,300},Increment=1,Suffix="JP",CurrentValue=50,Flag="LJ",Callback=function(v) if humanoid then humanoid.UseJumpPower=true; humanoid.JumpPower=v end end})

-- ABOUT
local AboutTab = Window:CreateTab("ℹ️ About", 4483362458)
AboutTab:CreateParagraph({Title="CLOES MENU v15.0 | HACKER EDITION",Content="By Cloes\n\n• Stealth\n• Universal + Fly + Fling\n• MM2\n• Arsenal\n• Da Hood\n• Blox Fruits\n• Pet Sim 99\n• Muscle Legends"})

Rayfield:Notify({Title="CLOES v15",Content="Yüklendi.",Duration=5,Image=4483362458})
print("=== CLOES v15 ===")
