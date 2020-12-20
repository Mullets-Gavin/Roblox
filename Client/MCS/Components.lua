--[=[
	@Author: Gavin "Mullets" Rosenthal
	@Desc: Internal Modular Component System
]=]

--[=[
[DOCUMENTATION]:
	This is the component documentation, these APIs work with the component passed
	
	Standard API:
	
	component:Bind('string', function)
		- Bind a function to the given name
	
	component:Unbind('string')
		- Unbind the function on the given name
	
	component:Fire('string', ...)
		- Fire a function binded on a name with any extra parameters to pass
	
	component:Get('string')
		- Returns a component state located as an attribute or ValueBase on/in a Configuration [a class]
	
	component:Set('string', variant)
		- Set a variant on an already existing ValueBase or create an attribute
	
	component:Update('string', variant)
		- Similar to :Set, this API will increment numbers but set everything else & requires
		the state to already be existing
	
	component:Attribute('string', function)
		- Don't be scared of the name, Attribute hooks a function to a given name on an already
		existing attribute or ValueBase. Unlike Roblox, I pass the changed value. Please support:
		https://devforum.roblox.com/t/getpropertychangedsignal-should-include-the-new-value-in-the-callback/108616/11?u=mullets_gavin
		
	component:Connect(GuiObject, 'string', function)
		- Connect a valid event to a GuiObject & hook the function, for example:
		component:Connect(TextButton, 'MouseButton1Click', function()
			print('click!')
		end)
	
	component:Lifecycle('name', function)
		- This Lifecycle method binds a function to RenderStepped & runs the code as long as the
		element is Visible = true
	
	component('string')
		- See component:Get
	
	component('string', variant)
		- See component:Set
	
	component.[index]
		- A custom index function which allows you to provide unknown children/props to the index
		on the component. This allows you to set everything on the same level:
		
		Heirarchy:
			Frame -- this is the tagged component
			└─ Title -- this is a direct child
		
		component.Frame.Title == component.Title
]=]

local Components = {}
Components._Name = 'Modular Component System'
Components._Error = '[MCS]: '
Components._Bindings = {}

local RunService = game:GetService('RunService')

--[=[
	Construct a new component out of a pre-existing element
	
	@param element GuiObject -- the main component
	@return Class
]=]
function Components.new(element: GuiObject): typeof(Components.new())
	local config = element:FindFirstChildWhichIsA('Configuration') do
		if not config then
			config = Instance.new('Configuration')
			config.Name = 'MCS_'..element.Name
			config.Parent = element
		end
	end
	
	return setmetatable({
		element = element;
		config = config;
	},Components)
end

--[=[
	Bind a function to a codename
	
	@param name string -- the name of the binding
	@param code function -- the function to bind
	@return nil
]=]
function Components:Bind(name: string, code: (any) -> nil): nil
	assert(Components._Bindings[name] == nil,"Attempted to overwrite binding on '"..name.."'")
	
	Components._Bindings[name] = code
end

--[=[
	Unbind a codename
	
	@param name string -- the name of the binding
	@return nil
]=]
function Components:Unbind(name: string): nil
	Components._Bindings[name] = nil
end

--[=[
	Fire a binded function on a codename
	
	@param name string -- the name of the binding
	@param ...? any -- optional parameters to pass
	@return nil
]=]
function Components:Fire(name: string, ...): nil
	assert(Components._Bindings[name],"Attempted to fire a non-existant binding on '"..name.."'")
    
    local data = {...}
	local code = Components._Bindings[name]
	coroutine.wrap(function()
        code(table.unpack(data))
    end)
end

--[=[
	Get an attribute value on the component. Checks for value objects first
	
	@param name string -- name of the attribute
	@return Value any?
]=]
function Components:Get(name: string): any?
	local obj = self.config:FindFirstChild(name)
	
	if obj then
		return obj.Value
	else
		return self.config:GetAttribute(name)
	end
end

--[=[
	Set an attribute value on the component. Checks for value objects first
	
	@param name string -- name of the attribute
	@param value any -- the value to set on an attribute
	@return Value any
]=]
function Components:Set(name: string, value: any): any?
	local obj = self.config:FindFirstChild(name)
	
	if obj then
		obj.Value = value
	else
		self.config:SetAttribute(name,value)
	end
	
	return value
end

--[=[
	Update a known attribute with a value & increment numbers
	
	@param name string -- the name of the attribute
	@param value any -- the value to update on an attribute
	@return Value any
]=]
function Components:Update(name: string, value: any): any
	local get = self:Get(name)
	
	assert(get ~= nil,Components._Error.."Attempted to update nil attribute '"..name.."'")
	
	if typeof(get) == 'number' and typeof(value) == 'number' then
		get += value
		self:Set(name,get)
	else
		self:Set(name,value)
	end
	
	return self:Get(name)
end

--[=[
	Bind a function to an attribute that changes. Checks for value objects first
	
	@param name string -- the name of the attribute
	@param code function -- the function to connect
	@return RBXScriptConnection
]=]
function Components:Attribute(name: string, code: (any, any) -> nil): RBXScriptConnection
	local last = self:Get(name)
	
	assert(last ~= nil,Components._Error.."Attempted to bind to nil attribute '"..name.."'")
	
    coroutine.wrap(function()
        code(last,last)
    end)
	
	local obj = self.config:FindFirstChild(name)
	local signal; do
		if obj then
			signal = obj.Changed:Connect(function(new)
				coroutine.wrap(function()
                    code(new,last)
                end)
				
				last = new
			end)
		else
			signal = self.config:GetAttributeChangedSignal(name):Connect(function()
				local new = self:Get(name)
				
				coroutine.wrap(function()
                    code(new,last)
                end)
				
				last = new
			end)
		end
	end
	
	return signal
end

--[=[
	Connect an event to a GuiObject apart of the component
	
	@param object GuiObject -- the object to connect
	@param event string -- the connection type
	@param code function -- the function to connect
	@return RBXScriptSignal
]=]
function Components:Connect(object: GuiObject, event: string, code: (any) -> nil): RBXScriptConnection
	local signal = object[event]:Connect(function(...)
		code(...)
	end)
	
	return signal
end

--[=[
	Hook a function to a lifecycle event which fires when the component is visible
	
	@param name string -- the name of the lifecycle
	@param code function -- the function to run
	@return RBXScriptConnection
]=]
function Components:Lifecycle(name: string, code: (number) -> nil): RBXScriptConnection
	local signal = RunService.RenderStepped:Connect(function(delta)
		if self.element.Visible then
			code(delta)
		end
	end)
	
	
	return signal
end

--[=[
	A custom index method which handles unknown or known indices
	
	@param index any -- the index being called on the component
	@return any?
]=]
function Components:__index(index: any): any?
	if Components[index] then
		return Components[index]
	end
	
	if index == self.element.Name then
		return self.element
	end
	
	if self.element[index] then
		return self.element[index]
	end
	
	error(index..' is not a valid member of '..self.element:GetFullName()..' "'..self.element.ClassName..'"',2)
end

--[=[
	Shorten getting an attribute attached to the component
	
	@param name string -- name of the component
	@param value any? -- include this to also set the component state
	@return Value any
]=]
function Components:__call(name: string, value: any?): any?
	if value ~= nil then
		self:Set(name,value)
	end
	
	return self:Get(name)
end

return Components