local Roact = require(script.Parent.Parent.Roact)

return {
	iterations = 100000,
	setup = function()
		Roact.setGlobalConfig({
			errorHandling = false,
		})
	end,
	teardown = function()
		require(script.Parent.Parent.Roact.GlobalConfig).reset()
	end,
	step = function()
		local hello = Roact.createElement("StringValue", {
			Value = "Hello, world!",
		})

		local handle = Roact.reify(hello)
		Roact.teardown(handle)
	end,
}