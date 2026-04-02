class_name HLAxle extends Node3D

const FRONT: int = 0
const REAR: int = 1

@export_group("Power Train")
## Determines which mode will supply power to wheels on this axle.
@export_enum("AWD:0", "FWD:1", "RWD:2", "FWD & AWD:3", "RWD & AWD:4") var mode_enabled: int
## Determines how to apply power when one or more wheels have no contact.
## 1.0 = Half power (limited slip), 0.0 = Full power (solid axle)
@export_range(0.0, 1.0, 0.001) var limited_slip: float = 1.0
## Used in power and fuel consumption calculations.
@export_range(0.0, 5.0, 0.001) var gear_ratio: float = 1.0

@export_group("Wheels")
## These are automatically populated when the vehicle is added to the tree. 
## Any suspension that are children of the axle will be added.
@export var left_wheel: HLSuspension
@export var right_wheel: HLSuspension

@export_group("Mesh")
## Mesh for the axle. Currently, the origin for the mesh should be at one end of
## the axle and be placed near the left wheel. This mesh will be pointed at the
## other wheel to keep it lined up betwen the wheels. This might change later.
@export var mesh_node: Node3D

# Just a reference to the vehicle.
var vehicle: HLVehicle

# This will be changed based on the mode at runtime.
var powered: bool = false
# This will be updated based on shapecast checks at runtime.
var contact_wheels: int = 0

func _enter_tree() -> void:

	vehicle = HLVehicle.find_vehicle(10, self)

func _process(delta: float) -> void:
	
	if mesh_node != null:
		mesh_node.global_position = left_wheel.wheel.global_position
		mesh_node.look_at(right_wheel.wheel.global_position)
