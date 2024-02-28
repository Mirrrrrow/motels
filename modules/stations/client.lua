local rooms = require 'modules.rooms.client'
local stations = {}

local function requestRentalMenu(motelId)
    local motelStation = stations[motelId]

    local menuId = 'motel_rental_' ..motelId
    lib.registerContext({
        id = menuId,
        title = locale('motel_rental_menu_title', motelStation.name),
        options = rooms.formatMenuOptions(motelId)
    })
    lib.showContext(menuId)
end

local spawnPed = require 'modules.ped.client'.spawn
local createBlip = require 'modules.blip.client'.create
for _, stationData in ipairs(lib.load('data.motels') --[[@as table<number, RawMotelStation>]]) do
    local station = {
        id = stationData.id,
        name = stationData.name,
    }
    local ped = stationData.ped
    if not ped then return end

    station.ped = spawnPed(ped.model, ped.coords, ped.scenario)

    local blip = stationData.blip
    if blip then
        stations.blip = createBlip(blip.sprite, 0.69, blip.colour, station.name, blip.coords.x, blip.coords.y, blip.coords.z)
    end

    exports.ox_target:addLocalEntity(station.ped, {
        label = locale('target_open_label', station.name),
        icon = 'fas fa-hotel',
        onSelect = function (data)
            requestRentalMenu(station.id)
        end
    })

    stations[station.id] = station
    rooms.setupRooms(station.id, stationData.rooms)
end

--- @class RawMotelStation
--- @field id number;
--- @field name string;
--- @field ped {coords: vector4, scenario: string?, model: string|number};
--- @field blip {coords: vector3, sprite: number, colour: number}?;
--- @field rooms RawRoom[];

--- @class RawRoom
--- @field id number;
--- @field price number;
--- @field note? string;