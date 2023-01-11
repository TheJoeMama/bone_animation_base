function JAnimBase:IsPlyAnimated(ply)
    if not IsValid(ply) then return end
    return ply.jemote_manipulated
end