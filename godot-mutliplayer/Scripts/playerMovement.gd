extends CharacterBody3D

var isLocalPlayer = true

const SPEED = 7.0
const JUMP_VELOCITY = 4.5
const jetPackVelocity = 4.5
const mouseSens = 0.003

var fuel = 100

@onready var camera = $Camera3D
@onready var fuelBar = $FuelBar

var targetPos: Vector3
var targetRotation: float = 0.0

var sendTimer = 0.0

func _ready() -> void:
	if isLocalPlayer:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	else:
		camera.current = false

func _unhandled_input(event: InputEvent) -> void:
	if not isLocalPlayer:
		return
	
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouseSens)
		camera.rotate_x(-event.relative.y * mouseSens)
		camera.rotation.x = clamp(camera.rotation.x, -1.5, 1.5)

func _physics_process(delta: float) -> void:
	if isLocalPlayer:
		
		if $Camera3D/RayCast3D.is_colliding():
			var target = $Camera3D/RayCast3D.get_collider()
			print(target)
		
		
		fuelBar.value = fuel
		$FuelLabel.text = str(fuel)
		
		if fuelBar.value <= 35:
			$lowFuelLabel.show()
		else:
			$lowFuelLabel.hide()
		
		if fuelBar.value >= 70:
			fuelBar.tint_progress = Color.LIME_GREEN
		elif fuelBar.value <= 70 and fuelBar.value >= 35:
			fuelBar.tint_progress = Color.ORANGE
		else:
			fuelBar.tint_progress = Color.RED
	
		# Add the gravity.
		if not is_on_floor():
			velocity += get_gravity() * delta

		if Input.is_action_just_pressed("restart"):
			get_tree().reload_current_scene()
		
		# Handle jump.
		if Input.is_action_pressed("ui_accept") and fuel > 0:
			velocity.y = jetPackVelocity
			$JetPack/CPUParticles3D.emitting = true
			fuel -= 1
		elif Input.is_action_just_pressed("ui_accept") and fuel <= 0 and is_on_floor():
			velocity.y = JUMP_VELOCITY
		else:
			$JetPack/CPUParticles3D.emitting = false
		
		if Input.is_action_just_pressed("escape"):
			get_tree().quit()
			queue_free()
			
		if Input.is_action_just_pressed("reset_pos"):
			position = Vector3(0,0,0)

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
			Network.send_player_data("update_player",Global.playerUsername, global_position, rotation.y)
	
		move_and_slide()
	

func _process(delta):
	if not isLocalPlayer:
		global_position = global_position.lerp(targetPos, 10.0 * delta)
		rotation.y = lerp_angle(rotation.y, targetRotation, 10.0 * delta)
