util.AddNetworkString("JAnimBase_StartAnim")
function JAnimBase:StartAnim(ply,data)
    if not data or not istable(data) then return end
    ply.jemote_manipulated = true
    net.Start("JAnimBase_StartAnim")
    net.WriteEntity(ply)
    net.WriteUInt(table.Count(data),8)
    for name,chgdata in pairs(data) do
        net.WriteString(name)
        local bool = isvector(chgdata)
        if bool then
            net.WriteBool(true)
            net.WriteVector(chgdata)
        else
            net.WriteBool(false)
            net.WriteAngle(chgdata)
        end
    end
    net.Broadcast()
end

util.AddNetworkString("JAnimBase_ResetAnim")
function JAnimBase:ResetAnim(ply)
    ply.jemote_manipulated = false
    net.Start("JAnimBase_ResetAnim")
    net.WriteEntity(ply)
    net.Broadcast()
end

hook.Add("SetupMove", "JAnimBase:RemoveAnimOnMove", function(ply, mv, cmd)
    if not ply.jemote_manipulated then return end
    if ( mv:GetVelocity() == Vector(0,0,0) or ply:KeyDown(IN_WALK) ) then return end
    JAnimBase:ResetAnim(ply)
end)