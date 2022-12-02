return function()
    local Timeout = require(script.Parent.Timeout)

    describe("set", function()
        it("should create a timeout", function()
            local handle = nil
            expect(function()
                handle = Timeout.set(1, 0, function() end)
            end).to.never.throw()
            expect(handle).to.equal(0)
        end)

        it("should execute timeout", function()
            local called = false
            local delay = 1
            Timeout.set(delay, 0, function()
                called = true
            end)
            local start = tick()
            while called == false and tick() - start < delay + 1 do
                wait()
            end
            expect(called).to.be.equal(true)
            expect(tick() - start).to.be.near(delay, 0.05)
        end)

        it("should repeat n times", function()
            local calls = 0
            local delay = 1
            local repeats = 5
            Timeout.set(delay, repeats, function()
                calls = calls + 1
            end)

            local start = tick()
            local totalTime = delay * repeats
            while calls < repeats and tick() - start < totalTime + 1 do
                wait()
            end
            expect(calls).to.be.equal(repeats)
            expect(tick() - start).to.be.near(totalTime, 0.2)
        end)

        it("should pass a parameter", function()
            local receivedParam = 0
            local sentParam = 12345
            local delay = 1
            Timeout.set(delay, 0, function(param)
                receivedParam = param
            end, sentParam)
            local start = tick()
            while receivedParam == 0 and tick() - start < delay + 1 do
                wait()
            end
            expect(receivedParam).to.be.equal(sentParam)
            expect(tick() - start).to.be.near(delay, 0.05)
        end)

        it("should pass multiple parameters", function()
            local receivedParamA = 0
            local sentParamA = 12345

            local receivedParamB = "0"
            local sentParamB = "12345"

            local delay = 1
            Timeout.set(delay, 0, function(paramA, paramB)
                receivedParamA = paramA
                receivedParamB = paramB
            end, sentParamA, sentParamB)
            local start = tick()
            while receivedParamA == 0 and receivedParamB == "0" and tick() - start < delay + 1 do
                wait()
            end
            expect(receivedParamA).to.be.equal(sentParamA)
            expect(receivedParamB).to.be.equal(sentParamB)
            expect(tick() - start).to.be.near(delay, 0.05)
        end)

        it("should clear", function()
            local delay = 1
            local called = false
            local handle = Timeout.set(delay, 0, function(paramA, paramB)
                called = true
            end)
            local start = tick()
            -- Wait for half the time then clear the timeout
            while called == false and tick() - start < (delay * 0.5) do
                wait()
            end
            Timeout.clear(handle)
            -- Wait for the second half plus some
            while called == false and tick() - start < (delay * 0.5 + 1) do
                wait()
            end
            expect(called).to.be.equal(false)
        end)
    end)
end
