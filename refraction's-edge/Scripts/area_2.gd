extends Area2D
#meant to simulate entering a room/tunnel/etc.
#note: used seperate scripts for area 1 and 2 since using the same script
#was causing unpredictable results

#define variables
@onready var cover = $infront

#when the player enters this area make the cover not visible
func _on_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		cover.visible = false

#when the player exits this area make the cover visible again
func _on_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		cover.visible = true
