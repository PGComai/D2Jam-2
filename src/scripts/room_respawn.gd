@tool
extends Sprite2D
class_name RoomRespawn


const CLR := Color("ff53ff9d")
const ROOM_RESPAWN = preload("res://misc/room_respawn.tres")


@export var room: int = 0:
	set(value):
		room = value
		if label:
			label.text = str(room)


var label: Label


func _enter_tree() -> void:
	texture = ROOM_RESPAWN
	if Engine.is_editor_hint():
		modulate = CLR
	else:
		modulate = Color(1.0, 1.0, 1.0, 0.0)
	add_to_group("respawn")
	
	if Engine.is_editor_hint():
		var new_label := Label.new()
		new_label.text = str(room)
		add_child(new_label)
		label = new_label
		var ls := LabelSettings.new()
		ls.font_color = Color(1.0, 1.0, 1.0, 1.0)
		ls.outline_size = 4.0
		ls.outline_color = Color(0.0, 0.0, 0.0, 1.0)
		ls.font_size = 16
		label.label_settings = ls
		label.z_index = 5
