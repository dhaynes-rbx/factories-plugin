local Studio = {}

function Studio.setSelectionTool()
    getfenv(0).plugin:SelectRibbonTool(Enum.RibbonTool.Select, UDim2.new())
end

return Studio