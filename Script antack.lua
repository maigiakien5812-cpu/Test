-- Auto Attack Script
-- Toggle button UI

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local isEnabled = false
local attackCooldown = 0.5 -- giây giữa các lần attack
local lastAttack = 0
local attackRange = 20 -- khoảng cách tấn công

-- ===== TẠO NÚT BẬT/TẮT =====
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoAttackGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer.PlayerGui

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 120, 0, 50)
ToggleButton.Position = UDim2.new(0, 10, 0.5, -25)
ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Text = "Auto Attack\nOFF"
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.TextSize = 14
ToggleButton.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = ToggleButton

-- ===== HÀM TÌM NHÂN VẬT GẦN NHẤT =====
local function getNearestEnemy()
    local nearest = nil
    local minDist = attackRange
    
    local myRoot = Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = player.Character
            if char then
                local root = char:FindFirstChild("HumanoidRootPart")
                local hum = char:FindFirstChild("Humanoid")
                if root and hum and hum.Health > 0 then
                    local dist = (myRoot.Position - root.Position).Magnitude
                    if dist < minDist then
                        minDist = dist
                        nearest = char
                    end
                end
            end
        end
    end
    return nearest
end

-- ===== HÀM ATTACK =====
local function attackEnemy(target)
    if not target then return end
    local hum = target:FindFirstChild("Humanoid")
    if hum and hum.Health > 0 then
        -- Simulate click/touch lên nhân vật
        local root = target:FindFirstChild("HumanoidRootPart")
        if root then
            -- Fire tool hoặc simulate tap
            local tool = Character:FindFirstChildOfClass("Tool")
            if tool and tool:FindFirstChild("Handle") then
                -- Nếu có tool thì activate
                local activateEvent = tool:FindFirstChild("RemoteEvent") 
                    or tool:FindFirstChild("RemoteFunction")
                tool:Activate()
            end
            
            -- Di chuyển nhìn về phía enemy
            LocalPlayer.Character.Humanoid:MoveTo(
                root.Position + (Character.HumanoidRootPart.Position - root.Position).Unit * 5
            )
        end
    end
end

-- ===== TOGGLE LOGIC =====
ToggleButton.MouseButton1Click:Connect(function()
    isEnabled = not isEnabled
    if isEnabled then
        ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        ToggleButton.Text = "Auto Attack\nON"
    else
        ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        ToggleButton.Text = "Auto Attack\nOFF"
    end
end)

-- ===== MAIN LOOP =====
RunService.Heartbeat:Connect(function()
    if not isEnabled then return end
    
    -- Cập nhật character nếu respawn
    Character = LocalPlayer.Character
    if not Character then return end
    
    local now = tick()
    if now - lastAttack < attackCooldown then return end
    lastAttack = now
    
    local target = getNearestEnemy()
    if target then
        attackEnemy(target)
    end
end)

-- Cập nhật character khi respawn
LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
end)

print("Auto Attack Script loaded! Nhấn nút để bật/tắt.")
