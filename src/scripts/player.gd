extends CharacterBody2D
class_name Player


class HistoryState:
	var pos: Vector2
	var state: States


const MAX_HISTORY: int = 300
const SPEED: float = 100.0
const JUMP: float = 150.0
const ACCEL: float = 0.1
const GRAV: float = 1.2
const JUMP_HOLD: float = 0.3
const WALL_FRICTION: float = 0.1
const HOLD_DIVISOR: float = 2.5
const JUMP_BUFFER: int = 8
const ENTER_WALL_VEL: float = 50.0
const TERMINAL_VEL: float = 300.0
const WALL_STICK_FRAMES: int = 30
const WALL_COYOTE_FRAMES: int = 2
const COYOTE_FRAMES: int = 3
const WALL_JUMP_EFFECT_DECAY: float = 1.3
const WALL_JUMP_Y_SCALE: float = 0.8


signal room_changed


enum States {ON_FLOOR,
			ON_WALL,
			ASCENDING,
			FALLING,
			FLOOR_COYOTE,
			WALL_COYOTE}


var state: States = States.ON_FLOOR
var state_last_frame: States = States.ON_FLOOR
var jump_buffer: int = 0
var wall_jump_effect: float = 0.0:
	set(value):
		wall_jump_effect = maxf(value, 0.0)
var last_wall_jump_dir: float = 0.0
var wall_jump_coyote: int = 0
var wall_normal_coyote: Vector2
var wall_stick: int = 0
var jump_coyote: int = 0
var jump_released := false
var history: Array[HistoryState] = []
var ghosts: Array[Ghost] = []
var placed_ghosts: Array[Ghost] = []
var spawn_pos: Vector2
var room: int = 0:
	set(value):
		var changed: bool = room != value
		var old_room := room
		room = value
		if changed:
			if not rooms_completed.has(old_room) and not rooms_completed.has(room):
				rooms_completed.append(old_room)
				print("completed room %s" % old_room)
			room_changed.emit()
		for rs: RoomRespawn in get_tree().get_nodes_in_group("respawn"):
			if rs.room == room:
				spawn_pos = rs.global_position
var room_center: Vector2
var rooms_completed: Array[int] = []


@onready var label: Label = $Label
@onready var room_detector: Area2D = $RoomDetector


func _ready() -> void:
	for rs: RoomRespawn in get_tree().get_nodes_in_group("respawn"):
		if rs.room == room:
			spawn_pos = rs.global_position
	room_changed.emit()


func movement_on_floor(delta: float) -> void:
	var input_x := Input.get_axis("left", "right")
	
	velocity.x = signf(input_x) * SPEED
	
	wall_jump_coyote = 0
	wall_stick = 0
	
	if Input.is_action_just_pressed("jump") or jump_buffer:
		velocity.y = -JUMP
		if not jump_buffer:
			jump_released = false
		else:
			jump_released = !Input.is_action_pressed("jump")
		jump_coyote = 0
		jump_buffer = 0
	else:
		jump_coyote = COYOTE_FRAMES


func movement_on_wall(delta: float) -> void:
	var input_x := Input.get_axis("left", "right")
	var wall_normal := get_wall_normal()
	wall_normal_coyote = wall_normal
	
	if not wall_stick:
		velocity.x = signf(input_x) * SPEED
	velocity.x -= wall_normal.x * 50.0
	
	jump_coyote = 0
	
	if velocity.y <= 0.0:
		if Input.is_action_just_released("jump"):
			jump_released = true
		
		if jump_released:
			velocity += get_gravity() * delta * GRAV
		else:
			var hold_factor := 1.0 - pow(-clampf(velocity.y, (-JUMP/HOLD_DIVISOR), 0.0) / (JUMP/HOLD_DIVISOR), 2.0)
			velocity += get_gravity() * delta * GRAV * lerpf(JUMP_HOLD, 1.0, hold_factor)
	else:
		if state_last_frame == States.FALLING:
			velocity.y = minf(velocity.y, ENTER_WALL_VEL)
		velocity += get_gravity() * delta * GRAV * WALL_FRICTION
	
	if Input.is_action_just_pressed("jump") or jump_buffer:
		var diagonal_vel := Vector2(wall_normal.x, -1.0).normalized() * JUMP
		velocity = Vector2(diagonal_vel.x, -JUMP * WALL_JUMP_Y_SCALE)
		wall_jump_effect = 1.0
		last_wall_jump_dir = wall_normal.x
		if not jump_buffer:
			jump_released = false
		else:
			jump_released = !Input.is_action_pressed("jump")
		wall_jump_coyote = 0
		jump_buffer = 0
		wall_stick = WALL_STICK_FRAMES
	else:
		wall_jump_coyote = WALL_COYOTE_FRAMES


func movement_ascending(delta: float) -> void:
	var input_x := Input.get_axis("left", "right")
	
	var target_x_vel: float = lerpf(signf(input_x) * SPEED, velocity.x, wall_jump_effect)
	velocity.x = lerpf(velocity.x, target_x_vel, 0.3)
	
	if Input.is_action_just_released("jump"):
		jump_released = true
	
	if jump_released:
		velocity += get_gravity() * delta * GRAV
	else:
		var hold_factor := 1.0 - pow(-clampf(velocity.y, (-JUMP/HOLD_DIVISOR), 0.0) / (JUMP/HOLD_DIVISOR), 2.0)
		velocity += get_gravity() * delta * GRAV * lerpf(JUMP_HOLD, 1.0, hold_factor)
	
	if Input.is_action_just_pressed("jump"):
		jump_buffer = JUMP_BUFFER


func movement_falling(delta: float) -> void:
	var input_x := Input.get_axis("left", "right")
	
	var target_x_vel: float = lerpf(signf(input_x) * SPEED, velocity.x, wall_jump_effect)
	velocity.x = lerpf(velocity.x, target_x_vel, 0.3)
	velocity += get_gravity() * delta * GRAV
	velocity.y = minf(velocity.y, TERMINAL_VEL)
	
	if Input.is_action_just_pressed("jump"):
		jump_buffer = JUMP_BUFFER


func movement_floor_coyote(delta: float) -> void:
	var input_x := Input.get_axis("left", "right")
	
	velocity.x = signf(input_x) * SPEED
	
	if Input.is_action_just_pressed("jump") or jump_buffer:
		velocity.y = -JUMP
		if not jump_buffer:
			jump_released = false
		else:
			jump_released = !Input.is_action_pressed("jump")
		jump_coyote = 0
		jump_buffer = 0


func movement_wall_coyote(delta: float) -> void:
	var input_x := Input.get_axis("left", "right")
	
	if not wall_stick:
		velocity.x = signf(input_x) * SPEED
	
	if Input.is_action_just_pressed("jump") or jump_buffer:
		var diagonal_vel := Vector2(wall_normal_coyote.x, -1.0).normalized() * JUMP
		velocity = Vector2(diagonal_vel.x, -JUMP * WALL_JUMP_Y_SCALE)
		wall_jump_effect = 1.0
		last_wall_jump_dir = wall_normal_coyote.x
		if not jump_buffer:
			jump_released = false
		else:
			jump_released = !Input.is_action_pressed("jump")
		wall_jump_coyote = 0
		jump_buffer = 0
		wall_stick = WALL_STICK_FRAMES


func add_ghost(gg: GhostGet) -> void:
	var new_ghost := Ghost.new()
	new_ghost.idx = ghosts.size()
	new_ghost.player = self
	new_ghost.room = room
	new_ghost.ghost_get = gg
	add_child(new_ghost)
	ghosts.append(new_ghost)


func evaluate_room() -> void:
	if room_detector.get_overlapping_areas():
		var room_area: CameraTile = room_detector.get_overlapping_areas()[0]
		room_center = room_area.global_position
		room = room_area.room


func _physics_process(delta: float) -> void:
	if state == States.ON_FLOOR:
		label.text = "ON_FLOOR"
		movement_on_floor(delta)
	elif state == States.ON_WALL:
		label.text = "ON_WALL"
		movement_on_wall(delta)
	elif state == States.FLOOR_COYOTE:
		label.text = "FLOOR_COYOTE"
		movement_floor_coyote(delta)
	elif state == States.WALL_COYOTE:
		label.text = "WALL_COYOTE"
		movement_wall_coyote(delta)
	elif state == States.ASCENDING:
		label.text = "ASCENDING"
		movement_ascending(delta)
	elif state == States.FALLING:
		label.text = "FALLING"
		movement_falling(delta)
	
	if velocity.x > 0.0:
		room_detector.position.x = 4.0
	elif velocity.x < 0.0:
		room_detector.position.x = -4.0 
	
	move_and_slide()
	
	var last_collision := get_last_slide_collision()
	var invisible_wall := false
	
	if last_collision:
		var last_collider := last_collision.get_collider()
		if last_collider.is_in_group("invisible_wall"):
			invisible_wall = true
	
	state_last_frame = state
	
	if is_on_floor():
		state = States.ON_FLOOR
	elif is_on_wall() and not invisible_wall:
		state = States.ON_WALL
	elif jump_coyote:
		state = States.FLOOR_COYOTE
	elif wall_jump_coyote:
		state = States.WALL_COYOTE
	elif velocity.y > 0.0:
		state = States.FALLING
	else:
		state = States.ASCENDING
	
	if wall_jump_effect:
		wall_jump_effect -= delta * WALL_JUMP_EFFECT_DECAY
	if jump_coyote:
		jump_coyote -= 1
	if wall_jump_coyote:
		wall_jump_coyote -= 1
	if jump_buffer:
		jump_buffer -= 1
	if wall_stick:
		wall_stick -= 1
	
	var new_history_state := HistoryState.new()
	new_history_state.pos = global_position
	new_history_state.state = state
	history.append(new_history_state)
	
	if history.size() > MAX_HISTORY:
		history.remove_at(0)
	elif fmod(history.size(), Ghost.INTERVAL) == 0:
		pass
	
	if Input.is_action_just_pressed("place"):
		var rghosts := ghosts.duplicate()
		rghosts.reverse()
		
		var chosen_ghost: Ghost
		
		for ghost: Ghost in rghosts:
			if not ghost.placement and not ghost.placed:
				chosen_ghost = ghost
				break
		
		if chosen_ghost:
			chosen_ghost.placement = ((chosen_ghost.idx) * Ghost.INTERVAL) + Ghost.INTERVAL + 1
			placed_ghosts.append(chosen_ghost)
	if Input.is_action_just_pressed("clear_ghosts"):
		for pghost: Ghost in placed_ghosts:
			pghost.placed = false
		for ghost: Ghost in ghosts:
			ghost.placement = 0
		#global_position = spawn_pos
		for history_state: HistoryState in history:
			history_state.pos = global_position
			history_state.state = state
	if Input.is_action_just_pressed("respawn"):
		respawn()


func respawn() -> void:
	global_position = spawn_pos
	var lost_ghosts: Array[Ghost] = []
	for ghost: Ghost in ghosts:
		if not rooms_completed.has(ghost.room):
			lost_ghosts.append(ghost)
	for lg: Ghost in lost_ghosts:
		if ghosts.has(lg):
			ghosts.erase(lg)
		if placed_ghosts.has(lg):
			placed_ghosts.erase(lg)
		lg.ghost_get.active = true
		lg.queue_free()
	room_changed.emit()


func _on_room_detector_area_entered(area: Area2D) -> void:
	var room_area: CameraTile = area
	room_center = room_area.global_position
	room = room_area.room
