class_name MenuController extends Control

static var INSTANCE: MenuController = null

const VAN = preload("uid://cobdo74mtk4tn")
const HOVERCRAFT = preload("uid://crwjgj14d63sd")
const WAGON = preload("uid://bncr8dmfwc87f")

@export var vehicle_node: Node3D

static func get_instance() -> MenuController:
	return INSTANCE

func _ready() -> void:
	MenuController.INSTANCE = self

func toggle_menu() -> void:

	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		visible = true
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		visible = false

func _on_spawn_van_button_pressed() -> void:

	for child in vehicle_node.get_children():
		child.queue_free()

	var v: HLVehicle = VAN.instantiate()
	vehicle_node.add_child(v)
	
	v.global_position = vehicle_node.global_position
	v.global_rotation = vehicle_node.global_rotation
	
	InfoController.get_instance().vehicle = v
	InputController.get_instance().vehicle = v
	CameraController.get_instance().tracked_object = v
	
	v.engine.engine_running = true
	
	toggle_menu()

func _on_spawn_hover_button_pressed() -> void:

	for child in vehicle_node.get_children():
		child.queue_free()

	var v: HLVehicle = HOVERCRAFT.instantiate()
	vehicle_node.add_child(v)
	
	v.global_position = vehicle_node.global_position
	v.global_rotation = vehicle_node.global_rotation
	
	InfoController.get_instance().vehicle = v
	InputController.get_instance().vehicle = v
	CameraController.get_instance().tracked_object = v
	
	v.engine.engine_running = true
	
	toggle_menu()


func _on_spawn_wagon_button_pressed() -> void:

	for child in vehicle_node.get_children():
		child.queue_free()

	var v: HLVehicle = WAGON.instantiate()
	vehicle_node.add_child(v)
	
	v.global_position = vehicle_node.global_position
	v.global_rotation = vehicle_node.global_rotation
	
	InfoController.get_instance().vehicle = v
	InputController.get_instance().vehicle = v
	CameraController.get_instance().tracked_object = v
	
	v.engine.engine_running = true
	
	toggle_menu()
