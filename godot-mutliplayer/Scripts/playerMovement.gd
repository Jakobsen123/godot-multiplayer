extends CharacterBody3D

var isLocalPlayer = true

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const mouseSens = 0.003

@onready var camera = $Camera3D

var targetPos: Vector3

var sendTimer = 0.0

func _ready() -> void:
	if isLocalPlayer:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	else:
		camera.current = false

func _unhandled_input(event: InputEvent) -> void:
	if isLocalPlayer:
		return
	
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouseSens)
		camera.rotate_x(-event.relative.y * mouseSens)
		camera.rotation.x = clamp(camera.rotation.x, -1.5, 1.5)

func _physics_process(delta: float) -> void:
	
	if isLocalPlayer:
	
		# Add the gravity.
		if not is_on_floor():
			velocity += get_gravity() * delta

		# Handle jump.
		if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			velocity.y = JUMP_VELOCITY
		
		if Input.is_action_just_pressed("escape"):
			get_tree().quit()

		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var input_dir := Input.get_vector("moveLeft", "moveRight", "moveForward", "moveBackward")
		var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)
		
		sendTimer += delta
		
		if sendTimer >= 0.05:
			sendTimer = 0.0
			Network.send_player_data("Mattebassen", global_position)
	
	move_and_slide()
	

func _process(delta):
	if not isLocalPlayer:
		global_position = global_position.lerp(
			targetPos,
			10.0 * delta
		)
