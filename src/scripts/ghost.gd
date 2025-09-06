extends Node2D
class_name Ghost


const INTERVAL: int = 20
const GHOST_SPRITE = preload("res://scenes/ghost_sprite.tscn")
const GHOST_COLLIDER = preload("res://scenes/ghost_collider.tscn")


var player: Player
var idx: int = 0
var placement: int
var placed := false:
	set(value):
		placed = value
		if collider:
			collider.set_collision_layer_value(1, placed)
			collider.set_collision_mask_value(1, placed)
var collider: StaticBody2D


func _ready() -> void:
	var new_sprite = GHOST_SPRITE.instantiate()
	add_child(new_sprite)
	var new_collider = GHOST_COLLIDER.instantiate()
	add_child(new_collider)
	collider = new_collider
	top_level = true


func _physics_process(delta: float) -> void:
	if player:
		if placement:
			placement -= 1
			if placement == 0:
				placed = true
		
		if placed:
			pass
		else:
			var history_pos: int = -(idx + 1) * INTERVAL
			var history_slice: Player.HistoryState = player.history[history_pos]
			
			global_position = history_slice.pos
