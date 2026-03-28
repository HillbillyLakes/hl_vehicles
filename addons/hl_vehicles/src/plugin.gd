# Copyright (c) 2025 Hillbilly Lakes LLC, C. Spurlock, and Contributors

@tool
extends EditorPlugin

const __transmission_script: String = "res://addons/hl_vehicles/src/transmission.gd"
const __vehicle_script: String = "res://addons/hl_vehicles/src/vehicle.gd"
const __suspension_script: String = "res://addons/hl_vehicles/src/suspension.gd"
const __controller_script: String = "res://addons/hl_vehicles/src/controller.gd"
const __steering_script: String = "res://addons/hl_vehicles/src/steering_controller.gd"
const __torque_script: String = "res://addons/hl_vehicles/src/torque_controller.gd"
const __engine_script: String = "res://addons/hl_vehicles/src/engine.gd"
const __vehicle_state_script: String = "res://addons/hl_vehicles/src/vehicle_state.gd"
const __wheel_state_script: String = "res://addons/hl_vehicles/src/wheel_state.gd"
const __driver_state_script: String = "res://addons/hl_vehicles/src/driver_state.gd"
const __light_state_script: String = "res://addons/hl_vehicles/src/light.gd"
const __multiplayer_vehicle_script: String = "res://addons/hl_vehicles/src/multiplayer_vehicle.gd"
const __axle_script: String = "res://addons/hl_vehicles/src/axle.gd"
const __tank_script: String = "res://addons/hl_vehicles/src/tank.gd"
const __electrical_system_script: String = "res://addons/hl_vehicles/src/electrical_system.gd"
const __th_script: String = "res://addons/hl_vehicles/src/terrain_handlers/terrain_handler.gd"
const __th_terrain3D_script: String = "res://addons/hl_vehicles/src/terrain_handlers/th_terrain3d.gd"

const __transmission_icon: String = "res://addons/hl_vehicles/assets/imgs/transmission.png"
const __vehicle_icon: String = "res://addons/hl_vehicles/assets/imgs/vehicle.png"
const __suspension_icon: String = "res://addons/hl_vehicles/assets/imgs/suspension.png"
const __circuit_icon: String = "res://addons/hl_vehicles/assets/imgs/circuit.png"
const __engine_icon: String = "res://addons/hl_vehicles/assets/imgs/engine.png"
const __state_machine_icon: String = "res://addons/hl_vehicles/assets/imgs/state_machine.png"
const __light_icon: String = "res://addons/hl_vehicles/assets/imgs/light.png"
const __axle_icon: String = "res://addons/hl_vehicles/assets/imgs/axle.png"
const __tank_icon: String = "res://addons/hl_vehicles/assets/imgs/tank.png"
const __terrain_icon: String = "res://addons/hl_vehicles/assets/imgs/terrain.png"

func _enter_tree() -> void:
	add_custom_type("HLTransmission", "Node3D", load(__transmission_script), load(__transmission_icon))
	add_custom_type("HLVehicle", "Node3D", load(__vehicle_script), load(__vehicle_icon))
	add_custom_type("HLSuspension", "Node3D", load(__suspension_script), load(__suspension_icon))
	add_custom_type("HLController", "Node3D", load(__controller_script), load(__circuit_icon))
	add_custom_type("HLSteeringController", "Node3D", load(__steering_script), load(__circuit_icon))
	add_custom_type("HLTorqueController", "Node3D", load(__torque_script), load(__circuit_icon))
	add_custom_type("HLEngine", "Node3D", load(__engine_script), load(__engine_icon))
	add_custom_type("HLWheelState", "Node3D", load(__wheel_state_script), load(__state_machine_icon))
	add_custom_type("HLVehicleState", "Node3D", load(__vehicle_state_script), load(__state_machine_icon))
	add_custom_type("HLDriverState", "Node3D", load(__driver_state_script), load(__state_machine_icon))
	add_custom_type("HLLight", "Node3D", load(__light_state_script), load(__light_icon))
	add_custom_type("HLMultiplayerVehicle", "Node3D", load(__multiplayer_vehicle_script), load(__vehicle_icon))
	add_custom_type("HLAxle", "Node3D", load(__axle_script), load(__axle_icon))
	add_custom_type("HLTank", "Node3D", load(__tank_script), load(__tank_icon))
	add_custom_type("HLElectricalSystem", "Node3D", load(__electrical_system_script), load(__circuit_icon))
	add_custom_type("HLTerrainHandler", "Node3D", load(__th_script), load(__terrain_icon))
	add_custom_type("HLTHTerrain3D", "Node3D", load(__th_terrain3D_script), load(__terrain_icon))

func _exit_tree() -> void:
	remove_custom_type("HLTransmission")
	remove_custom_type("HLVehicle")
	remove_custom_type("HLSuspension")
	remove_custom_type("HLController")
	remove_custom_type("HLSteeringController")
	remove_custom_type("HLTorqueController")
	remove_custom_type("HLEngine")
	remove_custom_type("HLWheelState")
	remove_custom_type("HLVehicleState")
	remove_custom_type("HLDriverState")
	remove_custom_type("HLLight")
	remove_custom_type("HLMultiplayerVehicle")
	remove_custom_type("HLAxle")
	remove_custom_type("HLTank")
	remove_custom_type("HLElectricalSystem")
	remove_custom_type("HLTerrainHandler")
	remove_custom_type("HLTHTerrain3D")
