class_name HLVehicleState extends Node

var velocity_front_axis: float
var velocity_rear_axis: float
var velocity_sideways: float
var vehicle_direction: Vector3
var velocity_direction: Vector3
var vehicle_moving_forward: bool
var drift_angle_measurement: float

func update(vehicle_rotation: Quaternion, vehicle_velocity: Vector3):
	var vehicle_direction_sideways: Vector3 = vehicle_rotation * Vector3.LEFT
	vehicle_direction = vehicle_rotation * Vector3.FORWARD
	vehicle_direction = vehicle_direction.normalized()
	velocity_front_axis = vehicle_velocity.length()
	velocity_rear_axis = vehicle_velocity.dot(vehicle_direction)
	velocity_sideways = vehicle_velocity.dot(vehicle_direction_sideways)
	if velocity_front_axis > 0:
		velocity_direction = vehicle_velocity.normalized()
	else:
		velocity_direction = vehicle_direction
	vehicle_moving_forward = vehicle_direction.dot(velocity_direction) > 0
	var cross_product: Vector3
	if vehicle_moving_forward:
		cross_product = vehicle_direction.cross(velocity_direction)
	else:
		cross_product = velocity_direction.cross(vehicle_direction)
	if velocity_front_axis > 0.1:
		drift_angle_measurement = asin(cross_product.y)
	if !vehicle_moving_forward:
		velocity_front_axis = -velocity_front_axis

func brake():
	velocity_front_axis = 0
	velocity_rear_axis = 0
