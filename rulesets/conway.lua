os = nil
conway = {}

function conway:onInit()
    self.domain = {}
    for i=0, 31 do
        self.domain[i] = {}
        for j=0, 31 do
            self.domain[i][j] = math.random(0, 1)
        end
    end
    self.rule =
        function (x, ones)
            if x == 1 then
                if ones < 2 then return 0
                else return 1 end
            elseif ones == 3 then return 1
            end
        end
end

function conway:onUpdate()
    copy = {}
    for i=0, 31 do
        for j=0, 31 do
            copy[i][j] = self.domain[i][j]
        end
    end

    for i=0, 31 do
        for j=0, 31 do
            k = 0
            for x=-1, 1 do
                for y=-1, 1 do
                    k = k + copy[i+x][j+y]
                end
            end

            self.domain[i][j] =
                self.rule(self.domain[i][j], k-copy[i][j])
        end
    end
end

-- function conway:onDisplay()
--     for i=0, 31 do
--         for j=0, 31 do
--             io.write("\033[" .. (47+2*self.domain[i][j]) .. "m  ")
--         end
--         io.write("\033[m\n")
--     end
-- end

return conway
