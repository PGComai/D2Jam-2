@tool
extends Sprite2D
class_name Feesh


const FEESH = preload("res://sprites/feesh.tres")


func _enter_tree() -> void:
	for child in get_children():
		child.queue_free()
	
	texture = FEESH
	var new_area := Area2D.new()
	var new_collider := CollisionShape2D.new()
	var new_shape := RectangleShape2D.new()
	new_shape.size = Vector2(8.0, 8.0)
	new_collider.shape = new_shape
	#new_collider.debug_color = Color(0.0, 0.5, 1.0, 0.04)
	add_child(new_area)
	new_area.add_child(new_collider)
	if not new_area.body_entered.is_connected(_on_body_entered):
		new_area.body_entered.connect(_on_body_entered)


func _on_body_entered(body) -> void:
	if body.is_in_group("player"):
		var player: Player = body
		player.fish_count += 1
		queue_free()
