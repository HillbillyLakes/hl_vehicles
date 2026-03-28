class_name UUID extends Node

static var characters: String = "abcdef0123456789"

func _ready():
	pass

func _process(delta):
	pass

# Example usage:
# var uuid: String = UUID.generate()
static func generate() -> String:
	var word: String
	var n_char = len(characters)
	for i in range(8):
		word += characters[randi()% n_char]
	word += "-"
	for i in range(4):
		word += characters[randi()% n_char]
	word += "-"
	for i in range(4):
		word += characters[randi()% n_char]
	word += "-"
	for i in range(4):
		word += characters[randi()% n_char]
	word += "-"
	for i in range(12):
		word += characters[randi()% n_char]
	return word
