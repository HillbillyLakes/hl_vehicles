class_name CameraController extends Node3D

static var INSTANCE: CameraController = null

static func get_instance() -> CameraController:
	return INSTANCE

func _ready() -> void:
	CameraController.INSTANCE = self
	
@export var tracked_object: Node3D
@export var camera: Camera3D

func _process(delta: float) -> void:

	if tracked_object != null:
		global_position = lerp(global_position, tracked_object.global_position, 20.0 * delta)
		camera.look_at(tracked_object.global_position + Vector3(0.0, 2.0, 0.0))
