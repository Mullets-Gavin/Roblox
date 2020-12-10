--[=[
	@Author: Gavin "Mullets" Rosenthal
	@Desc: An Animation library for GuiObjects
]=]

--[=[
[DOCUMENTATION]:
	Simply use Tiffany's tag editor & apply the tags listed below
	to GuiObjects which take the given events!
	
	Tag editor:
	https://www.roblox.com/library/948084095/Tag-Editor

	How to add more events:
	This lib is very flexible & allows you to set your own functions! Simply
	create a new function with the following format:
	
Animator['tag_name'] = function(element: GuiObject): nil
	-- code
end

	This follows the Luau typed standard & also provides the GuiObject. You should not be setting
	UI_ in front of the tag in the function, this is set upon run time when searching for tags.

[TAGS]:
	MouseButton1Click:
		UI_BounceUp
		UI_BounceDown
		
	MouseButton1Down:
		
	MouseButton1Up:
		
	MouseEnter:
		UI_Grow
		
	MouseLeave:
		UI_Reset
]=]

local Animator = {}
Animator.Cache = {}
Animator.Original = {}
Animator.Bouncers = {}
Animator.Prefix = 'UI_'
Animator.TagList = {
	['MouseButton1Click'] = {'BounceUp','BounceDown'};
	['MouseButton1Down'] = {};
	['MouseButton1Up'] = {};
	['MouseEnter'] = {'Grow',''};
	['MouseLeave'] = {'Reset'};
}

local HttpService = game:GetService('HttpService')
local TweenService = game:GetService('TweenService')
local CollectionService = game:GetService('CollectionService')

local Length = 0.1 -- the time it takes to complete an animation, I recommend short & snappy
local Scale = 0.1 -- the scale of the UI (0.1 = 10%), if your UI uses offset, this will be pixels

--[=[
	Create and play a tween
	
	@param object Instance -- the instance to tween
	@param properties table -- a list of the properties
	@param goals table | any -- either a list of goals to fit properties, or a single goal
	@param duration? number -- how long the tween lasts
	@param style EnumItem -- an Enum.EasingStyle
	@param direction EnumItem -- an Enum.EasingDirection
	@return TweenObject
]=]
local function Tween(object: Instance, properties: table, goals: any | table, duration: number?, style: EnumItem?, direction: EnumItem?): TweenObject
	duration = typeof(duration) == 'number' and duration or 0.5
	style = typeof(style) == 'EnumItem' and style or Enum.EasingStyle.Linear
	direction = typeof(direction) == 'EnumItem' and direction or Enum.EasingDirection.InOut
	
	local values = {}; do
		for index,prop in pairs(properties) do
			values[prop] = typeof(goals) == 'table' and goals[index] or goals
		end
	end
	
	local info = TweenInfo.new(duration,style,direction)
	local tween = TweenService:Create(object,info,values)
	tween:Play()
	
	return tween
end

--[=[
	Debounce a function & return a result if one is provided
	
	@param key string -- the key of the debounce
	@param code function -- the function to wait for
	@return boolean | (any?)
]=]
function Debounce(key: any, code: (any) -> nil, ...): boolean | (any?)
	if Animator.Bouncers[key] then return false end
	Animator.Bouncers[key] = true
	
	local result = code(...)
	
	Animator.Bouncers[key] = false
	return result
end

--------------------
-- Common Effects --
--------------------
Animator['FadeOut'] = function(element: GuiObject): nil
	
end

Animator['FadeAll'] = function(element: GuiObject): nil
	
end

-----------------------
-- MouseButton1Click --
-----------------------
Animator['BounceUp'] = function(element: GuiObject): nil
	local original = Animator.Original[element]
	
	local increment = 1 - Scale
	local goal; do
		if original.Position.X.Scale > 0 and original.Position.X.Offset == 0 then
			goal = UDim2.fromScale(original.Position.X.Scale,original.Position.Y.Scale * increment)
		elseif original.Position.X.Offset > 0 and original.Position.X.Scale == 0 then
			goal = UDim2.fromOffset(original.Position.X.Offset,original.Position.Y.Offset * increment)
		end
	end
	
	local tween = Tween(element,{'Position'},{goal},Length)
	tween.Completed:Wait()
	tween = Tween(element,{'Position'},{original.Position},Length)
	tween.Completed:Wait()
end

Animator['BounceDown'] = function(element: GuiObject): nil
	local original = Animator.Original[element]
	
	local increment = Scale + 1
	local goal; do
		if original.Position.X.Scale > 0 and original.Position.X.Offset == 0 then
			goal = UDim2.fromScale(original.Position.X.Scale,original.Position.Y.Scale * increment)
		elseif original.Position.X.Offset > 0 and original.Position.X.Scale == 0 then
			goal = UDim2.fromOffset(original.Position.X.Offset,original.Position.Y.Offset * increment)
		end
	end
	
	local tween = Tween(element,{'Position'},{goal},Length)
	tween.Completed:Wait()
	tween = Tween(element,{'Position'},{original.Position},Length)
	tween.Completed:Wait()
end

----------------
-- MouseEnter --
----------------
Animator['Grow'] = function(element: GuiObject): nil
	local original = Animator.Original[element]
	
	local increment = Scale + 1
	local goal; do
		if original.Size.X.Scale > 0 and original.Size.X.Offset == 0 then
			goal = UDim2.fromScale(original.Size.X.Scale * increment,original.Size.Y.Scale * increment)
		elseif original.Size.X.Offset > 0 and original.Size.X.Scale == 0 then
			goal = UDim2.fromOffset(original.Size.X.Offset * increment,original.Size.Y.Offset * increment)
		end
	end
	
	local tween = Tween(element,{'Size'},{goal},Length)
	tween.Completed:Wait()
end

----------------
-- MouseLeave --
----------------
Animator['Reset'] = function(element: GuiObject): nil
	local original = Animator.Original[element]
	
	local prop,value = {},{}
	for index,base in pairs(original) do
		table.insert(prop,index)
		table.insert(value,base)
	end
	
	local tween = Tween(element,prop,value,Length)
	tween.Completed:Wait()
end

-----------------
-- Connections --
-----------------
local function ConnectAnimation(element: GuiObject, event: string, tag: string): nil
	local identifier = event..'_'..tag..'_'..tostring(element)
	if Animator.Cache[element] and Animator.Cache[element][identifier] then return end
	
	local IsImage = element:IsA('ImageButton') or element:IsA('ImageLabel')
	
	if not Animator.Original[element] then
		Animator.Original[element] = {
			AnchorPoint = element.AnchorPoint;
			Position = element.Position;
			Size = element.Size;
			
			BackgroundColor3 = element.BackgroundColor3;
			BackgroundTransparency = element.BackgroundTransparency;
			BorderColor3 = element.BorderColor3;
			
			ImageColor3 = IsImage and element.ImageColor3 or nil;
			ImageTransparency = IsImage and element.ImageTransparency or nil;
		}
	end
	
	local guid = HttpService:GenerateGUID(false)
	local code = Animator[string.sub(tag,#Animator.Prefix + 1)]
	local signal = element[event]:Connect(function(...)
		local data = {...}
		
		Debounce(guid,function()
			code(element,table.unpack(data))
		end)
	end)
	
	if not Animator.Cache[element] then
		Animator.Cache[element] = {}
	end
	
	Animator.Cache[element][identifier] = signal
end

local function ConnectTag(event: string, tag: string): nil
	CollectionService:GetInstanceAddedSignal(tag):Connect(function(element: GuiObject)
		ConnectAnimation(element,event,tag)
	end)
	
	local Tagged = CollectionService:GetTagged(tag)
	for index,element in pairs(Tagged) do
		ConnectAnimation(element,event,tag)
	end
end

for event,list in pairs(Animator.TagList) do
	for count,tag in pairs(list) do
		tag = Animator.Prefix..tag
		ConnectTag(event,tag)
	end
end

return Animator