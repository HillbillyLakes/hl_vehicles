class_name HLWheelState extends Node3D

var total_movement_front: float
var total_movement_rear: float
var left_tread_contact: bool = false
var right_tread_contact: bool = false

func update(delta: float, velocity_front_axis: float, velocity_rear_axis: float):
	total_movement_front += delta * velocity_front_axis
	total_movement_rear += delta * velocity_rear_axis

func reset_treads() -> void:
	left_tread_contact = false
	right_tread_contact = false
