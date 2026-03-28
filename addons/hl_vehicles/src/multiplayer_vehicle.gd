class_name HLMultiplayerVehicle extends HLVehicle

@export_group("Vehicle ID (Sync)")
# This is set when added to a scene and will be unique.
@export var vehicle_uuid: String
@export_group("Vehicle State (Sync)")
@export var is_accelerating: bool
@export var is_reversing: bool
@export var is_braking: bool

func _ready() -> void:

	super()

	if !is_multiplayer_authority():
		return

	vehicle_uuid = UUID.generate()
	add_to_group("HLMultiplayerVehicles")

#func _process(_delta: float) -> void:
	##super(_delta)
	#pass
#
#func _physics_process(_delta: float) -> void:
	##super(_delta)
	#pass
