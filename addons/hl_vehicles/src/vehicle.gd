class_name HLVehicle extends RigidBody3D

#@export var vmin_grip: float = 2

@export_group("Powertrain")
@export_subgroup("Engine")
@export var engine: HLEngine

@export_subgroup("Transmission")
@export var transmission: HLTransmission

@export_subgroup("Suspension")
@export var front_axle: HLAxle
@export var rear_axle: HLAxle

@export_subgroup("Controllers")
@export var steering_controller: HLSteeringController
@export var torque_controller: HLTorqueController

@export_group("Fuel System")
@export var fuel_tank: HLTank

@export_group("Electrical System")
@export var electrical_system: HLElectricalSystem

@export_group("Terrain")
@export var terrain_handler: HLTerrainHandler

var driver = HLDriverState.new()
var vehicle_state = HLVehicleState.new()
var wheel_state = HLWheelState.new()

signal brake_state_change(value: bool)

# Controls how easy it is to drift, this is measured in degrees.
# 1 = slippery
# 10 = 
var drift_angle_max_degree: float = 40.0

var brake_value: float = 20000
var has_grip: bool = false
var grip_force: float
var driving_force_position: Vector3 # The force to move the car is applied at this position (local to the car).
var offset_drive: Vector3
var wheelbase: float
var vehicle_rotation: Quaternion
var parking_brake: bool = false
var has_driver: bool = false
var choke_on: bool = false
var throttle_on: bool = false
var powered_wheels: int = 0
var powered_wheels_with_contact: int = 0

static func find_vehicle(attempts: int, node: Node) -> HLVehicle:
	if attempts == 0:
		return null
	if node.get_parent() != null and node.get_parent() is HLVehicle:
		return node.get_parent()
	return HLVehicle.find_vehicle(attempts - 1, node.get_parent())

func set_multiplayer_auth(id: int):
	set_multiplayer_authority(id)

func _ready():

	# Get the max distance from rear and front wheels.
	wheelbase = abs(front_axle.position.z - rear_axle.position.z)

	## This could be udpated when mode changes between AWD, FWD, and RWD.
	driving_force_position = Vector3(0, rear_axle.position.y, rear_axle.position.z)
	#driving_force_position = Vector3(0, rear_axle.position.y, front_axle.position.z)
	#driving_force_position = Vector3(0, rear_axle.position.y, (rear_axle.position.z + front_axle.position.z) / 2.0)

func _physics_process(delta: float):

	if !is_multiplayer_authority():
		return

	vehicle_rotation = Quaternion(transform.basis)

	update_suspension(delta, vehicle_rotation)

	var on_ground = is_on_ground()
	
	if !on_ground:
		has_grip = false
		grip_force = steering_controller.reset()
		torque_controller.reset()

	offset_drive = vehicle_rotation * driving_force_position

	if on_ground:
		vehicle_state.update(vehicle_rotation, linear_velocity)

	var vehicle_velocity_magnitude: float = linear_velocity.length()
	var steering: float = vehicle_state.drift_angle_measurement
	var turn_radius: float = get_turn_radius(vehicle_velocity_magnitude)

	# For drifting if that's a thing we want.
	#if vehicle_velocity_magnitude < vmin_grip:
		#has_grip = false
	#else:
		#if driver.did_accelerate:
			#if vehicle_state.drift_angle_measurement > deg_to_rad(-drift_angle_max_degree) && vehicle_state.drift_angle_measurement < deg_to_rad(drift_angle_max_degree):
				#has_grip = true
	# TODO: If all tires popped, then no grip.
	
	if on_ground:
		update_surface_contacts()
		if wheels_on_ice > 2:
			grip_force = steering_controller.reset()
		else:
			adjust_steering(vehicle_rotation)
			steering = asin(wheelbase / turn_radius)

	#if has_grip:
		#adjust_steering(vehicle_rotation)
		#steering = asin(wheelbase / turn_radius)
	#else:
		#grip_force = steering_controller.reset()
		
	#grip_force = steering_controller.reset()

	if on_ground:
		engine.update(driver.did_accelerate, driver.did_reverse, driver.did_brake, delta)

	transmission.update(delta)

	## Engine braking.
	## TODO: Use braking curve.
	if on_ground and !parking_brake:
		var angle_magnitude: float = get_axle_height(HLAxle.FRONT) - get_axle_height(HLAxle.REAR)
		if abs(angle_magnitude) > 0.15:
			if abs(angle_magnitude) > 0.3 or !driver.did_brake:
				#apply_central_force(-vehicle_state.vehicle_direction * angle_magnitude * mass * 0.35)
				apply_central_force(-vehicle_state.vehicle_direction * angle_magnitude * mass * 0.35)

	wheel_state.update(delta, vehicle_state.velocity_front_axis, vehicle_state.velocity_rear_axis)

	update_wheel_rotation(delta, steering)

var wheels_on_ice: int = 0

func update_surface_contacts() -> void:

	wheels_on_ice = 0

	if terrain_handler != null:
		terrain_handler.update_surface_contacts(front_axle.left_wheel)
		terrain_handler.update_surface_contacts(front_axle.right_wheel)
		terrain_handler.update_surface_contacts(rear_axle.left_wheel)
		terrain_handler.update_surface_contacts(rear_axle.right_wheel)

	if front_axle.left_wheel.is_on_ice:
		wheels_on_ice += 1
	if front_axle.right_wheel.is_on_ice:
		wheels_on_ice += 1
	if rear_axle.left_wheel.is_on_ice:
		wheels_on_ice += 1
	if rear_axle.right_wheel.is_on_ice:
		wheels_on_ice += 1

func adjust_steering(vehicle_rotation: Quaternion):
	grip_force = steering_controller.adjust(0, vehicle_state.velocity_sideways)
	var direction = vehicle_rotation * Vector3.LEFT
	var grip_force_vector: Vector3 = direction * grip_force
	apply_force(grip_force_vector, offset_drive)

func update_wheel_rotation(delta: float, steering: float):

	# Force wheels to follow steering wheel
	if driver.did_steer_left:
		steering = deg_to_rad(30)
	elif driver.did_steer_right:
		steering = deg_to_rad(-30)
	else:
		steering = deg_to_rad(0)

	front_axle.left_wheel.rotate_wheel(delta, wheel_state.total_movement_front, steering)
	front_axle.right_wheel.rotate_wheel(delta, wheel_state.total_movement_front, steering)
	rear_axle.left_wheel.rotate_wheel(delta, wheel_state.total_movement_front, steering)
	rear_axle.right_wheel.rotate_wheel(delta, wheel_state.total_movement_front, steering)

func get_turn_radius(vehicle_velocity_magnitude: float) -> float:

	var radius: float

	#var radius_min: float = 1.1 * wheelbase
	var radius_min: float = 1.0 * wheelbase * 5.0

	if angular_velocity.y > 0:
		radius = min(999, vehicle_velocity_magnitude / angular_velocity.y)
		if radius < radius_min:
			radius = radius_min

	elif angular_velocity.y < 0:
		radius = max(-999, vehicle_velocity_magnitude / angular_velocity.y)
		if radius > -radius_min:
			radius = -radius_min

	else:
		radius = 999

	return radius

func update_suspension(delta: float, vehicle_rotation: Quaternion) -> void:

	rear_axle.left_wheel.add_spring_force(delta, self, vehicle_rotation)
	rear_axle.right_wheel.add_spring_force(delta, self, vehicle_rotation)
	front_axle.left_wheel.add_spring_force(delta, self, vehicle_rotation)
	front_axle.right_wheel.add_spring_force(delta, self, vehicle_rotation)

func get_axle_height(location: int) -> float:

	if location == HLAxle.FRONT:
		return front_axle.global_position.y

	if location == HLAxle.REAR:
		return rear_axle.global_position.y

	return 0.0

func is_on_ground() -> bool:

	if front_axle.left_wheel.has_contact or front_axle.right_wheel.has_contact:
		return true

	if rear_axle.left_wheel.has_contact or rear_axle.right_wheel.has_contact:
		return true

	return false

## Gets a total number of powered wheels with contact
func _powered_wheels() -> int:

	var count = 0

	count = _powered_axle(front_axle, count)
	count = _powered_axle(rear_axle, count)

	powered_wheels = count

	return count

func _powered_axle(axle: HLAxle, count: int) -> int:

	axle.powered = false

	if (
		(transmission.mode == HLTransmission.AWD 
		and (
			axle.mode_enabled == HLTransmission.AWD
			or axle.mode_enabled == HLTransmission.FWDAWD
			or axle.mode_enabled == HLTransmission.RWDAWD
		))
		or
		(transmission.mode == HLTransmission.RWD 
		and (
			axle.mode_enabled == HLTransmission.RWD
			or axle.mode_enabled == HLTransmission.RWDAWD
		))
		or
		(transmission.mode == HLTransmission.FWD 
		and (
			axle.mode_enabled == HLTransmission.FWD
			or axle.mode_enabled == HLTransmission.FWDAWD
		))
	):
		axle.powered = true
		axle.left_wheel.is_powered = true
		axle.right_wheel.is_powered = true
		count += 2

	else:

		axle.left_wheel.is_powered = false
		axle.right_wheel.is_powered = false

	return count

func _powered_wheels_with_contact() -> int:

	var count = 0
	
	powered_wheels_with_contact = 0

	count = _powered_axles_with_contact(front_axle, count)
	count = _powered_axles_with_contact(rear_axle, count)
	powered_wheels_with_contact = count

	return count

func _powered_axles_with_contact(axle: HLAxle, count: int) -> int:

	axle.contact_wheels = 0

	if (
		(transmission.mode == HLTransmission.AWD 
		and (
			axle.mode_enabled == HLTransmission.AWD
			or axle.mode_enabled == HLTransmission.FWDAWD
			or axle.mode_enabled == HLTransmission.RWDAWD
		))
		or
		(transmission.mode == HLTransmission.RWD 
		and (
			axle.mode_enabled == HLTransmission.RWD
			or axle.mode_enabled == HLTransmission.RWDAWD
		))
		or
		(transmission.mode == HLTransmission.FWD 
		and (
			axle.mode_enabled == HLTransmission.FWD
			or axle.mode_enabled == HLTransmission.FWDAWD
		))
	):
		if axle.left_wheel.has_contact:
			axle.contact_wheels += 1
			count += 1
		if axle.right_wheel.has_contact:
			axle.contact_wheels += 1
			count += 1

	return count
