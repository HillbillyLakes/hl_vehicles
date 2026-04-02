@tool
class_name Cactus extends Node3D

@export_enum("TALL:0", "MEDIUM:1", "SHORT:2") var size: int:
	set(value):
		if value != size:
			size = value
			if Engine.is_editor_hint():
				refresh_size()
	get():
		return size

@export_range(0.0, 1.0, 0.001) var arm_amount: float = 1.0:
	set(value):
		if value != arm_amount:
			arm_amount = value
			if Engine.is_editor_hint():
				refresh_arm_amount()
	get():
		return arm_amount

@export_range(0.01, 2.0, 0.001) var scale_min: float = 1.0:
	set(value):
		if value != scale_min:
			scale_min = value
			if Engine.is_editor_hint():
				refresh_scale()
	get():
		return scale_min

@export_range(0.01, 2.0, 0.001) var scale_max: float = 1.0:
	set(value):
		if value != scale_max:
			scale_max = value
			if Engine.is_editor_hint():
				refresh_scale()
	get():
		return scale_max

@onready var cactus_tall: MeshInstance3D = $CactusTall
@onready var cactus_arm_1: MeshInstance3D = $CactusTall/CactusArm1
@onready var cactus_arm_2: MeshInstance3D = $CactusTall/CactusArm2
@onready var cactus_arm_3: MeshInstance3D = $CactusTall/CactusArm3
@onready var cactus_arm_4: MeshInstance3D = $CactusTall/CactusArm4
@onready var cactus_arm_5: MeshInstance3D = $CactusTall/CactusArm5
@onready var cactus_arm_6: MeshInstance3D = $CactusTall/CactusArm6
@onready var cactus_medium: MeshInstance3D = $CactusMedium
@onready var cactus_short: MeshInstance3D = $CactusShort

@onready var cactus_tall_collider_shape: CollisionShape3D = $CactusTall/CactusTallCollider/CactusTallColliderShape
@onready var cactus_medium_collider_shape: CollisionShape3D = $CactusMedium/CactusMediumCollider/CactusMediumColliderShape
@onready var cactus_short_collider_shape: CollisionShape3D = $CactusShort/CactusShortCollider/CactusShortColliderShape

var rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _enter_tree() -> void:
	pass

func _ready() -> void:

	refresh_size()
	refresh_arm_amount()
	refresh_scale()
	refresh_rotation()

func refresh_size() -> void:

	cactus_tall.visible = false
	cactus_medium.visible = false
	cactus_short.visible = false

	cactus_tall_collider_shape.disabled = true
	cactus_medium_collider_shape.disabled = true
	cactus_short_collider_shape.disabled = true

	match size:

		0:
			cactus_tall.visible = true
			cactus_tall_collider_shape.disabled = false

		1:
			cactus_medium.visible = true
			cactus_medium_collider_shape.disabled = false

		2:
			cactus_short.visible = true
			cactus_short_collider_shape.disabled = false

func refresh_arm_amount() -> void:

	show_arm_change(cactus_arm_1)
	show_arm_change(cactus_arm_2)
	show_arm_change(cactus_arm_3)
	show_arm_change(cactus_arm_4)
	show_arm_change(cactus_arm_5)
	show_arm_change(cactus_arm_6)

func show_arm_change(arm: MeshInstance3D) -> void:

	arm.visible = false

	var rand: float = rng.randf_range(0.0, 1.0)
	if rand >= (1.0 - arm_amount):
		arm.visible = true

func refresh_scale() -> void:

	var fscale: float = rng.randf_range(scale_min, scale_max)
	scale = Vector3(fscale, fscale, fscale)

func refresh_rotation() -> void:

	var frot: float = rng.randf_range(0.0, 360.0)
	rotation.y = deg_to_rad(frot)
