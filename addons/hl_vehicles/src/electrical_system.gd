class_name HLElectricalSystem extends Node3D

@export_group("Lights")
@export var tail_lights: Array[HLLight] = []

# Just a reference to the vehicle.
var vehicle: HLVehicle

func _enter_tree() -> void:

	vehicle = HLVehicle.find_vehicle(10, self)

func _ready() -> void:

	for light in tail_lights:
		vehicle.brake_state_change.connect(light.toggle)
