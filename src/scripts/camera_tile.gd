@tool
extends Area2D
class_name CameraTile


@export var room: int = 0:
	set(value):
		room = value
		if label:
			label.text = str(room)


var label: Label


func _enter_tree() -> void:
	for child in get_children():
		child.queue_free()
	
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
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
		body_exited.connect(_on_body_exited)
	if Engine.is_editor_hint():
		var new_label := Label.new()
		new_label.text = str(room)
		add_child(new_label)
		label = new_label
		var ls := LabelSettings.new()
		ls.font_color = Color(1.0, 1.0, 1.0, 0.3)
		ls.outline_size = 2.0
		ls.outline_color = Color(0.0, 0.0, 0.0, 0.3)
		label.label_settings = ls
		label.label_settings.font_size = 32
		label.z_index = 5


func _on_body_entered(body) -> void:
	if body.is_in_group("player"):
		var player: Player = body
		player.room_center = global_position
		player.room = room


func _on_body_exited(body) -> void:
	if body.is_in_group("player"):
		var player: Player = body
		player.evaluate_room()
