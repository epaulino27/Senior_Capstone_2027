extends "res://Scripts/item_base.gd"

func _ready():
	super._ready()

	if item == null:
		push_error("Item NPC has no InvItem assigned!")
		return

	if SaveManager.should_item_be_removed(item.name):
		queue_free()
		return
