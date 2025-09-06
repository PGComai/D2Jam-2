extends CharacterBody2D


const SPEED: float = 125.0
const JUMP: float = 225.0
const ACCEL: float = 0.1
const GRAV: float = 1.5
const JUMP_HOLD: float = 0.4
const WALL_FRICTION: float = 0.1
const HOLD_DIVISOR: float = 4.0
const JUMP_BUFFER: int = 16
const ENTER_WALL_VEL: float = 30.0


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
var jump_coyote: int = 0
var jump_released := false


@onready var label: Label = $Label


func _ready() -> void:
	pass


func movement_on_floor(delta: float) -> void:
	var input_x := Input.get_axis("left", "right")
	
	velocity.x = input_x * SPEED
	
	wall_jump_coyote = 0
	
	if Input.is_action_just_pressed("jump") or jump_buffer:
		velocity.y = -JUMP
		jump_released = false
		jump_coyote = 0
	else:
		jump_coyote = 1


func movement_on_wall(delta: float) -> void:
	var input_x := Input.get_axis("left", "right")
	var wall_normal := get_wall_normal()
	wall_normal_coyote = wall_normal
	
	velocity.x = input_x * SPEED
	
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
		velocity = Vector2(wall_normal.x, -1.0).normalized() * JUMP
		wall_jump_effect = 1.0
		last_wall_jump_dir = wall_normal.x
		jump_released = false
		wall_jump_coyote = 0
	else:
		wall_jump_coyote = 2


func movement_ascending(delta: float) -> void:
	var input_x := Input.get_axis("left", "right")
	
	var target_x_vel: float = lerpf(input_x * SPEED, velocity.x, wall_jump_effect)
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
	else:
		jump_buffer = 0


func movement_falling(delta: float) -> void:
	var input_x := Input.get_axis("left", "right")
	
	var target_x_vel: float = lerpf(input_x * SPEED, velocity.x, wall_jump_effect)
	velocity.x = lerpf(velocity.x, target_x_vel, 0.3)
	velocity += get_gravity() * delta * GRAV
	
	if Input.is_action_just_pressed("jump"):
		jump_buffer = JUMP_BUFFER
	else:
		jump_buffer = 0


func movement_floor_coyote(delta: float) -> void:
	var input_x := Input.get_axis("left", "right")
	
	velocity.x = input_x * SPEED
	
	if Input.is_action_just_pressed("jump") or jump_buffer:
		velocity.y = -JUMP
		jump_released = false
		jump_coyote = 0


func movement_wall_coyote(delta: float) -> void:
	var input_x := Input.get_axis("left", "right")
	
	velocity.x = input_x * SPEED
	
	if Input.is_action_just_pressed("jump") or jump_buffer:
		velocity = Vector2(wall_normal_coyote.x, -1.0).normalized() * JUMP
		wall_jump_effect = 1.0
		last_wall_jump_dir = wall_normal_coyote.x
		jump_released = false
		wall_jump_coyote = 0


func _physics_process(delta: float) -> void:
	#var input_x := Input.get_axis("left", "right")
	#
	#if jump_buffer:
		#jump_buffer -= 1
	#if wall_jump_effect:
		#wall_jump_effect -= delta * 1.5
	#if wall_jump_coyote:
		#wall_jump_coyote -= 1
	#if jump_coyote:
		#jump_coyote -= 1
	#if not is_on_floor():
		#if is_on_wall():
			#var wall_normal := get_wall_normal()
			#wall_normal_coyote = wall_normal
			#if (signf(input_x) != signf(wall_normal.x) and signf(input_x)) or wall_jump_coyote:
				#if velocity.y > 0.0:
					#velocity += get_gravity() * delta * 0.1
				#else:
					#velocity += get_gravity() * delta
				#wall_jump_coyote = 8
				#if Input.is_action_just_pressed("jump") or jump_buffer > 0:
					#velocity.y = minf(velocity.y, 0.0)
					#velocity += Vector2(wall_normal.x, -1.0).normalized() * JUMP
					#wall_jump_effect = 1.0
					#last_wall_jump_dir = wall_normal.x
					#wall_jump_coyote = 0
					#jump_coyote = 0
					#jump_buffer = 0
			#else:
				#if wall_jump_coyote:
					#velocity += get_gravity() * delta
					#if Input.is_action_just_pressed("jump") or jump_buffer > 0:
						#velocity.y = minf(velocity.y, 0.0)
						#velocity += Vector2(wall_normal.x, -1.0).normalized() * JUMP
						#wall_jump_effect = 1.0
						#last_wall_jump_dir = wall_normal.x
						#wall_jump_coyote = 0
						#jump_coyote = 0
						#jump_buffer = 0
				#else:
					#velocity += get_gravity() * delta
		#else:
			#if jump_coyote:
				#if Input.is_action_just_pressed("jump") or jump_buffer > 0:
					#velocity.y -= JUMP
					#jump_buffer = 0
					#jump_coyote = 0
					#wall_jump_coyote = 0
			#else:
				#if wall_jump_coyote:
					#if Input.is_action_just_pressed("jump") or jump_buffer > 0:
						#velocity.y = minf(velocity.y, 0.0)
						#velocity += Vector2(wall_normal_coyote.x, -1.0).normalized() * JUMP
						#wall_jump_effect = 1.0
						#last_wall_jump_dir = wall_normal_coyote.x
						#wall_jump_coyote = 0
						#jump_coyote = 0
						#jump_buffer = 0
				#else:
					#if Input.is_action_just_pressed("jump"):
						#jump_buffer = 6
				#velocity += get_gravity() * delta
	#else:
		#wall_jump_coyote = 0
		#jump_coyote = 3
		#if Input.is_action_just_pressed("jump") or jump_buffer > 0:
			#velocity.y -= JUMP
			#jump_buffer = 0
			#jump_coyote = 0
	#
	#if input_x:
		#if wall_jump_effect:
			#velocity.x = lerpf(input_x * SPEED, velocity.x, wall_jump_effect)
		#else:
			#if not is_on_floor():
				#velocity.x = lerpf(velocity.x, input_x * SPEED, 0.2)
			#else:
				#velocity.x = input_x * SPEED
	#else:
		#if wall_jump_effect:
			#velocity.x = lerpf(0.0, velocity.x, wall_jump_effect)
		#else:
			#velocity.x = 0.0
	
	
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
	
	move_and_slide()
	
	state_last_frame = state
	
	if is_on_floor():
		state = States.ON_FLOOR
	elif is_on_wall():
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
		wall_jump_effect -= delta * 1.5
	if jump_coyote:
		jump_coyote -= 1
	if wall_jump_coyote:
		wall_jump_coyote -= 1
	if jump_buffer:
		jump_buffer -= 1
