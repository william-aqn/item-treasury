-- Crude implementation of a stream for binary values of arbitrary bit length
--[[
bits are packed into bytes thus:
starting with an empty byte: 	|*|*|*|*|*|*|*|*|
inserting 01b: 			|*|*|*|*|*|*|0|1|
inserting 110b: 			|*|*|*|1|1|0|0|1|
etc ...
--]]

--import "bit32" --!*!

local table_insert = table.insert;
local math_min = math.min;
local bit32_rshift = bit32.rshift; --!*!
local bit32_lshift = bit32.lshift; --!*!
local bit32_extract = bit32.extract;--!*!

BitStream = class();
function BitStream:Constructor()
	self.bytes = {};
	self.currentByte = 0;
	self.currentLength = 0;
end

-- flush a byte to the output
function BitStream:_FlushByte()
	table_insert( self.bytes, self.currentByte );
	self.currentByte = 0;
	self.currentLength = 0;
end

-- output <bitLength> bits from integer <value>
function BitStream:Output( value, bitLength )
	value = bit32_extract( value, 0, bitLength ); -- truncate just in case this wasn't done before
	while bitLength > 0 do
		local nbits = math_min( 8 - self.currentLength, bitLength );
		local partialValue = bit32_extract( value, 0, nbits );
		self.currentByte = self.currentByte + bit32_lshift( partialValue, self.currentLength );
		self.currentLength = self.currentLength + nbits;
		value = bit32_rshift( value, nbits );
		bitLength = bitLength - nbits;
		if self.currentLength == 8 then
			self:_FlushByte();
		end
	end
end

-- output bits in reversed order, eg: 001b is inserted as 100b
function BitStream:OutputReversed( value, bitLength )
	local res = 0;
	local bit;
	for i=1, bitLength do
      bit = value % 2;
      value = (value - bit) / 2;
      res = res * 2 + bit;
    end

	self:Output( res, bitLength );
end

-- align the output to the a byte boundary
function BitStream:PadToNextByte()
	if self.currentLength == 0 then
		return;
	end
	self:_FlushByte();
end

-- returns the output
function BitStream:GetBytes()
	return self.bytes;
end
