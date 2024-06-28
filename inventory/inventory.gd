extends Resource
class_name Inv

signal update

@export var slots: Array[InvSlot]

func insert(item: InvItem):
	print("Inserting item into inventory: ", item)
	var itemslots = slots.filter(func(slot): return slot.item == item and slot.amount < item.max_stack_size)
	if !itemslots.is_empty():
		itemslots[0].amount += 1
	else:
		var emptyslots = slots.filter(func(slot): return slot.item == null)
		if !emptyslots.is_empty():
			emptyslots[0].item = item
			emptyslots[0].amount = 1
		else:
			print("Inventory is full, cannot insert item: ", item)
			return false
	update.emit()
	return true

func move_item(from_slot: int, to_slot: int):
	var from_item = slots[from_slot]
	var to_item = slots[to_slot]
	
	if from_item.item == null:
		return false
	
	if to_item.item == null:
		slots[to_slot] = from_item.duplicate()
		slots[from_slot] = InvSlot.new()
	elif from_item.item == to_item.item and to_item.item.stackable:
		var total_amount = from_item.amount + to_item.amount
		var max_stack = to_item.item.max_stack_size
		if total_amount <= max_stack:
			to_item.amount = total_amount
			slots[from_slot] = InvSlot.new()
		else:
			to_item.amount = max_stack
			from_item.amount = total_amount - max_stack
	else:
		var temp = slots[to_slot]
		slots[to_slot] = from_item.duplicate()
		slots[from_slot] = temp
	
	update.emit()
	return true

func remove_item(slot_index: int, amount: int = 1):
	if slot_index < 0 or slot_index >= slots.size():
		return false
	
	var slot = slots[slot_index]
	if slot.item == null:
		return false
	
	if amount >= slot.amount:
		slots[slot_index] = InvSlot.new()
	else:
		slot.amount -= amount
	
	update.emit()
	return true

func get_item(slot_index: int) -> InvItem:
	if slot_index < 0 or slot_index >= slots.size():
		return null
	return slots[slot_index].item

func get_item_count(item: InvItem) -> int:
	var count = 0
	for slot in slots:
		if slot.item == item:
			count += slot.amount
	return count

func has_item(item: InvItem, amount: int = 1) -> bool:
	return get_item_count(item) >= amount

func clear():
	for i in range(slots.size()):
		slots[i] = InvSlot.new()
	update.emit()


func find_available_slot(item: InvItem) -> int:
	for i in range(slots.size()):
		if slots[i].item == null or (slots[i].item == item and slots[i].amount < item.max_stack_size):
			return i
	return -1  
