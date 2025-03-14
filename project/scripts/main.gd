extends Node

var pieces

var rng

var current_piece = null

var did_win = false

var num_fell = 0

var is_not_colliding = false
var bouncyMaterial = PhysicsMaterial.new()
var frictionMaterial = PhysicsMaterial.new()
var frictionlessMaterial = PhysicsMaterial.new()
var is_rotating_chaos = false
var is_random_gravity = false
var is_fast_gravity = false
var is_unique = false

var music_player: AudioStreamPlayer
var chaos_player: AudioStreamPlayer
var is_rickroll = false

var pieces_to_lose = Shared.PIECES_TO_LOSE_SPRINT if Shared.sprint_mode else Shared.PIECES_TO_LOSE

var current_chaos_timer_time = 10




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
	body.set_meta("is_quantum", false)
	
	
	# chaos
	if is_not_colliding:
		body.set_collision_layer_value(1, false)
		body.set_collision_mask_value(1, false)
		body.set_collision_layer_value(2, false)
		body.set_collision_mask_value(2, false)
		body.set_collision_layer_value(3, true)
		body.set_collision_mask_value(3, true)
		is_not_colliding = false
	
	
	current_piece = piece
	body.add_to_group("pieces")
	

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
	
	$instructions.text = "reach the top!!\ndon't lose\n" + str(pieces_to_lose) + " pieces!"
	
	$AnimationPlayer.play("controls_fade")
	$TwentySecTimer.start()
	$OneSecTimer.start()
	
	bouncyMaterial.bounce = 1
	frictionMaterial.friction = 1
	
	
	# Create AudioStreamPlayer if it doesn't exist
	music_player = AudioStreamPlayer.new()
	add_child(music_player)
	
	# create music chaos player
	chaos_player = AudioStreamPlayer.new()
	add_child(chaos_player)
	
	music_player.connect("finished", Callable(self, "_on_audio_finished"))
	chaos_player.connect("finished", Callable(self, "_on_chaos_audio_finished"))
	
	if Shared.do_music:
		# Play a random song
		play_random_song()
	
	Shared.is_dead = false

func _on_audio_finished():
	is_rickroll = false
	play_random_song()
	
func _on_chaos_audio_finished():
	music_player.play()

func play_random_song():
	# Choose a random file from the array
	var random_file = Shared.audio_files[rng.randi() % Shared.audio_files.size()]
	
	# Load the audio file
	var audio_stream = load("res://music/" + random_file)
	if audio_stream:
		music_player.stream = audio_stream
		music_player.play()

func adjust_chaos_by_height():
	# Get current stack height
	var current_height = Shared.get_stack_height(get_tree().get_nodes_in_group("pieces"))

	# Calculate how close we are to -380 (0 means we're at -380, larger numbers mean we're further away)
	var distance_to_target = abs(current_height - (-380))

	# Convert this to a percentage (0.0 to 1.0)
	# Assuming the stack starts at around -760 (or adjust this value based on your game)
	var height_percentage = clamp(1.0 - (distance_to_target / 380.0), 0.0, 1.0)

	# Interpolate between max and min time based on height_percentage
	var max_time = 5.0 if Shared.sprint_mode else 10.0
	var min_time = 0.5
	var time_left = floor(lerp(max_time, min_time, height_percentage))


	print("Current height: ", current_height)
	print("Distance to target: ", distance_to_target)
	print("Height percentage: ", height_percentage)
	print("Time left: ", time_left)
	current_chaos_timer_time = time_left


func _process(_delta: float) -> void:
	if current_piece != null:
		if current_piece.get_node("RigidBody2D").is_controllable or did_win:
			return
	print("time to spawn")
	spawn_piece()
	
	adjust_chaos_by_height()
	
	handle_deletion()



func handle_deletion():
	for piece in get_tree().get_nodes_in_group("pieces"):
		if piece.get_meta("to_delete") == true:
			print(piece.is_controllable)
			if num_fell >= pieces_to_lose:
				$gameover.visible = true
				$gameoverrestart.visible = true
				$gameoverrestartadd.visible = true
				Shared.is_dead = true
				get_tree().paused = true
			num_fell += 1
			$pieceslost.text = "pieces lost: " + str(num_fell)
			piece.is_controllable = false
			piece.queue_free()

func win():
	$win.visible = true
	did_win = true
	var pieces = Shared.get_children_in_radius(10, $win)
	for piece in pieces:
		piece.visible = false
		piece.queue_free()

func chaos():
	var total_weight = 0
	for weight in Shared.CHAOS_EVENTS_WEIGHTED.values():
		total_weight += weight
	
	var random_num = rng.randi() % total_weight
	var current_weight = 0
	
	var event = ""
	
	# handle event weighting
	for event_iterated in Shared.CHAOS_EVENTS_WEIGHTED:
		current_weight += Shared.CHAOS_EVENTS_WEIGHTED[event_iterated]
		if random_num < current_weight:
			print("starting event " + event_iterated)
			$current_event.text = "Current Event: " + event_iterated
			event = event_iterated
			break
	
	
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
		is_rotating_chaos = true
		for child in get_tree().get_nodes_in_group("pieces"):
			child.is_rotating_chaos = true
		$EventTimer.start()
	elif event == "randomgravity":
		$ceiling.is_random_gravity = true
	elif event == "fastgravity":
		$ceiling.is_fast_gravity = true
	elif event == "downwardsforce":
		for piece in get_tree().get_nodes_in_group("pieces"):
			piece.apply_force(Vector2(0, 1000))
	elif event == "randomforce":
		for piece in get_tree().get_nodes_in_group("pieces"):
			piece.apply_force(Vector2(rng.randi_range(-10000, 10000), rng.randi_range(-10000, 10000)))
	elif event == "friction":
		for piece in get_tree().get_nodes_in_group("pieces"):
			piece.physics_material_override = frictionMaterial
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
				chaos_player.stream = audio_stream
				chaos_player.play()
			is_rickroll = true
	elif event == "table":
		music_player.stop()
		# Load the audio file
		var audio_stream = load("res://music/table.mp3")
		if audio_stream:
			chaos_player.stream = audio_stream
			chaos_player.play()
	elif event == "amongus":
		$amongus.visible = not $amongus.visible
		if $amongus.visible: $amongus.play()
	elif event == "huge":
		current_piece.get_node("RigidBody2D").get_node("Sprite2D").scale = Vector2(2, 2)
		current_piece.get_node("RigidBody2D").get_node("CollisionPolygon2D").scale = Vector2(2, 2)
	elif event == "tiny":
		current_piece.get_node("RigidBody2D").get_node("Sprite2D").scale = Vector2(0.5, 0.5)
		current_piece.get_node("RigidBody2D").get_node("CollisionPolygon2D").scale = Vector2(0.5, 0.5)
	elif event == "magnetic":
		for block1 in get_tree().get_nodes_in_group("pieces"):
			for block2 in get_tree().get_nodes_in_group("pieces"):
				if block1 != block2:
					var direction = (block2.position - block1.position).normalized()
					var distance = block1.position.distance_to(block2.position)
					var force = direction * (10000.0/distance)
					block1.apply_central_impulse(force)
	elif event == "frictionless":
		for piece in get_tree().get_nodes_in_group("pieces"):
			piece.physics_material_override = frictionlessMaterial
	elif event == "goodbyepiece":
		var piece_to_poof = get_tree().get_nodes_in_group("pieces")[rng.randi_range(0, len(get_tree().get_nodes_in_group("pieces")) - 1)]
		piece_to_poof.get_parent().queue_free()


func _on_twenty_sec_timer_timeout() -> void:
	chaos()
	$event_label.text = "Next Event: " + str(current_chaos_timer_time) + "s"
	$event_label.set_meta("time_left", current_chaos_timer_time)
	$TwentySecTimer.wait_time = current_chaos_timer_time
	$TwentySecTimer.start()
	

func _on_one_sec_timer_timeout() -> void:
	$event_label.text = "Next Event: " + str($event_label.get_meta("time_left")) + "s"
	$event_label.set_meta("time_left", $event_label.get_meta("time_left") - 1)
	if $event_label.get_meta("time_left") > 0:
		$OneSecTimer.start()


func _on_event_timer_timeout() -> void:
	if is_rotating_chaos:
		is_rotating_chaos = false
		for child in get_tree().get_nodes_in_group("pieces"):
			child.is_rotating_chaos = false
	if is_unique:
		is_unique = false
		for child in get_tree().get_nodes_in_group("pieces"):
			child.is_unique = false
		


func _on_yieldcontrol_body_entered(body: Node2D) -> void:
	print("yielding control of piece")
	body.is_controllable = false


func _on_gameoverrestart_pressed() -> void:
	get_tree().current_scene.prepare_restart()
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_gameoverrestartadd_pressed() -> void:
	if Shared.sprint_mode:
		Shared.PIECES_TO_LOSE_SPRINT += 10
	else:
		Shared.PIECES_TO_LOSE += 10
	get_tree().current_scene.prepare_restart()
	get_tree().paused = false
	get_tree().reload_current_scene()
