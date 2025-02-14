extends RigidBody2D


@export var sprite: Sprite2D
@export var shape: CollisionPolygon2D
@export var textures: Array[CompressedTexture2D] = []
@export var shapes: Array[PackedVector2Array] = []
@export var is_controllable: bool

var is_rotating_chaos = false
var is_unique = false


func get_random_angle() -> int:
	# Generate a random integer between 0 and 3
	var random_index = randi() % 4
	# Map the index to the corresponding angle
	return random_index * 90



func set_state(state: int) -> void:
	sprite.texture = textures[state]
	shape.polygon = shapes[state]
	sprite.set_meta("state", state)
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.body_entered.connect(_on_body_enter)
	
	
# handle rotation logic
func _integrate_forces(state):
	if Input.is_action_just_pressed("up") and (is_controllable or is_rotating_chaos):
		rotate(PI*0.5)
	
	if Input.is_action_just_pressed("down") and (is_controllable or is_rotating_chaos):
		rotate(-PI*0.5)



func process_inputs():
	if Input.is_action_just_pressed("small_left"):
		move_and_collide(Vector2(-10, 0))		
	elif Input.is_action_just_pressed("small_right"):
		move_and_collide(Vector2(10, 0))
	elif Input.is_action_just_pressed("left"):
		move_and_collide(Vector2(-25, 0))
	elif Input.is_action_just_pressed("right"):
		move_and_collide(Vector2(25, 0))
	
	if Input.is_action_just_pressed("space"):
		apply_force(Vector2(0, 100000))
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# process left and right inputs and rotate accordingly
	if is_controllable:
		process_inputs()
		
	

func _on_body_enter(node):
	if node.name == "ceiling":
		visible = true
	elif node.name != "walls" and node.name != "deathplane" and is_controllable:
		is_controllable = false
		set_collision_layer_value(2, true)  # other pieces
		set_collision_mask_value(2, true)
		set_collision_layer_value(1, false) # walls
		set_collision_mask_value(1, false)
		set_collision_layer_value(4, true) # floaty & flying pieces
		set_collision_mask_value(4, true)
		set_collision_layer_value(5, true) # win check
		set_collision_mask_value(5, true)
		set_meta("is_landed", true) # win check
		gravity_scale = 1
		
