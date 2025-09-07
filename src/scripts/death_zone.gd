@tool
extends Area2D
class_name DeathZone

@export var size := Vector2i(320.0, 60.0):
	set(value):
		size = value
		if shape:
			shape.size = size


var shape: RectangleShape2D


func _enter_tree() -> void:
	for child in get_children():
		child.queue_free()
	
	var new_collider := CollisionShape2D.new()
	var new_shape := RectangleShape2D.new()
	new_shape.size = size
	shape = new_shape
	new_collider.shape = shape
	new_collider.debug_color = Color(1.0, 0.1, 0.1, 0.1)
	add_child(new_collider)
	
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)


func _on_body_entered(body) -> void:
	if body.is_in_group("player"):
		var player: Player = body
		player.respawn()
