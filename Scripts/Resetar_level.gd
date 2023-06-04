extends Node

var vida_1 = preload("res://Outros/Vida_item.tscn")

func _ready():
	yield(get_tree().create_timer(0.5), "timeout")
	Mundo.moedas = 0

func _enter_tree():
	if Mundo.ultima_posicao_checkpoint:
		$Jogador.global_position = Mundo.ultima_posicao_checkpoint


func _on_Acionar_JogadorEntrou_Camera():
	$Boss/BossCamera.current = true


func _on_Muzan_Muzan_morto():
	$Boss/BossCamera.current = false
	$Timer_spawn_vidas.stop()


func _on_Timer_spawn_vidas_timeout():
	var posicao_vida = Vector2(rand_range(3350, 3775), rand_range(-250, -260))
	while posicao_vida.x < 3745 and posicao_vida.x > 3340 and posicao_vida.y < -260 and posicao_vida.y > -250:
		posicao_vida = Vector2(rand_range(3350, 3775), rand_range(-250, -260))
	Mundo.instanciar_no(vida_1, posicao_vida, self)


func _on_Acionar_JogadorEntrou():
	$Timer_spawn_vidas.start()
