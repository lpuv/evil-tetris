extends RigidBody2D


@export var sprite: Sprite2D
@export var shape: CollisionPolygon2D
@export var textures: Array[CompressedTexture2D] = []
@export var shapes: Array[PackedVector2Array] = []
@export var is_controllable: bool



func set_state(state: int) -> void:
	sprite.texture = textures[state]
	shape.polygon = shapes.get(state)
	sprite.set_meta("state", state)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# randomize starting state
	var state = randi_range(0, (len(textures) - 1))
	print("state: " + str(state))
	set_state(state)
	self.body_entered.connect(_on_body_enter)
	

func process_inputs():
	if Input.is_action_just_pressed("up"):
		if (sprite.get_meta("state") == (len(textures) - 1)):
			set_state(0)
		else:
			set_state(sprite.get_meta("state") + 1)
	
	if Input.is_action_just_pressed("down"):
		if (sprite.get_meta("state") == 0):
			set_state(len(textures) - 1)
		else:
			set_state(sprite.get_meta("state") - 1)
			
			
	if Input.is_action_just_pressed("left"):
		move_and_collide(Vector2(-25, 0))
	elif Input.is_action_just_pressed("right"):
		move_and_collide(Vector2(25, 0))
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# process left and right inputs and rotate accordingly
	if is_controllable:
		process_inputs()
	

func _on_body_enter(node):
	if node.name == "ceiling":
		visible = true
	elif node.name != "walls" and is_controllable:
		#transform.origin = Shared.position_snapped(transform.origin)
		is_controllable = false
		collision_layer = 2
		collision_mask = 2
		gravity_scale = 1
