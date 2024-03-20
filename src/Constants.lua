return {
    Panels = {
        EditDatasetUI = "Edit Dataset",
        EditFactoryUI = "Edit Factory",
        EditMachineUI = "Edit Machine",
        EditItemUI = "Edit Item",
        EditPowerupUI = "Edit Powerup",
        SelectThumbnailUI = "Select Thumbnail",
        SelectMachineUI = "Select Machine",
        SelectOutputItemUI = "Select Item",
        SelectRequirementItemUI = "Select Requirement Item",
    },
    MachineTypes = {
        maker = "maker",
        makerSeller = "makerSeller",
        purchaser = "purchaser",
        invalid = "invalid",
    },
    MachineAssetPaths = {
        maker = "Assets.Machines.Machine-Default",
        makerSeller = "Assets.Machines.Seller",
        purchaser = "Assets.Machines.Purchaser",
        placeholder = "Assets.Machines.PlaceholderMachine",
    },
    Errors = {
        None = "None",
        DuplicateCoordinatesError = "Duplicate Coordinates Error",
        InvalidMachine = "Invalid machine: Machine has no source, yet outputs an item that has a value",
    },
    Defaults = {
        BoldFont = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
        MachineDefaultOutput = 40,
        MachineDefaultOutputRange = {
            min = 0,
            max = 100,
        },
        MachineDefaultMaxStorage = 100,
    },
    None = "None",
}
