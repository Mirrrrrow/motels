local blip = {}

---Creates a blip on the map
---@param sprite number
---@param scale number
---@param colour number
---@param name string
---@param x number
---@param y number
---@param z number
function blip.create(sprite, scale, colour, name, x, y, z)
    local createdBlip = AddBlipForCoord(x, y, z)
    SetBlipSprite(createdBlip, sprite)
    SetBlipScale(createdBlip, scale)
    SetBlipColour(createdBlip, colour)
    SetBlipAsShortRange(createdBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(name)
    EndTextCommandSetBlipName(createdBlip)
    return createdBlip
end

return blip