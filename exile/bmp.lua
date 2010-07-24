local _G = _G
module("bmp")

local function bytesToInt(bytes, endian)
	endian = endian or "big"
	if(endian == "little") then
		local newBytes = {}
		for i, v in _G.ipairs(bytes) do
			newBytes[#bytes - (i - 1)] = v
		end
		bytes = newBytes
	end
	local ret = 0
	for i, v in _G.ipairs(bytes) do
		ret = _G.bit.lshift(ret, 8)
		ret = _G.bit.bor(ret, _G.bit.band(v, 255))
	end
	return ret
end
local function bytes(s, startI, endI)
	local ret = {}
	for i = startI, endI do
		ret[#ret + 1] = _G.string.byte(s, i)
	end
	return ret
end


local function byteToString(byte)
	local b = byte
	local powers = {128, 64, 32, 16, 8, 4, 2, 1}
	local s = "";
	for i = 1, 8 do
		if b >= powers[i] then
			b = b - powers[i]
			s = s .. "1"
		else
			s = s .. "0"
		end
	end
	return s
end

function load(filename)
	local img = _G.love.filesystem.read(filename)
	local b = function(i) return _G.string.byte(img, i) end
	local c = function(i) return _G.string.byte(i) end
	-- Check for 'BM' idenfitier
	if not (b(1) == c('B') and b(2) == c('M')) then
		_G.error("Not BMP format")
	end
	--Size is in bytes 3-6
	local size = bytesToInt(bytes(img, 3, 6), "little")
	--Offset of start of bmp data is bytes 11-14
	local offset = bytesToInt(bytes(img, 11, 14), "little")
	--Width is in bytes 19-22
	local width = bytesToInt(bytes(img, 19, 22), "little")
	--Height is in bytes 23-26
	local height = bytesToInt(bytes(img, 23, 26), "little")
	
	local bytesPerLine = _G.math.ceil(width / 8)
	local paddingBytes = bytesPerLine % 4
	
	if (bytesPerLine + paddingBytes) % 4 ~= 0 then _G.error("Padding bytes incorrect. Was " .. paddingBytes) end
	
	return {size = size, offset = offset, img = img, 
			bytesPerLine = bytesPerLine, paddingBytes = paddingBytes,
			width = width, height = height}
end

local bytePowers = {128, 64, 32, 16, 8, 4, 2, 1}
function isSolid(b, x, y)
	x = _G.math.floor(x)
	y = _G.math.floor(y)
	--Get the offset in the bitmap
	local offset = ((b.bytesPerLine + b.paddingBytes) * y) + _G.math.floor(x / 8) + b.offset
	--Get the byte for the offset
	local byte = _G.string.byte(b.img, offset)
	if not byte then _G.error("Tried to access in invalid offset: " .. offset) end
	--Get the bit (1 = most significant) the pixel represents
	local bytePosition = (x % 8) + 1
	
	return _G.bit.band(byte, bytePowers[bytePosition]) == bytePowers[bytePosition]
end