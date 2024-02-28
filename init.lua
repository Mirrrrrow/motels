Shared = {
    resource = GetCurrentResourceName(),
    framework = GetConvar('mdevelopment:framework', 'esx')
}

function Shared.getStashIdentifier(motelId, roomId)
    return 'motels-' .. motelId .. '-rooms-' .. roomId
end

if IsDuplicityVersion() then
    Server = {}
else
    Client = {}
end

if not lib then
    return error('ox_lib was not found!')
end

if lib.context == 'server' then
    local currentVersion = GetResourceMetadata(Shared.resource, 'version', 0)
    if currentVersion == '0.0.0' then
        warn(("You are running a development build of the '%s' System. Please do not use this in production."):format(Shared.resource))
    end
    return require 'server'
end

require 'client'