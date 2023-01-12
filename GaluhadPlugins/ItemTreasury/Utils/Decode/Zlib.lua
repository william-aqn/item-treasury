-- Basic implementation of the zlib library in lua
-- FDICT is not supported
-- the static huffman codes method is not supported
--[[
import "bit32" --!*!
import "Deflate"; --!*!
import "Inflate"; --!*!
import "BitStream"; --!*!
--]]
Zlib = {};

-- Deflate (compress) data
-- 'data" should be an array of bytes
-- returns an array of bytes
function Zlib.Deflate( data )
	local bit32_rshift = bit32.rshift; --!*!
	local bitStream = BitStream(); --!*!

	-- output zlib header
	-- hardcoded, TODO parametrize
	bitStream:Output( 0x78, 8 ); -- CMF (CM + CINFO = Deflate compression method, 32K window size)
	bitStream:Output( 0x9C, 8 ); -- FCHECK + FDICT (false) + FLEVEL (2) FLEVEL is arbitrary here

	-- compress and output data as one block
	Deflate( data, bitStream, 0 ); --!*!

	-- align to next byte
	bitStream:PadToNextByte();

	-- compute and output adler32 checksum
	local checksum = Zlib.ComputeAdler32( data );
	bitStream:Output( bit32_rshift( checksum, 24), 8 );
	bitStream:Output( bit32_rshift( checksum, 16), 8 );
	bitStream:Output( bit32_rshift( checksum, 8), 8 );
	bitStream:Output( checksum, 8 );

	local res = bitStream:GetBytes();

	return res;
end

-- inflate (uncompress) data
-- Data is a binary string
-- returns an array of bytes
function Zlib.Inflate( data )
	inflatedData = {};
	local outputFun = function ( byte )
		table.insert( inflatedData, byte );
	end

	ZlibDeflate.inflate_zlib( { input = data, output = outputFun, disable_crc=false }); --!*!

	return inflatedData;
end

-- Compute zlib checksum (so called adler32) on the data to deflate, as per the zlib RFC
function Zlib.ComputeAdler32( data )
	local base = 65521;
	local s1 = 1;
	local s2 = 0;

	for _,v in ipairs( data ) do
		s1 = (s1 + v) % base;
		s2 = (s2 + s1) % base;
	end

	local checksum = bit32.lshift( s2, 16 ) + s1; --!*!
	return checksum;
end


