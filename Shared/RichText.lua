--[[
	@Author: Gavin "Mullets" Rosenthal
	@Desc: Rich text formatter
--]]

--[[
[NOTES]:
	- You can append two RichTexts to format into one message

[DOCUMENTATION]:
	.create() -- start formatting
	
	- Note: general
	:Append(text or RichText format)
	:GetText() -- returns the formatted text
	
	- Note: true to start format, false to end it
	:Bold(bool)
	:Italic(bool)
	:Underline(bool)
	:Strike(bool)
	:Comment(bool)
	
	- Note: font prop to start, false to end
	:Font(font name or bool)
	:Size(font size or bool)
	:Color(font color or bool)
	
[TYPES]:
	- Font
	- Color
	- Size
	- Bold
	- Italic
	- Underline
	- Strikethrough
	- Comment

[EXAMPLE]:
	local sample = RichText.create()
		:Size(45)
		:Bold(true)
		:Append('Hello, ')
		:Bold(false)
		:Underline(true)
		:Font('Ubuntu')
		:Append('world!')
		:Font(false)
		:Underline(false)
		:Strike(true)
		:Color(Color3.fromRGB(255, 0, 4))
		:Append(' this is so cool')
		:Color(false)
		:Strike(false)
		:Size(false)
--]]

--// logic
local RichText = {}
RichText.__index = RichText

--// functions
local function FormatColor(color)
	assert(typeof(color) == 'Color3',"Must provide a valid Color3")
	
	return string.format(
		'rgb(%i,%i,%i)',
		math.floor(color.r * 255),
		math.floor(color.g * 255),
		math.floor(color.b * 255)
	)
end

function RichText.create()
	return setmetatable({
		_raw = {};
		_richtext = true;
	},RichText)
end

function RichText:Append(value)
	assert(typeof(value) == 'string' or 'table',"':Append' Text or other RichText must be defined to correctly format Rich Text")
	
	if typeof(value) == 'string' then
		table.insert(self._raw,value)
	elseif typeof(value) == 'table' then
		if not value._richtext then return self end
		for index,format in ipairs(value._raw) do
			table.insert(self._raw,format)
		end
	end
	
	return self
end

function RichText:Bold(state)
	assert(typeof(state) == 'boolean',"':Bold' A boolean must be defined to correctly format Rich Text")
	
	if state then
		table.insert(self._raw,'<b>')
	else
		table.insert(self._raw,'</b>')
	end
	
	return self
end

function RichText:Italic(state)
	assert(typeof(state) == 'boolean',"':Italic' A boolean must be defined to correctly format Rich Text")
	
	if state then
		table.insert(self._raw,'<i>')
	else
		table.insert(self._raw,'</i>')
	end
	
	return self
end

function RichText:Underline(state)
	assert(typeof(state) == 'boolean',"':Underline' A boolean must be defined to correctly format Rich Text")
	
	if state then
		table.insert(self._raw,'<u>')
	else
		table.insert(self._raw,'</u>')
	end
	
	return self
end

function RichText:Strike(state)
	assert(typeof(state) == 'boolean',"':Strike' A boolean must be defined to correctly format Rich Text")
	
	if state then
		table.insert(self._raw,'<s>')
	else
		table.insert(self._raw,'</s>')
	end
	
	return self
end

function RichText:Comment(state)
	assert(typeof(state) == 'boolean',"':Comment' A boolean must be defined to correctly format Rich Text")
	
	if state then
		table.insert(self._raw,'<!--')
	else
		table.insert(self._raw,'-->')
	end
	
	return self
end

function RichText:Font(name)
	assert(typeof(name) == 'string' or 'EnumItem' or 'boolean',"':Font' A name or EnumItem or false must be defined to correctly format Rich Text")
	
	if typeof(name) == 'string' then
		table.insert(self._raw,'<font face="'.. name ..'">')
	elseif typeof(name) == 'EnumItem' then
		table.insert(self._raw,'<font face="'.. name.Name ..'">')
	elseif not name then
		table.insert(self._raw,'</font>')
	end
	
	return self
end

function RichText:Size(number)
	assert(typeof(number) == 'number' or 'boolean',"':Size' A number or false must be defined to correctly format Rich Text")
	
	if typeof(number) == 'number' then
		table.insert(self._raw,'<font size="'.. number ..'">')
	elseif not number then
		table.insert(self._raw,'</font>')
	end
	
	return self
end

function RichText:Color(color)
	assert(typeof(color) == 'Color3' or 'boolean',"':Color' A Color3 or false must be defined to correctly format Rich Text")
	
	if typeof(color) == 'Color3' then
		table.insert(self._raw,'<font color="'.. FormatColor(color) ..'">')
	elseif not color then
		table.insert(self._raw,'</font>')
	end
	
	return self
end

function RichText:GetText()
	return table.concat(self._raw)
end

return RichText