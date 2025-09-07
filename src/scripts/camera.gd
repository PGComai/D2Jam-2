extends Camera2D


@export var player: Player


var free_left := false
var free_right := false
var free_top := false
var free_bottom := false

var new_room_center: Vector2
var goto_new_center := false


@onready var sensor_left: Area2D = $SensorLeft
@onready var sensor_right: Area2D = $SensorRight
@onready var sensor_top: Area2D = $SensorTop
@onready var sensor_bottom: Area2D = $SensorBottom


func _process(delta: float) -> void:
	var target_pos: Vector2
	
	free_left = sensor_left.get_overlapping_areas().size()
	free_right = sensor_right.get_overlapping_areas().size()
	free_top = sensor_top.get_overlapping_areas().size()
	free_bottom = sensor_bottom.get_overlapping_areas().size()
	
	var bad_left := false
	var bad_right := false
	var bad_top := false
	var bad_bottom := false
	
	if free_left:
		var o_area: CameraTile = sensor_left.get_overlapping_areas()[0]
		if player.room == o_area.room:
			pass
		else:
			free_left = false
			bad_left = true
	if free_right:
		var o_area: CameraTile = sensor_right.get_overlapping_areas()[0]
		if player.room == o_area.room:
			pass
		else:
			free_right = false
			bad_right = true
	if free_top:
		var o_area: CameraTile = sensor_top.get_overlapping_areas()[0]
		if player.room == o_area.room:
			pass
		else:
			free_top = false
			bad_top = true
	if free_bottom:
		var o_area: CameraTile = sensor_bottom.get_overlapping_areas()[0]
		if player.room == o_area.room:
			pass
		else:
			free_bottom = false
			bad_bottom = true
	
	if player:
		target_pos = player.global_position - Vector2(0.0, 0.5)
	
	if goto_new_center:
		global_position = global_position.lerp(new_room_center, 0.3)
		if global_position.is_equal_approx(new_room_center):
			global_position = new_room_center
			goto_new_center = false
	elif target_pos:
		var target_dir := global_position.direction_to(target_pos)
		var next_pos := global_position.lerp(target_pos, 0.2)
		
		if target_dir.x < 0.0:
			if not free_left:
				next_pos.x = global_position.x
		if target_dir.x > 0.0:
			if not free_right:
				next_pos.x = global_position.x
		if target_dir.y < 0.0:
			if not free_top:
				next_pos.y = global_position.y
		if target_dir.y > 0.0:
			if not free_bottom:
				next_pos.y = global_position.y
		
		global_position = next_pos


func _on_player_room_changed() -> void:
	new_room_center = player.room_center
	goto_new_center = true
