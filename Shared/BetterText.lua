--[[
	@Author: Gavin "Mullets" Rosenthal
	@Desc: I made this out of spite, scales text to be Good and fair in a textbox with character limits
--]]

--// logic
local BetterText = {}

--// services
local LoadLibrary = require(game:GetService('ReplicatedStorage'):WaitForChild('PlayingCards'))
local Services = setmetatable({}, {__index = function(cache, serviceName)
    cache[serviceName] = game:GetService(serviceName)
    return cache[serviceName]
end})

--// functions
function BetterText.ScaleFont(textboxObj,characterLimit)
	assert(typeof(textboxObj) == 'Instance','The textboxObj argument must be a TextBox or TextLabel Instance')
	textboxObj.TextScaled = false
	textboxObj.TextWrapped = true
	textboxObj.TextTruncate = Enum.TextTruncate.AtEnd
	if BetterText[characterLimit] then
		if BetterText[characterLimit]['Size'] == textboxObj.AbsoluteSize.X + textboxObj.AbsoluteSize.Y then
			textboxObj.TextSize = BetterText[characterLimit]['Font']
			return BetterText[characterLimit]
		end
	end
	local newFontSize = 100
	local lastText = textboxObj.Text
	local tempText = ''
	for index = 1, characterLimit do
		if index % 2 == 0 then
			tempText = tempText .. ' '
		else
			tempText = tempText .. tostring(math.random(1,9))
		end
	end
	textboxObj.Text = tempText
	for index = 100, 1, -1 do
		textboxObj.TextSize = index
		if textboxObj.TextFits then
			newFontSize = index
			break
		end
	end
	textboxObj.Text = lastText
	BetterText[characterLimit] = {}
	BetterText[characterLimit]['Font'] = newFontSize
	BetterText[characterLimit]['Size'] = textboxObj.AbsoluteSize.X + textboxObj.AbsoluteSize.Y
	return newFontSize
end

function BetterText.LetterByLetter(textboxObj,characterLimit)
	local current = textboxObj.Text
	local TimeToTake = #current/30
	local Accumulated = 0
	textboxObj.Text = ''
	while TimeToTake > Accumulated do
		Accumulated = Accumulated + Services['RunService'].Heartbeat:Wait()
		textboxObj.Text = string.sub(current, 1, math.floor((Accumulated/TimeToTake) * #current))
		if characterLimit then
			BetterText.ScaleFont(textboxObj,characterLimit)
		end
	end
end

function BetterText.FormatListText(textFrame)
	assert(typeof(textFrame) == 'Instance','The textFrame argument must be a Frame Instance')
	for index,obj in pairs(textFrame:GetChildren()) do
		if obj:IsA('TextBox') or obj:IsA('TextLabel') or obj:IsA('TextButton') then
			local currentY = obj.Size.Y.Scale
			obj.Size = UDim2.new(1,0,currentY,0)
			local textX = obj.TextBounds.X
			obj.Size = UDim2.new(0,textX,currentY,0)
		end
	end
end

return BetterText