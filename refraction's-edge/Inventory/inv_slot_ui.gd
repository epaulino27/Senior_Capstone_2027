extends Panel

#set variables for later processes
@onready var item_visuals: Sprite2D = $CenterContainer/Panel/item_display
@onready var amount_text: Label = $CenterContainer/Panel/number

#update the visual slot aspects of the inventory
#if a sprite is visible and how many of that item the player has
func update(slot: InvSlot):
	if !slot.item:
		item_visuals.visible = false
		amount_text.visible = false
	else:
		item_visuals.visible = true
		item_visuals.texture = slot.item.texture
		if slot.amount > 1:
			amount_text.visible = true
		amount_text.text = str(slot.amount)
