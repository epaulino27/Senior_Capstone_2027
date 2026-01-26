extends StaticBody2D

#set-up variables
@export var item: InvItem
@export var message: Node
@export var item_name: String
var player = null

#don't want you to be able to pick up the item until you enter its collision shape
func _ready() -> void:
	item.name = item_name
	print("Instance name:", item_name)
	print("Resource name BEFORE override:", item.name)
	if SaveManager.should_item_be_removed(item.name):
		queue_free()
	message.visible = false

#once player is in range show pop up 
func _on_interactable_area_body_entered(body):
	if body.has_method("player"):
		player = body
		message.visible = true

#helper methods to perform button actions
func player_collect():
	player.collect(item)
	# Update collected items list
	SaveManager.current_save.collected_items.append(item.name)
	# Save the player's ACTUAL inventory
	SaveManager.current_save.player_inventory = player.inv.duplicate(true)
	# Write to disk
	SaveManager.save_game(SaveManager.current_slot, SaveManager.current_save)
	queue_free()

func _on_yes_pressed() -> void:
	player_collect()
	self.queue_free()

func _on_no_pressed() -> void:
	message.visible = false
