extends Node2D
class_name Ghost


const INTERVAL: int = 20
const GHOST_SPRITE = preload("res://scenes/ghost_sprite.tscn")
const GHOST_COLLIDER = preload("res://scenes/ghost_collider.tscn")
const GHOST_TARGET = preload("res://scenes/ghost_target.tscn")


var player: Player
var idx: int = 0
var placement: int = 0:
	set(value):
		if value > placement:
			if player:
				target.visible = true
				target.global_position = player.global_position
		elif value == 0:
			target.visible = false
		placement = value
var placed := false:
	set(value):
		placed = value
		if collider:
			collider.set_collision_layer_value(1, placed)
			collider.set_collision_mask_value(1, placed)
var collider: StaticBody2D
var target: Sprite2D


func _ready() -> void:
	var new_sprite = GHOST_SPRITE.instantiate()
	add_child(new_sprite)
	new_sprite.position.y = -1.0
	var new_collider = GHOST_COLLIDER.instantiate()
	add_child(new_collider)
	collider = new_collider
	var new_target = GHOST_TARGET.instantiate()
	add_child(new_target)
	target = new_target
	top_level = true


func _physics_process(delta: float) -> void:
	if player:
		if placement:
			placement -= 1
			if placement == 0:
				placed = true
				target.visible = false
		
		if placed:
			pass
		else:
			var history_pos: int = -(idx + 1) * INTERVAL
			var history_slice: Player.HistoryState = player.history[history_pos]
			
			global_position = history_slice.pos
