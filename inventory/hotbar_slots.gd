extends Panel

@onready var item_visuals: Sprite2D = $CenterContainer/Panel/item_display
@onready var amount_text: Label = $CenterContainer/Panel/Label
var drag_data = null
var slot_index: int
var inv: Inv

func update_to_slot(slot: InvSlot):
	print("Updating hotbar slot ", slot_index, " with item: ", slot.item, " amount: ", slot.amount)
	if slot == null or slot.item == null:
		item_visuals.visible = false
		amount_text.visible = false
		drag_data = null
	else:
		item_visuals.visible = true
		if slot.item.texture:
			item_visuals.texture = slot.item.texture
			print("Hotbar item texture set: ", slot.item.texture)
		else:
			print("Warning: hotbar slot.item.texture is null")
			item_visuals.texture = null
		
		if slot.amount > 1:
			amount_text.visible = true
			amount_text.text = str(slot.amount)
		else:
			amount_text.visible = false
		
		drag_data = {
			"item": slot.item,
			"amount": slot.amount,
			"origin_slot": slot_index,
			"is_hotbar": true  
		}

func _get_drag_data(_at_position):
	print("Get drag data called for hotbar slot. Drag data: ", drag_data)
	if drag_data:
		var preview = Control.new()
		preview.set_anchors_preset(Control.PRESET_CENTER)
		
		var texture_rect = TextureRect.new()
		texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		texture_rect.size = Vector2(32, 32)  
		texture_rect.position = -texture_rect.size / 2  
		
		if item_visuals.texture:
			texture_rect.texture = item_visuals.texture
			print("Hotbar preview texture set: ", item_visuals.texture)
		else:
			print("Warning: hotbar item_visuals.texture is null")
			var placeholder = ColorRect.new()
			placeholder.size = Vector2(32, 32)
			placeholder.color = Color(1, 0, 0, 0.5) 
			texture_rect.add_child(placeholder)

		preview.add_child(texture_rect)
		
		set_drag_preview(preview)
		print("Hotbar drag preview created")
		return drag_data
	return null

func _can_drop_data(_at_position, data):
	return data is Dictionary and data.has("item")

func _drop_data(_at_position, data):
	if inv:
		var target_slot = slot_index
		if data.get("is_hotbar", false):
			inv.move_item(data["origin_slot"], target_slot)
		else:
			inv.move_item(data["origin_slot"], target_slot)
		update_to_slot(inv.slots[target_slot])
	else:
		print("Error: Inventory is null in hotbar slot")
