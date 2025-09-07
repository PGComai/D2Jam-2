@tool
extends Area2D
class_name CameraTile


@export var room: int = 0


func _ready() -> void:
	if get_child_count() == 0:
		var new_collider := CollisionShape2D.new()
		var new_shape := RectangleShape2D.new()
		new_shape.size = Vector2(320.0, 180.0)
		new_collider.shape = new_shape
		new_collider.debug_color = Color(0.0, 0.5, 1.0, 0.04)
		set_collision_layer_value(1, false)
		set_collision_mask_value(1, false)
		set_collision_layer_value(4, true)
		set_collision_mask_value(4, true)
		add_child(new_collider)
		add_to_group("camera_tile")
		body_entered.connect(_on_body_entered)
		body_exited.connect(_on_body_exited)


func _on_body_entered(body) -> void:
	if body.is_in_group("player"):
		var player: Player = body
		player.room_center = global_position
		player.room = room


func _on_body_exited(body) -> void:
	if body.is_in_group("player"):
		var player: Player = body
		player.evaluate_room()
