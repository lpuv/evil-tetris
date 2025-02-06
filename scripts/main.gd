extends Node

const NUM_PIECES = 3

var pieces

var rng

var current_piece = null

func spawn_piece():
	var type_to_spawn = rng.randi_range(0, NUM_PIECES - 1)
	print("spawning piece #" + str(type_to_spawn))
	print("spawning piece " + str(pieces[type_to_spawn]))
	var piece = pieces[type_to_spawn].instantiate()
	add_child(piece)
	var body = piece.get_node("RigidBody2D")
	body.is_controllable = true
	body.transform.origin.y = -393
	body.visible = false
	body.gravity_scale = 1
	body.contact_monitor = true
	body.max_contacts_reported = 5
	piece.set_meta("to_delete", false)
	current_piece = piece

func _ready():
	
	rng = RandomNumberGenerator.new()
	randomize()
	rng.seed = Time.get_ticks_msec()
	
	var I = preload("res://blocks/I.tscn")
	var J = preload("res://blocks/J.tscn")
	var L = preload("res://blocks/L.tscn")
	var O = preload("res://blocks/O.tscn")
	var S = preload("res://blocks/S.tscn")
	var T = preload("res://blocks/T.tscn")
	var Z = preload("res://blocks/Z.tscn")
	
	pieces = [I, J, L, O, S, T, Z]
	pieces.shuffle()
	spawn_piece()

func _process(_delta: float) -> void:
	#print(str(current_piece.name))
	if current_piece.get_meta("to_delete"):
		current_piece.queue_free()
	elif current_piece.get_node("RigidBody2D").is_controllable:
		return
	print("time to spawn")
	spawn_piece()
	
