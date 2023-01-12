-- Short implementation of a priority queue using a skew heap

-- The queue is arranged in such a way that an element equal to the first n elements will be pulled last of those elements
-- (TODO: or is it ?)

PriorityQueue = class();
function PriorityQueue:Constructor()
	self.heap = nil; -- our 'heap'
end

-- skew heap merge, n[1] = priority, n[2] = element, n[3] = left child, n[4] = right child
local function merge(a, b)
	if not (a and b) then
        return a or b
    end

	-- make it so 'a' is always the smaller root and 'b' the other root
	if a[1] > b[1] then a,b = b,a end;
	
	a[3],a[4] = merge( a[4], b ), a[3];
	return a;
end

-- insert an element with a given priority into the heap
-- nodes: array[3] = left, array[4] = right
function PriorityQueue:Insert( element, priority )
	self.heap = merge( self.heap, {priority, element, false, false} );
end

-- Pull the first element off the queue
function PriorityQueue:Pull()
	local node = self.heap;
	if not node then return nil,nil end;
	self.heap = merge( node[4], node[3] );
	return node[2], node[1];
end
