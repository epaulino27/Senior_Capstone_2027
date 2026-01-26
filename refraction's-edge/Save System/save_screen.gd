extends Node2D

var save_slot : int = 0

#buttons that define which save slot to use
func _on_button_1_pressed() -> void:
	SaveScreen.save_slot = 1
	load_and_go()

func _on_button_2_pressed() -> void:
	SaveScreen.save_slot = 2
	load_and_go()

func _on_button_3_pressed() -> void:
	SaveScreen.save_slot = 3
	load_and_go()

#helper function to load existing file, make new file, and switch scenes
func load_and_go():
	#get what game info, if any, is available
	var data = SaveManager.load_game(SaveScreen.save_slot)

	# If no save exists, create a new one
	if data == null:
		SaveManager.current_save = SaveGame.new()
		SaveManager.current_slot = SaveScreen.save_slot
		get_tree().change_scene_to_file("res://Scenes/level_1.tscn")
		return

	# otherwise load the existing save
	SaveManager.current_save = data
	SaveManager.current_slot = SaveScreen.save_slot

	# fallback for missing or empty level
	#note: here due to a issue I was having in debugging, should be cleared up when more levels are put in place
	var level = data.current_level
	level = "res://Scenes/level_1.tscn"
	
	#switch to the next scene
	get_tree().change_scene_to_file(level)
