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
var isBoosting := false

@onready var camera = $Camera3D
@onready var fuelBar = $UI/FuelBar
@onready var dashCooldown = $UI/DashCooldown
@onready var jetParticles = $JetPack/CPUParticles3D

var cooldown = 2.0
var cooldownTimer = 0.0
var dashTimer = 0.0

var sendTimer = 0.0

# --- Remote player interpolation ---
const INTERP_DELAY := 150.0   # ms behind real time; raise if remote players stutter
var snapshots: Array = []     # [{t, pos, rot}] in local time
var clock_offset := INF


func _ready() -> void:
	if isLocalPlayer:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	else:
		camera.current = false
		$UI.hide()


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

	if is_on_floor() and fuel <= 75:
		fuel += 0.05

	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()

	# Jetpack / jump
	if Input.is_action_pressed("ui_accept") and fuel > 0:
		velocity.y = jetPackVelocity
		fuel = max(fuel - 1, 0)
		isBoosting = true
	elif Input.is_action_just_pressed("ui_accept") and fuel <= 0 and is_on_floor():
		velocity.y = JUMP_VELOCITY
		isBoosting = false
	else:
		isBoosting = false
	jetParticles.emitting = isBoosting

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
		Network.send_player_data("update_player", Global.playerUsername, global_position, rotation.y, isBoosting)


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
	$UI/FuelLabel.text = str(fuelBar.value).split('.')[0]

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


# Called by playerManager for remote players
func add_snapshot(sender_t: float, pos: Vector3, rot: float) -> void:
	var now := float(Time.get_ticks_msec())
	# Map the sender's clock to ours, using the fastest packet seen so far
	clock_offset = min(clock_offset, now - sender_t)
	var local_t := sender_t + clock_offset
	if not snapshots.is_empty() and local_t <= snapshots[-1].t:
		return   # old or out-of-order packet
	snapshots.append({"t": local_t, "pos": pos, "rot": rot})
	if snapshots.size() > 30:
		snapshots.pop_front()


# Called by playerManager for remote players
func set_boosting(on: bool) -> void:
	isBoosting = on
	jetParticles.emitting = on


func _process(delta: float) -> void:
	if isLocalPlayer or snapshots.is_empty():
		return

	var render_t: float = float(Time.get_ticks_msec()) - INTERP_DELAY

	# Drop snapshots we've already passed
	while snapshots.size() >= 2 and snapshots[1].t <= render_t:
		snapshots.pop_front()

	if snapshots.size() >= 2 and snapshots[0].t <= render_t:
		# Normal case: glide between the two snapshots around render_t
		var a = snapshots[0]
		var b = snapshots[1]
		var w = clamp((render_t - a.t) / (b.t - a.t), 0.0, 1.0)
		global_position = a.pos.lerp(b.pos, w)
		rotation.y = lerp_angle(a.rot, b.rot, w)
	else:
		# Waiting for data (start-up or packet loss): ease toward what we have
		var target = snapshots[0] if snapshots[0].t > render_t else snapshots[-1]
		global_position = global_position.lerp(target.pos, 10.0 * delta)
		rotation.y = lerp_angle(rotation.y, target.rot, 10.0 * delta)
