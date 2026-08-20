extends StaticBody2D

var solid: bool = false

#one direction interactable platform
#triggers when landed on from the top but allows interaction from teh side or bottom to pass through seamlessly
func update_platform(player: CharacterBody2D) -> void:
	var shape: CapsuleShape2D = player.get_node("CollisionShape2D").shape

	var player_bottom: float = player.global_position.y + (shape.height * 0.5) + shape.radius
	var platform_top: float = global_position.y - $CollisionShape2D.shape.extents.y

	var above: bool = player_bottom <= platform_top

	if above:
		_set_solid(true)
	else:
		_set_solid(false)

func _set_solid(state: bool) -> void:
	solid = state
	collision_layer = 1 if state else 0
