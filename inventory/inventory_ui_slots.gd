extends Panel

@onready var item_visuals: Sprite2D = $CenterContainer/Panel/item_display
@onready var amount_text: Label = $CenterContainer/Panel/Label
var drag_data = null
var slot_index: int
var inv: Inv

func update(slot: InvSlot, index: int, inventory: Inv):
	print("Updating slot ", index, " with item: ", slot.item, " amount: ", slot.amount)
	slot_index = index
	inv = inventory
	if slot == null or slot.item == null:
		item_visuals.visible = false
		amount_text.visible = false
		drag_data = null
	else:
		item_visuals.visible = true
		if slot.item.texture:
			item_visuals.texture = slot.item.texture
			print("Item texture set: ", slot.item.texture)
		else:
			print("Warning: slot.item.texture is null")
			item_visuals.texture = null
		
		if slot.amount > 1:
			amount_text.visible = true
			amount_text.text = str(slot.amount)
		else:
			amount_text.visible = false
		
		drag_data = {
			"item": slot.item,
			"amount": slot.amount,
			"origin_slot": slot_index
		}

func _get_drag_data(at_position):
	print("Get drag data called. Drag data: ", drag_data)
	if drag_data:
		var preview = Control.new()
		preview.set_anchors_preset(Control.PRESET_CENTER)
		
		var texture_rect = TextureRect.new()
		texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		texture_rect.size = Vector2(32, 32) 
		texture_rect.position = -texture_rect.size / 2  
		
		if item_visuals.texture:
			texture_rect.texture = item_visuals.texture
			print("Preview texture set: ", item_visuals.texture)
		
		preview.add_child(texture_rect)
		
		return drag_data
	return null

func _can_drop_data(at_position, data):
	print("Can drop data called. Data: ", data)
	if data is Dictionary and data.has("item"):
		var item = data["item"]
		return inv.slots[slot_index].slot_type == 0 or inv.slots[slot_index].slot_type == item.slot_type
	return false

func _drop_data(at_position, data):
	print("Drop data called. Data: ", data)
	if inv:
		print("Moving item from slot ", data["origin_slot"], " to slot ", slot_index)
		inv.move_item(data["origin_slot"], slot_index)
	else:
		print("Error: Inventory is null")


