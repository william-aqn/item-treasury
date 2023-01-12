-- Relatively crude implementation of a (compression) DEFLATE algorithm as described in RFC 1951
--
-- The Lua code for huffman encoding can't be terribly efficient but
-- 	1) lua is not well suited for the task
-- 	2) it probably does not matter, as ultimately, the alphabets are small,
--	    unless the data is also quite small, huffman encoding should pale in
--	    execution time compared to the LZ77 compression or even weigthing the resulting data
--	    and if the data is small, efficiency should matter very little at all

-- TODO:
-- Currently, LZ77 compression is not implemented at all, only huffman encoding,
-- LZ77 might cause more harm than good if the data to compress is small however,
-- as it increases the number of symbols to huffman-encode (distances & lengths symbols)
-- inducing some overhead to output the code table.  Besides, huffman encoding makes
-- for a pretty capable compression scheme on its own, if not impaired by LZ77
-- smoothing out the frequency of symbols

-- TODO:
-- RFC 1951 dictates that huffman codes should not exceed a certain length,
-- which is not implemented here.
-- (ideally should be using the package-merge algorithm for optimal encoding).

--import "HuffmanEncoding"; --!*!
--import "Log"; --!*!

local table_insert = table.insert;
--local HuffmanEncoding = HuffmanEncoding; --!*!

--[[
-- returns an array of {symbol, repeat-count} RLE encoding a code lengths array as described in RFC 1951 (DEFLATE)
-- ie: using the following alphabet
0 - 15: Represent code lengths of 0 - 15
16: 	Copy the previous code length 3 - 6 times.
                       The next 2 bits indicate repeat length
                             (0 = 3, ... , 3 = 6)
                          Example:  Codes 8, 16 (+2 bits 11),
                                    16 (+2 bits 10) will expand to
                                    12 code lengths of 8 (1 + 6 + 5)
17: 	Repeat a code length of 0 for 3 - 10 times.
                       (3 bits of length)
18: 	Repeat a code length of 0 for 11 - 138 times
                       (7 bits of length)
--]]
local PackCodeLengths = function( codeLengths )
	local packedCodeLengths = {};

	local codeLengthsSize = #codeLengths;

	local n = 0;
	local i = 1;
	while i <= codeLengthsSize do
		codeLength = codeLengths[i];

		-- find how many times  the code length repeats if at all
		n = i;
		while (i <= codeLengthsSize) and ( codeLengths[i] == codeLength ) do
			i = i + 1;
		end
		n = i - n;

		if codeLength == 0 then
			-- special cases for code lengths of 0

--			if i > codeLengthsSize then
				-- we've reached the end and it's all 0's, which we do not need to output
--				break; -- we've already output enough elements, break the loop
			--end

			-- shouldn't really happen more than once, but just in case, we loop as long as the repeat count is over 138 ...
			while n > 138 do
				table_insert( packedCodeLengths, { 18, 138 } ); -- = repeat a code length of 0 138 times
				n = n - 138;
			end

			if n > 10 then
				table_insert( packedCodeLengths, { 18, n } ); -- = repeat a code length of 0 n times (n in range 11..138)
			elseif n > 2 then
				table_insert( packedCodeLengths, { 17, n } ); -- = repeat a code length of 0 n times (n in range 3..10)
			else
				-- output individual code lengths
				while n > 0 do
					table_insert( packedCodeLengths, { 0, 0 } );
					n = n - 1;
				end
			end
		else
			-- a non 0 code length, we insert it first then add repeats as relevant
			table_insert( packedCodeLengths, {codeLength, 0 } );
			n = n -1;
			while n > 6 do
				table_insert( packedCodeLengths, {16,6} );
				n = n - 6;
			end

			if n > 2 then
				table_insert( packedCodeLengths, {16, n } );
			else
				while n > 0 do
					table_insert( packedCodeLengths, {codeLength, 0 } );
					n = n - 1;
				end
			end
		end
	end

	return packedCodeLengths;
end

-- Return data compressed through a LZ77 algorithm
-- Data should be an array of bytes
-- Stategy is undefined at this point
-- TODO: not suitable for compressing large amount of data, we should have some handling of blocks somewhere
-- TODO: actually implement a compression algorithm ...
-- returns either a literal, end of block (256) or {}ength code, length, distance code, distance }
local LZ77Compress = function( data, strategy )
	-- For now, merely return a copy of the data with end of block appended
	local dataCopy = {};

	for _,v in ipairs( data ) do
		table_insert( dataCopy, v );
	end
	table_insert( dataCopy, 256 ); -- end of data

	return dataCopy;
end

-- Output a block header
-- isFinal indicates whether this is the final block in the stream  (true/false)
-- method should be a two bits value from:
-- 00 (0) no compression
-- 01 (1) - compressed with fixed Huffman codes
-- 10 (2) - compressed with dynamic Huffman codes
-- 11 (3) - reserved (error)
local OutputBlockHeader = function( outStream, isFinal, method )
	if isFinal then isFinal = 1 else isFinal = 0; end
	outStream:Output( isFinal, 1 );
	outStream:Output( method, 2 );
end

--- returns the weights of literal/length and distance data
local LitlenAndDistanceWeights = function( lz77data )
	local litlenWeights = {};
	local distanceWeights = {};
	for _,v in ipairs( lz77data ) do
		if type( v ) == "table" then
			-- length/distance {length code, length, distance code, distance }
			local lengthCode, distanceCode = v[1], v[3];
			litlenWeights[lengthCode] = ( litlenWeights[lengthCode] or 0 ) + 1;
			distanceWeights[distanceCode] = ( distanceWeights[distanceCode] or 0 ) + 1;
		else
			-- literal or end of block
			litlenWeights[v] = ( litlenWeights[v] or 0 ) + 1;
		end
	end
	return litlenWeights, distanceWeights;
end

local PackedCodeLengthsWeights = function( packedLitlenCodeLengths, packedDistanceCodeLengths )
	local weights = {};
	for _, packCode in ipairs( packedLitlenCodeLengths ) do
		weights[packCode[1]] = ( weights[packCode[1]] or 0 ) + 1;
	end

	for _, packCode in ipairs( packedDistanceCodeLengths ) do
		weights[packCode[1]] = ( weights[packCode[1]] or 0)  + 1;
	end

	return weights;
end

local OutputPackedCodeLengths = function( outStream, packedCodeLengths, reversePackedCodeLengthsCanonicalCodes)
	-- output packed code lengths
	for i = 1, #packedCodeLengths do
		local code = packedCodeLengths[i];
		local reversePackedCodeLengthsCanonicalCode = reversePackedCodeLengthsCanonicalCodes[code[1]];

		outStream:OutputReversed( reversePackedCodeLengthsCanonicalCode[1], reversePackedCodeLengthsCanonicalCode[2] );

		-- output extra bits if relevant
		if code[1] == 16 then
			outStream:Output( code[2] - 3, 2 );
		elseif code[1] == 17 then
			outStream:Output( code[2] - 3, 3 );
		elseif code[1] == 18 then
			outStream:Output( code[2] - 11, 7 );
		else
			-- error: TODO
		end
	end
end

-- prefixes 257+ for lengths
-- {threshold length, bits} array
local LengthsPrefixesAndExtraBits = {
	{3,0},{4,0},{5,0},{6,0},{7,0},{8,0},{9,0},{10,0},
	{11,1},{13,1},{15,1},{17,1},
	{19,2},{23,2},{27,2},{31,2},
	{35,3},{43,3},{51,3},{59,3},
	{67,4},{83,4},{99,4},{115,4},
	{131,5},{163,5},{195,5},{227,5},
	{258,0}
};
local OutputLength = function( outStream, length, literalsLengthsCodesLookupTable )
	-- find the prefix to output
	for i,v in ipairs( LengthsPrefixesAndExtraBits ) do
		if length < v[1] then
			prefixIndex = i - 1;
			break;
		end
	end

	if prefixIndex == 0 then
		return false; -- error
	else
		-- Encoded length prefix
		local prefix = prefixIndex + 256;
		outStream:OutputReversed( literalsLengthsCodesLookupTable[prefix][1], literalsLengthsCodesLookupTable[prefix][2] );

		-- extra bits (if any)
		outStream:Output( length - LengthsPrefixesAndExtraBits[prefixIndex][1], LengthsPrefixesAndExtraBits[prefixIndex][2] );
	end
	return true;
end

-- {threshold distance, extra bits} array
local DistancesPrefixesAndExtraBits = {
	{1,0},{2,0},{3,0},{4,0},
	{5,1},{7,1},
	{9,2},{13,2},
	{17,3},{25,3},
	{33,4},{49,4},
	{65,5},{97,5},
	{129,6},{193,6},
	{257,7},{385,7},
	{513,8},{769,8},
	{1025,9},{1537,9},
	{2049,10},{3073,10},
	{4097,11},{6145,11},
	{8193,12},{12289,12},
	{16385,13},{24577,13}
};
local OutputDistance = function( outStream, distance, distancesCodesLookupTable )
	for i,v in ipairs( DistancesPrefixesAndExtraBits ) do
		if length < v[1] then
			prefixIndex = i - 1;
			break;
		end
	end

	if prefixIndex == 0 then
		return false; -- error
	else
		-- Encoded length prefix
		local prefix = prefixIndex - 1;
		outStream:OutputReversed( distanceCodesLookupTable[prefix][1], distanceCodesLookupTable[prefix][2] );

		-- extra bits (if any)
		outStream:Output( distance - DistancePrefixesAndExtraBits[prefixIndex][1], DistancePrefixesAndExtraBits[prefixIndex][2] );
	end
	return true;
end

local OutputLZ77Data = function( outStream, lz77Data, literalsLengthsCodesLookupTable, distancesCodesLookupTable )
	for _,datum in ipairs( lz77Data ) do
		if type(datum) == "table" then
			-- length / distance entry
			local length = datum[1];
			local distance = datum[2];

			local res = OutputLength( outStream, length, literalsLengthsCodesLookupTable);
			if res == false then
				return false; -- error
			end

			res = OutputDistance( outStream, distance, distancesCodesLookupTable );
			if res == false then
				return false; -- error
			end

		else
			-- literal or end of block (256)
			outStream:OutputReversed( literalsLengthsCodesLookupTable[datum][1], literalsLengthsCodesLookupTable[datum][2] );

			if literalsLengthsCodesLookupTable[datum][2] > 15 then
				Log.Error( "Deflate", string.format("Litlen code too long (%d)", literalsLengthsCodesLookupTable[datum][2] ) ); --!*!
			end
		end
	end
	return true;
end

local CodesLookupTable = function( codes )
	if codes == nil then
		return nil;
	end
	local lookupTable = {};
	for _,code in ipairs( codes ) do
		lookupTable[code[1]] = { code[2], code[3] }; -- [symbol] = { code, length }
	end
	return lookupTable;
end

local ReorderPackCodeLengths = function( packedCodeLengthsCodeLengths )
	-- local PackedCodeLengthsCodeLengthsOrder = { 16, 17, 18, 0, 8, 7, 9, 6, 10, 5, 11, 4, 12, 3, 13, 2, 14, 1, 15 };
	local t = {};
	table_insert( t, packedCodeLengthsCodeLengths[17] );
	table_insert( t, packedCodeLengthsCodeLengths[18] );
	table_insert( t, packedCodeLengthsCodeLengths[19] );
	table_insert( t, packedCodeLengthsCodeLengths[1] );
	table_insert( t, packedCodeLengthsCodeLengths[9] );
	table_insert( t, packedCodeLengthsCodeLengths[8] );
	table_insert( t, packedCodeLengthsCodeLengths[10] );
	table_insert( t, packedCodeLengthsCodeLengths[7] );
	table_insert( t, packedCodeLengthsCodeLengths[11] );
	table_insert( t, packedCodeLengthsCodeLengths[6] );
	table_insert( t, packedCodeLengthsCodeLengths[12] );
	table_insert( t, packedCodeLengthsCodeLengths[5] );
	table_insert( t, packedCodeLengthsCodeLengths[13] );
	table_insert( t, packedCodeLengthsCodeLengths[4] );
	table_insert( t, packedCodeLengthsCodeLengths[14] );
	table_insert( t, packedCodeLengthsCodeLengths[3] );
	table_insert( t, packedCodeLengthsCodeLengths[15] );
	table_insert( t, packedCodeLengthsCodeLengths[2] );
	table_insert( t, packedCodeLengthsCodeLengths[16] );

	return t;
end

local EncodeLZ77Data = function( outStream, lz77Data )
	OutputBlockHeader( outStream, true, 2 ); -- true = last block, 2 = compressed with dynamic Huffman codes

	-- weight the lz77 data for huffman encoding
	local litlenWeights, distanceWeights = LitlenAndDistanceWeights( lz77Data );

	-- encoding of literals / lengths
	-- make alphabet for lz77 literal/length codes
	local lZ77Alphabet = {};
	for i = 0, 285 do table_insert( lZ77Alphabet, i ) end;
	local litlenHuffmanTree = HuffmanEncoding.MakeTree( litlenWeights, 15 );
	local litlenCanonicalCodes = HuffmanEncoding.CanonicalCodesForAlphabet( litlenHuffmanTree, lZ77Alphabet );
	local litlenCodeLengths = HuffmanEncoding.CodeLengthsForCanonicalCodes( litlenCanonicalCodes, 257 );
	local packedLitlenCodeLengths = PackCodeLengths( litlenCodeLengths );

	-- encoding of distances
	-- make alphabet for lz77 distance codes
	local distanceAlphabet = {};
	for i = 0, 29 do table_insert( distanceAlphabet, i ) end;
	local distanceHuffmanTree = HuffmanEncoding.MakeTree( distanceWeights, 15 );
	local distanceCanonicalCodes = HuffmanEncoding.CanonicalCodesForAlphabet( distanceHuffmanTree, distanceAlphabet );
	local distanceCodeLengths = HuffmanEncoding.CodeLengthsForCanonicalCodes( distanceCanonicalCodes, 1 );
	local packedDistanceCodeLengths = PackCodeLengths( distanceCodeLengths );


	-- make alphabet for packed code lengths codes
	local packAlphabet = {};
	for i = 0, 18 do table_insert( packAlphabet, i ) end;
	local packWeights = PackedCodeLengthsWeights( packedLitlenCodeLengths, packedDistanceCodeLengths );
	local packHuffmanTree = HuffmanEncoding.MakeTree( packWeights, 7 );
	local packCanonicalCodes = HuffmanEncoding.CanonicalCodesForAlphabet( packHuffmanTree, packAlphabet );
	local packCodeLengths = HuffmanEncoding.CodeLengthsForCanonicalCodes( packCanonicalCodes, 18 );

	-- reorder the code lengths of code lengths according to RFC 1951
	local reorderedPackCodeLengths = ReorderPackCodeLengths( packCodeLengths );

	-- truncate the code lengths code lengths reordered array
	for i = #reorderedPackCodeLengths, 5, -1 do
		if reorderedPackCodeLengths[i] == 0 then
			reorderedPackCodeLengths[i] = nil;
		else
			break;
		end
	end

	-- output the sizes of the encoded huffman trees
	outStream:Output( #litlenCodeLengths - 257, 5 );
	outStream:Output( #distanceCodeLengths - 1, 5 );
	outStream:Output ( #reorderedPackCodeLengths - 4, 4 );

	-- ouput code lengths for the huffman tree of literals/lengths & distances packed code lengths ...
	for _,length in ipairs( reorderedPackCodeLengths ) do
		if length > 7 then
			Log.Error( "Deflate", string.format("pack code too long (%d)", length ) ); --!*!
		end
		outStream:Output( length, 3 );
	end

	-- reverse lookup table to access codes to output
	local packCanonicalCodesLookupTable = CodesLookupTable( packCanonicalCodes );

	-- output the literals/lengths huffman trees as huffman encoded packed code lengths
	OutputPackedCodeLengths( outStream, packedLitlenCodeLengths, packCanonicalCodesLookupTable );

	-- output the distances huffman tree (as packed code lengths)
	OutputPackedCodeLengths( outStream, packedDistanceCodeLengths, packCanonicalCodesLookupTable );

	-- and finally output the compressed data, huffman encoded
	local litlenCanonicalCodesLookupTable = CodesLookupTable( litlenCanonicalCodes );
	local distanceCanonicalCodesLookupTable = CodesLookupTable( distanceCanonicalCodes );
	return OutputLZ77Data( outStream, lz77Data, litlenCanonicalCodesLookupTable, distanceCanonicalCodesLookupTable );
end

-- Compress the array of bytes <data> as per the DEFLATE method and using a strategy <strategy> (TODO), deflated data is output to <outstream>
Deflate = function( data, outStream, strategy )
	lz77Data = LZ77Compress( data, strategy );

	if lz77Data == nil then
		Log.Error( "Deflate", "An error occured while compressing data" ); --!*!
		return false;
	end

	return EncodeLZ77Data( outStream, lz77Data );
end
