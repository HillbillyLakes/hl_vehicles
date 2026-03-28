class_name InfoController extends Control

static var INSTANCE: InfoController = null

static func get_instance() -> InfoController:
	return INSTANCE

func _ready() -> void:
	InfoController.INSTANCE = self
	
@export var vehicle: HLVehicle
@export var label: Label

func _process(_delta: float) -> void:
	
	var info: String = ""

	if vehicle != null:
		info += "Current Gear: " + str(vehicle.transmission.current_gear) + "\n"
		info += "Speed: " + str(snapped(vehicle.transmission.speed, 0.1)) + " MPH\n"
		info += ("Fuel: " + str(snapped(vehicle.fuel_tank.remaining, 0.01)) 
				+ " / " + str(snapped(vehicle.fuel_tank.capacity, 0.01)) + " Gal") + "\n"
		#info += "Powered Contact: " + str(vehicle.powered_wheels_with_contact) + "\n"

	label.text = info
