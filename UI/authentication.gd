extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	Firebase.Auth.login_succeeded.connect(on_login_succeeded)
	Firebase.Auth.signup_succeeded.connect(on_signup_succeeded)
	Firebase.Auth.login_failed.connect(on_login_failed)
	Firebase.Auth.signup_failed.connect(on_signup_failed)
	
	if Firebase.Auth.check_auth_file():
		%statelabel.text = "Logged in"
		get_tree().change_scene_to_file("res://UI/main_menu.tscn")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_login_pressed():
	var email = %EmailLineEdit.text
	var password =%PasswordLineEdit.text 
	Firebase.Auth.login_with_email_and_password(email,password)
	%statelabel.text = "Logging in"

func _on_signup_pressed():
	var email = %EmailLineEdit.text
	var password =%PasswordLineEdit.text 
	Firebase.Auth.signup_with_email_and_password(email,password)
	%statelabel.text = "Signing up"

func on_login_succeeded(auth):
	print(auth)
	%statelabel.text = "Login success!"
	Firebase.Auth.save_auth(auth)
	Firebase.Auth.load_auth()
	get_tree().change_scene_to_file("res://UI/main_menu.tscn")
	
func on_signup_succeeded(auth):
	print(auth)
	%statelabel.text = "Signup sucess!"
	Firebase.Auth.save_auth(auth)
	Firebase.Auth.load_auth()
	get_tree().change_scene_to_file("res://UI/main_menu.tscn")
	
func on_login_failed(error_code,message):
	print(error_code)
	print(message)
	%statelabel.text = "Login failed. Error: %s" % message
	
func on_signup_failed(error_code,message):
	print(error_code)
	print(message)
	%statelabel.text = "Signup failed. Error: %s" % message


func _on_quit_pressed():
	get_tree().quit()
