extends Resource

#set a name so it's easier to reference elseware
class_name Inv
#connect to the update in the inventory ui's
signal update

#array to hold the slots
#slots to hold the item
#item to hold the name and sprite
@export var slots: Array[InvSlot]

#add an item to the inventory
func insert(item: InvItem):
	#get slot variable that we can iterate through
	var item_slots = slots.filter(func(slot):return slot.item == item)
	#check first slot, if slot is full go to next slot 
	if !item_slots.is_empty():
		item_slots[0].amount += 1
	#else if slot is empty add item to slot and adjust number of items accordingly
	else:
		var empty_slots = slots.filter(func(slot):return slot.item == null)
		if !empty_slots.is_empty():
			empty_slots[0].item = item
			empty_slots[0].amount = 1
	update.emit()
