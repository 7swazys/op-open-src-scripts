--I AM InxTdS

local SilentAim = {}

SilentAim.bone = "Head"
SilentAim.range = math.huge

SilentAim.services = {
    rep = game:GetService("ReplicatedStorage"),
    plr = game:GetService("Players")
}

SilentAim.mod = require(SilentAim.services.rep.Modules.Utility)
SilentAim.originalRaycast = SilentAim.mod.Raycast
SilentAim.camera = workspace.CurrentCamera
SilentAim.localPlayer = SilentAim.services.plr.LocalPlayer

SilentAim.mod.Raycast = function(...)
    local args = {...}
    
    if args[4] ~= 999 then
        return SilentAim.originalRaycast(...)
    end
    
    local origin = args[2]
    local direction = args[3]
    local rayVector = direction - origin
    
    if rayVector.Magnitude > 0 and rayVector.Unit.Y < -0.7 then
        return SilentAim.originalRaycast(...)
    end
    
    local centerX = SilentAim.camera.ViewportSize.X / 2
    local centerY = SilentAim.camera.ViewportSize.Y / 2
    
    local closestTarget = nil
    local closestDistance = SilentAim.range
    
    local targets = {}
    
    for _, obj in workspace:GetChildren() do
        if obj:FindFirstChildOfClass("Humanoid") then
            targets[#targets + 1] = obj
        end
        
        if obj.Name == "HurtEffect" then
            for _, child in obj:GetChildren() do
                if child.ClassName ~= "Highlight" then
                    targets[#targets + 1] = child
                end
            end
        end
    end
    
    for _, target in targets do
        if target == SilentAim.localPlayer.Character then
            continue
        end
        
        if not target:FindFirstChild("HumanoidRootPart") then
            continue
        end
        if not target:FindFirstChild(SilentAim.bone) then
            continue
        end
        
        local bonePosition = target[SilentAim.bone].Position
        local screenPos, isVisible = SilentAim.camera:WorldToViewportPoint(bonePosition)
        
        if not isVisible then
            continue
        end
        
        local screenCenter = Vector2.new(centerX, centerY)
        local targetScreenPos = Vector2.new(screenPos.X, screenPos.Y)
        local distance = (screenCenter - targetScreenPos).Magnitude
        
        if distance < closestDistance then
            closestTarget = target
            closestDistance = distance
        end
    end
    
    if closestTarget and closestTarget:FindFirstChild(SilentAim.bone) then
        args[3] = closestTarget[SilentAim.bone].Position
    end
    
    return SilentAim.originalRaycast(table.unpack(args))
end
