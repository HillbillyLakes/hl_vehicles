class_name HLTank extends Node3D

## Name of the tank.
@export var tank_name: String = "Tank"
## What the tank contains. Note: This can be anything, HLVehicle will treat it
## as fuel. But this could be useful for display to player or if customizing to
## add other liquid reseviors.
@export var contains: String = "Fuel"
## How much this tank holds.
@export_range (0.0, 100.0, 0.001) var capacity: float = 15.0

## Tank state is exported so it can be multiplayer synchronized.
@export_group("Tank State")
## How much is left in the tank.
@export_range (0.0, 100.0, 0.001) var remaining: float = 15.0

## Reduces the remaining volume by a specific amount.
## Returns true if there was enough in the tank, false otherwise.
func use(amount: float) -> bool:

	if remaining < amount:
		remaining = 0.0
		return false

	remaining -= amount
	return true
