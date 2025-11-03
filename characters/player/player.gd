extends CharacterBody3D

@onready var model: Sprite3D = $RotationOffset/Model
@onready var camera: Camera3D = $RotationOffset/Model/Camera3D

@export var move_speed: float = 13.0
@export var gravity: float = 40.0

var camera_offset: Vector3 = Vector3.ZERO

# Wobble effect variables
var wobble_amplitude: float = 0.05
var wobble_speed: float = 8.0
var wobble_timer: float = 0.0

@export_category("Camera")
@export var camera_near: float = 0.05
@export var camera_size: float = 14.0
@export var camera_far: float = 4000.0
@export var camera_sprint_smooth: float = 8.0

@export_category("Stamina")
@export var max_stamina: float = 100.0
@export var stamina: float = max_stamina
@export var stamina_regen_rate: float = 10.0

# Jump animation variables
@export_category("Jump")
@export var jump_force: float = 10.0
var is_jumping: bool = false
var jump_anim_timer: float = 0.0
var jump_anim_duration: float = 0.3

# Dash mechanic variables
@export_category("Dash")
@export var dash_force: float = 30.0
@export var dash_duration: float = 0.1
@export var dash_cooldown: float = 1.0
var is_dashing: bool = false
var dash_timer: float = 0.0
var dash_cooldown_timer: float = 0.0
var dash_direction: Vector3 = Vector3.ZERO

@export_category("Sprint")
@export var double_press_threshold = 0.3
@export var sprint_speed: float = 16.0
var tap_elapsed_forward: float = 9999.0
var tap_elapsed_backward: float = 9999.0
var tap_elapsed_left: float = 9999.0
var tap_elapsed_right: float = 9999.0
var is_sprinting: bool = false

func _unhandled_input(event: InputEvent) -> void:
	#if event.is_action_pressed("exit"):
		#get_tree().quit()
	if event.is_action_pressed("exit"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	camera.top_level = true
	camera_offset = camera.global_position - global_position
	model.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y

	camera.global_position = global_position + camera_offset
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.current = true
	camera.size = camera_size
	camera.near = camera_near
	camera.far = camera_far

func _physics_process(delta: float) -> void:
	var direction = Vector3.ZERO
	if Input.is_action_pressed("move_forward"):
		direction.z -= 1
	if Input.is_action_pressed("move_backward"):
		direction.z += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_right"):
		direction.x += 1

	direction = direction.normalized()
	if direction != Vector3.ZERO:
		var cam_move = camera.global_transform.basis * direction
		cam_move.y = 0.0
		direction = cam_move.normalized()

	var is_moving = direction != Vector3.ZERO

	tap_elapsed_forward += delta
	tap_elapsed_backward += delta
	tap_elapsed_left += delta
	tap_elapsed_right += delta
	if Input.is_action_just_pressed("move_forward"):
		if tap_elapsed_forward <= double_press_threshold:
			is_sprinting = true
		tap_elapsed_forward = 0.0
	if Input.is_action_just_pressed("move_backward"):
		if tap_elapsed_backward <= double_press_threshold:
			is_sprinting = true
		tap_elapsed_backward = 0.0
	if Input.is_action_just_pressed("move_left"):
		if tap_elapsed_left <= double_press_threshold:
			is_sprinting = true
		tap_elapsed_left = 0.0
	if Input.is_action_just_pressed("move_right"):
		if tap_elapsed_right <= double_press_threshold:
			is_sprinting = true
		tap_elapsed_right = 0.0

	var any_move_pressed = Input.is_action_pressed("move_forward") or Input.is_action_pressed("move_backward") or Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right")
	if not any_move_pressed:
		is_sprinting = false

	if is_sprinting and is_moving and stamina > 0.0:
		stamina = max(stamina - stamina_regen_rate * delta, 0.0)
	else:
		stamina = min(stamina + stamina_regen_rate * delta, max_stamina)
	if stamina <= 0.0:
		is_sprinting = false

	var speed = sprint_speed if (is_sprinting and is_moving and stamina > 0.0) else move_speed
	if dash_cooldown_timer > 0.0:
		dash_cooldown_timer -= delta

	if is_dashing:
		dash_timer -= delta
		var current_y = velocity.y
		velocity = dash_direction * dash_force
		velocity.y = current_y
		if dash_timer <= 0.0:
			is_dashing = false
			dash_cooldown_timer = dash_cooldown
	else:
		if Input.is_action_just_pressed("move_dash") and is_moving and dash_cooldown_timer <= 0.0:
			is_dashing = true
			dash_timer = dash_duration

			var cam_space = camera.global_transform.basis * direction
			cam_space.y = 0.0
			if cam_space.length() == 0:
				dash_direction = -global_transform.basis.z
			else:
				dash_direction = cam_space.normalized()

			# set velocity for the dash (keep existing y)
			var cur_y = velocity.y
			velocity = dash_direction * dash_force
			velocity.y = cur_y

	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		if Input.is_action_just_pressed("move_jump"):
			velocity.y = jump_force
			is_jumping = true
			jump_anim_timer = 0.0
		else:
			is_jumping = false

	if not is_dashing:
		if direction != Vector3.ZERO:
			rotation.y = lerp_angle(rotation.y, atan2(direction.x, direction.z), 0.1)
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = 0.0
			velocity.z = 0.0

	move_and_slide()
	camera.global_position = global_position + camera_offset
	var cam_target_size = camera_size + 5.0 if (is_sprinting and is_moving and stamina > 0.0) else camera_size
	var cam_target_far = camera_far + 5.0 if (is_sprinting and is_moving and stamina > 0.0) else camera_far
	var cam_lerp_w = min(1.0, camera_sprint_smooth * delta)
	camera.size = lerp(camera.size, cam_target_size, cam_lerp_w)
	camera.far = lerp(camera.far, cam_target_far, cam_lerp_w)

	if is_moving and is_on_floor() and not is_dashing:
		wobble_timer += delta * wobble_speed
		var wobble_y = sin(wobble_timer) * wobble_amplitude
		var wobble_x = cos(wobble_timer * 0.5) * wobble_amplitude * 0.5
		model.position.y = wobble_y
		model.position.x = wobble_x
	else:
		model.position.y = lerp(model.position.y, 0.0, delta * 10.0)
		model.position.x = lerp(model.position.x, 0.0, delta * 10.0)

	if is_jumping:
		jump_anim_timer += delta
		var t = jump_anim_timer / jump_anim_duration
		if t < 0.5:
			model.scale = Vector3(1.0, 1.2 - t * 0.4, 1.0)
		else:
			model.scale = Vector3(1.0, 0.9 + sin(t * PI) * 0.1, 1.0)
	else:
		model.scale = model.scale.lerp(Vector3.ONE, delta * 10.0)
