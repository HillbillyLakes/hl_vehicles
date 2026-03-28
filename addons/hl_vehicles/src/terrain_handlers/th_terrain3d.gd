## Class for handling checking Terrain3D for specific texture IDs
## to determine if the wheel is on ice or snow.
class_name HLTHTerrain3D extends HLTerrainHandler

## Array of Terrain3D texture IDs to be considered ice.
@export var texture_ids_ice: Array[int]
## Array of Terrain3D texture IDs to be considered snow.
@export var texture_ids_snow: Array[int]

## Reference to the Terrain3D node.
## TODO: Should this be exported? Maybe user wants to swap terrains easily?
var terrain: Node

func _ready() -> void:

	var terrains: Array[Node]

	if Engine.is_editor_hint():
		terrains = get_tree().get_edited_scene_root().find_children("*", "Terrain3D")
	else:
		terrains = get_tree().get_current_scene().find_children("*", "Terrain3D")

	if !terrains.is_empty():
		terrain = terrains[0]

func update_surface_contacts(wheel: HLSuspension) -> void:

	wheel.is_on_ice = false
	wheel.is_on_snow = false

	if wheel.is_on_terrain:

		var terrain_texture_id: int

		if terrain != null:

			var _terrain_texture_id: Vector3 = terrain.data.get_texture_id(wheel.global_position)

			if _terrain_texture_id.z > 0.5:
				terrain_texture_id = int(_terrain_texture_id.y)
			else:
				terrain_texture_id = int(_terrain_texture_id.x)

			if texture_ids_ice.has(terrain_texture_id):
				wheel.is_on_ice = true

			if texture_ids_snow.has(terrain_texture_id):
				wheel.is_on_snow = true

	else:
		# TODO: Should checking other meshes be done here for on ice or in parent?
		# TODO: For example, a list of classes or maybe collision layers to check?
		# TODO: If doing this, do so in the base class and reference via super.
		pass

	return 
