# This is a reactive transmission, meaning it only makes
# it look like the vehicle shifts. This does not tell
# the wheels how much power they're getting.

class_name HLTransmission extends Node3D

const AWD: int = 0
const FWD: int = 1
const RWD: int = 2
const FWDAWD: int = 3
const RWDAWD: int = 4


# TODO: Shift points, power transfer, ...?
@export_group("Gears")
# Don't export this? This is now just set to whatever the rear gear ratio
# is so the engine sound can be made normally.
@export_range(0.01, 5.00, 0.001) var gear_ratio: float = 1.0
## Gears are reactionary. Gears (as of current at least) are used to
## determine where the shifter is and engine pitch. These are not manually
## changed by the player, think of it as programming for an automatic transmission.
## TODO: Consider adding support to manually switch gears.
@export var gears: Dictionary = {
	-1: {
		"gear_name": "R",
		"min_speed": -1000.0,
		"max_speed": -0.1,
		"shift_time": 1.0,
		"shift_lerp": 10.0,
		"shifter_rot_x": -7.0,
		"shifter_rot_y": -7.0,
		"revs_low_end": 0.0,
		"revs_top_end": 5.0,
		"revs_low_pitch": 1.0,
		"revs_top_pitch": 1.5
	},
	0: {
		"gear_name": "N",
		"min_speed": -0.1,
		"max_speed": 0.1,
		"shift_time": 1.0,
		"shift_lerp": 10.0,
		"shifter_rot_x": 0.0,
		"shifter_rot_y": 0.0,
		"revs_low_end": 0.0,
		"revs_top_end": 1.0,
		"revs_low_pitch": 1.0,
		"revs_top_pitch": 1.0
	},
	1: {
		"gear_name": "1",
		"min_speed": 0.1,
		"max_speed": 10.0,
		"shift_time": 1.0,
		"shift_lerp": 10.0,
		"shifter_rot_x": 7.0,
		"shifter_rot_y": -7.0,
		"revs_low_end": 0.0,
		"revs_top_end": 5.0,
		"revs_low_pitch": 1.0,
		"revs_top_pitch": 1.5
	},
	2: {
		"gear_name": "2",
		"min_speed": 10.0,
		"max_speed": 30.0,
		"shift_time": 1.0,
		"shift_lerp": 10.0,
		"shifter_rot_x": -7.0,
		"shifter_rot_y": 7.0,
		"revs_low_end": 7.0,
		"revs_top_end": 27.0,
		"revs_low_pitch": 1.0,
		"revs_top_pitch": 1.5
	},
	3: {
		"gear_name": "3",
		"min_speed": 30.0,
		"max_speed": 1000.0,
		"shift_time": 1.0,
		"shift_lerp": 10.0,
		"shifter_rot_x": 7.0,
		"shifter_rot_y": 7.0,
		"revs_low_end": 25.0,
		"revs_top_end": 40.0,
		"revs_low_pitch": 1.0,
		"revs_top_pitch": 1.5
	}
}

@export_group("Sounds")
@export var gear_grind_sound: AudioStream
@export var gear_grind_sound_max_db: float
@export var gear_grind_sound_max_distance: float
@export var gear_grind_sound_bus: String
@export var gear_grind_sound_min_time: float
@export var gear_grind_sound_max_time: float

## Transmission state is exported so it can be multiplayer synchronized.
@export_group("Transmission State")
@export var speed: float = 0.0
@export var shift_time: float = 0.0
@export var current_gear: String = "N"
@export var is_shifting: bool = false
@export var is_low: bool = false
@export_enum("AWD:0", "FWD:1", "RWD:2") var mode: int

# References to modes that might react based on the transmission.

var vehicle: HLVehicle

var gear_shifter: Node3D

# Internal components

var gear_grind_sound_player: AudioStreamPlayer3D

# Internal variables.
var is_speed_negative: bool = false
var prev_speed: float = 0.0
var prev_gear: String = "N"
var gear: Dictionary
var rng = RandomNumberGenerator.new()

func _enter_tree() -> void:

	vehicle = HLVehicle.find_vehicle(10, self)

func _ready() -> void:

	# Create player for gear grind sound.
	gear_grind_sound_player = AudioStreamPlayer3D.new()
	gear_grind_sound_player.stream = gear_grind_sound
	gear_grind_sound_player.max_db = gear_grind_sound_max_db
	gear_grind_sound_player.max_distance = gear_grind_sound_max_distance
	gear_grind_sound_player.bus = gear_grind_sound_bus
	add_child(gear_grind_sound_player)

func _physics_process(_delta: float) -> void:

	if !is_multiplayer_authority():
		return

	speed = -vehicle.transform.basis.z.dot(vehicle.linear_velocity)
	speed = snappedf((speed / 1000) * 60 * 60 * 0.621371, 0.1)

func update(delta: float):

	#print(str(vehicle.linear_velocity.rotated(vehicle.global_rotation, vehicle.linear_velocity.angle_to(vehicle.global_rotation)).dot(vehicle.global_rotation)))

	#if (vehicle.driver.did_accelerate or vehicle.driver.did_reverse):

	# Find our current gear based on speed. I know, backwards, but for a 
	# non-racing game faking it is probably okay.
	#print("GEARING")
	for key in gears:
		gear = gears[key]
		if speed > (gear.min_speed) and speed < (gear.max_speed):
		#if speed > (gear.min_speed / gear_ratio) and speed < (gear.max_speed / gear_ratio):
			if current_gear != gear.gear_name:
				instant_shift_sound()
				is_shifting = true
				prev_gear = current_gear
				current_gear = gear.gear_name
				shift_time = gear.shift_time

			# Found our gear, exit loop.
			break

	# We should always have a gear, but just in case let's check.
	#if gear != null:
#
		#if is_shifting and vehicle.parking_brake_change_time < Time.get_ticks_msec():
#
			#shift_time -= delta
#
			## Allow for 0.3 seconds on either side of the shift to allow
			## the player's hand to move to the shifter before moving.
			#if shift_time > 0.3 and shift_time < (gear.shift_time - 0.3):
#
				#if gear_shifter != null and vehicle.has_driver:
#
					#gear_shifter.rotation.y = lerp(
						#gear_shifter.rotation.y, 
						#deg_to_rad(gear.shifter_rot_x), 
						#gear.shift_lerp * delta
					#)
#
					#gear_shifter.rotation.x = lerp(
						#gear_shifter.rotation.x, 
						#deg_to_rad(gear.shifter_rot_y), 
						#gear.shift_lerp * delta
					#)
#
			## Done shifting.
			#if shift_time <= 0.0:
				#is_shifting = false

	prev_speed = speed

func play_shift_sound() -> void:

	if is_shifting:

		gear_grind_sound_player.pitch_scale = (
			0.5 + (vehicle.engine.engine_rev_pitch / 10.0)
		)

		if !gear_grind_sound_player.playing:
			gear_grind_sound_player.play()
			gear_grind_sound_player.seek(
				rng.randf_range(
					gear_grind_sound_min_time, 
					gear_grind_sound_max_time)
			)

	else:

		if gear_grind_sound_player.playing:
			gear_grind_sound_player.stop()

func instant_shift_sound() -> void:

	gear_grind_sound_player.pitch_scale = (
		0.9 + (vehicle.engine.engine_rev_pitch / 10.0)
	)

	if gear_grind_sound_player.playing:
		gear_grind_sound_player.stop()

	gear_grind_sound_player.play()

	gear_grind_sound_player.seek(
		rng.randf_range(
			gear_grind_sound_min_time, 
			gear_grind_sound_max_time)
	)
