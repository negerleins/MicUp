local modules = {
	["class"] = setmetatable({
		global = {
			[1] = setmetatable({
				name = "new",
			}, {
				__call = function(self, array)
					assert(array, "missing [array]:null")
					assert(typeof(array) == "table", "invalid [array]:type")

					assert(array[1], "missing [index]:constructor")
					assert(getmetatable(array[1]), "invalid [index]:type")

					local constructor = array[1];
					constructor();
				end,
			}),
			[2] = setmetatable({
				name = "conmstructor",
			}, {
				__call = function(self, method)
					return setmetatable({
						global = {},
						private = {},

					}, {
						__call = function(self)
							method(self);
						end,
					})
				end,
			}),
		},
	}, {
		__index = function(self, index)
			for _, object in self.global do
				if object.name == index then
					return object;
				end;
			end;
		end,
	}),
}

local import = setmetatable({
	modules = modules,
}, {
	__call = function(self, array)
		return {
			from = function(_, name)
				local module = self.modules[name]
				return module, unpack(module.global)
			end,
		}
	end,
})

local class, new, constructor = import({ "class", "new", "constructor" }):from("class")

local class = new {
	constructor(function(self)
		warn(self)
	end),
}

return {}
