extends Node

#handles saving processes
var current_save: SaveGame
var current_slot: int 

#used to differentiate between the different save slots
func get_save_path(slot: int) -> String:
		return "user://save_slot_%d.tres" % slot

#get the path, save using the built in process, then doible check the save was successful and where
func save_game(slot: int, data: SaveGame) -> void:
	var path := get_save_path(slot)
	var confirmation = ResourceSaver.save(data, path)
	#debug check
	if confirmation != OK:
		push_error("Failed to save slot %d" % slot)
	else:
		print("Saved successfully to slot %d" % slot)

#load the game based on which save slot is selected
func load_game(slot: int) -> SaveGame:
	current_slot = slot
	var path := get_save_path(slot)
	#if the file exists load it, if not return so it can start a new save
	if FileAccess.file_exists(path):
		current_save = ResourceLoader.load(path) as SaveGame
		return current_save
	return null

#goes through removal items and removes them from overall world
#so that the player can't "go back in time" and double up on items by accident 
func should_item_be_removed(item_id: String) -> bool:
	if current_save == null:
		return false
	return item_id in current_save.collected_items
