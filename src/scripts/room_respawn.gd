@tool
extends Sprite2D
class_name RoomRespawn


const CLR := Color("ff53ff9d")
const ROOM_RESPAWN = preload("res://misc/room_respawn.tres")


@export var room: int = 0


func _enter_tree() -> void:
	texture = ROOM_RESPAWN
	modulate = CLR
	add_to_group("respawn")
