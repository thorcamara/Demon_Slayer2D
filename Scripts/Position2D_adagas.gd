extends Position2D

const projetil_adaga_instancia = preload("res://Projeteis/Projetil_adaga.tscn")

export var delay = 0.5
export var direcao_position2d = -1

func _ready():
	pass


func _lancar_adaga():
	
	var adaga1 = projetil_adaga_instancia.instance()
	get_parent().add_child(adaga1)
	adaga1.rotation_degrees = -50
	print(adaga1.rotation_degrees)
	adaga1.global_position = self.global_position
	
	if sign(direcao_position2d) == 1:
		adaga1.set_direcao(1)
	else:
		adaga1.set_direcao(-1)

func _on_Armadilha_grama4_JogadorPisou():
	yield(get_tree().create_timer(delay), "timeout")
	_lancar_adaga()
