extends Node2D
#meant to simulate entering a room/tunnel/etc. similar to hidden rooms in the origional Sonic Wii

#variables
@onready var cover = $infront

#turn translucent when the player enters the area
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		cover.modulate.a = 0.5

#turn back to solid on player exit
func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		cover.visible = true
