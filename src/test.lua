

-- POSSIBLE NAMES: TACO, NUGGET, DONOUT, CHEESE, BOBA, CAKE, HAM
local Tacos = {
	parties = {
		create = Taco.new(),
		delete = Taco.new(),
		kick = Taco.new(),
	},

	animations = {
		replicate = Taco.new {
			client = function(cframe: CFrame) return {'CFrame'} end,
			server = function(cframe: CFrame) return {'CFrame'} end,
		},
	}
}

-- Server

Tacos.animations.replicate:Connect(function(player: Player, cframe: CFrame)
	Tacos.animations.replicate:FireToAllExcept(player, cframe)
end)

Tacos.parties.create:Connect(function(player: Player)
	print(player, 'created a party!!')
end)

-- Client

Tacos.animations.replicate:Fire(game:GetService('Players').LocalPlayer.Character:GetPivot())

Tacos.parties.create:Fire()