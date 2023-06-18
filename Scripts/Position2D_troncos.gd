extends Position2D

const projetil_tronco_instancia = preload("res://Projeteis/Projetil_tronco.tscn")
const projetil_tronco_horizontal_instancia = preload("res://Projeteis/Projetil_tronco_horizontal.tscn")

export var delay = 0.5
export var tipo_tronco = 0

var vezes_acionada = 1

func _ready():
	pass

func _arremessar_tronco():
	var tronco1 = projetil_tronco_instancia.instance()
	get_parent().add_child(tronco1)
	tronco1.global_position = self.global_position

func _arremessar_tronco_horizontal():
	var tronco2 = projetil_tronco_horizontal_instancia.instance()
	get_parent().add_child(tronco2)
	tronco2.global_position = self.global_position

func _on_Armadilha_corda4_JogadorCaiu():
	if vezes_acionada == 1:
		vezes_acionada -= 1
		yield(get_tree().create_timer(delay), "timeout")
		if tipo_tronco == 0:
			_arremessar_tronco()
		elif tipo_tronco == 1:
			_arremessar_tronco_horizontal()
