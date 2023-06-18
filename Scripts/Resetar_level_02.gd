extends Node

var vida_1 = preload("res://Outros/Vida_item.tscn")
var feitico_1 = preload("res://Outros/Feitico.tscn")

onready var jogador = get_node("/root/Level_02/Jogador") #Pegar a referência ao nó do jogador

func _ready():
	yield(get_tree().create_timer(0.5), "timeout")
	Mundo.moedas = 0
	Mundo.level_02 = true

func _enter_tree():
	if Mundo.ultima_posicao_checkpoint:
		$Jogador.global_position = Mundo.ultima_posicao_checkpoint


func _on_Acionar_JogadorEntrou_Camera():
	$Boss_01/BossCamera_01.current = true


func _on_Timer_spawn_vidas_timeout():
	var posicao_vida = Vector2(rand_range(12075, 12500), rand_range(-500, -525))
	while posicao_vida.x < 12075 and posicao_vida.x > 12500 and posicao_vida.y < -500 and posicao_vida.y > -525:
		posicao_vida = Vector2(rand_range(12075, 12500), rand_range(-500, -525))
	Mundo.instanciar_no(vida_1, posicao_vida, self)


func _on_Acionar_JogadorEntrou():
	$Som_boss_01.play()
	$Som_musica.stop()


func _on_Guerreiro_trevas_Guerreiro_trevas_morto():
	$Boss_01/BossCamera_01.current = true
	$Timer_spawn_vidas.stop()
	$Som_boss_01.stop()
	$Som_musica.play()


func _on_Acionar_02_JogadorEntrou():
	$Timer_spawn_vidas.start()
	$Som_boss_02.play()
	$Som_musica.stop()


func _on_Acionar_02_JogadorEntrou_Camera_02():
	$Boss_02/BossCamera_02.current = true


func _on_Portador_morte_Portador_morte_morto():
	$Boss_01/BossCamera_01.current = true
	$Timer_spawn_vidas.stop()
	$Som_boss_02.stop()
	$Som_musica.play()

func _process(delta):
	yield(get_tree().create_timer(1), "timeout")
	if Mundo.castando_feitico == true:
		var posicao_feitico = Vector2(jogador.position.x - 150, -175)
		print("Posicao jogador = ", jogador.position.x)
		print("Posicao feitico = ", posicao_feitico)
		while posicao_feitico.x < jogador.position.x and posicao_feitico.x > jogador.position.x and posicao_feitico.y < jogador.position.y and posicao_feitico.y > jogador.position.y:
			posicao_feitico = Vector2(jogador.position.x, -175)
		Mundo.instanciar_no(feitico_1, posicao_feitico, self)
		Mundo.castando_feitico = false


func _on_Chegada2_Chegada_02():
	$Som_musica.stop()

func _on_Guerreiro_trevas_Retirar_musica():
	$Som_boss_01.stop()

func _on_Portador_morte_Retirar_musica():
	$Som_boss_02.stop()
