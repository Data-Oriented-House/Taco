local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Signal = require(ReplicatedStorage.Packages.Signal)

local function hardValidate<T...>(types: { string }, ...: T...)
	local args = table.pack(...) :: { unknown }
	for i, arg in ipairs(args) do
		if typeof(arg) ~= types[i] then
			error('Type ' .. typeof(arg) .. ' is not of the defined type ' .. types[i], 3)
		end
	end
end

local function softValidate<T...>(types: { string }, ...: T...)
	local args = table.pack(...) :: { unknown }
	for i, arg in ipairs(args) do
		if typeof(arg) ~= types[i] then
			warn('Type ' .. typeof(arg) .. ' is not of the defined type ' .. types[i])
			return false
		end
	end

	return true
end

local Taco = {
	client = {},
	server = {},
	name = string.char(0, 7, 82, 234, 1),
}

if RunService:IsServer() then
	Taco.remote = Instance.new 'RemoteEvent'
	Taco.remote.Name = Taco.name
	Taco.remote.Parent = ReplicatedStorage
	Taco.server.ids = -1

	Taco.server.connections = {}

	Taco.remote.OnServerEvent:Connect(function(player: Player, id: unknown, ...: unknown)
		if typeof(id) ~= 'string' then return end

		local connections = Taco.server.connections[id] :: Signal.Class?
		if not connections then return end

		connections:Fire(...)
	end)

	Taco.server.new = function<T..., U...>(params: {
		client: ((T...) -> {string}),
		server: ((U...) -> {string}),
	})
		local types = params.server()
		Taco.server.ids += 1

		local taco = {
			client = {},
			server = {},
			id = Taco.server.ids,
		}

		-- TODO: Replace this with FastSignal
		local connections = Signal.new()
		Taco.server.connections[taco.id] = connections

		taco.server.Connect = function(callback: (player: Player,  U...) -> ())
			return connections:Connect(callback)
		end

		taco.server.Fire = function(player: Player, ...: U...)
			hardValidate(types, ...)
			Taco.remote:FireClient(player, table.unpack(table.pack(...))) -- To fix the type error, might be ignored later
		end

		return taco
	end
elseif RunService:IsClient() then
	Taco.client.new = function<T..., U...>(params: {
		client: ((T...) -> {string}),
		server: ((U...) -> {string}),
	})
		local types = params.client()
		Taco.server.ids += 1

		local taco = {
			client = {},
			server = {},
			id = Taco.server.ids,
		}

		taco.client.Connect = function(callback: (T...) -> ())
			return Taco.remote.OnClientEvent:Connect(function(...: any)
				if not softValidate(types, ...) then return end
				callback(...)
			end)
		end

		taco.client.Fire = function(...: T...)
			hardValidate(types)
			Taco.remote.FireServer(...)
		end

		return taco
	end
end

return Taco