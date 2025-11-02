extends CharacterBody3D

@export var camera: Camera3D
@export var move_speed: float = 5.0
@export var jump_force: float = 10.0
@export var sprint_speed: float = 8.0
@export var max_stamina: float = 100.0
@export var stamina: float = max_stamina
@export var stamina_regen_rate: float = 10.0
@onready var player: CharacterBody3D = $"."
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
@onready var rotation_offset: Marker3D = $RotationOffset
@onready var sprite_3d: Sprite3D = $RotationOffset/Sprite3D
@onready var camera_3d: Camera3D = $RotationOffset/Sprite3D/Camera3D
var camera_offset: Vector3 = Vector3.ZERO

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("exit"):
		get_tree().quit()

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	# Make camera ignore parent's rotation and follow position with a fixed offset
	camera_3d.top_level = true
	camera_offset = camera_3d.global_position - global_position
	# Keep sprite facing the camera horizontally (no yaw inheritance)
	sprite_3d.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y

func _process(delta: float) -> void:
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
	var is_sprinting = is_moving and Input.is_action_pressed("move_sprint") and stamina > 0.0
	var speed = sprint_speed if is_sprinting else move_speed

	if is_sprinting:
		stamina = max(stamina - stamina_regen_rate * delta, 0.0)
	else:
		stamina = min(stamina + stamina_regen_rate * delta, max_stamina)

	if direction != Vector3.ZERO:
		rotation.y = lerp_angle(rotation.y, atan2(direction.x, direction.z), 0.1)

	velocity.x = direction.x * speed
	velocity.z = direction.z * speed

	move_and_slide()

	# Keep camera fixed in orientation; only follow player position
	camera_3d.global_position = global_position + camera_offset
