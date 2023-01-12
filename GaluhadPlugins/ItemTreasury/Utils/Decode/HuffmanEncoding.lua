-- Huffman encoding algorithms

--import "PriorityQueue"; --!*!

HuffmanEncoding = {};

local table_insert = table.insert;

local function HuffmanTreeString( huffmanTree )
	if type (huffmanTree ) == "table" then
		return "( " .. HuffmanTreeString( huffmanTree[1] ) .. " " .. HuffmanTreeString( huffmanTree[2] ) .. " )";
	end

	return tostring( huffmanTree );
end

-- build a huffman tree for a set of symbols and their weights
-- symbolWeights is a table where keys are symbols and weights are the corresponding values
-- TODO: restrict depth of tree if needed
-- returns a tree where nodes are array {[1] = left, [2] = right} and leafs are the symbols themselves
HuffmanEncoding.MakeTree = function( symbolWeights, maxDepth )
	local priorityQueue = PriorityQueue(); --!*!

	-- first add all symbols in the priority queue
	for symbol,weight in pairs( symbolWeights ) do
		priorityQueue:Insert( symbol, weight );
	end

	local elt1, elt2;
	local weight1, weight2;
	while true do
		elt1,weight1 = priorityQueue:Pull();
		elt2,weight2 = priorityQueue:Pull();
--		Turbine.Shell.WriteLine( "Huffman tree: Pulled(1) "..tostring( elt1 ) .. ":" .. tostring( weight1) );
		if elt2 == nil then
			break; -- one element left, we're done,  elt1 is the root of the tree
		end

		local node;
		if weight1 < weight2 then
			node = { elt1, elt2 };
		else
			node = { elt2, elt1 };
		end

		priorityQueue:Insert( node, weight1 + weight2 );
	end

	-- elt1 is the root of the tree
	return elt1;
end


local function HuffmanTreeIteratorRec( huffmanTree, code, length, fun )
	if type(huffmanTree ) == "table" then
		-- this is a node, recurse over its children
		length = length + 1;
		local newCode = code * 2; -- shift the code left
		HuffmanTreeIteratorRec( huffmanTree[1], newCode, length, fun );
		newCode = newCode + 1;
		HuffmanTreeIteratorRec( huffmanTree[2], newCode, length, fun );
		return;
	end
	-- this is a leaf, ie, a symbol, call the function
	fun( huffmanTree, code, length );
end


-- Iterates over every symbol in the tree and calls fun( symbol, code, length ) for each
local HuffmanTreeIterator = function( huffmanTree, fun )
	if type(huffmanTree) ~= "table" and huffmanTree ~= nil then
		-- only one element, handle it as a special case
		-- if there are no elements (huffmanTree == nil) do nothing
		fun( huffmanTree, 0, 1 );
		return;
	end
	HuffmanTreeIteratorRec( huffmanTree, 0, 0, fun );
end

-- turns a huffman tree into canonical huffman code for a given alphabet
-- 'alphabet' is an array of all possible symbols in order
-- returns canonical huffman code as an array of {symbol, code, length} values in the same order
HuffmanEncoding.CanonicalCodesForAlphabet = function( huffmanTree, alphabet )
	if huffmanTree == nil then
		return nil;
	end

	-- first we build a reverse lookup table for the alphabet
	local reverseAlphabet = {};
	for order,symbol in ipairs( alphabet ) do
		reverseAlphabet[symbol] = order;
	end

	-- initialize the canonical code with {symbol, 0, 0 } values in alphabetical order
	local canonicalCodeArray = {};
	for i = 1, #alphabet do
		table_insert( canonicalCodeArray, { alphabet[i], 0, 0 } );
	end

	-- set the code length for symbols in the huffman tree
	-- since we're going to rewrite the codes to make them canonical, we only care about the length
	local setLength = function( symbol, code, length )
		local symbolCode = canonicalCodeArray[reverseAlphabet[symbol]];
		symbolCode[3] = length; -- [3] = length
	end
	HuffmanTreeIterator( huffmanTree, setLength );

	-- sort the code array by code length then alphabetical order
	local sortByLengthAndAlphabeticalOrder = function( a, b )
		if a[3] < b[3] then -- compare lengths
			return true;
		elseif a[3] > b[3] then
			return false;
		else
			return reverseAlphabet[a[1]] < reverseAlphabet[b[1]]; -- compare alphabetical order
		end
	end
	table.sort( canonicalCodeArray, sortByLengthAndAlphabeticalOrder );

	-- generate new canonical codes
	local code = -1;
	local lastLength = 0;
	for _,symbolCode in ipairs( canonicalCodeArray ) do
		local length = symbolCode[3];
		if length > 0 then
			code = code + 1;
			if length ~= lastLength then
				code = code * (2^(length-lastLength)); -- shift code left
			end
			symbolCode[2] = code;
			lastLength = length;
		end
	end

	-- finally, sort the array back to alphabetical order
	local sortByAlphabet = function( a, b )
		return reverseAlphabet[a[1]] < reverseAlphabet[b[1]]; -- compare alphabetical order
	end

	table.sort( canonicalCodeArray, sortByAlphabet );

	return canonicalCodeArray;
end

-- returns an array of length suitable to regenerate canonical Huffman codes with prior knowledge of the alphabet
-- code lengths of 0 are truncated at the end of the table starting with 'minSize'
HuffmanEncoding.CodeLengthsForCanonicalCodes = function( canonicalCodes, minSize )
	local codeLengths = {};

	-- add code lengths in order
	if canonicalCodes ~= nil then
		for _,symbolCode in ipairs( canonicalCodes ) do
			table_insert( codeLengths, symbolCode[3] );
		end
	end

	-- pad with code lengths of 0 until we reach <minSize> code lengths
	for i = #codeLengths + 1, minSize do
		table_insert( codeLengths, 0 );
	end

	-- truncate code lengths of 0 starting at minSize
	for i = #codeLengths, minSize + 1, - 1 do
		if codeLengths[i] == 0 then
			codeLengths[i] = nil;
		else
			break;
		end
	end

	return codeLengths;
end
