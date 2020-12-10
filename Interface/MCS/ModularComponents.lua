--[=[
	@Author: Gavin "Mullets" Rosenthal
	@Desc: Public Modular Component System. The only respectible way to handle Roblox UI
]=]

--[=[
	Modular Component System is a light weight component system designed
	for handling interface at a surface level. Components work with attributes
	so you won't have to do anything when Roblox enables them. ValueBase objects
	work perfectly fine as well.
	
[DOCUMENTATION]:
	This is an overview of how MCS works.
	
	This is the recommended way to initialize a component on a given tag:
	MCS('tag',function(component)
		-- code
	end)
	
	This is the recommended way to get the *first* component on a tag in PlayerGui:
	MCS('tag')
	
	Note the function, by excluding it you can shortcut this function to return a get instead of a create
	
	Standard API:
	
	MCS:Get(GuiObject)
		- Returns the component on a UI object
	
	MCS:GetAll('string')
		- Returns all components, in a table, on a given tag
	
	MCS:GetComponent('string')
		- Returns the first component on a tag in the PlayerGui
	
	MCS:Fire('string', ...)
		- Fire a binded function on a given name
	
	MCS:Create('string', function)
		- Create the component & pass it in the function
	
	MCS('string', function)
		- See MCS:Create
	
	MCS('string')
		- See MCS:GetComponent

[LICENSE]:
	MIT License
	
	Copyright (c) 2020 Mullet Mafia Dev
	
	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:
	
	The above copyright notice and this permission notice shall be included in all
	copies or substantial portions of the Software.
	
	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	SOFTWARE.
]=]

local MCS = {}
MCS.__index = MCS
MCS._ComponentCode = {}
MCS._ComponentCache = {}
setmetatable(MCS,MCS)

local Components = require(script:WaitForChild('Components'))
local Players = game:GetService('Players')
local CollectionService = game:GetService('CollectionService')

--[=[
	Bind & create a component with an element
	
	@param tag string -- the tag used
	@param element GuiObject -- the object used for the component
	@return nil
	@private
]=]
local function BindComponent(tag: string, element: GuiObject): nil
	if MCS._ComponentCache[tag][element] then return end
	
	local Player = Players.LocalPlayer
	local PlayerGui = Player.PlayerGui
	
	coroutine.wrap(function()
		while not element:IsDescendantOf(PlayerGui) do
			element.AncestryChanged:Wait()
		end
		
		local code = MCS._ComponentCode[tag]
		local create = Components.new(element)
		MCS._ComponentCache[tag][element] = create
		
		code(create)
	end)()
end

--[=[
	Return a component on an element
	
	@param element GuiObject -- the element to get a component from
]=]
function MCS:Get(element: GuiObject): typeof(MCS:Create())?
	for tag,data in pairs(MCS._ComponentCache) do
		for index,obj in pairs(data) do
			if index ~= element then continue end
			return obj
		end
	end
end

--[=[
	Returns all the components on a tag in PlayerGui
	
	@param tag string -- the tag to get from
]=]
function MCS:GetAll(tag: string): table
	return MCS._ComponentCache[tag]
end

--[=[
	Get the first component on a tag in the PlayerGui
	
	@param tag string
	@return Component?
]=]
function MCS:GetComponent(tag: string): typeof(MCS:Create())?
	local tags = MCS:GetAll(tag)
	for index,component in pairs(tags) do
		return component
	end
end

--[=[
	Fires a function with the tag
	
	@param name string -- the name of the binding
	@param ...? any -- optional parameters to pass
	@return nil
]=]
function MCS:Fire(name: string, ...): nil
	assert(Components._Bindings[name],"Attempted to fire non-existant binding on '"..name.."'")
	
	local code = Components._Bindings[name]
	code(...)
end

--[=[
	Create a component out of a collection service tag!
	
	@param tag string -- the CollectionService tag to track
	@param code function -- the function to run when you get a component
	@return nil
]=]
function MCS:Create(tag: string, code: (any) -> nil): nil
	assert(MCS._ComponentCache[tag] == nil,"tag is claimed")
	
	MCS._ComponentCache[tag] = {}
	MCS._ComponentCode[tag] = code
	
	CollectionService:GetInstanceAddedSignal(tag):Connect(function(component)
		BindComponent(tag,component)
	end)
	
	local tagged = CollectionService:GetTagged(tag)
	for index,component in pairs(tagged) do
		BindComponent(tag,component)
	end
end

--[=[
	Redirects to either Interface:Create() or Interface:GetComponent(), streamlines shortcutting to Interface()
	
	@param tag string -- the CollectionService tag to track
	@param code? function -- the function to run when you get a component
	@return typeof(MCS:Create())?
]=]
function MCS:__call(tag: string, code: ((any) -> nil)?): typeof(MCS:Create())?
	if not code and MCS._ComponentCache[tag] then
		return MCS:GetComponent(tag)
	end
	
	MCS:Create(tag,code)
end

return MCS