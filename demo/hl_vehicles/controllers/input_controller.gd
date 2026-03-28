class_name InputController extends Node3D

static var INSTANCE: InputController = null

static func get_instance() -> InputController:
	return INSTANCE

@export var vehicle: HLVehicle
@export var terrain: Terrain3D
@export var camera_controller: Node3D
@export var camera_rotator: Node3D

func _ready() -> void:

	InputController.INSTANCE = self
	#vehicle.engine.engine_running = true

	#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(_delta: float) -> void:

	if Input.is_action_just_pressed("ui_cancel"):
		MenuController.get_instance().toggle_menu()
	
	if Input.is_action_just_pressed("toggle_info"):
		InfoController.get_instance().visible = !InfoController.get_instance().visible

	if vehicle != null:

		vehicle.driver.start_query()

		if Input.is_key_pressed(KEY_W):
			vehicle.driver.accelerate()
		elif Input.is_key_pressed(KEY_S):
			vehicle.driver.reverse()

		if Input.is_key_pressed(KEY_A):
			vehicle.driver.turn_left()
		elif Input.is_key_pressed(KEY_D):
			vehicle.driver.turn_right()

		if Input.is_key_pressed(KEY_SHIFT):
			vehicle.driver.brake()
			vehicle.brake_state_change.emit(true)
		else:
			vehicle.brake_state_change.emit(false)

		if Input.is_action_just_pressed("ui_accept"):
			var height: float = terrain.data.get_height(vehicle.global_position)
			vehicle.global_position.y = height + 0.5
			vehicle.global_rotation = camera_controller.global_rotation

func _input(event: InputEvent) -> void:

	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			camera_rotator.rotation.y -= event.relative.x * 0.01
