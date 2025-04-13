extends CharacterBody3D

const WALK_SPEED = 5.0
const SPRINT_SPEED = 8.0
const JUMP_VELOCITY = 4.5
const SENSITIVITY = 0.010

const BOB_FREQ = 2.0
const BOB_AMP = 0.08

var gravity = 9.8
var speed = WALK_SPEED
var t_bob = 0.0

@onready var head = $Head
@onready var camera = $Head/Camera3D

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		# Rotate horizontally (left/right)
		var new_rotation_y = head.rotation_degrees.y - event.relative.x * SENSITIVITY
		head.rotation_degrees.y = clamp(new_rotation_y, -100, 100)

		# Rotate vertically (up/down)
		var new_rotation_x = camera.rotation_degrees.x - event.relative.y * SENSITIVITY
		camera.rotation_degrees.x = clamp(new_rotation_x, -40, 60)

func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0
		if Input.is_action_just_pressed("ui_accept"):
			velocity.y = JUMP_VELOCITY

	# Sprint toggle
	speed = SPRINT_SPEED if Input.is_action_pressed("sprint") else WALK_SPEED

	# Movement direction
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction = Vector3(input_dir.x, 0, input_dir.y).rotated(Vector3.UP, head.global_rotation.y)

	# Smooth velocity
	if is_on_floor():
		if direction != Vector3.ZERO:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x, 0.0, delta * 7.0)
			velocity.z = lerp(velocity.z, 0.0, delta * 7.0)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 3.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 3.0)

	# Headbob
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)

	# Move
	move_and_slide()

func _headbob(time: float) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos
