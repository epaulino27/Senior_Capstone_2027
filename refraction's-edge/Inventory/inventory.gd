extends Resource

#set a name so it's easier to reference elseware
class_name Inv
#connect to the update in the inventory ui
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
	
func remove(item_name: String):
	#get slot item we can interact with, thats not null and has teh same name
	var item_slots = slots.filter(func(slot): return slot.item != null and slot.item.name == item_name)
	#don't do anything if its not there
	if item_slots.is_empty():
		return  
	#adjust number amount and remove item if is there
	var slot = item_slots[0]
	slot.amount -= 1
	if slot.amount <= 0:
		slot.item = null
		slot.amount = 0
	update.emit()
	
#take name return number of that item in the inventory
func get_amount(item_name: String) -> int:
	#find slot
	var item_slots = slots.filter(func(slot): 
		return slot.item != null and slot.item.name == item_name)
	#if its empty do nothing else return teh correct amount
	if item_slots.is_empty():
		return 0  
	return item_slots[0].amount
