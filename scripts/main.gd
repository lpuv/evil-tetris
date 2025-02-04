extends Node

func _ready():
	var I = preload("res://blocks/I.tscn").instantiate();
	add_child(I);
	
