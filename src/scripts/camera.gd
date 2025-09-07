extends Camera2D


const PAN_WAIT: int = 16


signal player_can_move_again


@export var player: Player
@export var virtual_camera: Node2D


var free_left := false
var free_right := false
var free_top := false
var free_bottom := false

var new_room_center: Vector2
var goto_new_center := false
var pan_wait_frames: int = PAN_WAIT
var room_tiles: Array[CameraTile] = []
var timer_start_time: int
var victory := false


@onready var sensor_left: Area2D = $SensorLeft
@onready var sensor_right: Area2D = $SensorRight
@onready var sensor_top: Area2D = $SensorTop
@onready var sensor_bottom: Area2D = $SensorBottom
@onready var label_time: Label = $LabelTime
@onready var label_feesh: Label = $HBoxContainer/LabelFeesh
@onready var victory_timer: Timer = $VictoryTimer
@onready var label_victory: Label = $LabelVictory


func _ready() -> void:
	timer_start_time = Time.get_ticks_usec()


func _process(delta: float) -> void:
	if not victory:
		label_time.text = stringify_time(Time.get_ticks_usec() - timer_start_time)
	
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
	
	var player_y_pan := Input.get_axis("up", "down") * 36.0
	var no_pan_if := Input.get_axis("left", "right")
	
	
	if player:
		target_pos = player.global_position - Vector2(0.0, 0.5)
		if absf(no_pan_if) < 0.2 and player_y_pan:
			if pan_wait_frames:
				pan_wait_frames -= 1
			else:
				target_pos.y += player_y_pan
		else:
			pan_wait_frames = PAN_WAIT
	
	if goto_new_center:
		global_position = global_position.lerp(virtual_camera.global_position, 0.15)
		if global_position.is_equal_approx(virtual_camera.global_position):
			global_position = virtual_camera.global_position
			goto_new_center = false
	elif target_pos:
		var target_dir := global_position.direction_to(target_pos)
		var next_pos := global_position.lerp(target_pos, 0.1)
		
		var nearest_tile: CameraTile
		var tile_dist: float = 10000000.0
		
		if room_tiles.size():
			for rt: CameraTile in room_tiles:
				var dist := next_pos.distance_squared_to(rt.global_position)
				if dist < tile_dist:
					nearest_tile = rt
					tile_dist = dist
		
		if not free_left:
			if nearest_tile:
				next_pos.x = maxf(nearest_tile.global_position.x, next_pos.x)
			else:
				next_pos.x = global_position.x
		if not free_right:
			if nearest_tile:
				next_pos.x = minf(nearest_tile.global_position.x, next_pos.x)
			else:
				next_pos.x = global_position.x
		if not free_top:
			if nearest_tile:
				next_pos.y = maxf(nearest_tile.global_position.y, next_pos.y)
			else:
				next_pos.y = global_position.y
		if not free_bottom:
			if nearest_tile:
				next_pos.y = minf(nearest_tile.global_position.y, next_pos.y)
			else:
				next_pos.y = global_position.y
		
		global_position = next_pos


func _on_player_room_changed() -> void:
	new_room_center = player.room_center
	room_tiles.clear()
	for ct: CameraTile in get_tree().get_nodes_in_group("camera_tile"):
		if ct.room == player.room:
			room_tiles.append(ct)
	goto_new_center = true


func _on_player_fish_get() -> void:
	if player:
		label_feesh.text = str(player.fish_count)


func _on_player_respawned() -> void:
	if player:
		if not player.rooms_completed.size():
			timer_start_time = Time.get_ticks_usec()


func stringify_time(_time: int) -> String:
	var minutes: int = (int(float(_time) / 1000000.0)) / 60
	var seconds = str((float(_time) / 1000000.0) - float(minutes * 60))
	var slice1 = seconds.get_slice(".", 0)
	if slice1.length() == 1:
		slice1 = "0" + slice1
	
	var slice2 = seconds.get_slice(".", 1).substr(0, 2)
	if slice2.length() == 0:
		slice2 = "00"
	elif slice2.length() == 1:
		slice2 = slice2 + "0"
		
	var slice3 = seconds.get_slice(".", 1).substr(2, 2)
	if slice3.length() == 0:
		slice3 = "00"
	elif slice3.length() == 1:
		slice3 = slice3 + "0"
	
	var min_string = str(minutes)
	if min_string.length() < 2:
		min_string = "0" + min_string
	
	return min_string + ":" + slice1 + ":" + slice2


func _on_player_victory() -> void:
	victory = true
	victory_timer.start()
	label_victory.visible = true


func _on_victory_timer_timeout() -> void:
	label_victory.visible = false
	player_can_move_again.emit()
