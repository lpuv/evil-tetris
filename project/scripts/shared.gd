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


var CHAOS_EVENTS = [
	"nocollision",
	"upwardforce",
	"bouncy",
	#"rickroll",
	#"table",
	"rotatechaos",
	"randomgravity",
	"fastgravity",
	"downwardsforce",
	"randomforce",
	"friction",
	"randomcenterofmass",
	"floaty"
]
