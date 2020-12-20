--// logic
local LoadString = {}

--// services
local LoadLibrary = require(game:GetService('ReplicatedStorage'):WaitForChild('PlayingCards'))
local Services = setmetatable({}, {__index = function(cache, serviceName)
    cache[serviceName] = game:GetService(serviceName)
    return cache[serviceName]
end})

--// functions
function LoadString:Execute(code)
	print('[LOADSTRING]: Code is being executed:')
	Services['RunService'].Heartbeat:Wait()
	print('>',code)
	Services['RunService'].Heartbeat:Wait()
	local success,err = pcall(function()
		loadstring(code)()
	end)
	Services['RunService'].Heartbeat:Wait()
	if not success then
		warn('[LOADSTRING]: Code failed to run:')
		Services['RunService'].Heartbeat:Wait()
		warn('>',err)
	end
end

return LoadString