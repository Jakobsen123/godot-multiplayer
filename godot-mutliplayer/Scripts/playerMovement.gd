extends CharacterBody3D

var isLocalPlayer = true

var SPEED = 7.0
const NORMAL_SPEED = 7.0
const DASH_SPEED = 15.0
const DASH_DURATION = 0.3
const JUMP_VELOCITY = 4.5
const jetPackVelocity = 4.5
const mouseSens = 0.003

var fuel = 100

@onready var camera = $Camera3D
@onready var fuelBar = $UI/FuelBar
@onready var dashCooldown = $UI/DashCooldown

var cooldown = 2.0
var cooldownTimer = 0.0
var dashTimer = 0.0

var targetPos: Vector3
var targetRotation: float = 0.0

var sendTimer = 0.0


func _ready() -> void:
	if isLocalPlayer:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	else:
		camera.current = false
		$UI.hide()
		targetPos = global_position
		targetRotation = rotation.y

func takeDamage():
	get_tree().quit()

func shoot():
	var collider = $Camera3D/RayCast3D.get_collider()
	if collider != null and collider.has_method("takeDamage"):
		collider.takeDamage()

func _unhandled_input(event: InputEvent) -> void:
	if not isLocalPlayer:
		return

	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouseSens)
		camera.rotate_x(-event.relative.y * mouseSens)
		camera.rotation.x = clamp(camera.rotation.x, -1.5, 1.5)


func _physics_process(delta: float) -> void:
	if not isLocalPlayer:
		return

	handle_dash(delta)
	update_fuel_ui()

	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()
	
	if Input.is_action_just_pressed("shoot"):
		shoot()

	# Jetpack / jump
	if Input.is_action_pressed("ui_accept") and fuel > 0:
		velocity.y = jetPackVelocity
		$JetPack/CPUParticles3D.emitting = true
		fuel = max(fuel - 1, 0)
	elif Input.is_action_just_pressed("ui_accept") and fuel <= 0 and is_on_floor():
		velocity.y = JUMP_VELOCITY
	else:
		$JetPack/CPUParticles3D.emitting = false

	if Input.is_action_just_pressed("escape"):
		get_tree().quit()

	if Input.is_action_just_pressed("reset_pos"):
		position = Vector3.ZERO

	# Movement
	var input_dir := Input.get_vector("moveLeft", "moveRight", "moveForward", "moveBackward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

	# Network (after moving, so we send the newest position)
	sendTimer += delta
	if sendTimer >= 0.05:
		sendTimer = 0.0
		Network.send_player_data("update_player", Global.playerUsername, global_position, rotation.y,$JetPack/CPUParticles3D.emitting)


func handle_dash(delta: float) -> void:
	cooldownTimer = max(cooldownTimer - delta, 0.0)
	dashCooldown.value = (1.0 - cooldownTimer / cooldown) * 100

	if Input.is_action_just_pressed("shift") and fuel > 0 and cooldownTimer <= 0:
		cooldownTimer = cooldown
		dashTimer = DASH_DURATION
		fuel = max(fuel - 10, 0)

	if dashTimer > 0:
		dashTimer -= delta
		SPEED = DASH_SPEED
	else:
		SPEED = NORMAL_SPEED


func update_fuel_ui() -> void:
	fuelBar.value = fuel
	$UI/FuelLabel.text = str(fuel)

	if fuel <= 35:
		$UI/lowFuelLabel.show()
	else:
		$UI/lowFuelLabel.hide()

	if fuel >= 70:
		fuelBar.tint_progress = Color.LIME_GREEN
	elif fuel >= 35:
		fuelBar.tint_progress = Color.ORANGE
	else:
		fuelBar.tint_progress = Color.RED


func _process(delta: float) -> void:
	if not isLocalPlayer:
		global_position = global_position.lerp(targetPos, 10.0 * delta)
		rotation.y = lerp_angle(rotation.y, targetRotation, 10.0 * delta)
