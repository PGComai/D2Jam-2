extends Node2D
class_name Ghost


const INTERVAL: int = 10
const GHOST_SPRITE = preload("res://scenes/ghost_sprite.tscn")
const GHOST_COLLIDER = preload("res://scenes/ghost_collider.tscn")
const GHOST_TARGET = preload("res://scenes/ghost_target.tscn")
const GHOST_AREA = preload("res://scenes/ghost_area.tscn")
const AUDIO_STREAM_PLAYER_PLACED = preload("res://scenes/audio_stream_player_placed.tscn")


var player: Player
var idx: int = 0
var placement: int = 0:
	set(value):
		if value > placement:
			if player:
				target.visible = true
				target.global_position = player.global_position
		elif value == 0:
			target.visible = player_in_way
		placement = value
var placed := false:
	set(value):
		placed = value
		if collider:
			collider.set_collision_layer_value(1, placed)
			collider.set_collision_mask_value(1, placed)
		if audio_placed and placed:
			audio_placed.play()
var collider: StaticBody2D
var target: Sprite2D
var room: int = 0
var initializing := true
var ghost_get: GhostGet
var player_in_way := false
var area: Area2D
var audio_placed: AudioStreamPlayer


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
	var new_area = GHOST_AREA.instantiate()
	add_child(new_area)
	area = new_area
	var new_audio = AUDIO_STREAM_PLAYER_PLACED.instantiate()
	add_child(new_audio)
	audio_placed = new_audio
	top_level = true
	global_position = player.global_position


func _physics_process(delta: float) -> void:
	if player:
		if placement:
			if area.get_overlapping_bodies().has(player):
				player_in_way = true
			placement -= 1
			if placement == 0:
				if player_in_way:
					pass
				else:
					placed = true
					target.visible = false
		elif player_in_way:
			if not area.get_overlapping_bodies().has(player):
				player_in_way = false
				placed = true
				target.visible = false
		
		if placed:
			pass
		elif not (player_in_way and not placement):
			var history_pos: int = -(idx + 1) * INTERVAL
			var history_slice: Player.HistoryState = player.history[history_pos]
			
			if initializing:
				if global_position.is_equal_approx(history_slice.pos):
					initializing = false
			else:
				global_position = history_slice.pos
