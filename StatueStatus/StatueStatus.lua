
_addon.name = 'StatueStatus'
_addon.author = 'Windower'
_addon.version = '1.0.0.3'
_addon.command = 'StatueStatus'


packets = require('packets')
config = require('config')
texts = require('texts')

defaults = {}
defaults.pos = {}
defaults.pos.x = -178
defaults.pos.y = 121
defaults.text = {}
defaults.text.font = 'Arial'
defaults.text.size = 14
defaults.flags = {}
defaults.flags.right = true

defaults.aurixtxt = {}
defaults.aurixtxt.pos = {}
defaults.aurixtxt.pos.x = -178
defaults.aurixtxt.pos.y = 141
defaults.aurixtxt.text = {}
defaults.aurixtxt.text.font = 'Arial'
defaults.aurixtxt.text.size = 14
defaults.aurixtxt.flags = {}
defaults.aurixtxt.flags.right = true


settings = config.load(defaults)
statue_textbox = texts.new('${value}', settings)
aurix_textbox = texts.new('${value}', settings.aurixtxt)
aurix_textbox:color(255,0,0)

debug.setmetatable(nil, {__index = {}, __call = functions.empty})

local statue_list = {}
local AurixIndex = 99999999999

windower.register_event('incoming chunk', function(id,original,modified,injected,blocked)
    if id == 0x00E then
		local packet = packets.parse('incoming', original)
		local index = packet["Index"]
		local mob = windower.ffxi.get_mob_by_index(index)
		if mob.name == "Corporal Tombstone" or mob.name == "Lithicthrower Image" or mob.name == "Incarnation Icon" or mob.name == "Impish Statue" then 
			local status = packet["_unknown4"]
			color = statue_list[index] or nil
			if (status == 458784) then color = "Green" end
			if (status == 393248) then color = "Blue" end
			if (status == 327712) then color = "Red" end
			if (color ~= "Green" and color ~= "Blue" and color ~= "Red") then 
				color = "Aurix" 
				AurixIndex = index
			end
			statue_list[index] = color
		end
	end
end)



windower.register_event('prerender', function()
    local t = windower.ffxi.get_mob_by_index(windower.ffxi.get_player().target_index or 0)
	if  statue_list[t.index] and (t.name == "Corporal Tombstone" or t.name == "Lithicthrower Image" or t.name == "Incarnation Icon" or t.name == "Impish Statue") then
		if statue_list[t.index] == "Green" then statue_textbox:color(0,255,0)
		elseif statue_list[t.index] == "Blue" then statue_textbox:color(0,0,255)
		elseif statue_list[t.index] == "Red" then statue_textbox:color(255,0,0)
		else statue_textbox:color(255,255,255)	end
		statue_textbox.value = statue_list[t.index]
	else
		statue_textbox.value = nil
	end
	local mobArray = windower.ffxi.get_mob_array()
	--aurix_textbox.value = nil
	local AurixVisible = false
	for i,v in pairs(mobArray) do
		local mob = windower.ffxi.get_mob_by_index(i)
		if mob.index == AurixIndex and (mob.status == 1 or mob.status == 0) and mob.distance < 2500 then
			local self_vector = windower.ffxi.get_mob_by_index(windower.ffxi.get_player().index or 0)
			local angle = (math.atan2((mob.y - self_vector.y), (mob.x - self_vector.x))*180/math.pi)*-1
			local direction = (angle):radian()
			local directionText = "None"
			AurixVisible = true
			if direction < 0.3925 and direction > -0.3925 then directionText = "E"
			elseif direction >= 0.3925 and direction < 1.1775 then directionText = "SE"
			elseif direction >= 1.1775 and direction < 1.9625 then directionText = "S"
			elseif direction >= 1.9625 and direction < 2.7475 then directionText = "SW"
			elseif direction >= 2.7475 or ( direction > -3.14 and direction < -2.7475 ) then directionText = "W"
			elseif direction >= -2.7475 and direction < -1.9625 then directionText = "NW"
			elseif direction >= -1.9625 and direction < -1.1775 then directionText = "N"
			elseif direction >= -1.1775 and direction < -0.3925 then directionText = "NE" end
			aurix_textbox.value = "Aurix is up! Yalms: "..math.floor(mob.distance:sqrt()).." Direction: "..directionText
		end
	end
	statue_textbox:visible(t ~= nil)
	aurix_textbox:visible(AurixVisible)
end)

windower.register_event('addon command', function(command)
    if command == 'save' then
        config.save(settings, 'all')
    end
end)