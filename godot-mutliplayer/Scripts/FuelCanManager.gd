extends Node

const MAX_FUEL_CANS: int = 4
var FUEL_CAN_OBJECTS = []
var fuel_can_template = get_tree().current_scene.get_node("fuelCan")

func SpawnFuelCan(pos: Vector3):
	var can = fuel_can_template.duplicate()
	can.position = pos

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(MAX_FUEL_CANS):
		SpawnFuelCan({})


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
