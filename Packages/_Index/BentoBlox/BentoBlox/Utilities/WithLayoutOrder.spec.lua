--!strict
local Roact = require(script.Parent.Parent.Parent.Roact)
local withLayoutOrder = require(script.Parent.WithLayoutOrder)

return function()
    describe("Initializing with an array style table", function()
        local fromArray = withLayoutOrder({
            Roact.createElement("TextLabel", { Text = "A" }),
            Roact.createElement("TextLabel", { Text = "B" }),
            Roact.createElement("TextLabel", { Text = "C" }),
        })
        it("Should assign each element a LayoutOrder prop of type number by index", function()
            for index, element in ipairs(fromArray) do
                expect(element["props"]["LayoutOrder"]).to.equal(index)
                -- and keep exisitng props intact
                if index == 1 then
                    expect(element["props"]["Text"]).to.equal("A")
                elseif index == 2 then
                    expect(element["props"]["Text"]).to.equal("B")
                elseif index == 3 then
                    expect(element["props"]["Text"]).to.equal("C")
                end
            end
        end)
    end)

    describe("Initializing using named keys and a prefix convention", function()
        local fromPrefixes = withLayoutOrder({
            _1_Thing = Roact.createElement("Frame", {}),
            _2_OtherThing = Roact.createElement("Frame", {}),
            _3_ALastItem = Roact.createElement("Frame", {}),
        })

        it("Should strip prefixes and assign each element a LayoutOrder prop of type number by prefix", function()
            expect(fromPrefixes["Thing"].props.LayoutOrder).to.equal(1)
            expect(fromPrefixes["OtherThing"].props.LayoutOrder).to.equal(2)
            expect(fromPrefixes["ALastItem"].props.LayoutOrder).to.equal(3)
        end)
    end)

    describe("Initializing using prop values (common Roact)", function()
        local fromProps = withLayoutOrder({
            Thing = Roact.createElement("Frame", { LayoutOrder = 1 }, {}),
            OtherThing = Roact.createElement("Frame", { LayoutOrder = 2 }, {}),
            ALastItem = Roact.createElement("Frame", { LayoutOrder = 3 }, {}),
        })
        it("Should pass through common Roact LayoutOrder props", function()
            expect(fromProps["Thing"].props.LayoutOrder).to.equal(1)
            expect(fromProps["OtherThing"].props.LayoutOrder).to.equal(2)
            expect(fromProps["ALastItem"].props.LayoutOrder).to.equal(3)
        end)
    end)

    describe("Initialize with mixed sources for LayoutOrder", function()
        -- NOTE: These mix and match uses are not encouraged patterns.

        -- In most cases you should use one method consistently
        -- OR use one method for initialization (e.g. prefix)
        -- AND THEN use a LayoutOrder prop on special case items
        --    * either at the end of the initalize list
        --    * or in a seperate `table.insert` / `t.key =` statement

        local fromMixedPrefixes = withLayoutOrder({
            _1_First = Roact.createElement("Frame", {}),
            Third = Roact.createElement("Frame", { LayoutOrder = 30 }),
            _20_Second = Roact.createElement("Frame", {}),
        })
        it("Should pass through common Roact LayoutOrder props and assign the others by prefix", function()
            expect(fromMixedPrefixes["First"].props.LayoutOrder).to.equal(1)
            expect(fromMixedPrefixes["Second"].props.LayoutOrder).to.equal(20)
            expect(fromMixedPrefixes["Third"].props.LayoutOrder).to.equal(30)
        end)

        local fromMixedTable = withLayoutOrder({
            Roact.createElement("Frame", {}), -- 1 from index
            Roact.createElement("Frame", { LayoutOrder = 30 }),
            Roact.createElement("Frame", {}), -- Q. 3 from index OR 31 from increment? A. 3 from index
        })
        it("Should pass through common Roact LayoutOrder props and assign the others by index", function()
            expect(fromMixedTable[1].props.LayoutOrder).to.equal(1)
            expect(fromMixedTable[2].props.LayoutOrder).to.equal(30)
            expect(fromMixedTable[3].props.LayoutOrder).to.equal(3)
        end)
    end)

    describe("Initializing with a component tree", function()
        local insertingTests = withLayoutOrder({
            _1_A = Roact.createElement("Frame", {}),
            _2_B = Roact.createElement(
                "Frame",
                {},
                withLayoutOrder({
                    _1_InnerA = Roact.createElement("Frame", {}),
                    _2_InnerB = Roact.createElement("Frame", {}),
                    _3_InnerC = Roact.createElement("Frame", {}),
                })
            ),
            _3_C = Roact.createElement("Frame", {}),
        })
        -- TODO: expect
    end)

    -- TODO: Come back to this in another sprint
    --[[ NOTES (discussion with Regis):
        * Right now these tests are failing because inserting is literally just inserting the element
        * should be using __newindex of the assigned metatable which points to the insertWithLayoutOrder (or w/e name) function
        * could do getmetatable(insertingTestTable) and see if the metatable is being set properly
        * it should not be nil and should have __newindex, __highestLayoutOrder and __seenLayoutOrder properties
    --]]
    --[[
    describe("Inserting additional items", function()
        local insertingTests = withLayoutOrder({
            _1_A = Roact.createElement("Frame", {}),
            _3_B = Roact.createElement("Frame", {}),
            _10_C = Roact.createElement("Frame", {}),
        })

        it("Should insert elements with an increment of the highest LayoutOrder value", function()
            insertingTests["ItGoesToEleven"] = Roact.createElement("Frame", {})
            expect(insertingTests["ItGoesToEleven"].props.LayoutOrder).to.equal(11)
        end)

        it("Should insert prefixed keys as LayoutOrder values and strip prefix", function()
            insertingTests["_13_Thirteen"] = Roact.createElement("Frame", {})
            expect(insertingTests["Thirteen"].props.LayoutOrder).to.equal(13) -- 12 would mean it incorrectly incremented
        end)

        it("Should insert elements with an set LayoutOrder and preserve that", function()
            insertingTests["Fifteen"] = Roact.createElement("Frame", { LayoutOrder = 15 })
            expect(insertingTests["Fifteen"].props.LayoutOrder).to.equal(15) -- 14 would mean it incorrectly incremented
        end)

        it("Should insert elements with LayoutOrder values between existing values", function()
            -- Prop style
            insertingTests["MeTwo"] = Roact.createElement("Frame", { LayoutOrder = 2 })
            expect(insertingTests["MeTwo"].props.LayoutOrder).to.equal(2)
            -- Prefix style
            insertingTests["_9_Nine"] = Roact.createElement("Frame", {})
            expect(insertingTests["Nine"].props.LayoutOrder).to.equal(9)
        end)

        it("Should warn on inserting items that have both LayoutOrder and a prefix set", function()
            insertingTests["_2020_WasBad"] = Roact.createElement("Frame", { LayoutOrder = 3030 })
            -- TODO: expect warning
            -- Still adds, prefers prop for value, still strips key prefix
            expect(insertingTests["WasBad"].props.LayoutOrder).to.equal(3030)
        end)

        it("Should warn on inserting items that collide with already set LayoutOrder values", function()
            insertingTests["ACollidingThing"] = Roact.createElement("Frame", { LayoutOrder = 1 })
            -- TODO: expect warning
            -- Still adds, preserves colliding LayoutOrder value
            expect(insertingTests["A"].props.LayoutOrder).to.equal(1)
            expect(insertingTests["ACollidingThing"].props.LayoutOrder).to.equal(1)
        end)

        it("Should insert elements to table with an incremented LayoutOrder value", function()
            local insertingTestTable = withLayoutOrder({
                Roact.createElement("TextLabel", { Text = "One" }),
                Roact.createElement("TextLabel", { Text = "Two" }),
            })
            -- table insert, index and LayoutOrder are circumstantially aligned
            table.insert(insertingTestTable, Roact.createElement("TextLabel", { Text = "Three" }))
            expect(insertingTestTable[3].props.Text).to.equal("Three")
            expect(insertingTestTable[3].props.LayoutOrder).to.equal(3)
            -- key insert, misaligns index and LayoutOrder
            insertingTestTable["Four"] = Roact.createElement("TextLabel", { Text = "Four" })
            expect(insertingTestTable["Four"].props.LayoutOrder).to.equal(4)
            -- table insert, incrementing LayoutOrder from highest seen
            table.insert(insertingTestTable, Roact.createElement("TextLabel", { Text = "Five" }))
            expect(insertingTestTable[4].props.Text).to.equal("Five")
            expect(insertingTestTable[4].props.LayoutOrder).to.equal(5)
        end)

        it(
            "Should increment from highest LayoutOrder on inserting to a table initialized with a set LayoutOrder prop",
            function()
                local fromMixedTableAndInsert = withLayoutOrder({
                    Roact.createElement("Frame", {}), -- 1 from index
                    Roact.createElement("Frame", { LayoutOrder = 30 }),
                    Roact.createElement("Frame", {}), -- 31 from increment during init
                })
                table.insert(fromMixedTableAndInsert, Roact.createElement("Frame", {})) -- 32 from increment on insert
                expect(fromMixedTableAndInsert[4].props.LayoutOrder).to.equal(32)
            end
        )

        it("Should error on inserting anything that isn't a Roact element", function()
            local onlyRoactElements = withLayoutOrder({})
            table.insert(onlyRoactElements, "Not a RoactElement")
            -- TODO: expect Error
        end)
    end)
    --]]
end
