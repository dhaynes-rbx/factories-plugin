--!strict
local findDeltaPaths = require(script.Parent.FindDeltaPaths)
local deepCompare = require(script.Parent.DeepCompare)
return function()
    describe("FindDeltaPaths", function()
        it("it should handle equivalent primitives", function()
            local paths = findDeltaPaths(1, 1)
            expect(deepCompare(paths, {})).to.equal(true)

            paths = findDeltaPaths("foo", "foo")
            expect(deepCompare(paths, {})).to.equal(true)

            paths = findDeltaPaths(true, true)
            expect(deepCompare(paths, {})).to.equal(true)
        end)

        it("it should handle different primitives", function()
            local paths = findDeltaPaths(1, 2)
            expect(deepCompare(paths, { "" })).to.equal(true)

            paths = findDeltaPaths("foo", "bar")
            expect(deepCompare(paths, { "" })).to.equal(true)

            paths = findDeltaPaths(true, false)
            expect(deepCompare(paths, { "" })).to.equal(true)
        end)

        it("it should handle different types", function()
            local paths = findDeltaPaths(1, true)
            expect(deepCompare(paths, { "" })).to.equal(true)
            paths = findDeltaPaths("foo", 1)
            expect(deepCompare(paths, { "" })).to.equal(true)
            paths = findDeltaPaths(true, "bar")
            expect(deepCompare(paths, { "" })).to.equal(true)
        end)

        it("it should handle equivalent arrays", function()
            local paths = findDeltaPaths({ 1, 2, 3 }, { 1, 2, 3 })
            expect(deepCompare(paths, {})).to.equal(true)

            paths = findDeltaPaths({ "foo", "bar" }, { "foo", "bar" })
            expect(deepCompare(paths, {})).to.equal(true)

            paths = findDeltaPaths({ true, true, true, false }, { true, true, true, false })
            expect(deepCompare(paths, {})).to.equal(true)
        end)

        it("it should handle different arrays", function()
            local paths = findDeltaPaths({ 1, 3, 5 }, {})
            expect(deepCompare(paths, { 1, 2, 3 })).to.equal(true)

            paths = findDeltaPaths({ 1, 3, 5 }, { 1, 5, 3, 7 })
            expect(deepCompare(paths, { 2, 3, 4 })).to.equal(true)

            paths = findDeltaPaths({ "foo", "bar" }, {})
            expect(deepCompare(paths, { 1, 2 })).to.equal(true)

            paths = findDeltaPaths({}, {})
            expect(deepCompare(paths, {})).to.equal(true)
        end)

        it("it should handle equivalent tables", function()
            local paths = findDeltaPaths({
                a = "a",
                b = 1,
                c = true,
                d = { 1, 2, 3, 4 },
            }, {
                a = "a",
                b = 1,
                c = true,
                d = { 1, 2, 3, 4 },
            })
            expect(deepCompare(paths, {})).to.equal(true)
        end)

        it("it should handle different tables", function()
            local paths = findDeltaPaths({
                a = "a",
                b = 1,
                c = true,
                d = { 1, 2, 3, 4 },
            }, {
                a = "b",
                b = 1,
                c = true,
                d = { 1, 2, 3, 4 },
            })
            expect(deepCompare(paths, { "a" })).to.equal(true)

            paths = findDeltaPaths({
                a = "a",
                b = 1,
                c = true,
                d = { 1, 2, 3, 4 },
            }, {
                a = "a",
                b = 2,
                c = true,
                d = { 1, 2, 3, 4 },
            })
            expect(deepCompare(paths, { "b" })).to.equal(true)

            paths = findDeltaPaths({
                a = "a",
                b = 1,
                c = true,
                d = { 1, 2, 3, 4 },
            }, {
                a = "a",
                b = 1,
                c = false,
                d = { 1, 2, 3, 4 },
            })
            expect(deepCompare(paths, { "c" })).to.equal(true)

            paths = findDeltaPaths({
                a = "a",
                b = 1,
                c = true,
                d = { 1, 2, 3 },
            }, {
                a = "a",
                b = 1,
                c = true,
                d = { 9, 2, 3, 4 },
            })
            expect(deepCompare(paths, { "d.1", "d.4" })).to.equal(true)

            paths = findDeltaPaths({
                a = "a",
                b = 1,
                c = true,
                d = { 1, 2, 3, 4 },
            }, {
                a = "b",
                b = 2,
                c = false,
                d = { 9 },
            })
            expect(deepCompare(table.sort(paths), table.sort({ "a", "b", "c", "d.1", "d.2", "d.3", "d.4" }))).to.equal(true)
        end)
    end)
end
