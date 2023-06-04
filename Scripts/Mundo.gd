extends Node

var ultima_posicao_checkpoint = null

var moedas = 0

var controle_desligado = false

var vida_jogador = 100

var energia_jogador = 100

var hinokami_jogador = 0

func instanciar_no(no, local, pai):
	var no_instancia = no.instance()
	pai.add_child(no_instancia)
	no_instancia.global_position = local
	return no_instancia
