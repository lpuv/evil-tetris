extends Node

var CELL_SIZE = 50 # or whatever

func position_snapped(pos: Vector2):
	return (pos / CELL_SIZE).floor() * CELL_SIZE


var CHAOS_EVENTS = {
	0: "nocollision",
	1: "upwardforce",
	2: "bouncy",
	3: "rickroll",
	4: "table",
	5: ""
}
