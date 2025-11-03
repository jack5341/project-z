extends CharacterBody3D

@export var camera: Camera3D
@export var move_speed: float = 5.0
@export var jump_force: float = 10.0
@export var sprint_speed: float = 8.0
@export var max_stamina: float = 100.0
@export var stamina: float = max_stamina
@export var stamina_regen_rate: float = 10.0
@export var gravity: float = 25.0

@onready var player: CharacterBody3D = $"." 
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
@onready var rotation_offset: Marker3D = $RotationOffset
@onready var sprite_3d: Sprite3D = $RotationOffset/Sprite3D
@onready var camera_3d: Camera3D = $RotationOffset/Sprite3D/Camera3D

var camera_offset: Vector3 = Vector3.ZERO

# Wobble effect variables
var wobble_amplitude: float = 0.05
var wobble_speed: float = 8.0
var wobble_timer: float = 0.0

# Jump animation variables
var is_jumping: bool = false
var jump_anim_timer: float = 0.0
var jump_anim_duration: float = 0.3

# Dash mechanic variables
var is_dashing: bool = false
@export var dash_force: float = 20.0
@export var dash_duration: float = 0.2
@export var dash_cooldown: float = 1.0
var dash_timer: float = 0.0
var dash_cooldown_timer: float = 0.0
var dash_direction: Vector3 = Vector3.ZERO

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("exit"):
		get_tree().quit()

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	camera_3d.top_level = true
	camera_offset = camera_3d.global_position - global_position
	sprite_3d.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y

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

	var is_moving = direction != Vector3.ZERO

	# --- Sprint mechanic (commented out) ---
	# var is_sprinting = is_moving and Input.is_action_pressed("move_sprint") and stamina > 0.0
	# var speed = sprint_speed if is_sprinting else move_speed
	# if is_sprinting:
	#     stamina = max(stamina - stamina_regen_rate * delta, 0.0)
	# else:
	#     stamina = min(stamina + stamina_regen_rate * delta, max_stamina)
	# ---------------------------------------

	var speed = move_speed  # Default movement speed
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

			var cam_space = camera_3d.global_transform.basis * direction
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
	camera_3d.global_position = global_position + camera_offset

	if is_moving and is_on_floor() and not is_dashing:
		wobble_timer += delta * wobble_speed
		var wobble_y = sin(wobble_timer) * wobble_amplitude
		var wobble_x = cos(wobble_timer * 0.5) * wobble_amplitude * 0.5
		sprite_3d.position.y = wobble_y
		sprite_3d.position.x = wobble_x
	else:
		sprite_3d.position.y = lerp(sprite_3d.position.y, 0.0, delta * 10.0)
		sprite_3d.position.x = lerp(sprite_3d.position.x, 0.0, delta * 10.0)

	if is_jumping:
		jump_anim_timer += delta
		var t = jump_anim_timer / jump_anim_duration
		if t < 0.5:
			sprite_3d.scale = Vector3(1.0, 1.2 - t * 0.4, 1.0)
		else:
			sprite_3d.scale = Vector3(1.0, 0.9 + sin(t * PI) * 0.1, 1.0)
	else:
		sprite_3d.scale = sprite_3d.scale.lerp(Vector3.ONE, delta * 10.0)
