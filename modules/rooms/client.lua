local rooms = {}

local function setupRooms(motelId, rawRooms)
    if not rooms[motelId] then rooms[motelId] = {} end

    for _, roomData in pairs(rawRooms --[[@as table<number, RawRoom>]]) do
        local room = {
            motel = motelId,
            id = roomData.id,
            price = roomData.price,
            note = roomData.note
        }
        room.menuLabel = locale('motel_rental_menu_room_title', room.id)
        if room.note then room.menuLabel = locale('motel_rental_menu_room_title_note', room.menuLabel, room.note) end

        room.menuDescription = locale('motel_rental_menu_room_description', room.price)

        rooms[motelId][room.id] = room
    end
end

local function formatMenuOptions(motelId)
    if not rooms[motelId] or #rooms[motelId] == 0 then return {} end

    local options, num = {}, 0
    for _, room in pairs(rooms[motelId]) do
        num = num + 1
        options[num] = {
            icon = 'fas fa-door-open',
            title = room.menuLabel,
            description = room.menuDescription,
            disabled = false
        }
    end

    return options
end

return {
    setupRooms = setupRooms,
    formatMenuOptions = formatMenuOptions
}