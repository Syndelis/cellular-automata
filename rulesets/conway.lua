math.randomseed(os.time())
os = nil
conway = {}


function conway:onInit()
    self.domain = {}
    for i=1, 32 do
        self.domain[i] = {}
        for j=1, 32 do
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
    for i=1, 32 do
        copy[i] = {}
        for j=1, 32 do
            copy[i][j] = self.domain[i][j]
        end
    end

    for i=1, 32 do
        for j=1, 32 do
            k = 0
            for x=-1, 1 do
                for y=-1, 1 do
                    if (i+x >= 1 and i+x <= 32 and j+y >= 1 and j+y <= 32) then
                        -- io.write("copy[" .. (i+x) .. "][" .. (j+y) .. "] = ")
                        -- print(copy[i+x][j+y])
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

-- function conway:onDisplay()
--     for i=0, 31 do
--         for j=0, 31 do
--             io.write("\033[" .. (47+2*self.domain[i][j]) .. "m  ")
--         end
--         io.write("\033[m\n")
--     end
-- end

return conway
