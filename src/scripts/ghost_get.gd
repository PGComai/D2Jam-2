@tool
extends Area2D
class_name GhostGet


const GHOST_SPRITE = preload("res://scenes/ghost_sprite.tscn")


func _ready() -> void:
	if get_child_count() == 0:
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
		
		body_entered.connect(_on_body_entered)


func _on_body_entered(body) -> void:
	if body.is_in_group("player"):
		var player: Player = body
		player.call_deferred("add_ghost")
		queue_free()
