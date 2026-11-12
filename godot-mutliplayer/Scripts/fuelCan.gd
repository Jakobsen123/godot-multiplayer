extends Node3D

@onready var player = get_tree().current_scene.get_node("Player")



func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		player.fuel = 150
		var newZ = randi_range(-20, 20)
		var newX = randi_range(-20, 20)
		var newY = randi_range(0, 10)
		
		global_position = Vector3(newX, newY, newZ)

func _process(delta: float) -> void:
	rotate_y(0.05)
