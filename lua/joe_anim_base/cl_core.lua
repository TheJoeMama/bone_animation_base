local nullang = Angle(0,0,0)
local fingerang = Angle(-8.120, -173.185, 0.000)
local reset = {	        
    ["ValveBiped.Bip01_Head1"] = nullang,
    ["ValveBiped.Bip01_R_UpperArm"] = nullang,
    ["ValveBiped.Bip01_R_Forearm"] = nullang,
    ["ValveBiped.Bip01_L_UpperArm"] = nullang,
    ["ValveBiped.Bip01_L_Forearm"] = nullang,
    ["ValveBiped.Bip01_R_Hand"] = nullang,
    ["ValveBiped.Bip01_L_Hand"] = nullang,
    ["ValveBiped.Bip01_R_Thigh"] = nullang,
    ["ValveBiped.Bip01_L_Thigh"] = nullang,
    ["ValveBiped.Bip01_R_Foot"] = nullang,
    ["ValveBiped.Bip01_L_Foot"] = nullang,
    ["ValveBiped.Bip01_R_Calf"] = nullang,
    ["ValveBiped.Bip01_L_Calf"] = nullang,
    ["ValveBiped.Bip01_Pelvis"] = nullang,

	["ValveBiped.Bip01_R_Clavicle"] = nullang,

    ["ValveBiped.Bip01_R_Finger4"] = nullang,
	["ValveBiped.Bip01_R_Finger41"] = nullang,
	["ValveBiped.Bip01_R_Finger42"] = nullang,
	["ValveBiped.Bip01_R_Finger3"] = nullang,
	["ValveBiped.Bip01_R_Finger31"] = nullang,
	["ValveBiped.Bip01_R_Finger32"] = nullang,
	["ValveBiped.Bip01_R_Finger2"] = nullang,
	["ValveBiped.Bip01_R_Finger21"] = nullang,
	["ValveBiped.Bip01_R_Finger22"] = nullang,
	["ValveBiped.Bip01_R_Finger1"] = nullang,
	["ValveBiped.Bip01_R_Finger11"] = nullang,
	["ValveBiped.Bip01_R_Finger12"] = nullang,
	["ValveBiped.Bip01_R_Finger0"] = nullang,
	["ValveBiped.Bip01_R_Finger01"] = nullang,
	["ValveBiped.Bip01_R_Finger02"] = nullang,
}

net.Receive("JAnimBase_StartAnim", function()
    local ply = net.ReadEntity()
    ply.jemote_manipulated = true
    ply.jemote_toreset = {}
    ply.jemote_tochange = {}
    for name,data in pairs(reset) do
        local boneid = ply:LookupBone(name)
        if not boneid then continue end
        if isvector(data) then
            ply:ManipulateBonePosition(boneid,data)
        else
            local curbone = ply:GetManipulateBoneAngles(boneid)
            
            ply:ManipulateBoneAngles(boneid, data)
        end
    end

    local ln = net.ReadUInt(8)
    for i=1,ln do
        local str = net.ReadString()
        local typebl = net.ReadBool()
        local data
        if typebl then
            data = net.ReadVector()
        else
            data = net.ReadAngle()
        end
        ply.jemote_tochange[str] = data
    end
end)

hook.Add("Think", "JAnimBase:LerpAngles", function()
    for _,ply in pairs(player.GetAll()) do
        if not ply.jemote_tochange and not ply.jemote_toreset then continue end
        
        if ply.jemote_toreset and table.Count(ply.jemote_toreset) > 0 then
            local done = true
            for name,data in pairs(ply.jemote_toreset) do
                if not data then continue end
                local boneid = ply:LookupBone(name)
                if not boneid then continue end
                if isvector(data) then
                    local curbone = ply:GetManipulateBonePosition(boneid)
                    if curbone != Vector(0,0,0) then done = false end 
                    ply:ManipulateBonePosition(boneid,Vector(0,0,0))
                else
                    local curbone = ply:GetManipulateBoneAngles(boneid) 
                    if curbone != Angle(0,0,0) then done = false end
                    ply:ManipulateBoneAngles(boneid, LerpAngle(FrameTime() * 5, curbone, Angle(0,0,0)))
                end
            end
            if done == true then ply.jemote_toreset = nil  end
        end

        if ply.jemote_tochange and table.Count(ply.jemote_tochange) > 0 then
            for name,data in pairs(ply.jemote_tochange) do
                if not data then continue end
                local boneid = ply:LookupBone(name)
                if not boneid then continue end
                if isvector(data) then
                    local curbone = ply:GetManipulateBonePosition(boneid)
                    ply:ManipulateBonePosition(boneid, LerpVector(FrameTime() * 5, curbone, data))
                else
                    local curbone = ply:GetManipulateBoneAngles(boneid)
                    ply:ManipulateBoneAngles(boneid,LerpAngle(FrameTime() * 5, curbone, data))
                end
            end
        end
    end
end)

net.Receive("JAnimBase_ResetAnim", function()
    local ply = net.ReadEntity()
    ply.jemote_toreset = reset
    ply.jemote_tochange = {}
    ply.jemote_manipulated = false
end)