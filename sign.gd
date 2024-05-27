extends Area2D
var showchatbox = false
var showInteractionLabel = false
var dialogLabel : Label
var chatbox : TextureRect

func _ready():
	chatbox = $chatbox
	dialogLabel = $chatbox/DialogLabel
	dialogLabel.visible = false
	chatbox.visible = false

func _process(delta):
	$Label.visible = showInteractionLabel
	if showInteractionLabel && Input.is_action_just_pressed("interact"):
		togglechatbox()

func _on_body_entered(body):
	if body is Player: showInteractionLabel = true
	dialogLabel.visible = false
	chatbox.visible = false

func _on_body_exited(body):
	if body is Player: showInteractionLabel = false
	dialogLabel.visible = false
	chatbox.visible = false

func togglechatbox():
	showchatbox = !showchatbox
	dialogLabel.visible = showchatbox
	chatbox.visible = showchatbox
	dialogLabel.text = "WASD or arrow keys to move \n Press 'Q' to attack"
