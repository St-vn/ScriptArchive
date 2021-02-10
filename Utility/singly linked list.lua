-- St_vn#3931
-- St_vnC(Roblox)
-- St-vn(Github)

local linkedList = {}
linkedList.__index = linkedList

local iterator = function(list)
    local position = 0
    local node = list.Head
    
    return function()
        if 1 < position then
            node = node.Next
        end
        
        position += 1
        
        return position, node, node.Value
    end, 0
end

function linkedList:Insert(element, insertPos)
    insertPos = insertPos or self.Depth + 1
    
    for position, node in iterator(self) do
        if position == insertPos then
            self.Depth += 1
            
            node.Next = {
                Value = element,
                Next = insertPos == self.Depth and nil or node.Next
            }
            
            break
        end
    end
end

function linkedList:Remove(removePos)
    removePos = (removePos or self.Depth) - 1
    
    for position, node in iterator(self) do
        if position == removePos then
            self.Depth -= 1
            node.Next = node.Next.Next

            break
        end
    end
end

function linkedList:View(viewPos)
    for position, node, value in iterator(self) do
        if position == viewPos then
            return value
        end
    end
end

return function(head)
    return setmetatable({
        Head = head,

        Depth = 1
    }, linkedList)
end
