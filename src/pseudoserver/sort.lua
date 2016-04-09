local function Partition(A,p,r)
    local x,i,j,tmp
    local randidx = math.random(p,r)
    if randidx ~= r then
        tmp = A[r]
        A[r] = A[randidx]
        A[randidx] = tmp
    end

    x = A[r]
    i = p - 1
    j = p
    while j <= r - 1 do
        if A[j] <= x then
            i = i + 1
            temp = A[i]  
            A[i] = A[j]
            A[j] = temp            
        end
        j = j + 1
    end
    temp = A[i+1]
    A[i+1] = A[r]  
    A[r] = temp  
    return i + 1  
end

local function Sort(A,p,r)
    local len = #A
    p = p or 1
    r = r or len
    if len > 0 and p < r then
        if r > len then
            r = len
        end
        local q = Partition(A,p,r)
        Sort(A,p,q-1)  
        Sort(A,q+1,r)  
    end
end

--local array = {5,4,7,2,9}

--Sort(array,1,#array)

--print(array[1],array[2],array[3],array[4],array[5])

return {
    Sort = Sort
}


