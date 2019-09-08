local mem8_t = "BYTE"
local END_PAD = 100
local PTR_SZ = 4

-- { offset, type, name }

local size_table = {
	["uint8_t"] = 1,
	["int8_t"] = 1,
	["char"] = 1,
	["unsigned char"] = 1,
	["BYTE"] = 1,
	["bool"] = 1,

	["WORD"] = 2,

	["int"] = 4,
	["unsigned int"] = 4,
	["DWORD"] = 4,
	["uint32_t"] = 4,
	["int32_t"] = 4,
	["float"] = 4,

	["DWORD64"] = 8,
	["uint64_t"] = 8,
	["int64_t"] = 8,
	["double"] = 8,

	["string"] = 28 -- be very careful..
}

local function createStruct(name, data)
	if data == nil then
		print(string.format("%s: undefined data", name))
		return
	end

	local c_struct = string.format("struct %s {\n", name)

	local currentOffset = 0
	local numPads = 0

	for i, member in pairs(data) do
		local soffset = member[1]
		local stype = member[2]
		local sname = member[3]
		local ssz = size_table[stype]
		local ptr = false

		if not ssz then
			if string.sub(stype, string.len(stype)) == "*" then
				ssz = PTR_SZ
				ptr = true
			end
		end
		if not ssz then
			error(string.format("Invalid type %s", stype))
		end

		if soffset - currentOffset > 0 then
			c_struct = c_struct .. string.format("\t%s pad%d[%d];\n", mem8_t, numPads, soffset - currentOffset)
			numPads = numPads + 1
		end

		c_struct = c_struct .. string.format((ptr and "\t%s%s;\n" or "\t%s %s;\n"), stype, sname)
		currentOffset = soffset + ssz
	end

	c_struct = c_struct .. string.format("\tBYTE end_pad[%d];\n", END_PAD)

	c_struct = c_struct .. string.format("};\n")

	return c_struct
end

local csgo_entity = {
{0x64, "int", "id"},
{0xF4, "DWORD", "type"},
{0x100, "DWORD", "health"},
{0x12C, "float", "angleY"},
{0x130, "float", "angleX"},
{0x274, "bool", "replicating"},
{0x3AC, "float", "x"},
{0x3B0, "float", "z"},
{0x3B4, "float", "y"},
{0x980, "bool", "visible"},
{0x3620, "bool", "self"},
{0xB3AC, "int", "crosshair"},
}

print("#pragma pack(push,1)")
print(createStruct("csgo_entity", csgo_entity))
print("#pragma pack(pop)")