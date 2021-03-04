--[=[
	Construct instances easily

	Inspired by "Make" by Validark, see:
	https://github.com/Validark/Roblox-TS-Libraries/tree/master/make
]=]

local CollectionService = game:GetService("CollectionService")

local Construct = {}
Construct.__index = Construct
Construct._Refs = {}
Construct._State = {}
Construct._Blacklist = { "Children", "Constructor", "Parent", "Name", "Key", "Attributes", "Tags", "Event", "Ref" }

local function Copy(master)
	local clone = {}

	for key, value in pairs(master) do
		if typeof(value) == "table" then
			clone[key] = Copy(value)
		else
			clone[key] = value
		end
	end

	return clone
end

local function Wrap(callback, ...)
	local thread = coroutine.create(callback)
	local ran, response = coroutine.resume(thread, ...)

	if not ran then
		local trace = debug.traceback(thread)
		error(response .. "\n" .. trace, 2)
	end
end

local function Build(instance, settings, children)
	children = children or settings.Children

	local attributes = typeof(settings.Attributes) == "table" and settings.Attributes[1] or settings.Attributes
	local tags = typeof(settings.Tags) == "table" and settings.Tags[1] or settings.Tags

	for setting, value in pairs(settings) do
		value = typeof(value) == "table" and value[1] or value

		if not table.find(Construct._Blacklist, setting) then
			local prop = instance[setting]

			if typeof(prop) == "RBXScriptSignal" then
				prop:Connect(value)
			else
				instance[setting] = value
			end
		elseif setting == "Key" then
			instance.Name = value
		end
	end

	if attributes then
		for index, value in pairs(attributes) do
			local success, response = pcall(function()
				return instance:SetAttribute(index, value)
			end)

			if not success then
				warn("Could not set attribute '" .. index .. "' with response:", response)
			end
		end
	end

	if tags then
		for _, tag in pairs(tags) do
			if CollectionService:HasTag(instance, tag) then
				continue
			end

			CollectionService:AddTag(instance, tag)
		end
	end

	if children then
		for _, child in ipairs(children) do
			child.Parent = instance
		end
	end

	return instance
end

local Executer = {} do
	Executer.__index = Executer

	function Executer.new(callback)
		return setmetatable({
			callback = callback,
		}, Executer)
	end

	function Executer:Destroy()
		self.callback()
	end

	function Executer:Disconnect()
		self.callback()
	end

	function Executer:__call(callback)
		return self.new(callback)
	end

	Executer = setmetatable(Executer, Executer)
end

local Changed = {} do
	Changed._StateCache = {}
	Changed._RefCache = {}
	Changed._PropCache = {}

	function Changed:State(key, callback)
		assert(key ~= nil, "Attempted to connect a state change event to a nil key")
		assert(
			typeof(callback) == "function",
			"State Changed expected a function for parameter 2, got '" .. typeof(callback) .. "'"
		)

		Changed._StateCache[key] = callback

		return Executer(function()
			Changed._StateCache[key] = nil
		end)
	end

	function Changed:Ref(key, callback) -- TODO: write ref callback code
		assert(key ~= nil, "Attempted to connect a ref change event to a nil key")
		assert(
			typeof(callback) == "function",
			"Ref Changed expected a function for parameter 2, got '" .. typeof(callback) .. "'"
		)

		Changed._RefCache[key] = callback

		return Executer(function()
			Changed._RefCache[key] = nil
		end)
	end

	function Changed:Prop(prop, callback) -- TODO: write prop callback code
		assert(prop ~= nil, "Attempted to connect a ref change event to a nil key")
		assert(
			typeof(callback) == "function",
			"Ref Changed expected a function for parameter 2, got '" .. typeof(callback) .. "'"
		)

		Changed._PropCache[prop] = callback

		return Executer(function()
			Changed._PropCache[prop] = nil
		end)
	end

	Construct.Changed = Changed
end

function Construct.new(className, settings, children)
	local instance = Build(Instance.new(className), settings, children)
	local parent = typeof(settings.Parent) == "table" and settings.Parent[1] or settings.Parent
	local events = typeof(settings.Events) == "table" and settings.Events or settings.Events and { settings.Events }
	local ref = typeof(settings.Ref) == "table" and settings.Ref[1] or settings.Ref
	local constructor = typeof(settings.Constructor) == "table" and settings.Constructor[1] or settings.Constructor

	if ref then
		Construct._Refs[ref] = instance
	end

	instance.Parent = parent
	if constructor then
		constructor()
	end
	
	return setmetatable({
		_obj = instance,
		_events = events,
		_ref = ref,
	}, Construct)
end

function Construct.extend(instance)
	return setmetatable({
		_obj = instance,
		_state = {},
	}, Construct)
end

function Construct:Update(settings, children)
	assert(self._obj, "No constructed component info exists")

	local instance = Build(self._obj, settings, children)
	local parent = typeof(settings.Parent) == "table" and settings.Parent[1] or settings.Parent
	local events = typeof(settings.Events) == "table" and settings.Events or settings.Events and { settings.Events }
	local ref = typeof(settings.Ref) == "table" and settings.Ref[1] or settings.Ref

	instance.Parent = parent or instance.Parent
	self._events = events or self._events
	self._ref = ref or self._ref
	return self
end

function Construct:Hook(events)
	events = typeof(events) == "table" and events or events and { events }

	if self._events then
		local capture = Copy(self._events)
		for _, event in pairs(events) do
			table.insert(capture, event)
		end

		self._events = capture
	else
		self._events = events
	end

	return self
end

function Construct:Ref(key)
	local get = Construct._Refs[key]
	assert(get, "No reference exists with the key '" .. key .. "'")
	return get
end

function Construct:State(keys)
	if typeof(keys) == "table" then
		local capture = Copy(Construct._State)
		for key, value in pairs(keys) do
			local callback = Changed._StateCache[key]
			if callback and value ~= capture[key] then
				Wrap(callback, value)
			end

			capture[key] = value
		end

		Construct._State = capture
		return self
	elseif keys then
		return Construct._State[keys]
	else
		return Construct._State
	end
end

function Construct:Reconcile(updated, default)
	updated = typeof(updated) == "table" and updated or {}
	default = typeof(default) == "table" and default or {}

	local capture = Copy(default)
	for key, value in pairs(updated) do
		if typeof(default[key]) ~= typeof(value) then
			warn(
				"Failed to reconcile '"
					.. key
					.. "' since the value passed was not the same type as the default value: Got type '"
					.. typeof(value)
					.. "' instead of type '"
					.. typeof(default[key])
					.. "'"
			)
			warn(debug.traceback(2))
			continue
		end

		capture[key] = value
	end

	return capture
end

function Construct:Mount(target)
	assert(self._obj, "No constructed component info exists")

	self._obj.Parent = target
	return self
end

function Construct:Unmount()
	assert(self._obj, "No constructed component info exists")

	self._obj.Parent = nil
	return self
end

function Construct:Disconnect()
	assert(self._events, "No constructed event info exists")

	for _, event in pairs(self._events) do
		event:Disconnect()
	end

	table.clear(self._events)
	return self
end

function Construct:Destroy()
	assert(self._obj, "No constructed component info exists")

	self._obj:Destroy()
	self._obj = nil
	return self
end

function Construct.__call(_, ...)
	local data = { ... }

	if typeof(data[1]) == "Instance" then
		return Construct.extend(...)
	else
		return Construct.new(...)
	end
end

function Construct:__tostring()
	if self._obj then
		return table.concat(
			{
				"[CONSTRUCT]: Constructed component:",
				"Key: " .. self._obj.Name,
				"Type: " .. typeof(self._obj),
				"Path: " .. self._obj:GetFullName(),
			},
			"\n"
		)
	else
		return "[CONSTRUCT]: No constructed component found"
	end
end

function Construct:__newindex(index, value)
	if self._obj then
		local prop = pcall(function()
			self._obj[index] = value
		end)

		if not prop then
			pcall(function()
				self._obj[index](self._obj)
			end)
		end
	end

	return self
end

return setmetatable(Construct, Construct)
