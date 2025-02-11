extends Node

const NUM_PIECES = 3

var pieces

var rng

var current_piece = null

var did_win = false


var is_not_colliding = false
var bouncyMaterial = PhysicsMaterial.new()
var frictionMaterial = PhysicsMaterial.new()
var is_rotating_chaos = false
var is_random_gravity = false
var is_fast_gravity = false

var music_player: AudioStreamPlayer
var is_rickroll = false



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
	frictionMaterial.friction = 1
	
	
	# Create AudioStreamPlayer if it doesn't exist
	music_player = AudioStreamPlayer.new()
	add_child(music_player)
	music_player.connect("finished", Callable(self, "_on_audio_finished"))
	
	if Shared.do_music:
		# Play a random song
		play_random_song()
		

func _on_audio_finished():
	is_rickroll = false
	play_random_song()

func play_random_song():
	# Choose a random file from the array
	var random_file = Shared.audio_files[rng.randi() % Shared.audio_files.size()]
	
	# Load the audio file
	var audio_stream = load("res://music/" + random_file)
	if audio_stream:
		music_player.stream = audio_stream
		music_player.play()

func _process(_delta: float) -> void:
	if current_piece.get_node("RigidBody2D").get_meta("to_delete") == true:
		current_piece.queue_free()
	elif current_piece.get_node("RigidBody2D").is_controllable or did_win:
		return
	print("time to spawn")
	spawn_piece()
	
	
	

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
		current_piece.get_node("RigidBody2D").set_collision_layer_value(1, false)
		current_piece.get_node("RigidBody2D").set_collision_mask_value(1, false)
		current_piece.get_node("RigidBody2D").set_collision_layer_value(2, false)
		current_piece.get_node("RigidBody2D").set_collision_mask_value(2, false)
		current_piece.get_node("RigidBody2D").set_collision_layer_value(4, true)
		current_piece.get_node("RigidBody2D").set_collision_mask_value(4, true)
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
			for child_child in child.get_children():
				if child_child is RigidBody2D:
					child_child.apply_force(Vector2(0, 1000))
	elif event == "randomforce":
		for child in get_children():
			for child_child in child.get_children():
				if child_child is RigidBody2D:
					child_child.apply_force(Vector2(randi_range(-10000, 10000), randi_range(-10000, 10000)))
	elif event == "friction":
		for child in get_children():
			for child_child in child.get_children():
				if child_child is RigidBody2D:
					child_child.physics_material_override = frictionMaterial
	elif event == "randomcenterofmass":
		current_piece.get_node("RigidBody2D").center_of_mass_mode = RigidBody2D.CenterOfMassMode.CENTER_OF_MASS_MODE_CUSTOM
		current_piece.get_node("RigidBody2D").center_of_mass = Vector2(randi_range(-20, 20), randi_range(0, 20))
	elif event == "floaty":
		current_piece.get_node("RigidBody2D").gravity_scale = 0
		current_piece.get_node("RigidBody2D").apply_force(Vector2(0, -10))
		current_piece.get_node("RigidBody2D").is_controllable = false
		current_piece.get_node("RigidBody2D").set_collision_layer_value(1, false)
		current_piece.get_node("RigidBody2D").set_collision_mask_value(1, false)
		current_piece.get_node("RigidBody2D").set_collision_layer_value(2, false)
		current_piece.get_node("RigidBody2D").set_collision_mask_value(2, false)
		current_piece.get_node("RigidBody2D").set_collision_layer_value(4, true)
		current_piece.get_node("RigidBody2D").set_collision_mask_value(4, true)
	elif event == "rickroll":
		if not is_rickroll:
			music_player.stop()
			# Load the audio file
			var audio_stream = load("res://music/rickroll.mp3")
			if audio_stream:
				music_player.stream = audio_stream
				music_player.play()
			is_rickroll = true
	elif event == "table":
		music_player.stop()
		# Load the audio file
		var audio_stream = load("res://music/table.mp3")
		if audio_stream:
			music_player.stream = audio_stream
			music_player.play()
		


func _on_twenty_sec_timer_timeout() -> void:
	chaos()
	$event_label.text = "Next Event: 5s"
	$event_label.set_meta("time_left", 5)
	$TwentySecTimer.start()
	

func _on_one_sec_timer_timeout() -> void:
	$event_label.text = "Next Event: " + str($event_label.get_meta("time_left")) + "s"
	$event_label.set_meta("time_left", $event_label.get_meta("time_left") - 1)
	if $event_label.get_meta("time_left") > 0:
		$OneSecTimer.start()


func _on_event_timer_timeout() -> void:
	is_rotating_chaos = false
	for child in get_children():
			for child_child in child.get_children():
				if child_child is RigidBody2D:
					child_child.is_rotating_chaos = false
	
