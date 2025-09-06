extends Node2D
class_name Ghost


const INTERVAL: int = 20
const GHOST_SPRITE = preload("res://scenes/ghost_sprite.tscn")


var player: Player
var idx: int = 0


func _ready() -> void:
	var new_sprite = GHOST_SPRITE.instantiate()
	add_child(new_sprite)
	top_level = true


func _physics_process(delta: float) -> void:
	if player:
		var history_pos: int = -(idx + 1) * INTERVAL
		var history_slice: Player.HistoryState = player.history[history_pos]
		
		global_position = history_slice.pos
