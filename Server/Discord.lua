--[[
	@Author: Gavin "Mullets" Rosenthal
	@Desc: Post to discord with this API module!
--]]

--// logic
local Discord = {}
Discord.Bots = {}

--// services
local LoadLibrary = require(game:GetService('ReplicatedStorage'):WaitForChild('PlayingCards'))
local Services = setmetatable({}, {__index = function(cache, serviceName)
    cache[serviceName] = game:GetService(serviceName)
    return cache[serviceName]
end})

--// function
function Discord.Post(bot,name,post)
	local getBot = Discord.Bots[bot]
	if getBot then
		local postData = Services['HttpService']:JSONEncode({username = name,content = post})
		Services['HttpService']:PostAsync(getBot, postData)
	end
end

function Discord.CreateBot(name,webhook)
	if not Discord.Bots[name] then
		Discord.Bots[name] = webhook
	end
end

return Discord