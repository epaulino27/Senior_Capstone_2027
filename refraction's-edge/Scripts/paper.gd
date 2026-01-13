extends StaticBody2D

#set-up variables
@export var item: InvItem
@export var message: Node
var player = null

#don't want you to be able to pick up the item until you enter its collision shape
func _ready() -> void:
	message.visible = false

#once player is in range show pop up 
func _on_interactable_area_body_entered(body):
	if body.has_method("player"):
		player = body
		message.visible = true

#helper methods to perform button actions
func player_collect():
	player.collect(item)	

func _on_button_pressed() -> void:
	message.visible = false

func _on_yes_pressed() -> void:
	player_collect()
	self.queue_free()

func _on_no_pressed() -> void:
	message.visible = false
