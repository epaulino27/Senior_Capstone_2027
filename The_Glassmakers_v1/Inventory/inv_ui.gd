extends Control

#get/set variables to be used later
@export var inv: Inv
@onready var slots: Array = $NinePatchRect/GridContainer.get_children()
var is_open = false

#on start update all slots using helper function
func _ready():
	inv.update.connect(update_slots)
	update_slots()
	close() 

#helper function, goes through each slot and runs update function from the slot ui so everythings visually up to date
func update_slots():
	for i in range(min(inv.slots.size(), slots.size())):
		slots[i].update(inv.slots[i])

#when player presses I the inventory will open/close
func _process(_delta):
	if Input.is_action_just_pressed("inventory_access"):
		if is_open:
			close()
		else:
			open()

#basic helper functions to adjust visibility & bool for opening adn closing inventory
func open():
	visible = true
	is_open = true
	
func _on_close_button_pressed():
	close()

func close():
	visible = false
	is_open = false
