class_name HovercraftBody extends MeshInstance3D

@export var vehicle: HLVehicle

var rest_y: float

func _ready() -> void:
	rest_y = position.y

func _process(_delta: float) -> void:
	position.y = rest_y + (sin(Time.get_ticks_msec() * 0.0025) * 0.0005 * ((vehicle.transmission.speed / 4.0) + 15.0))
