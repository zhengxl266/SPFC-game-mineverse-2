extends StaticBody2D

@export var item: InvItem
@export var hp_potion_scene: PackedScene
var player = null


func _on_interactable_area_body_entered(body):
	if body.has_method("collect"):
		print("Collecting item: ", item)
		player = body
		player.collect(item)
		await get_tree().create_timer(0.1).timeout
		self.queue_free()


