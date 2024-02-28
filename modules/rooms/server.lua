---@type table<number, table<number, RawRoom>>
local rawRoomData = {}
Citizen.CreateThreadNow(function ()
    local success, _ = pcall(MySQL.scalar.await, 'SELECT 1 FROM motel_rooms')
    if not success then
        MySQL.query.await([[
            CREATE TABLE motel_rooms (
                id INT AUTO_INCREMENT PRIMARY KEY,
                motel_id INT NOT NULL,
                room_id INT NOT NULL,
                occupant LONGTEXT NOT NULL
            )
        ]])
    end

    for _, stationData in pairs(lib.load('data.motels') --[[@as table<number, RawMotelStation>]]) do
        if not rawRoomData[stationData.id] then
            rawRoomData[stationData.id] = {}
        end

        for _, roomData in pairs(stationData.rooms) do
            local count = MySQL.scalar.await('SELECT COUNT(*) AS count FROM motel_rooms WHERE motel_id = ? AND room_id = ?', {stationData.id, roomData.id})
            if count == 0 then
                MySQL.insert.await('INSERT INTO motel_rooms (motel_id, room_id, occupant) VALUES (?, ?, ?)', {stationData.id, roomData.id, 'NaN'})
            end
            rawRoomData[stationData.id][roomData.id] = roomData
        end
    end

    local results = MySQL.query.await('SELECT motel_id, room_id FROM motel_rooms')
    for _, result in pairs(results) do
        local motel, room = result.motel_id, result.room_id
        local roomData = rawRoomData[motel][room]
        if not roomData.stash then return end

        local stashIdentifier = Shared.getStashIdentifier(motel, room)
        local stashLabel = locale('motel_stash_label', room)
        exports.ox_inventory:RegisterStash(stashIdentifier, stashLabel, roomData.stash.slots, roomData.stash.maxWeight)
    end
end)

local function isRoomAvailable(motelId, roomId)
    local occupant = MySQL.scalar.await('SELECT occupant FROM motel_rooms WHERE motel_id = ? AND room_id = ?', {motelId, roomId})
    return occupant == 'NaN'
end

local function getAllAvailableRooms(motelId)
    local availableRooms = {}
    local rooms = MySQL.query.await('SELECT occupant, room_id FROM motel_rooms WHERE motel_id = ?', {motelId})

    for _, room in pairs(rooms) do
        if room.occupant == 'NaN' then
            availableRooms[room.room_id] = true
        end
    end

    return availableRooms
end

lib.callback.register('motels:server:isRoomAvailable', function (_, motelId, roomId)
    if not roomId then
        return getAllAvailableRooms(motelId)
    end

    if type(roomId) == 'number' then
        return isRoomAvailable(motelId, roomId)
    end

    local availableRooms = {}
    for _, id in pairs(roomId) do
       availableRooms[id] = isRoomAvailable(motelId, id)
    end

    return availableRooms
end)