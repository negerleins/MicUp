local modules = {
	["objecter"] = setmetatable({
		global = {
			["class"] = setmetatable({}, {
				__call = function(self, __constructor_array)
					assert(__constructor_array, "missing [array]:null")
					assert(typeof(__constructor_array) == "table", "invalid [array]:type")

					assert(__constructor_array[1], "missing [index]:constructor")
					assert(getmetatable(__constructor_array[1]), "invalid [index]:type")

					local constructor = __constructor_array[1]
					table.remove(__constructor_array, 1)

					local __privated_data = {};

					for index, data in __constructor_array do
						if getmetatable(data) == "private" then
							local __claimed_data = data:claim();
							rawset(__privated_data, index, __claimed_data);
							rawset(__constructor_array, index, nil);
						else
							continue
						end;
					end;

					return constructor(__constructor_array, __privated_data);
				end,
				__metatable = "locked",
			}),
			["constructor"] = setmetatable({}, {
				__call = function(self, method)
					return setmetatable({}, {
						__call = function(self, __constructor_array, __privated_data)
							local metadata = setmetatable({}, {
								__index = function(__self, index)
									return rawget(__privated_data, index) or rawget(__constructor_array, index);
								end,
								__newindex = function(__self, index, value)
									local __pe_data = rawget(__privated_data, index);
									local __pc_data = rawget(__constructor_array, index);

									local data = __pe_data and __privated_data or __constructor_array;
									return rawset(data, index, value);
								end
							});

							method(metadata);
							return __constructor_array;
						end,
						__metatable = "constructor"
					})
				end,
				__metatable = "locked",
			}),
			["private"] = setmetatable({}, {
				__call = function(self, content)
					return setmetatable({ __unclaimed_data = content }, {
						__index = {
							claim = function(__self)
								local data = __self["__unclaimed_data"];

								if data then
									__self["__unclaimed_data"] = nil;
									return data;
								end;

								return "__private_data";
							end
						},
						__metatable = "private",
					})
				end,
				__metatable = "locked",
			}),
		},
	}, {
		__index = function(self, index)
			for name, object in self.global do
				if name == index then
					return object;
				else
					continue;
				end;
			end

			return nil
		end,
		__metatable = "locked",
	}),
}

local import = setmetatable({
	modules = modules,
}, {
	__call = function(self, array)
		return {
			from = function(_, module)
				local metadata = self.modules[module];
				local output = {};

				for index, name in array do
					if name == module then
						table.insert(output, metadata);
					else
						local object = metadata.global[name];

						if object then
							table.insert(output, object)
						end;
					end;
				end;

				return unpack(output)
			end,
		}
	end,
	__metatable = "locked",
})

local class, constructor, private = import({ "class", "constructor", "private" }):from("objecter")

local test = class({
	Private = private "SecretToken",
	Number = private(1),
	Public = "I am a public string",
	constructor(function(self)
		self.Constructed = true;
		warn(self.Private)
		warn(self.Public)
	end),
})

print(test)

return {}
