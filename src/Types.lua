--!strict

export type Item = {
    id: string,
    locName: Unit | string,
    thumb: string?,
    asset: string?,
    requirements: {
        [number]: RequirementItem,
    }?,
    value: RequirementItem?,
}

export type RequirementItem = {
    itemId: string,
    count: number,
} & Item

export type PendingItem = {
    itemId: string,
    count: number,
    steps: number,
}

export type Inventory = {
    [string]: number,
}

export type Powerup = {
    id: string,
    locName: string,
    locDesc: string,
    thumb: string,
    type: string,
    value: number,
    maxUsage: number,
    cost: RequirementItem,
}

export type Machine = {
    -- Definition -------------------------
    id: string,
    locName: string,
    thumb: string?,
    asset: string?,
    type: string, -- (purchaser|maker|makerSeller)
    outputs: {
        [number]: Item | string,
    },
    defaultMaxStorage: number?, -- (default: -1)
    defaultProductionDelay: number?, -- (default: 1)
    defaultOutputCount: number,
    sources: {
        [number]: number,
    },
    destinations: {
        [number]: number,
    },
    coordinates: {
        X: number,
        Y: number,
    },
    outputRange: { min: number, max: number }?,

    powerup: Powerup?,
    supportsPowerup: boolean?, -- (default: true)
    currentOutputIndex: number,
    currentOutputCount: number,
} & MachineSimulationStep

export type MachineSimulationStep = {
    storage: Inventory,
    pendingProduction: PendingItem,
    state: string, -- (processing, ready)
    actionMap: { [string]: boolean },
    sourceInventories: { number },
    overstock: number,
}

export type FactorySettings = {
    [string]: MachineSimulationSettings,
}

export type MachineSimulationSettings = {
    powerup: Powerup?,
    currentOutputIndex: number,
    currentOutputCount: number,
}

export type FactorySimulationStep = {
    step: number,
    machines: { [string]: MachineSimulationStep },
    inventory: Inventory,
}

export type FactorySimulation = {
    steps: { [number]: FactorySimulationStep },
    machineSettings: FactorySettings,
}

export type Unit = {
    singular: string,
    plural: string,
}

export type Factory = {
    id: string,
    locName: string,
    locDesc: string,
    scene: string,
    thumb: string,
    stepsPerRun: number,
    stepUnit: Unit,
    totalStepCount: number,
    currentStep: number,
    state: string,
    currentSimulation: number,
    items: { [string]: Item },
    inventory: { [string]: number },
    defaultInventory: { [string]: number },
    machines: { [number]: Machine },
    powerups: { [number]: Powerup },
    powerupsFocused: boolean,
    sellableItems: { [number]: string },
    simulations: { [number]: FactorySimulation },
    previousSettings: FactorySettings?,
    selectedMachineIndex: number,
    machineEditorSliderSteps: { [string]: number },
}

-- export type PatchMachine = Machine & CoreTypes.PatchTable
-- export type PatchFactory = Factory & CoreTypes.PatchTable
export type Target = {
    type: string,
    path: string,
    xOffset: number?,
    yOffset: number?,
}
export type Advances = {
    type: string,
}
export type Objective = {
    name: string,
    complete: boolean,
}

export type Objectives = {
    [number]: Objective,
}
export type TutorialStep = {
    key: string,
    requires: string,
    target: Target,
    relativePosition: string,
    pointer: boolean,
    text: string,
    delay: number,
    advances: Advances,
    objectives: Objectives?,
    allowedInputs: { string }?,
}

export type TutorialData = { steps: { [number]: TutorialStep } }

export type SpotlightPositionAndSize = { pos: Vector2, size: Vector2 }

return {}
