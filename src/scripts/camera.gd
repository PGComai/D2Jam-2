extends Camera2D


@export var player: CharacterBody2D


var free_left := false
var free_right := false
var free_top := false
var free_bottom := false


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
	
	if player:
		target_pos = player.global_position - Vector2(0.0, 0.5)
	
	if target_pos:
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
