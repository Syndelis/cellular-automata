math.randomseed(os.time())
os = nil
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

    for i=1, dimensions do
        for j=1, dimensions do
            k = 0
            for x=-1, 1 do
                for y=-1, 1 do
                    if (i+x >= 1 and i+x <= dimensions and j+y >= 1 and j+y <= dimensions) then
                        k = k + (copy[i+x][j+y] or 0)
                    end
                end
            end
            k = k - (copy[i][j] or 0)

            self.domain[i][j] =
                self.rule(copy[i][j], k)
        end
    end
end

return conway
