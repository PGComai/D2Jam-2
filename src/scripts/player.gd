extends CharacterBody2D


const SPEED: float = 100.0
const JUMP: float = 250.0
const ACCEL: float = 0.1


var jump_buffer: int = 0
var wall_jump_effect: float = 0.0:
	set(value):
		wall_jump_effect = maxf(value, 0.0)
var last_wall_jump_dir: float = 0.0
var wall_jump_coyote: int = 0
var wall_normal_coyote: Vector2
var jump_coyote: int = 0


func _ready() -> void:
	pass


func _physics_process(delta: float) -> void:
	var input_x := Input.get_axis("left", "right")
	
	if jump_buffer:
		jump_buffer -= 1
	if wall_jump_effect:
		wall_jump_effect -= delta * 1.5
	if wall_jump_coyote:
		wall_jump_coyote -= 1
	if jump_coyote:
		jump_coyote -= 1
	if not is_on_floor():
		if is_on_wall():
			var wall_normal := get_wall_normal()
			wall_normal_coyote = wall_normal
			if (signf(input_x) != signf(wall_normal.x) and signf(input_x)) or wall_jump_coyote:
				if velocity.y > 0.0:
					velocity += get_gravity() * delta * 0.1
				else:
					velocity += get_gravity() * delta
				wall_jump_coyote = 8
				if Input.is_action_just_pressed("jump") or jump_buffer > 0:
					velocity.y = minf(velocity.y, 0.0)
					velocity += Vector2(wall_normal.x, -1.0).normalized() * JUMP
					wall_jump_effect = 1.0
					last_wall_jump_dir = wall_normal.x
					wall_jump_coyote = 0
					jump_coyote = 0
					jump_buffer = 0
			else:
				if wall_jump_coyote:
					velocity += get_gravity() * delta
					if Input.is_action_just_pressed("jump") or jump_buffer > 0:
						velocity.y = minf(velocity.y, 0.0)
						velocity += Vector2(wall_normal.x, -1.0).normalized() * JUMP
						wall_jump_effect = 1.0
						last_wall_jump_dir = wall_normal.x
						wall_jump_coyote = 0
						jump_coyote = 0
						jump_buffer = 0
				else:
					velocity += get_gravity() * delta
		else:
			if jump_coyote:
				if Input.is_action_just_pressed("jump") or jump_buffer > 0:
					velocity.y -= JUMP
					jump_buffer = 0
					jump_coyote = 0
					wall_jump_coyote = 0
			else:
				if wall_jump_coyote:
					if Input.is_action_just_pressed("jump") or jump_buffer > 0:
						velocity.y = minf(velocity.y, 0.0)
						velocity += Vector2(wall_normal_coyote.x, -1.0).normalized() * JUMP
						wall_jump_effect = 1.0
						last_wall_jump_dir = wall_normal_coyote.x
						wall_jump_coyote = 0
						jump_coyote = 0
						jump_buffer = 0
				else:
					if Input.is_action_just_pressed("jump"):
						jump_buffer = 6
				velocity += get_gravity() * delta
	else:
		wall_jump_coyote = 0
		jump_coyote = 3
		if Input.is_action_just_pressed("jump") or jump_buffer > 0:
			velocity.y -= JUMP
			jump_buffer = 0
			jump_coyote = 0
	
	if input_x:
		if wall_jump_effect:
			velocity.x = lerpf(input_x * SPEED, velocity.x, wall_jump_effect)
		else:
			if not is_on_floor():
				velocity.x = lerpf(velocity.x, input_x * SPEED, 0.2)
			else:
				velocity.x = input_x * SPEED
	else:
		if wall_jump_effect:
			velocity.x = lerpf(0.0, velocity.x, wall_jump_effect)
		else:
			velocity.x = 0.0
	
	move_and_slide()
