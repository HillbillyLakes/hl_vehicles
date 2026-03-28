class_name HLSuspension extends Node3D

@export_group("Shocks")
## The maximum distance the wheel is allowed to extend from the wheels rest position.
@export var spring_distance_max: float = 0.05
## The spring stiffness, the higher the number the more stiff.
@export var spring_constant: float = 42214
## How much the spring motion is restrained.
## A low number may cause the spring to not return to rest.
## A high number may cause the spring to continuously bounce.
## Attempt to find a value that applies critical damping.
@export var spring_damping: float = 7904

@export_group("Wheel")
## The mesh that will represent the wheel.
@export var wheel: Node3D
## The radius of the wheel. This is used to help calculate the distance the wheel
## extends below the vehicle.
@export var wheel_radius: float = 0.37:
	set(value):
		if value != wheel_radius:
			wheel_radius = value
			init_wheel_radius()
	get:
		return wheel_radius

@export_group("Tire")
## The mesh which will represents the tire. If the tire is poppable, this mesh
## will be hidden and the suspension adjusted by the amount of the tire thickness.
@export var tire: MeshInstance3D
## Tire thickness is the amount of wheel radius which makes of the tire.
## This is *not* in addition to the wheel radius.
@export var tire_thickness: float = 0.15
## Whether the tire should be poppable.
@export var tire_poppable: bool = false
## The sound to play when popped.
## TODO: This should be a resource and not an audio player.
@export var tire_pop_sound: AudioStreamPlayer3D
## The state of the tire popped. This is exported in case the user wants to
## sync it with multiplayer.
@export var tire_popped: bool = false:
	set(value):
		wheel_collision_body.disabled = value
		if value != tire_popped:
			tire_popped = value
	get:
		return tire_popped

@export_group("Collision")
## The size of the shapecast that is created at the bottom of the wheel.
@export var collision_shape_radius: float = 0.3
## The collision layer to look for when considering the wheels
## are in contact with something.
@export_flags_3d_physics var collision_mask: int = 0b1:
	set(value):
		if value != collision_mask:
			collision_mask = value
			if ray != null:
				ray.collision_mask = collision_mask
	get:
		return collision_mask

@export_group("Steering")
## Determines if the wheel contributes to turning.
@export var enable_turning: bool = false
## Reverses the direction of rotation (visual only).
@export var reverse_rotation: bool = false
## How much braking force this wheel has.
@export var brake_force: float = 5000.0

@export_subgroup("Tank Mode")
## TODO: Tank config is not implemented yet.
@export var tank_mode: bool = false
@export var left_tread: bool = false
@export var right_tread: bool = false

var vehicle: HLVehicle
var ray: ShapeCast3D
var tire_area: Area3D
var wheel_collision_body: CollisionShape3D

var spring_distance: float
var spring_rest_position: float
var circumference: float
var steering_rotation: Quaternion
var has_contact: bool = false
var is_powered: bool = false
var is_on_terrain: bool = false

var dot_up: float = 0.0
var spring_force: float = 0.0
var damping_force: float = 0.0
var power_distribution: float = 0.0

var is_on_ice: bool = false
var is_on_snow: bool = false

func _enter_tree() -> void:

	vehicle = HLVehicle.find_vehicle(10, self)
	init_raycast()

func _ready():

	steering_rotation = Quaternion(wheel.transform.basis)

	var weight: float = vehicle.mass * ProjectSettings.get_setting("physics/3d/default_gravity")

	## TODO: Make total number of wheels dynamic.
	init_suspension(
		weight / 4, 
		spring_distance_max, 
		spring_constant, 
		spring_damping
	)
	
	# This creates a collision bar so when the wheel turns it can hit stuff
	# and it reacts as the vehicle body in order to apply body force.
	#var wheel_collision_body: CollisionShape3D = CollisionShape3D.new()
	#add_child(wheel_collision_body)
	#wheel_collision_body.shape = BoxShape3D.new()
	#wheel_collision_body.shape.size = Vector3(wheel_radius * 0.4, wheel_radius * 0.2, wheel_radius * 2.0)
	#wheel_collision_body.position = wheel.position + axle.position
	#wheel.wheel_collision_body = wheel_collision_body

func init_raycast() -> void:
	ray = ShapeCast3D.new()
	add_child(ray)
	ray.shape = SphereShape3D.new()
	ray.shape.radius = collision_shape_radius
	ray.collision_mask = collision_mask

func init_suspension(rest_force: float, _spring_distance_max: float, 
		_spring_constant: float, _spring_damping: float):

	spring_distance_max = _spring_distance_max - collision_shape_radius
	spring_constant = _spring_constant
	spring_damping = _spring_damping
	spring_distance = 0
	spring_rest_position = rest_force / spring_constant
	init_wheel_radius()

	## This creates a collision bar so when the wheel turns it can hit stuff
	## and it reacts as the vehicle body in order to apply body force.
	#wheel_collision_body = CollisionShape3D.new()
	#vehicle.add_child(wheel_collision_body)
	#wheel_collision_body.shape = BoxShape3D.new()
	#wheel_collision_body.shape.size = Vector3(wheel_radius * 0.4, wheel_radius * 0.2, wheel_radius * 2.0)
	#wheel_collision_body.position = position
	##wheel.wheel_collision_body = wheel_collision_body

func init_wheel_radius() -> void:
	if ray != null:
		#ray.target_position = Vector3(0, -(wheel_radius + spring_distance_max), 0)
		ray.target_position = Vector3(0, -(wheel_radius + spring_distance_max), 0)
	circumference = 2 * PI * wheel_radius

func add_spring_force(delta: float, vehicle_body: RigidBody3D, vehicle_rotation: Quaternion) -> bool:

	is_on_terrain = false

	has_contact = ray.is_colliding()

	# If wheel is on ground, calculate spring force upwards on the vehicle body
	# Else, when wheel is not on the ground it should be fully extended.
	
	if has_contact:

		var contact_point = ray.get_collision_point(0)
		var collider = ray.get_collider(0)

		## TODO: Use the terrain handler to figure out if something is on whatever is
		## considered the terrain.
		if str(collider.get_class()) == "Terrain3D":
			is_on_terrain = true

		var contact_point_vehicle: Vector3 = vehicle.to_local(contact_point)
		var spring_distance_now: float = contact_point_vehicle.y + wheel_radius
		var spring_velocity: float = 0.0

		if tire_popped:
			spring_distance_now -= tire_thickness
		
		#if spring_distance_now > spring_distance_max:
			#spring_distance_now = spring_distance_max

		if spring_distance != 0:
			spring_velocity = (spring_distance_now - spring_distance - collision_shape_radius) / delta

		spring_distance = spring_distance_now
		
		# Hooke's Law
		spring_force = spring_constant * (spring_distance + spring_rest_position) 
		damping_force = spring_damping * spring_velocity
		
		# Find dot product so we only apply upward force when spring is facing mostly upwards.
		#var force_direction: Vector3 = global_position.direction_to(contact_point)
		#var force_direction: Vector3 = wheel.global_position.direction_to(global_position)
		#dot_up = clampf((-force_direction.dot(Vector3.UP) - 0.5) * 2.0, 0.0, 1.0)
		#dot_up = global_rotation.angle_to(Vector3.UP)
		dot_up = clamp((wheel.global_position.y - contact_point.y + collision_shape_radius) / wheel_radius, 0.0, 1.0)

		vehicle_body.apply_force(
			Vector3(0, spring_force + damping_force, 0) * dot_up, 
			vehicle_rotation * contact_point_vehicle
		)

		wheel.transform.origin = Vector3(0, spring_distance - wheel_radius, 0)
		

	else:
		dot_up = 0.0
		spring_distance = 0
		wheel.transform.origin.x = 0.0
		wheel.transform.origin.y = lerp(wheel.transform.origin.y, -spring_distance_max, 10.0 * delta)
		wheel.transform.origin.z = 0.0

	return has_contact

func rotate_wheel(delta: float, distance_moved: float, steering_angle: float):

	var rotation_angle = 2 * PI * distance_moved / circumference

	if tire_popped:
		rotation_angle *= 20.0

	if reverse_rotation:
		rotation_angle *= -1

	if !enable_turning:
		steering_angle = 0.0

	steering_rotation = steering_rotation.slerp(Quaternion(Vector3.UP, steering_angle), 6 * delta)
	var rotation = steering_rotation
	
	if has_contact:
		rotation *= Quaternion(Vector3.LEFT, rotation_angle)
	elif is_powered && (vehicle.driver.did_accelerate || vehicle.driver.did_reverse):
		var ratio: float = 0.05
		var direction: int = 1
		if vehicle.driver.did_reverse:
			direction = -1
		if reverse_rotation:
			rotation *= Quaternion(Vector3.LEFT, direction * -Time.get_ticks_msec() / circumference * ratio)
		else:
			rotation *= Quaternion(Vector3.LEFT, direction * Time.get_ticks_msec() / circumference * ratio)

	wheel.transform.basis = Basis(rotation)
	
	if wheel_collision_body != null:
		wheel_collision_body.position.y = wheel.position.y + wheel_radius
		wheel_collision_body.rotation.y = wheel.rotation.y

func pop_tire() -> void:

	# Can't pop a popped tire
	if !tire_poppable or tire_popped:
		return

	tire_popped = true
	wheel_radius -= tire_thickness
	vehicle.freeze = false

	if tire != null:
		tire.visible = false

	if tire_pop_sound != null:
		tire_pop_sound.play()

func unpop_tire() -> void:

	# Can't unpop an unpopped tire
	if !tire_popped:
		return

	tire_popped = false
	wheel_radius += tire_thickness

	if tire != null:
		tire.visible = true
