@tool
extends Area2D
class_name VictoryZone


@export var size := Vector2i(80.0, 40.0):
	set(value):
		size = value
		if shape:
			shape.size = size
@export var sprite: Texture2D:
	set(value):
		sprite = value
		if sprite_2d:
			sprite_2d.texture = sprite


var shape: RectangleShape2D
var sprite_2d: Sprite2D


func _enter_tree() -> void:
	for child in get_children():
		child.queue_free()
	
	var new_collider := CollisionShape2D.new()
	var new_shape := RectangleShape2D.new()
	new_shape.size = size
	shape = new_shape
	new_collider.shape = shape
	new_collider.debug_color = Color(0.7, 0.7, 0.0, 0.07)
	add_child(new_collider)
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	
	if sprite:
		var new_sprite2d := Sprite2D.new()
		new_sprite2d.texture = sprite
		sprite_2d = new_sprite2d
		add_child(sprite_2d)


func _on_body_entered(body) -> void:
	if body.is_in_group("player"):
		var player: Player = body
		player.victory.emit()
		queue_free()
