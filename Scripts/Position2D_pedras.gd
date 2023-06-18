extends Position2D

const projetil_pedra_instancia = preload("res://Projeteis/Projetil_pedra.tscn")

export var delay = 0.5
export var direcao_position2d = -1

func _ready():
	pass


func _arremessar_pedra():
	
	var pedra1 = projetil_pedra_instancia.instance()
	get_parent().add_child(pedra1)
	pedra1.global_position = self.global_position
	
	if sign(direcao_position2d) == 1:
		pedra1.set_direcao(1)
	else:
		pedra1.set_direcao(-1)

func _on_Armadilha_corda_JogadorCaiu():
	yield(get_tree().create_timer(delay), "timeout")
	_arremessar_pedra()


func _on_Armadilha_corda7_JogadorCaiu():
	yield(get_tree().create_timer(delay), "timeout")
	_arremessar_pedra()
