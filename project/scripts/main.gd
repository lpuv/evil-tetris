extends Node

const NUM_PIECES = 3

var pieces

var rng

var current_piece = null

var did_win = false


var is_not_colliding = false
var bouncyMaterial = PhysicsMaterial.new()
var is_rotating_chaos = false
var is_random_gravity = false
var is_fast_gravity = false


func get_visible_children_count() -> int:
	var visible_count = 0
	for child in get_children():
		if child is not Node2D:
			continue
		if child.visible:
			visible_count += 1
	return visible_count


func prepare_restart():
	current_piece.queue_free()

func spawn_piece():
	
	var piece = pieces[rng.randi() % pieces.size()].instantiate()
	add_child(piece)
	var body = piece.get_node("RigidBody2D")
	body.is_controllable = true
	body.transform.origin.y = -393
	body.visible = false
	body.gravity_scale = 1
	body.contact_monitor = true
	body.max_contacts_reported = 5
	body.set_meta("to_delete", false)
	
	
	# chaos
	if is_not_colliding:
		print("disabling collision")
		body.set_collision_layer_value(1, false)
		body.set_collision_layer_value(2, false)
		body.set_collision_mask_value(1, false)
		body.set_collision_mask_value(2, false)
		body.set_collision_layer_value(3, true)
		body.set_collision_mask_value(3, true)
		is_not_colliding = false
		
	
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
	
	bouncyMaterial.bounce = 1

func _process(_delta: float) -> void:
	if current_piece.get_node("RigidBody2D").get_meta("to_delete") == true:
		current_piece.queue_free()
	elif current_piece.get_node("RigidBody2D").is_controllable or did_win:
		return
	print("time to spawn")
	spawn_piece()
	
	print(get_visible_children_count())
	
	if get_visible_children_count() > 300:
		win()
	

func win():
	$win.visible = true
	did_win = true
	var pieces = Shared.get_children_in_radius(10, $win)
	for piece in pieces:
		piece.visible = false
		piece.queue_free()

func chaos():
	var chaos_events = Shared.CHAOS_EVENTS
	chaos_events.shuffle()
	var event = chaos_events[rng.randi() % chaos_events.size()]
	print("starting event " + event)
	
	$current_event.text = "Current Event: " + event
	
	if event == "nocollision":
		is_not_colliding = true
	elif event == "upwardforce":
		current_piece.get_node("RigidBody2D").apply_force(Vector2(0, -5000))
		current_piece.get_node("RigidBody2D").is_controllable = false
	elif event == "bouncy":
		current_piece.get_node("RigidBody2D").physics_material_override = bouncyMaterial
	elif event == "rotatechaos":
		for child in get_children():
			for child_child in child.get_children():
				if child_child is RigidBody2D:
					child_child.is_rotating_chaos = true
		$EventTimer.start()
	elif event == "randomgravity":
		$ceiling.is_random_gravity = true
	elif event == "fastgravity":
		$ceiling.is_fast_gravity = true
	elif event == "downwardsforce":
		for child in get_children():
			print("to down: " + str(child))
			for child_child in child.get_children():
				print("to down: " + str(child_child))
				if child_child is RigidBody2D:
					print("downwards force")
					child_child.apply_force(Vector2(0, 1000))
	elif event == "randomforce":
		for child in get_children():
			print("to random: " + str(child))
			for child_child in child.get_children():
				print("to random: " + str(child_child))
				if child_child is RigidBody2D:
					print("random force")
					child_child.apply_force(Vector2(randi_range(-1000, 1000), randi_range(-1000, 1000)))

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


func _on_event_timer_timeout() -> void:
	is_rotating_chaos = false
	for child in get_children():
			print("to rotate: " + str(child))
			for child_child in child.get_children():
				if child_child is RigidBody2D:
					print("rotating chaos")
					child_child.is_rotating_chaos = false
	
