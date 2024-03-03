---@type table<number, table<number, RawRoom>>
local rawRoomData = {}

local function syncRoomsToDB(stationId, rooms)
    if not rawRoomData[stationId] then
        rawRoomData[stationId] = {}
    end

    for _, roomData in pairs(rooms) do
        local count = MySQL.scalar.await('SELECT COUNT(*) AS count FROM motel_rooms WHERE motel_id = ? AND room_id = ?', {stationId, roomData.id})
        if count == 0 then
            MySQL.insert.await('INSERT INTO motel_rooms (motel_id, room_id, occupant) VALUES (?, ?, ?)', {stationId, roomData.id, 'NaN'})
        end
        rawRoomData[stationId][roomData.id] = roomData
    end
end

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

        syncRoomsToDB(stationData.id, stationData.rooms)
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

RegisterServerEvent('motels:server:rentRoom', function (motelId, roomId, price)
    local rawRoom = rawRoomData[motelId][roomId]
    if not rawRoom then return end
    if not isRoomAvailable(motelId, roomId) then return end

    if price ~= (rawRoom.price + (rawRoom.firstPrice or 0)) then return end

    local playerId = source
    local xPlayer = ESX.GetPlayerFromId(playerId)
    if not xPlayer then return end

    if xPlayer.getAccount('bank').money < price then
        return lib.notify(playerId, {
            description = locale('motel_rental_room_not_enough_money', price),
            type = 'error'
        })
    end

    xPlayer.removeAccountMoney('bank', price)
    -- DB: Update room occupant and notify player
end)

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