--// logic
local Info = {}
Info.Connections = {}
Info.Name = nil
Info.Creator = nil
Info.Version = nil
Info.Updated = nil
Info.Outdated = false
Info.Server = nil

--// services
local Services = setmetatable({}, {__index = function(cache, serviceName)
    cache[serviceName] = game:GetService(serviceName)
    return cache[serviceName]
end})

--// functions
function Info.Hook(func)
	if typeof(func) == 'function' then
		table.insert(Info.Connections,func)
	end
	func(Info.Outdated)
end

function Info:Update()
	if Services['RunService']:IsStudio() then return end
	local GetInfo = Services['MarketplaceService']:GetProductInfo(game.PlaceId)
	Info.Updated = GetInfo['Updated']
	if Info.Updated ~= Info.Version then
		Info.Outdated = true
		warn('[INFORMATION]: This server is outdated. Server Version:',Info.Version,'| Game Version:',Info.Updated)
	end
	for index,connections in pairs(Info.Connections) do
		connections(Info.Outdated)
	end
	return Info.Outdated
end

function Info:Retrieve()
	local contents = {
		['Name'] = Info.Name;
		['Creator'] = Info.Creator;
		['Version'] = Info.Version;
		['Updated'] = Info.Updated;
		['Outdated'] = Info.Outdated;
		['Server'] = Info.Server;
	}
	return contents
end

function Info:Initialize()
	if Services['RunService']:IsStudio() then return end
	local GetInfo = Services['MarketplaceService']:GetProductInfo(game.PlaceId)
	Info.Name = GetInfo['Name']
	Info.Version = GetInfo['Updated']
	Info.Updated = GetInfo['Updated']
	if Services['RunService']:IsStudio() then
		Info.Server = 'Studio'
	else
		Info.Server = game.JobId
	end
	if game.CreatorType == Enum.CreatorType.Group then
		local get = Services['GroupService']:GetGroupInfoAsync(game.CreatorId)
		Info.Creator = get['Name']
	elseif game.CreatorType == Enum.CreatorType.User then
		local get = Services['Players']:GetNameFromUserIdAsync(game.CreatorId)
		Info.Creator = get
	end
	while wait(60) do
		Info:Update()
	end
end

return Info