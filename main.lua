local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- == SETTINGS ==
local Settings = {
    -- Main
    ESP = false,
    MobHunt = false,
    HuntHeight = 60,
    -- Boat
    BoatSpeed = false,
    BoatSpeedVal = 150,
    BoatAgility = false,
    -- Visuals
    FOV = 70,
    -- Misc
    WaterWalk = false,
    WalkSpeed = false,
    WalkSpeedVal = 16,
    -- System
    MenuKey = Enum.KeyCode.RightControl,
    UIOpen = true
}

local ESP_Storage = {}
local CurrentTarget = nil
local LastTargetPos = nil
local LootingTime = 0
local WaterPlatform = nil 

-- == COLORS ==
local Colors = {
    Background = Color3.fromRGB(15, 20, 30),
    Sidebar = Color3.fromRGB(10, 15, 25),
    Element = Color3.fromRGB(25, 30, 40),
    Accent = Color3.fromRGB(0, 255, 128), 
    Text = Color3.fromRGB(240, 240, 255),
    TextDark = Color3.fromRGB(120, 130, 140)
}

-- == UI FIX ==
local TargetParent = nil
pcall(function()
    if gethui then TargetParent = gethui()
    elseif game:GetService("CoreGui") then TargetParent = game:GetService("CoreGui") end
end)
if not TargetParent then TargetParent = LocalPlayer:WaitForChild("PlayerGui") end
if TargetParent:FindFirstChild("OceanHubV13") then TargetParent.OceanHubV13:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "OceanHubV13"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
local success, err = pcall(function() ScreenGui.Parent = TargetParent end)
if not success then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- GUI ELEMENTS (Shortened for brevity, same as before)
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Name = "MainFrame"
MainFrame.BackgroundColor3 = Colors.Background
MainFrame.Position = UDim2.new(0.5, -275, 0.5, -175)
MainFrame.Size = UDim2.new(0, 550, 0, 350)
local UICorner = Instance.new("UICorner", MainFrame)
UICorner.CornerRadius = UDim.new(0, 12)
local UIStroke = Instance.new("UIStroke", MainFrame)
UIStroke.Color = Colors.Accent
UIStroke.Thickness = 2
UIStroke.Transparency = 0.6
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.BackgroundColor3 = Colors.Sidebar
Sidebar.Size = UDim2.new(0, 140, 1, 0)
local SidebarCorner = Instance.new("UICorner", Sidebar)
SidebarCorner.CornerRadius = UDim.new(0, 12)
local Title = Instance.new("TextLabel", Sidebar)
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 15, 0, 20)
Title.Size = UDim2.new(1, -30, 0, 30)
Title.Font = Enum.Font.GothamBlack
Title.Text = "OCEAN\nHUB v13"
Title.TextColor3 = Colors.Accent
Title.TextSize = 22
Title.TextXAlignment = Enum.TextXAlignment.Left
local TabContainer = Instance.new("Frame", Sidebar)
TabContainer.BackgroundTransparency = 1
TabContainer.Position = UDim2.new(0, 0, 0, 80)
TabContainer.Size = UDim2.new(1, 0, 1, -80)
local TabListLayout = Instance.new("UIListLayout", TabContainer)
TabListLayout.Padding = UDim.new(0, 5)
local PageContainer = Instance.new("Frame", MainFrame)
PageContainer.BackgroundTransparency = 1
PageContainer.Position = UDim2.new(0, 150, 0, 20)
PageContainer.Size = UDim2.new(1, -160, 1, -40)
local StatusFrame = Instance.new("Frame", ScreenGui)
StatusFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
StatusFrame.BackgroundTransparency = 0.2
StatusFrame.Position = UDim2.new(0.5, -100, 0.1, 0)
StatusFrame.Size = UDim2.new(0, 200, 0, 40)
StatusFrame.Visible = false
local SCorner = Instance.new("UICorner", StatusFrame)
SCorner.CornerRadius = UDim.new(0, 20)
local SStroke = Instance.new("UIStroke", StatusFrame)
SStroke.Color = Color3.fromRGB(255, 50, 50)
SStroke.Thickness = 2
local SText = Instance.new("TextLabel", StatusFrame)
SText.Size = UDim2.new(1, 0, 1, 0)
SText.BackgroundTransparency = 1
SText.Text = "HUNTING ACTIVE"
SText.TextColor3 = Color3.fromRGB(255, 255, 255)
SText.Font = Enum.Font.GothamBold
SText.TextSize = 14

-- == FUNCTIONS ==
local Tabs, Pages = {}, {}
local function CreateTab(name)
    local Page = Instance.new("ScrollingFrame", PageContainer)
    Page.Name = name .. "Page"
    Page.BackgroundTransparency = 1
    Page.BorderSizePixel = 0
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.ScrollBarThickness = 2
    Page.Visible = false
    local PList = Instance.new("UIListLayout", Page)
    PList.Padding = UDim.new(0, 8)
    table.insert(Pages, Page)
    local TabBtn = Instance.new("TextButton", TabContainer)
    TabBtn.BackgroundColor3 = Colors.Sidebar
    TabBtn.BackgroundTransparency = 1
    TabBtn.Size = UDim2.new(1, 0, 0, 40)
    TabBtn.Text = ""
    local TabLabel = Instance.new("TextLabel", TabBtn)
    TabLabel.BackgroundTransparency = 1
    TabLabel.Position = UDim2.new(0, 20, 0, 0)
    TabLabel.Size = UDim2.new(1, -20, 1, 0)
    TabLabel.Font = Enum.Font.GothamSemibold
    TabLabel.Text = name
    TabLabel.TextColor3 = Colors.TextDark
    TabLabel.TextSize = 14
    TabLabel.TextXAlignment = Enum.TextXAlignment.Left
    local Indicator = Instance.new("Frame", TabBtn)
    Indicator.BackgroundColor3 = Colors.Accent
    Indicator.Position = UDim2.new(0, 0, 0.2, 0)
    Indicator.Size = UDim2.new(0, 3, 0.6, 0)
    Indicator.Visible = false
    TabBtn.MouseButton1Click:Connect(function()
        for _, p in pairs(Pages) do p.Visible = false end
        for _, t in pairs(Tabs) do t.Frame.Visible = false; TweenService:Create(t.Label, TweenInfo.new(0.2), {TextColor3 = Colors.TextDark}):Play() end
        Page.Visible = true; Indicator.Visible = true; TweenService:Create(TabLabel, TweenInfo.new(0.2), {TextColor3 = Colors.Text}):Play()
    end)
    table.insert(Tabs, {Btn = TabBtn, Label = TabLabel, Frame = Indicator})
    return Page
end

local function CreateToggle(parent, text, callback)
    local Frame = Instance.new("Frame", parent)
    Frame.BackgroundColor3 = Colors.Element
    Frame.Size = UDim2.new(1, 0, 0, 45)
    local Corner = Instance.new("UICorner", Frame)
    Corner.CornerRadius = UDim.new(0, 8)
    local Label = Instance.new("TextLabel", Frame)
    Label.BackgroundTransparency = 1
    Label.Position = UDim2.new(0, 15, 0, 0)
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.Font = Enum.Font.GothamSemibold
    Label.Text = text
    Label.TextColor3 = Colors.Text
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    local ToggleBtn = Instance.new("TextButton", Frame)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    ToggleBtn.Position = UDim2.new(1, -55, 0.5, -12)
    ToggleBtn.Size = UDim2.new(0, 40, 0, 24)
    ToggleBtn.Text = ""
    local TCorner = Instance.new("UICorner", ToggleBtn)
    TCorner.CornerRadius = UDim.new(1, 0)
    local Circle = Instance.new("Frame", ToggleBtn)
    Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Circle.Position = UDim2.new(0, 2, 0.5, -10)
    Circle.Size = UDim2.new(0, 20, 0, 20)
    local CCorner = Instance.new("UICorner", Circle)
    CCorner.CornerRadius = UDim.new(1, 0)
    local state = false
    ToggleBtn.MouseButton1Click:Connect(function()
        state = not state; callback(state)
        local tColor = state and Colors.Accent or Color3.fromRGB(50, 50, 60)
        local tPos = state and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
        TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = tColor}):Play()
        TweenService:Create(Circle, TweenInfo.new(0.2), {Position = tPos}):Play()
    end)
end

local function CreateSlider(parent, text, min, max, default, callback)
    local Frame = Instance.new("Frame", parent)
    Frame.BackgroundColor3 = Colors.Element
    Frame.Size = UDim2.new(1, 0, 0, 60)
    local Corner = Instance.new("UICorner", Frame)
    Corner.CornerRadius = UDim.new(0, 8)
    local Label = Instance.new("TextLabel", Frame)
    Label.BackgroundTransparency = 1
    Label.Position = UDim2.new(0, 15, 0, 8)
    Label.Size = UDim2.new(1, -30, 0, 20)
    Label.Font = Enum.Font.GothamSemibold
    Label.Text = text
    Label.TextColor3 = Colors.Text
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    local ValueLabel = Instance.new("TextLabel", Frame)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Position = UDim2.new(0, 15, 0, 8)
    ValueLabel.Size = UDim2.new(1, -30, 0, 20)
    ValueLabel.Font = Enum.Font.Gotham
    ValueLabel.Text = tostring(default)
    ValueLabel.TextColor3 = Colors.Accent
    ValueLabel.TextSize = 14
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    local SliderBar = Instance.new("TextButton", Frame)
    SliderBar.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    SliderBar.Position = UDim2.new(0, 15, 0, 38)
    SliderBar.Size = UDim2.new(1, -30, 0, 6)
    SliderBar.Text = ""
    local SCorner = Instance.new("UICorner", SliderBar)
    SCorner.CornerRadius = UDim.new(1, 0)
    local Fill = Instance.new("Frame", SliderBar)
    Fill.BackgroundColor3 = Colors.Accent
    Fill.Size = UDim2.new((default - min)/(max-min), 0, 1, 0)
    local FCorner = Instance.new("UICorner", Fill)
    FCorner.CornerRadius = UDim.new(1, 0)
    local dragging = false
    local function Update(input)
        local pos = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
        Fill.Size = UDim2.new(pos, 0, 1, 0)
        local value = math.floor(min + ((max - min) * pos))
        ValueLabel.Text = tostring(value); callback(value)
    end
    SliderBar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; Update(input) end end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
    UserInputService.InputChanged:Connect(function(input) if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then Update(input) end end)
end

local function CreateButton(parent, text, callback)
    local Btn = Instance.new("TextButton", parent)
    Btn.BackgroundColor3 = Colors.Element
    Btn.Size = UDim2.new(1, 0, 0, 40)
    Btn.Text = text
    Btn.Font = Enum.Font.GothamBold
    Btn.TextColor3 = Colors.Text
    Btn.TextSize = 14
    local Corner = Instance.new("UICorner", Btn)
    Corner.CornerRadius = UDim.new(0, 8)
    Btn.MouseButton1Click:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.1), {BackgroundColor3 = Colors.Accent}):Play()
        task.wait(0.1)
        TweenService:Create(Btn, TweenInfo.new(0.3), {BackgroundColor3 = Colors.Element}):Play()
        callback()
    end)
end

-- Dragging
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; dragStart = input.Position; startPos = MainFrame.Position end end)
MainFrame.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end end)
UserInputService.InputChanged:Connect(function(input) if input == dragInput and dragging then local delta = input.Position - dragStart; MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end end)
UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

local function IsValid(obj)
    if not obj or not obj.Parent then return false end
    local n = obj.Name:lower()
    if string.find(n, "whale") or string.find(n, "shark") then
        if obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart then return true end
    end
    return false
end

local function UpdateESP()
    for _, obj in pairs(Workspace:GetChildren()) do
        if IsValid(obj) and not ESP_Storage[obj] then
            pcall(function()
                local hl = Instance.new("Highlight", TargetParent)
                hl.Adornee = obj; hl.FillColor = Color3.fromRGB(255, 50, 50); hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                local bb = Instance.new("BillboardGui", TargetParent)
                bb.Adornee = obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart; bb.Size = UDim2.new(0, 200, 0, 50); bb.StudsOffset = Vector3.new(0, 10, 0); bb.AlwaysOnTop = true
                local txt = Instance.new("TextLabel", bb)
                txt.Size = UDim2.new(1,0,1,0); txt.BackgroundTransparency = 1; txt.TextColor3 = Color3.new(1,1,1); txt.Font = Enum.Font.GothamBold; txt.TextSize = 12
                ESP_Storage[obj] = {hl, bb, txt}
            end)
        end
    end
    for obj, data in pairs(ESP_Storage) do
        if obj.Parent then
            local root = obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart
            local dist = (LocalPlayer.Character.HumanoidRootPart.Position - root.Position).Magnitude
            data[3].Text = obj.Name .. " [" .. math.floor(dist) .. "m]"
        else
            data[1]:Destroy(); data[2]:Destroy(); ESP_Storage[obj] = nil
        end
    end
end

-- == RENDER STEPPED (CAMERA) ==
RunService.RenderStepped:Connect(function()
    if Settings.MobHunt and CurrentTarget and CurrentTarget.Parent then
        local targetRoot = CurrentTarget:FindFirstChild("HumanoidRootPart") or CurrentTarget.PrimaryPart
        local aimPart = CurrentTarget:FindFirstChild("Torso") or CurrentTarget:FindFirstChild("UpperTorso") or targetRoot
        if aimPart then
            local frontFacePosition = aimPart.Position + (aimPart.CFrame.LookVector * 0.5)
            Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, frontFacePosition)
            VirtualUser:Button1Down(Vector2.new(0,0), Camera.CFrame)
            VirtualUser:Button1Up(Vector2.new(0,0), Camera.CFrame)
        end
    end
end)

-- == HEARTBEAT (PHYSICS) ==
RunService.Heartbeat:Connect(function()
    if Settings.ESP then UpdateESP() else for o, d in pairs(ESP_Storage) do d[1]:Destroy(); d[2]:Destroy(); ESP_Storage[o]=nil end end
    
    if Settings.WaterWalk and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local rootPos = LocalPlayer.Character.HumanoidRootPart.Position
        if not WaterPlatform then
            WaterPlatform = Instance.new("Part", Workspace); WaterPlatform.Name = "OceanWalkPlate"; WaterPlatform.Size = Vector3.new(40, 1, 40); WaterPlatform.Transparency = 1; WaterPlatform.Anchored = true; WaterPlatform.CanCollide = true
        end
        WaterPlatform.Position = Vector3.new(rootPos.X, -3.5, rootPos.Z)
    elseif WaterPlatform then WaterPlatform:Destroy(); WaterPlatform = nil end

    if Settings.WalkSpeed and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = Settings.WalkSpeedVal
    end
    
    -- MOB HUNT
    if Settings.MobHunt and LocalPlayer.Character then
        local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root then
            -- 1. Search
            if (not CurrentTarget or not CurrentTarget.Parent) and tick() > LootingTime then
                local min, found = math.huge, nil
                for _, o in pairs(Workspace:GetChildren()) do
                    if IsValid(o) then
                        local r = o:FindFirstChild("HumanoidRootPart") or o.PrimaryPart
                        local d = (root.Position - r.Position).Magnitude
                        if d < min then min = d; found = o end
                    end
                end
                CurrentTarget = found
            end
            
            -- 2. Attack
            if CurrentTarget and CurrentTarget.Parent then
                local targetRoot = CurrentTarget:FindFirstChild("HumanoidRootPart") or CurrentTarget.PrimaryPart
                LastTargetPos = targetRoot.Position
                local hoverPos = targetRoot.Position + Vector3.new(0, Settings.HuntHeight, 0)
                root.CFrame = CFrame.new(hoverPos)
                root.AssemblyLinearVelocity = Vector3.new(0,0,0)
                SText.Text = "HUNTING: " .. CurrentTarget.Name
                StatusFrame.Visible = true

            -- 3. Loot (Down to 1st Obstacle)
            elseif LastTargetPos and (not CurrentTarget or not CurrentTarget.Parent) then
                if LootingTime == 0 then LootingTime = tick() + 1.2 end -- Время на лут (1.2 сек)
                
                if tick() < LootingTime then
                    -- Пускаем луч вниз, чтобы найти землю
                    local rayOrigin = Vector3.new(LastTargetPos.X, LastTargetPos.Y + 20, LastTargetPos.Z)
                    local rayDirection = Vector3.new(0, -500, 0)
                    local rayParams = RaycastParams.new()
                    rayParams.FilterDescendantsInstances = {LocalPlayer.Character}
                    rayParams.FilterType = Enum.RaycastFilterType.Exclude

                    local rayResult = Workspace:Raycast(rayOrigin, rayDirection, rayParams)
                    
                    local landY = LastTargetPos.Y -- По дефолту высота моба
                    if rayResult then
                        landY = rayResult.Position.Y -- Если нашли землю, берем её высоту
                    end

                    -- Телепортируемся чуть выше земли (+3.5 студа)
                    root.CFrame = CFrame.new(LastTargetPos.X, landY + 3.5, LastTargetPos.Z)
                    root.AssemblyLinearVelocity = Vector3.new(0,0,0)
                    SText.Text = "LOOTING (GROUND)..."
                    StatusFrame.Visible = true
                else
                    LastTargetPos = nil -- Сбор окончен, идем к след цели
                    LootingTime = 0
                end
            else
                StatusFrame.Visible = false
            end
        end
    else
        StatusFrame.Visible = false
    end

    if LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum and hum.SeatPart and hum.SeatPart:IsA("VehicleSeat") then
            if Settings.BoatSpeed then
                hum.SeatPart.MaxSpeed = Settings.BoatSpeedVal
                if hum.SeatPart:FindFirstChild("BodyVelocity") then hum.SeatPart.BodyVelocity.Velocity = hum.SeatPart.CFrame.LookVector * Settings.BoatSpeedVal end
            end
            if Settings.BoatAgility then hum.SeatPart.TurnSpeed = 5; hum.SeatPart.Torque = math.huge end
        end
    end
end)

UserInputService.InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == Enum.KeyCode.K then Settings.MobHunt = false; StatusFrame.Visible = false; Camera.CameraType = Enum.CameraType.Custom end
    if input.KeyCode == Settings.MenuKey then Settings.UIOpen = not Settings.UIOpen; MainFrame.Visible = Settings.UIOpen end
end)

-- PAGES
local PageFarm = CreateTab("Farm")
CreateToggle(PageFarm, "Mob Hunt (Auto Kill)", function(val) Settings.MobHunt = val; if not val then Camera.CameraType = Enum.CameraType.Custom end end)
CreateSlider(PageFarm, "Hover Height", 20, 150, 60, function(val) Settings.HuntHeight = val end)
CreateButton(PageFarm, "Teleport to Destroyed Ship", function()
    for _, v in pairs(Workspace:GetDescendants()) do if v:IsA("Model") and string.find(v.Name, "ShipModel") then local r = v:FindFirstChild("HumanoidRootPart") or v.PrimaryPart; if r then LocalPlayer.Character.HumanoidRootPart.CFrame = r.CFrame + Vector3.new(0,60,0); break end end end
end)
local PageVis = CreateTab("Visuals")
CreateToggle(PageVis, "ESP Mobs", function(val) Settings.ESP = val end)
CreateSlider(PageVis, "FOV Changer", 70, 120, 70, function(val) Settings.FOV = val; Camera.FieldOfView = val end)
local PageBoat = CreateTab("Boat")
CreateToggle(PageBoat, "Enable Boat Speed", function(val) Settings.BoatSpeed = val end)
CreateSlider(PageBoat, "Speed Value", 50, 800, 150, function(val) Settings.BoatSpeedVal = val end)
CreateToggle(PageBoat, "High Agility", function(val) Settings.BoatAgility = val end)
local PageMisc = CreateTab("Misc")
CreateToggle(PageMisc, "Water Walk", function(val) Settings.WaterWalk = val end)
CreateToggle(PageMisc, "Enable WalkSpeed", function(val) Settings.WalkSpeed = val end)
CreateSlider(PageMisc, "Speed Value", 16, 200, 32, function(val) Settings.WalkSpeedVal = val end)
CreateButton(PageMisc, "Server Hop", function()
    local Api = "https://games.roblox.com/v1/games/"; local _place = game.PlaceId; local _servers = Api.._place.."/servers/Public?sortOrder=Asc&limit=100"
    local function ListServers(cursor) local Raw = game:HttpGet(_servers .. ((cursor and "&cursor="..cursor) or "")); return HttpService:JSONDecode(Raw) end
    local Server, Next; repeat local Servers = ListServers(Next); Server = Servers.data; Next = Servers.nextPageCursor; for _, v in pairs(Server) do if v.playing < v.maxPlayers and v.id ~= game.JobId then pcall(function() TeleportService:TeleportToPlaceInstance(_place, v.id, LocalPlayer) end) end end until not Next
end)
local PageSet = CreateTab("Settings")
CreateButton(PageSet, "Unload Script", function() ScreenGui:Destroy(); StatusFrame:Destroy(); if WaterPlatform then WaterPlatform:Destroy() end; Settings.ESP = false; Settings.MobHunt = false end)
CreateButton(PageSet, "Rejoin", function() if #Players:GetPlayers() <= 1 then LocalPlayer:Kick("\nRejoining..."); task.wait(); TeleportService:Teleport(game.PlaceId, LocalPlayer) else TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer) end end)

Tabs[1].Btn.BackgroundColor3 = Colors.Accent; Tabs[1].Btn.BackgroundTransparency = 0.9; Tabs[1].Label.TextColor3 = Colors.Text; Tabs[1].Frame.Visible = true; Pages[1].Visible = true
print("Ocean Hub v13 Loaded")
