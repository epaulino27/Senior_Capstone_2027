extends StaticBody2D

#set-up variables
@export var item: InvItem
@export var message: Node
var player = null

#don't want you to be able to pick up the item until you enter its collision shape
func _ready() -> void:
	print("Checking item:", item.name)
	print("Save contains:", SaveManager.current_save.collected_items)
	message.visible = false
	if SaveManager.should_item_be_removed(item.name):
		queue_free()

#once player is in range show pop up 
func _on_interactable_area_body_entered(body):
	if body.has_method("player"):
		player = body
		message.visible = true

#helper methods to perform button actions
func player_collect():
	player.collect(item)

	# update collected list
	SaveManager.current_save.collected_items.append(item.name)
	# save the inventory in game
	SaveManager.current_save.player_inventory = player.inv.duplicate(true)
	# save it to the save inventory
	SaveManager.save_game(SaveManager.current_slot, SaveManager.current_save)
	queue_free()

func _on_button_pressed() -> void:
	message.visible = false

func _on_yes_pressed() -> void:
	player_collect()

func _on_no_pressed() -> void:
	message.visible = false
