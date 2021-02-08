--[=[
	@Author: Gavin "Mullets" Rosenthal
	@Desc: A Secrets module to use hidden secrets with DataStores
]=]

--[=[
[ABOUT]:
	Store tokens, otherwise known as secrets, in Roblox DataStores
	so you don't have access to them in scripts and keep them secured.
	
	Command line snippits:

	Set:
	=require(game.ServerStorage.Secrets:Clone()).new("name"):Store("token")

	Get:
	=require(game.ServerStorage.Secrets:Clone()).new("name"):Get()
	
[LICENSE]:
	MIT License
	
	Copyright (c) 2021 Gavin "Mullets" Rosenthal
	
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

local DataStoreService = game:GetService("DataStoreService")

local Secrets = {}
Secrets.__index = Secrets

local function LoadDataStore(name: string): boolean | GlobalDataStore
	local success, response = pcall(function()
		return DataStoreService:GetDataStore(name, name)
	end)

	if success then
		return response
	end

	return false
end

local function SetStoreKey(store: typeof(LoadDataStore()), name: string, token: string): boolean
	local success, _ = pcall(function()
		return store:SetAsync(name, token)
	end)

	return success
end

local function GetStoreKey(store: typeof(LoadDataStore()), name: string): boolean | string
	local success, response = pcall(function()
		return store:GetAsync(name)
	end)

	if success and response ~= nil then
		return response
	end

	return false
end

function Secrets.new(name: string): boolean | typeof(Secrets.new())
	local store = LoadDataStore(name)

	if store then
		return setmetatable({
			_store = store,
			_name = name,
		}, Secrets)
	else
		warn("[Secrets]: Failed to load Secret Store '" .. name .. "'")
	end

	return false
end

function Secrets:Get(): string | boolean
	assert(
		typeof(self._name) == "string",
		"Secret expected a name, got '" .. typeof(self._name) .. "'"
	)

	local token = GetStoreKey(self._store, self._name)
	if token then
		return token
	else
		warn("[Secrets]: Failed to get token on Secret '" .. self._name .. "'")
	end

	return false
end

function Secrets:Store(token: string): boolean
	assert(
		typeof(self._name) == "string",
		"Secret name expected a string, got '" .. typeof(self._name) .. "'"
	)
	assert(
		typeof(token) == "string",
		"Secret token expected a string, got '" .. typeof(token) .. "'"
	)

	local success = SetStoreKey(self._store, self._name, token)
	if success then
		print("[Secrets]: Successfully saved token on Secret '" .. self._name .. "'")

		return true
	else
		warn("[Secrets]: Failed to save token on Secret '" .. self._name .. "'")
	end

	return false
end

return Secrets
