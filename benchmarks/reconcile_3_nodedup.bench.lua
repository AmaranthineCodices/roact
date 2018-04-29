local Roact = require(script.Parent.Parent.Roact)

local handle

return {
	iterations = 100000,
	setup = function()
		handle = Roact.reify(Roact.createElement("Frame", {
			Position = UDim2.new(0, 1, 0, 0),
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderSizePixel = 3,
			BorderColor3 = Color3.new(1, 0, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Size = UDim2.new(0, 100, 0, 100),
			ZIndex = 4,
		}))

		Roact.setGlobalConfig({
			primitiveDeduplication = false,
		})
	end,
	teardown = function()
		Roact.teardown(handle)
		require(script.Parent.Parent.Roact.GlobalConfig).reset()
	end,
	step = function(i)
		handle = Roact.reconcile(handle, Roact.createElement("Frame", {
			Position = UDim2.new(0, 1, 0, i),
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderSizePixel = 3,
			BorderColor3 = Color3.new(1, 0, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Size = UDim2.new(0, 100, 0, 100),
			ZIndex = 4,
		}))
	end,
}