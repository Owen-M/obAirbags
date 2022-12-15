Config = {}

Config.deploySpeed = 60.0 -- If there is a collision above this speed, the airbags will deploy. Speed in MPH.
Config.airbagProp = `prop_carairbag` -- The airbag prop to use.
Config.damageLevel = 200.0 -- If the vehicle gets below this level of damage then the airbags will deploy.
Config.exemptVehicles = { -- Vehicles that airbags will not be deployed on
    `sanchez`
}

Config.exemptClasses = { -- Classes of vehicle to be exempt from airbags being deployed.
    8,
    13,
    15,
    16,
    14
}

