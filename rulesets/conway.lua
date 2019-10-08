math.randomseed(time())
conway = {}

function conway:onInit(dimensions)
    self.domain = {}
    for i=1, dimensions do
        self.domain[i] = {}
        for j=1, dimensions do
            self.domain[i][j] = (math.random(0, 2) == 0 and 0 or 1)
        end
    end
    self.rule =
        function (x, ones)
            if x == 1 then
                if ones < 2 or ones > 3 then return 0
                else return 1 end
            elseif ones == 3 then return 1
            else return 0
            end
        end
end

function conway:onUpdate()
    copy = {}
    dimensions = #self.domain

    for i=1, dimensions do
        copy[i] = {}
        for j=1, dimensions do
            copy[i][j] = self.domain[i][j]
        end
    end

    zeroes = 0

    for i=1, dimensions do
        for j=1, dimensions do
            k = 0

            neighbors = neighbors8(i, j, copy)--, function (b) return b == 1 end)
            for i, v in ipairs(neighbors) do
                k = k + v
            end

            self.domain[i][j] = self.rule(copy[i][j], k)
        end
    end
end

return conway
