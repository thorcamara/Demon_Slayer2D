extends Area2D

signal JogadorEntrou

func _ready():
	pass

func _physics_process(delta: float):
	var corpos = get_overlapping_bodies()
	
	for body in corpos:
		if body.name == "Jogador":
			emit_signal("JogadorEntrou")
			queue_free()
