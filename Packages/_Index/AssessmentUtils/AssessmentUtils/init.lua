-- !strict
return {
    -- Modules
    Bezier = require(script.Bezier),
    Crypto = require(script.Crypto),
    Http = require(script.Http),
    InputProxy = require(script.InputProxy),
    JSONPatch = require(script.JSONPatch),
    StringUtils = require(script.StringUtils),
    Timeout = require(script.Timeout),
    Timer = require(script.Timer),

    -- Functions
    deepCompare = require(script.DeepCompare),
    deepcopy = require(script.Deepcopy),
    findDeltaPaths = require(script.FindDeltaPaths),
    forEachDescendent = require(script.ForEachDescendent),
    getDescendantsByNameAndClass = require(script.GetDescendantsByNameAndClass),
    getRemoteEvent = require(script.GetRemoteEvent),
    getRemoteFunction = require(script.GetRemoteFunction),
    getTableSize = require(script.GetTableSize),
    getTotalMass = require(script.GetTotalMass),
    getValueAtPath = require(script.GetValueAtPath),
    getWorldBounds = require(script.GetWorldBounds),
    getWorldCornersFromBounds = require(script.GetWorldCornersFromBounds),
    hideInstance = require(script.HideInstance),
    isDevelopmentEnvironment = require(script.IsDevelopmentEnvironment),
    pruneTable = require(script.PruneTable),
    retry = require(script.Retry),
    setHierarchyProperty = require(script.SetHierarchyProperty),
    setInstanceTransparency = require(script.SetInstanceTransparency),
    showInstance = require(script.ShowInstance),
    vector3FromObject = require(script.Vector3FromObject),
    waitForValueAtPath = require(script.WaitForValueAtPath),
    worldObjectToScreenRect = require(script.WorldObjectToScreenRect),

    -- Module Scripts
    Logger = script.Logger,
}
