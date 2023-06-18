extends Node

var ultima_posicao_checkpoint = null

var moedas = 0

var controle_desligado = false

var vida_jogador = 200

var vida_maxima_jogador = 200

var energia_jogador = 100

var hinokami_jogador = 0

var hinokami_ativado = false

var muzan_normal = true

var ataque1_cooldown_pronto = true

var ataque2_cooldown_pronto = true

var habilidade1_cooldown_pronto = true

var habilidade2_cooldown_pronto = true

var habilidade3_cooldown_pronto = true

var ultimate_cooldown_pronto = true

var musica_mutada = false

var castando_feitico = false

var level_00 = false

var level_01 = false

var level_02 = false

func instanciar_no(no, local, pai):
	var no_instancia = no.instance()
	pai.add_child(no_instancia)
	no_instancia.global_position = local
	return no_instancia
