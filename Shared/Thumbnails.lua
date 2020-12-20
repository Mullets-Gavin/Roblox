--[[
	@Author: Gavin "Mullets" Rosenthal
	@Desc: A thumbnails API module created for proper caching
--]]

--// logic
local Thumbnail = {}
Thumbnail.HeadshotCache = {}
Thumbnail.AvatarCache = {}
Thumbnail.BustCache = {}

--// services
local LoadLibrary = require(game:GetService('ReplicatedStorage'):WaitForChild('PlayingCards'))
local Services = setmetatable({}, {__index = function(cache, serviceName)
    cache[serviceName] = game:GetService(serviceName)
    return cache[serviceName]
end})

--// functions
function Thumbnail.Headshot(id,size)
	if not Thumbnail.HeadshotCache[id] then
		local timeout = tick()
		local pic,ready
		repeat 
			local success,err = pcall(function()
				size = size or Enum.ThumbnailSize.Size420x420
				pic,ready = Services['Players']:GetUserThumbnailAsync(id,Enum.ThumbnailType.HeadShot,size)
				end)
			if success then
				Thumbnail.HeadshotCache[id] = pic
			end
		until ready or tick() - timeout >= 5
	end
	if not Thumbnail.HeadshotCache[id] then
		return 'http://www.roblox.com/asset/?id=3143448237'
	end
	return Thumbnail.HeadshotCache[id]
end
	
function Thumbnail.Avatar(id,size)
	if not Thumbnail.AvatarCache[id] then
		local timeout = tick()
		local pic,ready
		repeat 
			local success,err = pcall(function()
				size = size or Enum.ThumbnailSize.Size420x420
				pic,ready = Services['Players']:GetUserThumbnailAsync(id,Enum.ThumbnailType.AvatarThumbnail,size)
				end)
			if success then
				Thumbnail.AvatarCache[id] = pic
			end
		until ready or tick() - timeout >= 5
	end
	if not Thumbnail.AvatarCache[id] then
		return 'http://www.roblox.com/asset/?id=3143448237'
	end
	return Thumbnail.AvatarCache[id]
end

function Thumbnail.Bust(id,size)
	if not Thumbnail.BustCache[id] then
		local timeout = tick()
		local pic,ready
		repeat 
			local success,err = pcall(function()
				size = size or Enum.ThumbnailSize.Size420x420
				pic,ready = Services['Players']:GetUserThumbnailAsync(id,Enum.ThumbnailType.AvatarBust,size)
				end)
			if success then
				Thumbnail.BustCache[id] = pic
			end
		until ready or tick() - timeout >= 5
	end
	if not Thumbnail.BustCache[id] then
		return 'http://www.roblox.com/asset/?id=3143448237'
	end
	return Thumbnail.BustCache[id]
end

return Thumbnail