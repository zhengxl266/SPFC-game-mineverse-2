extends HBoxContainer

@onready var inv: Inv = preload("res://inventory/playerinv.tres")
@onready var slots: Array = get_children()

func _ready():
	inv.update.connect(update_slots)
	update_slots()

func update_slots():
	for i in range(min(4, slots.size())): 
		var slot_button = slots[i]
		slot_button.slot_index = i
		slot_button.inv = inv
		slot_button.update_to_slot(inv.slots[i])


func on_inventory_updated():
	update_slots()
