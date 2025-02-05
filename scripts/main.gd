extends Node

const NUM_PIECES = 3

var pieces

var current_piece = "tmp"

func spawn_piece():
	var type_to_spawn = randi_range(0, NUM_PIECES - 1)
	#print("spawning piece " + str(pieces[type_to_spawn]))
	var piece = pieces[type_to_spawn].instantiate()
	add_child(piece)
	var body = piece.get_node("RigidBody2D")
	body.is_controllable = true
	body.transform.origin.y = -393
	body.visible = false
	body.gravity_scale = 1
	body.contact_monitor = true
	body.max_contacts_reported = 5
	current_piece = piece

func _ready():
	var I = preload("res://blocks/I.tscn")
	var J = preload("res://blocks/J.tscn")
	var L = preload("res://blocks/L.tscn")
	var O = preload("res://blocks/O.tscn")
	var S = preload("res://blocks/S.tscn")
	
	pieces = [I, J, L, O, S]
	pieces.shuffle()
	spawn_piece()
	

func _process(delta: float) -> void:
	if current_piece is String or not current_piece.get_node("RigidBody2D").is_controllable:
		print("time to spawn")
		spawn_piece()
	
