extends "res://Scripts/item_base.gd"

func _ready():
	super._ready()
	
	pickup_lines = [
		"You've found a worker!",
		"Put him in your inventory?"
	]
	
	if item == null:
		push_error("Item NPC has no InvItem assigned!")
		return

	if SaveManager.should_item_be_removed(world_id):
		queue_free()
		return
