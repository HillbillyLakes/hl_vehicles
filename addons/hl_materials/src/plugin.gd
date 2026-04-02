# Copyright (c) 2025 Hillbilly Lakes LLC, C. Spurlock, and Contributors

@tool
extends EditorPlugin

const __wind_controller_script: String = "res://addons/hl_materials/src/wind_controller.gd"

const __wind_controller_icon: String = "res://addons/hl_materials/assets/imgs/wind.png"

func _enter_tree() -> void:
	add_custom_type("HLWindController", "Node3D", load(__wind_controller_script), load(__wind_controller_icon))

func _exit_tree() -> void:
	remove_custom_type("HLWindController")
