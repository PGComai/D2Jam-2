@tool
extends Area2D
class_name CameraTile


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
