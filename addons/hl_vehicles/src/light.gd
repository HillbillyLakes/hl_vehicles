class_name HLLight extends Node3D

var vehicle: HLVehicle

var light: Light3D

func toggle(value: bool) -> void:

	if visible != value:
		visible = value
