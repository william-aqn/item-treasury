
------------------------------------------------------------------------------------------------------------------------
--[[

		Item Encoding by Vorozhej

--]]
------------------------------------------------------------------------------------------------------------------------


local numberToBinary32Float = function( n )
	if n == 0 then return 0 end;

	local precision = 24;
	local sign;
	if n > 0 then
		sign = 0;
	else
		sign = 1;
	end
	n = math.abs( n );

	local maxn = 2^(precision - 1)
	local exponent = math.ceil(math.log(math.floor(n))/math.log(2));

	if n > (2*maxn) then
		while n > maxn do
			n = n / 2;
		end
	else
		while n < maxn do
			n = n * 2;
			if n < 0 then
				exponent = exponent - 1;
			end
		end
	end

	-- bias the exponent
	exponent = exponent + 127

	local result = sign;
	result = Templ.Utils.bit32.lshift( result, 8 ); -- exponent is encoded on 8bits
	result = result + exponent;
	result = Templ.Utils.bit32.lshift( result, 23 ); -- and significand on 23 bits
	result = result + math.floor( n - 2^precision ); -- we don't store the most significant bit (always 1, as number is normalized)
	return result;
end

function Codec_Serialize(vItem_ID, vPlayer_Lvl, vItem_Lvl, vExtra_count, vArmour, vMaxDmg, tEssences)
	local out = ByteStream(); --!*!

	-- Instance ID
	out:PutLongLE( 0x00000000 );

	out:PutLongLE( 0x03000003 ); -- note: 'xx' should be replaced with the server ID (same as any instance item ID on that server), unsure about the 0003. May all work with just 0x03000000

	-- Generic ID
	out:PutLongLE( vItem_ID );--0x700292A1 );
	-- additional data
	out:Put(0);
	out:Put(vExtra_count); -- 3 extra structures
	--out:Put(3); -- 3 extra structures
	-- extra extra info
	out:PutLongLE( 0x100012C5 );	-- header
	out:PutLongLE( 0x100012C5 );	-- header repeated
	-- number of extra extra structures
	local extras = vExtra_count;
	out:PutLongLE( 2 );
	-- player level
	if vPlayer_Lvl ~= nil then
		out:PutLongLE( 0x100000C4 );	-- header
		out:PutLongLE( vPlayer_Lvl );
	end
	-- item level
	if vItem_Lvl ~= nil then -- ALWAYS NEEDS TO HAVE AN ITEM LEVEL!
		out:PutLongLE( 0x10000669 );
		out:PutLongLE( vItem_Lvl );
	end
	-- Armour rating
	if vArmour ~= nil then -- Armour header
		out:PutLongLE( 0x10000570 );
		out:PutLongLE( vArmour );
	end;
	-- Max damage rating
	if vMaxDmg ~= nil then
		out:PutLongLE( 0x10001042 );
		out:PutLongLE( numberToBinary32Float(vMaxDmg) );
	end;

	if type(tEssences) == 'table' then

		out:PutLongLE( 0x10005F0E); -- main Essence header
		out:PutLongLE(#tEssences);

		for k,v in ipairs(tEssences) do
			out:PutLongLE( 0x10005F3D );	-- Essence header
			out:Put(0);
			out:Put(2);

			out:PutLongLE( 0x10005F05 );	-- Essence Item ID header
			out:PutLongLE( 0x10005F05 );	-- Repeated

			out:PutLongLE(v);	-- ID

			out:PutLongLE( 0x10005F3E );	-- Essence Level header
			out:PutLongLE( 0x10005F3E );	-- repeated

			local iLevel = _ITEMSDB[v][3];
			if SETTINGS.LEVELINFLATE ~= nil then iLevel = iLevel * (1 + SETTINGS.LEVELINFLATE) end;
			out:PutLongLE(iLevel); -- Item level
			--out:PutLongLE(999);

		end

	end

	-- GenericID
	out:PutLongLE( 0x10000421 );	-- header
	out:PutLongLE( 0x10000421 );	-- header repeated
	out:PutLongLE( vItem_ID );
	-- Instance ID
	out:PutLongLE( 0x10002897 );	-- header
	out:PutLongLE( 0x10002897 );	-- header repeated
	out:PutLongLE( 0x00000000 );	-- instance id low
	out:PutLongLE( 0x03000003 );	-- instance id high
	return out:GetData();
end

function Codec_Encode(vItem_ID, vPlayer_Lvl, vItem_Lvl, vExtra_count, vArmour, vMaxDmg, tEssences)
	local table_insert = table.insert;
	-- serialize the item
	local serializedData = Codec_Serialize(vItem_ID, vPlayer_Lvl, vItem_Lvl, vExtra_count, vArmour, vMaxDmg,tEssences);
	-- compress it
	local deflatedData = Zlib.Deflate( serializedData ); --!*!
	-- array with header + data. Header stats with a 0 longword
	local preEncodingArray = {0,0,0,0};
	-- append length of (inflated) data to header
	local len = #serializedData;
	for i = 1,4 do
		local byte = len % 256;
		table_insert( preEncodingArray, byte );
		len = bit32.rshift( len, 8 ); --!*!
	end
	-- append data
	for _,byte in ipairs( deflatedData ) do
		table_insert( preEncodingArray, byte );
	end
	-- encode it to Uncode characters using Turbine's scheme
	local encodedString = TurbineUTF8Binary.Encode( preEncodingArray ); --!*!
	return encodedString;
end
