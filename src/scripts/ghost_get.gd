@tool
extends Area2D
class_name GhostGet


const GHOST_SPRITE = preload("res://scenes/ghost_sprite.tscn")


var room: int = 0
var active := true:
	set(value):
		active = value
		visible = active
		set_collision_layer_value(1, active)
		set_collision_mask_value(1, active)
		set_collision_mask_value(4, active)


func _enter_tree() -> void:
	for child in get_children():
		child.queue_free()
	
	var new_collider := CollisionShape2D.new()
	var new_shape := RectangleShape2D.new()
	new_shape.size = Vector2(8.0, 16.0)
	new_collider.shape = new_shape
	new_collider.debug_color = Color(0.0, 1.0, 0.5, 0.1)
	add_child(new_collider)
	add_to_group("ghost_get")
	var new_sprite = GHOST_SPRITE.instantiate()
	new_sprite.modulate = Color.LIGHT_GREEN
	add_child(new_sprite)
	
	set_collision_mask_value(4, true)
	
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
		area_entered.connect(_on_area_entered)


func _on_body_entered(body) -> void:
	if body.is_in_group("player"):
		var player: Player = body
		player.call_deferred("add_ghost", self)
		active = false


func _on_area_entered(area) -> void:
	if area.is_in_group("camera_tile"):
		var tile: CameraTile = area
		room = tile.room
