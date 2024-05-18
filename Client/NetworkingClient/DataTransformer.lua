local tblToString

local function getString(value, alreadyDoneTables, tabs, oneLine)
	tabs = tabs or 0
	if type(value) == "string" then
		return "\""..value.."\""
	elseif type(value) == "table" then
		alreadyDoneTables = alreadyDoneTables or {}
		if alreadyDoneTables[value] then
			return "** cyclic table reference **"
		end
		alreadyDoneTables[value] = true
		
		return tblToString(value, alreadyDoneTables, tabs+1, oneLine)
	else
		return tostring(value)
	end
end

function tblToString(tbl, alreadyDoneTables, tabs, oneLine)
	local alreadyDoneTables = alreadyDoneTables or {}
	if not next(tbl) then
		return "{}"
	end
	local str = "{\n"
	for index, value in pairs(tbl) do
		local indexString = string.rep("    ", tabs).."["..getString(index, alreadyDoneTables, nil, oneLine).."]"
		local valueString = getString(value, alreadyDoneTables, tabs, oneLine)
		
		str = str..indexString.." = "..valueString..",\n"
	end
	str = str..string.rep("    ", tabs-1).."}"
	if oneLine then
str = str:gsub([[

]], "")
		
		str = str:gsub("    ", "")
	end
	return str
end

local function getValue(str)
	return loadstring("return "..str)()
end

return {
	Load = getValue,
	Save = getString,
}