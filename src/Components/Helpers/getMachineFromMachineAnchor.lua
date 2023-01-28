return function(map:table, anchor:Instance)
    local debugId = anchor:GetAttribute("debugId")
    local counter = 0
    local machine = nil
    for _,machineObj in map["machines"] do
        print(machineObj["coordinates"]["X"], machineObj["coordinates"]["Y"], machineObj)
        if machineObj["machineAnchor"] and machineObj["machineAnchor"] == debugId then
            machine = machineObj
            counter += 1
        end
    end

    if counter > 1 then
        print("Error! More than one machine refers to this anchor!")
    end

    return machine
end