extends Area2D


func _ready():
	pass # Replace with function body.


func _on_Fall_zone_body_entered(body):
	get_tree().reload_current_scene()
