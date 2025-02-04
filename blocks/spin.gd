extends RigidBody2D


@export var sprite: Sprite2D
@export var shape: CollisionPolygon2D
@export var textures: Array[CompressedTexture2D] = []
@export var shape_id: String
@export var shapes: Array[PackedVector2Array] = []


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("left"):
		if (sprite.get_meta("state") == (len(textures) - 1)):
			sprite.texture = textures[0]
			shape.polygon = shapes.get(0)
			sprite.set_meta("state", 0)
		else:
			sprite.texture = textures[sprite.get_meta("state") + 1]
			shape.polygon = shapes.get(sprite.get_meta("state") + 1)
			sprite.set_meta("state", sprite.get_meta("state") + 1)
	
	if Input.is_action_just_pressed("right"):
		if (sprite.get_meta("state") == 0):
			sprite.texture = textures[len(textures) - 1]
			shape.polygon = shapes.get(len(textures) - 1)
			sprite.set_meta("state", len(textures) - 1)
		else:
			sprite.texture = textures[sprite.get_meta("state") - 1]
			shape.polygon = shapes.get(sprite.get_meta("state") - 1)
			sprite.set_meta("state", sprite.get_meta("state") - 1)
