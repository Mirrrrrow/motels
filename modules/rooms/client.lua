---@type table<number, table<number, {motel: number, id: number, price: number, note: string, firstPrice: number, menuLabel: string, menuDescription: string}>>
local rooms = {}

local function rentRoom(motelId, roomId)
    local isRoomAvailable = lib.callback.await('motels:server:isRoomAvailable', false, motelId, roomId)
    if not isRoomAvailable then
        return lib.notify({
            description = locale('motel_rental_room_not_available'),
            type = 'error'
        })
    end

    local room = rooms[motelId][roomId]
    local priceToPay = room.price + room.firstPrice
    TriggerServerEvent('motels:server:rentRoom', motelId, roomId, priceToPay)
end

local function setupRooms(motelId, rawRooms)
    if not rooms[motelId] then rooms[motelId] = {} end

    for _, roomData in pairs(rawRooms --[[@as table<number, RawRoom>]]) do
        local room = {
            motel = motelId,
            id = roomData.id,
            price = roomData.price,
            note = roomData.note,
            firstPrice = roomData.firstPrice or 0,
        }
        room.menuLabel = locale('motel_rental_menu_room_title', room.id)
        if room.note then room.menuLabel = locale('motel_rental_menu_room_title_note', room.menuLabel, room.note) end

        room.menuDescription = locale('motel_rental_menu_room_description', room.price)

        rooms[motelId][room.id] = room
    end
end

local function formatMenuOptions(motelId)
    if not rooms[motelId] or #rooms[motelId] == 0 then return {} end

    ---@type table<number, ContextMenuItem>
    local options, num = {}, 0
    local availableRooms = lib.callback.await('motels:server:isRoomAvailable', false, motelId)

    for _, room in pairs(rooms[motelId]) do
        num = num + 1
        
        options[num] = {
            icon = availableRooms[room.id] and 'fas fa-door-open' or 'fas fa-door-closed',
            title = room.menuLabel,
            description = room.menuDescription,
            disabled = not availableRooms[room.id],
            onSelect = function (args)
                rentRoom(motelId, room.id)
            end
        }
    end

    return options
end

return {
    setupRooms = setupRooms,
    formatMenuOptions = formatMenuOptions
}