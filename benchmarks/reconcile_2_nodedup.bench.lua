local Roact = require(script.Parent.Parent.Roact)

local handle

return {
	iterations = 100000,
	setup = function()
		handle = Roact.reify(Roact.createElement("StringValue", {
			Value = "Initial",
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
		handle = Roact.reconcile(handle, Roact.createElement("StringValue", {
			Value = "Initial",
		}))
	end,
}