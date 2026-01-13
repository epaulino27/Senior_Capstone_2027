extends Control

#load and define global variables for easier usage
@onready var inv: Inv =  preload("res://Inventory/player_inv.tres")
@onready var slots: Array = $NinePatchRect/GridContainer.get_children()
var is_open = false

#on start inventory is closed and refreshed
func _ready():
	inv.update.connect(update_slots)
	update_slots()
	close()	
	
#checks each slot and calls update to ensure num of items and sprite is correct
func update_slots():
	for i in range(min(inv.slots.size(), slots.size())):
		slots[i].update(inv.slots[i])

#called every frame/sec, closes and opens inventory on pressing I
func _process(_delta):
	if Input.is_action_just_pressed("I"):
		if is_open:
			close()
		else:
			open()
			
#helper functions

func open():
	visible = true
	is_open = true
	
func _on_close_button_pressed():
	close()

func close():
	visible = false
	is_open = false
