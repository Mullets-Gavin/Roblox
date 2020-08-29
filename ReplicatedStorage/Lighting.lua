--[[
	@Author: Gavin "Mullets" Rosenthal
	@Desc: Day 'n Night script + adjust lighting
--]]

--// logic
local Lighting = {}
Lighting.Times = {
	['Day'] = 360;
	['Night'] = 150;
}

--// services
local LoadLibrary = require(game:GetService('ReplicatedStorage'):WaitForChild('PlayingCards'))
local Services = setmetatable({}, {__index = function(cache, serviceName)
    cache[serviceName] = game:GetService(serviceName)
    return cache[serviceName]
end})

--// functions
function Lighting.Day()
	local toDay = Services['TweenService']:Create(Services['Lighting'],TweenInfo.new(5,Enum.EasingStyle.Exponential),{ClockTime = 8})
	toDay:Play()
	toDay.Completed:Wait()
	local stayDay = Services['TweenService']:Create(Services['Lighting'],TweenInfo.new(Lighting.Times.Day),{ClockTime = 16})
	stayDay:Play()
	stayDay.Completed:Wait()
end

function Lighting.Night()
	local toNight = Services['TweenService']:Create(Services['Lighting'],TweenInfo.new(5,Enum.EasingStyle.Exponential),{ClockTime = 20})
	toNight:Play()
	toNight.Completed:Wait()
	local toMidnight = Services['TweenService']:Create(Services['Lighting'],TweenInfo.new(Lighting.Times.Night/2),{ClockTime = 24})
	toMidnight:Play()
	toMidnight.Completed:Wait()
	Services['Lighting'].ClockTime = 1
	local toMorning = Services['TweenService']:Create(Services['Lighting'],TweenInfo.new(Lighting.Times.Night/2),{ClockTime = 4})
	toMorning:Play()
	toMorning.Completed:Wait()
end

function Lighting.Cycle()
	Services['Lighting'].ClockTime = 4
	while true do
		Lighting.Day()
		Lighting.Night()
	end
end

return Lighting