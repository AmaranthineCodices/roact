return function()
	local NoopRenderer = require(script.Parent.NoopRenderer)
	local createElement = require(script.Parent.createElement)
	local createSpy = require(script.Parent.createSpy)
	local Type = require(script.Parent.Type)

	local createReconciler = require(script.Parent.createReconciler)

	local noopReconciler = createReconciler(NoopRenderer)

	describe("tree operations", function()
		it("should mount and unmount", function()
			local tree = noopReconciler.mountTree(createElement("StringValue"))

			expect(tree).to.be.ok()

			noopReconciler.unmountTree(tree)
		end)

		it("should mount, update, and unmount", function()
			local tree = noopReconciler.mountTree(createElement("StringValue"))

			expect(tree).to.be.ok()
			expect(tree.rootNode).to.be.ok()

			noopReconciler.updateTree(tree, createElement("StringValue"))

			expect(tree.rootNode).to.be.ok()

			noopReconciler.unmountTree(tree)
		end)
	end)

	describe("booleans", function()
		it("should mount booleans as nil", function()
			local node = noopReconciler.mountNode(false, nil, "test")
			expect(node).to.equal(nil)
		end)

		it("should unmount nodes if they are updated to a boolean value", function()
			local node = noopReconciler.mountNode(createElement("StringValue"), nil, "test")

			expect(node).to.be.ok()

			node = noopReconciler.updateNode(node, true)

			expect(node).to.equal(nil)
		end)
	end)

	describe("Host components", function()
		it("should invoke the renderer to mount host nodes", function()
			local mountHostNode = createSpy(NoopRenderer.mountHostNode)

			local renderer = {
				mountHostNode = mountHostNode.value,
			}

			local reconciler = createReconciler(renderer)

			local element = createElement("StringValue")
			local hostParent = Instance.new("IntValue")
			local key = "Some Key"
			local node = reconciler.mountNode(element, hostParent, key)

			expect(Type.of(node)).to.equal(Type.Node)

			expect(mountHostNode.callCount).to.equal(1)

			local values = mountHostNode:captureValues("reconciler", "node")

			expect(values.reconciler).to.equal(reconciler)
			expect(values.node).to.equal(node)
		end)

		it("should invoke the renderer to update host nodes", function()
			local updateHostNode = createSpy(NoopRenderer.updateHostNode)

			local renderer = {
				mountHostNode = NoopRenderer.mountHostNode,
				updateHostNode = updateHostNode.value,
			}

			local reconciler = createReconciler(renderer)

			local element = createElement("StringValue")
			local hostParent = Instance.new("IntValue")
			local key = "Key"
			local node = reconciler.mountNode(element, hostParent, key)

			expect(Type.of(node)).to.equal(Type.Node)

			local newElement = createElement("StringValue")
			local newNode = reconciler.updateNode(node, newElement)

			expect(newNode).to.equal(node)

			expect(updateHostNode.callCount).to.equal(1)

			local values = updateHostNode:captureValues("reconciler", "node", "newElement")

			expect(values.reconciler).to.equal(reconciler)
			expect(values.node).to.equal(node)
			expect(values.newElement).to.equal(newElement)
		end)

		it("should invoke the renderer to unmount host nodes", function()
			local unmountHostNode = createSpy(NoopRenderer.unmountHostNode)

			local renderer = {
				mountHostNode = NoopRenderer.mountHostNode,
				unmountHostNode = unmountHostNode.value,
			}

			local reconciler = createReconciler(renderer)

			local element = createElement("StringValue")
			local hostParent = Instance.new("IntValue")
			local key = "Key"
			local node = reconciler.mountNode(element, hostParent, key)

			expect(Type.of(node)).to.equal(Type.Node)

			reconciler.unmountNode(node)

			expect(unmountHostNode.callCount).to.equal(1)

			local values = unmountHostNode:captureValues("reconciler", "node")

			expect(values.reconciler).to.equal(reconciler)
			expect(values.node).to.equal(node)
		end)
	end)

	describe("Function components", function()
		it("should mount and unmount function components", function()
			local componentSpy = createSpy(function(props)
				return nil
			end)

			local element = createElement(componentSpy.value, {
				someValue = 5,
			})
			local hostParent = Instance.new("Folder")
			local key = "A Key"
			local node = noopReconciler.mountNode(element, hostParent, key)

			expect(Type.of(node)).to.equal(Type.Node)

			expect(componentSpy.callCount).to.equal(1)

			local calledWith = componentSpy:captureValues("props")

			expect(calledWith.props).to.be.a("table")
			expect(calledWith.props.someValue).to.equal(5)

			expect(#hostParent:GetChildren()).to.equal(0)

			noopReconciler.unmountNode(node)

			expect(componentSpy.callCount).to.equal(1)
		end)

		it("should mount single children of function components", function()
			local childComponentSpy = createSpy(function(props)
				return nil
			end)

			local parentComponentSpy = createSpy(function(props)
				return createElement(childComponentSpy.value, {
					value = props.value + 1,
				})
			end)

			local element = createElement(parentComponentSpy.value, {
				value = 13,
			})
			local hostParent = Instance.new("Folder")
			local key = "A Key"
			local node = noopReconciler.mountNode(element, hostParent, key)

			expect(Type.of(node)).to.equal(Type.Node)

			expect(parentComponentSpy.callCount).to.equal(1)
			expect(childComponentSpy.callCount).to.equal(1)

			local parentCalledWith = parentComponentSpy:captureValues("props")
			local childCalledWith = childComponentSpy:captureValues("props")

			expect(parentCalledWith.props).to.be.a("table")
			expect(parentCalledWith.props.value).to.equal(13)

			expect(childCalledWith.props).to.be.a("table")
			expect(childCalledWith.props.value).to.equal(14)

			expect(#hostParent:GetChildren()).to.equal(0)

			noopReconciler.unmountNode(node)

			expect(parentComponentSpy.callCount).to.equal(1)
			expect(childComponentSpy.callCount).to.equal(1)
		end)

		it("should mount multiple children of function components", function()
			local childAComponentSpy = createSpy(function(props)
				return nil
			end)

			local childBComponentSpy = createSpy(function(props)
				return nil
			end)

			local parentComponentSpy = createSpy(function(props)
				return {
					A = createElement(childAComponentSpy.value, {
						value = props.value + 1,
					}),
					B = createElement(childBComponentSpy.value, {
						value = props.value + 5,
					}),
				}
			end)

			local element = createElement(parentComponentSpy.value, {
				value = 17,
			})
			local hostParent = Instance.new("Folder")
			local key = "A Key"
			local node = noopReconciler.mountNode(element, hostParent, key)

			expect(Type.of(node)).to.equal(Type.Node)

			expect(parentComponentSpy.callCount).to.equal(1)
			expect(childAComponentSpy.callCount).to.equal(1)
			expect(childBComponentSpy.callCount).to.equal(1)

			local parentCalledWith = parentComponentSpy:captureValues("props")
			local childACalledWith = childAComponentSpy:captureValues("props")
			local childBCalledWith = childBComponentSpy:captureValues("props")

			expect(parentCalledWith.props).to.be.a("table")
			expect(parentCalledWith.props.value).to.equal(17)

			expect(childACalledWith.props).to.be.a("table")
			expect(childACalledWith.props.value).to.equal(18)

			expect(childBCalledWith.props).to.be.a("table")
			expect(childBCalledWith.props.value).to.equal(22)

			expect(#hostParent:GetChildren()).to.equal(0)

			noopReconciler.unmountNode(node)

			expect(parentComponentSpy.callCount).to.equal(1)
			expect(childAComponentSpy.callCount).to.equal(1)
			expect(childBComponentSpy.callCount).to.equal(1)
		end)
	end)
end