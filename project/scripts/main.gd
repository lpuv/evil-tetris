extends Node

const NUM_PIECES = 3

var pieces

var rng

var current_piece = null


func prepare_restart():
	current_piece.queue_free()

func spawn_piece():
	
	var piece = pieces[randi() % pieces.size()].instantiate()
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
	
	$AnimationPlayer.play("RESET")
	
	rng = RandomNumberGenerator.new()
	rng.randomize()
	
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
	
	$AnimationPlayer.play("controls_fade")
	$TwentySecTimer.start()
	$OneSecTimer.start()

func _process(_delta: float) -> void:
	#print(str(current_piece.name))
	if current_piece.get_meta("to_delete"):
		current_piece.queue_free()
	elif current_piece.get_node("RigidBody2D").is_controllable:
		return
	print("time to spawn")
	spawn_piece()
	

func chaos():
	pass


func _on_twenty_sec_timer_timeout() -> void:
	chaos()
	$event_label.text = "Next Event: 20s"
	$event_label.set_meta("time_left", 20)
	$TwentySecTimer.start()

func _on_one_sec_timer_timeout() -> void:
	$event_label.text = "Next Event: " + str($event_label.get_meta("time_left")) + "s"
	$event_label.set_meta("time_left", $event_label.get_meta("time_left") - 1)
	if $event_label.get_meta("time_left") > 0:
		$OneSecTimer.start()
