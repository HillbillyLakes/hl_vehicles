class_name HLEngine extends Node3D

@export_group("Power")
@export var power_curve: Curve
@export var horse_power: float = 60.0

## Max speed in KPH for a 1:1 gear ratio.
@export var max_speed: float = 20
@export var max_wheel_spin_speed: float = 6
@export var max_reverse_speed: float = 7

@export var omega_curve: Curve
@export var omega_max: float = 0.6

@export_group("Braking")
## Used for engine braking, not wheels.
@export var brake_force: float = 20000
## Curve used for engine braking. The higher the curve the more braking applied.
## The curve should be low on left and high on right so engine braking is applied more
## at higher speeds. No part of the curve should be 0, though, otherwise the vehicle
## may never roll to a stop.
## TODO: Not implemented yet.
@export var engine_braking_curve: Curve

@export_group("Fuel")
## The rate at which fuel is consumed.
@export_range(0.0, 5.0, 0.001) var fuel_rate: float = 0.01

@export_group("Sounds")
@export var engine_start_sound: AudioStreamPlayer3D
@export var engine_rev_sound: AudioStreamPlayer3D
@export var mute_neutral: bool = false

## Engine state is exported so it can be multiplayer synchronized.
@export_group("Engine State")
@export var engine_running: bool = false:
	set(value):
		if value != engine_running:
			engine_running = value
			if engine_running:
				play_start_audio()
	get:
		return engine_running

# Just a reference to the vehicle.
var vehicle: HLVehicle

# Engine measurements
var acceleration_force: float
var velocity_measurement: float
var acceleration_measurement: float
var omega_reference: float
var engine_rev_pitch: float = 1.0

func _enter_tree() -> void:

	vehicle = HLVehicle.find_vehicle(10, self)

func _process(_delta: float) -> void:

	play_rev_audio(_delta)

func update(accelerate: bool, reverse: bool, brake: bool, delta: float) -> void:

	var vehicle_velocity_magnitude: float = vehicle.linear_velocity.length()

	acceleration_measurement = (vehicle_velocity_magnitude - velocity_measurement) / delta
	velocity_measurement = vehicle_velocity_magnitude
	acceleration_force = 0.0

	vehicle._powered_wheels()
	vehicle._powered_wheels_with_contact()

	if engine_running:
		if accelerate and !vehicle.parking_brake:

			accelerate(delta, false, max_speed)

			if ((vehicle.transmission.mode == HLTransmission.RWD
					or vehicle.transmission.mode == HLTransmission.RWDAWD
					or vehicle.transmission.mode == HLTransmission.AWD
					) and vehicle.rear_axle != null):
						
				var rear_wheels_on_ice: int = 0
				if vehicle.rear_axle.left_wheel.is_on_ice:
					rear_wheels_on_ice += 1
				if vehicle.rear_axle.right_wheel.is_on_ice:
					rear_wheels_on_ice += 1
				if rear_wheels_on_ice == 2:
					if vehicle.vehicle_state.velocity_rear_axis < max_wheel_spin_speed:
						vehicle.vehicle_state.velocity_rear_axis = max_wheel_spin_speed

			if ((vehicle.transmission.mode == HLTransmission.FWD
					or vehicle.transmission.mode == HLTransmission.FWDAWD
					or vehicle.transmission.mode == HLTransmission.AWD
					) and vehicle.front_axle != null):
				var front_wheels_on_ice: int = 0
				if vehicle.front_axle.left_wheel.is_on_ice:
					front_wheels_on_ice += 1
				if vehicle.front_axle.right_wheel.is_on_ice:
					front_wheels_on_ice += 1
				if front_wheels_on_ice == 2:
					if vehicle.vehicle_state.velocity_front_axis < max_wheel_spin_speed:
						vehicle.vehicle_state.velocity_front_axis = max_wheel_spin_speed

		elif reverse and !vehicle.parking_brake:

			accelerate(delta, true, max_reverse_speed)

		else:

			engine_braking(delta, vehicle_velocity_magnitude, max_speed)

	if brake or vehicle.parking_brake:

		brake(vehicle_velocity_magnitude, delta)

	control_omega(delta, vehicle_velocity_magnitude)

	var torque: float = vehicle.torque_controller.adjust(omega_reference, vehicle.angular_velocity.y)
	var torque_vector: Vector3 = Quaternion(vehicle.transform.basis) * Vector3.UP * torque

	var steering_wheels_in_contact: int = 0
	var steering_tires_popped: int = 0

	if vehicle.front_axle.left_wheel.has_contact:
		steering_wheels_in_contact += 1
	if vehicle.front_axle.left_wheel.tire_popped:
		steering_tires_popped += 1
	if vehicle.front_axle.right_wheel.has_contact:
		steering_wheels_in_contact += 1
	if vehicle.front_axle.right_wheel.tire_popped:
		steering_tires_popped += 1
	if vehicle.rear_axle.left_wheel.has_contact:
		steering_wheels_in_contact += 1
	if vehicle.rear_axle.left_wheel.tire_popped:
		steering_tires_popped += 1
	if vehicle.rear_axle.right_wheel.has_contact:
		steering_wheels_in_contact += 1
	if vehicle.rear_axle.right_wheel.tire_popped:
		steering_tires_popped += 1
	
	if steering_wheels_in_contact > 0:
		if steering_tires_popped > 0:
			# TODO: Add veer left or right based on tires popped.
			vehicle.apply_torque(torque_vector)
		else:
			vehicle.apply_torque(torque_vector)

	if engine_running:
		use_fuel(delta, vehicle_velocity_magnitude, max_speed)

func use_fuel(_delta: float, vehicle_velocity_magnitude: float, max_speed: float) -> void:

	var avg_gear_ratio: float = (
		vehicle.front_axle.gear_ratio + vehicle.rear_axle.gear_ratio
	) / 2.0

	var force_curve_value: float = power_curve.sample(velocity_measurement / float(max_speed) / avg_gear_ratio)
	var fuel_usage: float = fuel_rate * force_curve_value * _delta

	var has_fuel: bool = vehicle.fuel_tank.use(fuel_usage)

	if !has_fuel:
		engine_running = false

func engine_braking(_delta: float, vehicle_velocity_magnitude: float, max_speed: float) -> void:

	var angle_magnitude: float = (vehicle.get_axle_height(HLAxle.FRONT) - vehicle.get_axle_height(HLAxle.REAR))

	if angle_magnitude > 0.30:
		return

	_engine_braking_axle(vehicle.front_axle, _delta, vehicle_velocity_magnitude, max_speed)
	_engine_braking_axle(vehicle.rear_axle, _delta, vehicle_velocity_magnitude, max_speed)

func _engine_braking_axle(axle: HLAxle, _delta: float, vehicle_velocity_magnitude: float, max_speed: float) -> void:

	_engine_braking_wheel(axle.left_wheel, _delta, vehicle_velocity_magnitude, max_speed)
	_engine_braking_wheel(axle.right_wheel, _delta, vehicle_velocity_magnitude, max_speed)

func _engine_braking_wheel(wheel: HLSuspension, _delta: float, vehicle_velocity_magnitude: float, max_speed: float) -> void:

	if !wheel.has_contact:
		return

	var _brake_force = brake_force * vehicle.vehicle_state.velocity_direction

	vehicle.apply_force(
		-_brake_force + Vector3(0.0, -brake_force * vehicle_velocity_magnitude * 0.05, 0.0), 
		vehicle.vehicle_rotation * vehicle.to_local(wheel.global_position)
	)

func accelerate(_delta: float, is_reverse: bool, max_speed: float) -> void:

	# If no wheels are powered, we cannot move.
	if vehicle.powered_wheels == 0 or vehicle.powered_wheels_with_contact == 0:
		return

	_accelerate_axle(vehicle.front_axle, _delta, is_reverse, max_speed)
	_accelerate_axle(vehicle.rear_axle, _delta, is_reverse, max_speed)

func _accelerate_axle(axle: HLAxle, _delta: float, is_reverse: bool, max_speed: float) -> void:

	var angle_magnitude: float = (vehicle.get_axle_height(HLAxle.FRONT) - vehicle.get_axle_height(HLAxle.REAR)) 	

	if !axle.powered:
		return;
	
	# 1 = equal distribution
	# 0 = only power contact wheels

	if vehicle.powered_wheels == 0:
		return

	var gear_ratio: float = 1.0 / axle.gear_ratio
	
	var force_curve_value: float = power_curve.sample(velocity_measurement / float(max_speed) / gear_ratio)

	var acceleration_force: float = (
		((horse_power * 40.0)/ gear_ratio)
		* 
		force_curve_value
	)

	# Limit power while shifting?
	if vehicle.transmission.is_shifting:
		acceleration_force *= 0.75
	
	var force_vector: Vector3 = vehicle.vehicle_state.vehicle_direction * acceleration_force
	
	if is_reverse:
		force_vector *= -1.0

	# Make 0.15 configurable and min angle to roll
	# TODO: Do we need this still if the vehicle has the regular roll physics?
	if angle_magnitude > 0.15:
		force_vector -= (force_vector * abs((1.0 - angle_magnitude) * gear_ratio) * 0.05)

	_accelerate_wheel(axle, axle.left_wheel, force_vector, _delta, is_reverse, max_speed)
	_accelerate_wheel(axle, axle.right_wheel, force_vector, _delta, is_reverse, max_speed)

func _accelerate_wheel(axle: HLAxle, wheel: HLSuspension, force_vector: Vector3, _delta: float, is_reverse: bool, max_speed: float) -> void:

	var power_per_wheel: float = power_per_wheel(axle)
	wheel.power_distribution = power_per_wheel

	if !wheel.has_contact or !wheel.is_powered:
		return

	if abs(vehicle.transmission.speed) > max_speed:
		return

	if !wheel.tire_popped:
		vehicle.apply_force(
			force_vector * power_per_wheel, 
			vehicle.vehicle_rotation * vehicle.to_local(wheel.global_position))
	else:
		vehicle.apply_force(
			force_vector * power_per_wheel * 0.2, 
			vehicle.vehicle_rotation * vehicle.to_local(wheel.global_position))
	
func power_per_wheel(axle: HLAxle) -> float:

	return (
			(float(axle.contact_wheels) 
				/ float(vehicle.powered_wheels) 
				/ float(2))
			+
			(
				(float(2) - float(axle.contact_wheels)) * (float(axle.contact_wheels) 
				/ float(vehicle.powered_wheels) 
				/ float(2)) * (1.0 - axle.limited_slip)
			)
		)

func brake(vehicle_velocity_magnitude: float, _delta: float) -> void:

	# No check for wheel power as even non-powered wheels can have brakes.

	vehicle.vehicle_state.brake()
	omega_reference = 0

	_brake_axle(vehicle.front_axle, vehicle_velocity_magnitude, _delta)
	_brake_axle(vehicle.rear_axle, vehicle_velocity_magnitude, _delta)

func _brake_axle(axle: HLAxle, vehicle_velocity_magnitude: float, _delta: float) -> void:

	_brake_wheel(axle.left_wheel, vehicle_velocity_magnitude, _delta)
	_brake_wheel(axle.right_wheel, vehicle_velocity_magnitude, _delta)

func _brake_wheel(wheel: HLSuspension, vehicle_velocity_magnitude: float, _delta: float) -> void:

	var _brake_force: Vector3

	if !wheel.has_contact:
		return

	if vehicle_velocity_magnitude < 0.5:
		_brake_force = wheel.brake_force * vehicle_velocity_magnitude * vehicle.vehicle_state.velocity_direction
	else:
		_brake_force = wheel.brake_force * vehicle.vehicle_state.velocity_direction

	if wheel.tire_popped:
		_brake_force *= 0.2
	elif wheel.is_on_ice:
		_brake_force *= 0.05

	vehicle.apply_force(
		-_brake_force + Vector3(0.0, -wheel.brake_force * vehicle_velocity_magnitude * 0.05, 0.0), 
		vehicle.vehicle_rotation * vehicle.to_local(wheel.global_position)
	)

func control_omega(delta: float, velocity: float):

	var arg: float = velocity / max_speed
	var extent: float = omega_curve.sample(arg)
	var direction: float

	if vehicle.driver.did_steer_left:
		direction = 1

	if vehicle.driver.did_steer_right:
		direction = -1

	if vehicle.vehicle_state.velocity_rear_axis > velocity: # Obstacle detected ?
		extent = 1
	elif !vehicle.vehicle_state.vehicle_moving_forward:
		direction = -direction

	if vehicle.driver.did_steer:
		omega_reference = extent * lerp(omega_reference, omega_max * direction, 2 * delta)
	else:
		omega_reference = lerp(omega_reference, 0.0, 2.0 * delta)

func play_start_audio() -> void:

	if engine_start_sound != null and !engine_start_sound.playing:
		engine_start_sound.play()

func play_rev_audio(delta: float) -> void:
	
	if !engine_running or (mute_neutral and vehicle.transmission.current_gear == "N"):
		if engine_rev_sound != null and engine_rev_sound.playing:
			engine_rev_sound.stop()
		return

	if engine_start_sound != null and engine_start_sound.playing:
		return

	if vehicle.powered_wheels_with_contact > 1:

		var current_gear: Dictionary = vehicle.transmission.gear

		if current_gear != null and !current_gear.is_empty():
			engine_rev_pitch = clamp(lerp(
				engine_rev_pitch, 
				lin_interpolate(
					current_gear.revs_low_end,# / vehicle.transmission.gear_ratio, 
					current_gear.revs_low_pitch, 
					current_gear.revs_top_end,# / vehicle.transmission.gear_ratio, 
					current_gear.revs_top_pitch,
					abs(vehicle.transmission.speed)), 
				15 * delta
			), current_gear.revs_low_pitch, current_gear.revs_top_pitch)

		if engine_rev_sound != null:
			engine_rev_sound.pitch_scale = engine_rev_pitch

			if !engine_rev_sound.playing:
				engine_rev_sound.play()
	
	else:

		if engine_rev_sound != null:

			var pitch: float = engine_rev_sound.pitch_scale

			if vehicle.driver.did_accelerate:
				engine_rev_pitch = lerp(pitch, 1.0, 5.0 * delta)
			else:
				engine_rev_pitch = lerp(pitch, 0.2, 5.0 * delta)

			engine_rev_sound.pitch_scale = engine_rev_pitch

			if !engine_rev_sound.playing:
				engine_rev_sound.play()

func lin_interpolate(x1: float, y1: float, x2: float, y2: float, x: float) -> float:
	return (y1 + (((y2 - y1)/(x2 - x1)) * ((x) - x1)))
