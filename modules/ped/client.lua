local ped = {}

---Creates a local ped<br>
---Returns nil when getting into an error
---@param hash string|number
---@param coords vector4
---@param scenario? string
---@return number|nil
function ped.spawn(hash, coords, scenario)
    local model = lib.requestModel(hash)
    if not model then return end

    local entity = CreatePed(0, model, coords.x, coords.y, coords.z, coords.w, false ,true)
    if scenario then TaskStartScenarioInPlace(entity, scenario, 0, true) end

    SetModelAsNoLongerNeeded(model)
    FreezeEntityPosition(entity, true)
    SetEntityInvincible(entity, true)
    SetBlockingOfNonTemporaryEvents(entity, true)

    return entity
end

return ped