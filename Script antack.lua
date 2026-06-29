local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local MaxDistance = 50
local ClickSpeed = 0.40
local IsEnabled = false
local LastClickTime = 0

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeltaAutoClick"
ScreenGui.Parent = game:GetService("CoreGui")

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 120, 0, 30)
ToggleButton.Position = UDim2.new(0, 20, 0, 20)
ToggleButton.Text = "BẬT/TẮT"
ToggleButton.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
ToggleButton.TextColor3 = Color3.new(1, 1, 1)
ToggleButton.Parent = ScreenGui

local DistLabel = Instance.new("TextLabel")
DistLabel.Size = UDim2.new(0, 120, 0, 20)
DistLabel.Position = UDim2.new(0, 20, 0, 55)
DistLabel.Text = "Khoảng cách: 50"
DistLabel.BackgroundColor3 = Color3.new(0.15, 0.15, 0.15)
DistLabel.TextColor3 = Color3.new(1, 1, 1)
DistLabel.Parent = ScreenGui

local DistSlider = Instance.new("TextBox")
DistSlider.Size = UDim2.new(0, 120, 0, 20)
DistSlider.Position = UDim2.new(0, 20, 0, 78)
DistSlider.Text = "50"
DistSlider.PlaceholderText = "Khoảng cách"
DistSlider.Parent = ScreenGui

local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Size = UDim2.new(0, 120, 0, 20)
SpeedLabel.Position = UDim2.new(0, 20, 0, 103)
SpeedLabel.Text = "Click Speed: 0.40"
SpeedLabel.BackgroundColor3 = Color3.new(0.15, 0.15, 0.15)
SpeedLabel.TextColor3 = Color3.new(1, 1, 1)
SpeedLabel.Parent = ScreenGui

local SpeedSlider = Instance.new("TextBox")
SpeedSlider.Size = UDim2.new(0, 120, 0, 20)
SpeedSlider.Position = UDim2.new(0, 20, 0, 126)
SpeedSlider.Text = "0.40"
SpeedSlider.PlaceholderText = "Tốc độ click"
SpeedSlider.Parent = ScreenGui

local Circle = Drawing.new("Circle")
Circle.Visible = false
Circle.Color = Color3.new(1, 0, 0)
Circle.Thickness = 1
Circle.Filled = false

local HighlightBoxes = {}

local function CreateHighlight(player)
    if HighlightBoxes[player] then return end
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = Color3.new(1, 0, 0)
    box.Thickness = 2
    box.Filled = false
    HighlightBoxes[player] = box
    return box
end

local function RemoveHighlight(player)
    if HighlightBoxes[player] then
        HighlightBoxes[player]:Remove()
        HighlightBoxes[player] = nil
    end
end

local function GetNearestPlayer()
    local nearest = nil
    local minDist = MaxDistance
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        local char = player.Character
        if not char then continue end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end
        local dist = (root.Position - hrp.Position).Magnitude
        if dist < minDist then
            minDist = dist
            nearest = player
        end
    end
    return nearest
end

local function UpdateHighlights()
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        local char = player.Character
        if not char then RemoveHighlight(player); continue end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local head = char:FindFirstChild("Head")
        if not hrp or not head then RemoveHighlight(player); continue end
        if root then
            local dist = (root.Position - hrp.Position).Magnitude
            if dist <= MaxDistance and IsEnabled then
                local box = CreateHighlight(player)
                local headPos, headOnScreen = Camera:WorldToViewportPoint(head.Position)
                local footPos = hrp.Position - Vector3.new(0, 3.5, 0)
                local footScreen, footOnScreen = Camera:WorldToViewportPoint(footPos)
                if headOnScreen and footOnScreen then
                    local size = math.abs(headPos.Y - footScreen.Y)
                    local width = size * 0.5
                    box.Visible = true
                    box.Position = Vector2.new(headPos.X - width/2, headPos.Y)
                    box.Size = Vector2.new(width, size)
                else
                    box.Visible = false
                end
            else
                RemoveHighlight(player)
            end
        end
    end
end

local function ClickOnPlayer(player)
    if not player or not player.Character then return end
    local head = player.Character:FindFirstChild("Head")
    local humanoid = player.Character:FindFirstChild("Humanoid")
    if head and humanoid and humanoid.Health > 0 then
        local targetPos = head.Position - Vector3.new(0, 1.5, 0)
        local screenPos, onScreen = Camera:WorldToViewportPoint(targetPos)
        if onScreen then
            VirtualInputManager:SendMouseButtonEvent(screenPos.X, screenPos.Y, 0, true, game, 1)
            task.wait(0.05)
            VirtualInputManager:SendMouseButtonEvent(screenPos.X, screenPos.Y, 0, false, game, 1)
        end
    end
end

RunService.Heartbeat:Connect(function()
    local newDist = tonumber(DistSlider.Text)
    if newDist and newDist > 0 then MaxDistance = newDist; DistLabel.Text = "Khoảng cách: " .. newDist end
    local newSpeed = tonumber(SpeedSlider.Text)
    if newSpeed and newSpeed > 0 then ClickSpeed = newSpeed; SpeedLabel.Text = "Click Speed: " .. string.format("%.2f", newSpeed) end
    if IsEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local rootPos = LocalPlayer.Character.HumanoidRootPart.Position
        Circle.Visible = true
        Circle.Position = Camera:WorldToViewportPoint(rootPos)
        Circle.Radius = MaxDistance * (Camera.ViewportSize.Y / (2 * math.tan(math.rad(Camera.FieldOfView/2)) * (rootPos - Camera.CFrame.Position).Magnitude))
    else
        Circle.Visible = false
    end
    UpdateHighlights()
    if IsEnabled then
        local currentTime = os.clock()
        if currentTime - LastClickTime >= ClickSpeed then
            local target = GetNearestPlayer()
            if target then ClickOnPlayer(target); LastClickTime = currentTime end
        end
    end
end)

ToggleButton.MouseButton1Click:Connect(function()
    IsEnabled = not IsEnabled
    if IsEnabled then
        ToggleButton.BackgroundColor3 = Color3.new(0, 1, 0)
        ToggleButton.Text = "ĐANG BẬT"
    else
        ToggleButton.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
        ToggleButton.Text = "ĐANG TẮT"
        for player, _ in pairs(HighlightBoxes) do RemoveHighlight(player) end
    end
end)

Players.PlayerRemoving:Connect(function(player) RemoveHighlight(player) end)

ScreenGui.Destroying:Connect(function()
    Circle:Remove()
    for player, _ in pairs(HighlightBoxes) do RemoveHighlight(player) end
end)
