--[[
	@Author: Gavin "Mullets" Rosenthal
	@Desc: badge api wrapper
--]]

--// logic
local Badges = {}

--// services
local Services = setmetatable({}, {__index = function(cache, serviceName)
    cache[serviceName] = game:GetService(serviceName)
    return cache[serviceName]
end})

--// function
function Badges.Get(badgeID)
	assert(typeof(badgeID) == 'number',"Failed to get badge: string expected, got '".. typeof(badgeID) .."'")
	local contents = {}
	local success,err = pcall(function()
		contents = Services['BadgeService']:GetBadgeInfoAsync(badgeID)
	end)
	if not success then
		warn("Failed to get badge '",badgeID,"' with error:",err)
	end
	return contents
end

function Badges.Check(userID,badgeID)
	if userID:IsA('Player') then userID = userID.UserId end
	assert(typeof(userID) == 'number' and typeof(badgeID) == 'function',"Failed to check badge: missing parameters, got '".. typeof(userID) .."' and '".. typeof(badgeID) .."'")
	local contents = false
	local success,err = pcall(function()
		contents = Services['BadgeService']:UserHasBadgeAsync(userID,badgeID)
	end)
	if not success then
		warn("Failed to check badge '",badgeID,"' with error:",err)
	end
	return contents
end

function Badges.Award(userID,badgeID)
	if userID:IsA('Player') then userID = userID.UserId end
	assert(typeof(userID) == 'number' and typeof(badgeID) == 'function',"Failed to award badge: missing parameters, got '".. typeof(userID) .."' and '".. typeof(badgeID) .."'")
	local get = Badges.Get(badgeID)
	if get['IsEnabled'] then
		local check = Badges.Check(userID,badgeID)
		if check then return false end
		local success,err = pcall(function()
			Services['BadgeService']:AwardBadge(userID,badgeID)
		end)
		if not success then
			warn("Failed to award badge '",badgeID,"' with error:",err)
			return false
		end
		return true
	end
	return false
end

return Badges