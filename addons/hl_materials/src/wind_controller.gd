@tool
class_name WindController extends Node3D

static var INSTANCE: WindController = null

static func get_instance() -> WindController:
	return INSTANCE

@export var wind_direction: Vector3 = Vector3(1.0, 0.0, 0.0):
	set(value):
		if wind_direction != value:
			wind_direction = value
			_update_direction(value)
	get():
		return wind_direction

@export var wind_intensity: float = 1.0:
	set(value):
		if wind_intensity != value:
			wind_intensity = value
			_update_intensity(value)
	get():
		return wind_intensity

@export var wind_speed: float = 1.0:
	set(value):
		if wind_speed != value:
			wind_speed = value
			_update_speed(value)
	get():
		return wind_speed

func _ready() -> void:
	
	WindController.INSTANCE = self
	
	RenderingServer.global_shader_parameter_add("wind_direction", RenderingServer.GLOBAL_VAR_TYPE_VEC3, Vector3(1.0, 0.0, 0.0))
	RenderingServer.global_shader_parameter_add("wind_intensity", RenderingServer.GLOBAL_VAR_TYPE_FLOAT, 1.0)
	RenderingServer.global_shader_parameter_add("wind_speed", RenderingServer.GLOBAL_VAR_TYPE_FLOAT, 1.0)

func _update_direction(direction: Vector3) -> void:
	RenderingServer.global_shader_parameter_set("wind_direction", direction)

func _update_intensity(intensity: float) -> void:
	RenderingServer.global_shader_parameter_set("wind_intensity", intensity)
	
func _update_speed(speed: float) -> void:
	RenderingServer.global_shader_parameter_set("wind_speed", speed)
