extends Node

var CELL_SIZE = 50 # or whatever

func position_snapped(pos: Vector2):
	return (pos / CELL_SIZE).floor() * CELL_SIZE

func get_children_in_radius(radius: float, center: Object) -> Array:
	var selected_children = []
	var position = center.position 

	for child in get_children():
		if child is RigidBody2D:  # Ensure the child is a Node2D (or any type you want)
			var distance = position.distance_to(child.global_position)
			if distance <= radius:
				selected_children.append(child)

	return selected_children

func get_stack_height(pieces: Array[Node]):
	var highest_y = 372
	for piece in pieces:
		if piece.position.y < highest_y and piece.position.y > -361:
			highest_y = piece.position.y
	return highest_y

var do_music = true

var audio_files = [
	"8bit.mp3", "abberall.mp3", "brass.mp3", "chiptune.mp3", 
	"creepy.mp3", "dubstep.mp3", "entraceremix.mp3", "entryremix2.mp3",
	"killer.mp3", "letsplay.mp3", "lofi.mp3", "musicbox.mp3",
	"proteus.mp3", "ragtime.mp3", "remix.mp3", "strings.mp3",
	"tech.mp3", "techno.mp3", "thebest.mp3", "trap.mp3",
	"trap2.mp3", "windowsxp.mp3"
]

var CHAOS_EVENTS_WEIGHTED = {
	"nocollision": 10,
	"upwardforce": 10,
	"bouncy": 10,
	"rickroll": 1,    # lowest chance
	"table": 3,       # second lowest chance
	"rotatechaos": 10,
	"randomgravity": 10,
	"fastgravity": 10,
	"downwardsforce": 10,
	"randomforce": 10,
	"friction": 10,
	"randomcenterofmass": 10,
	"floaty": 10,
	"amongus": 10,
	"huge": 10,
	"tiny": 10,
	"magnetic": 10,
	"unique": 10,
}
