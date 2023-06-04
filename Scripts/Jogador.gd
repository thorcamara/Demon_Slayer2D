extends KinematicBody2D

const projetil_habilidade1_instancia = preload("res://Projeteis/Projetil_habilidade1.tscn")
const projetil_habilidade3_instancia = preload("res://Projeteis/Projetil_habilidade3.tscn")
const projetil_habilidade1_hinokami_instancia = preload("res://Projeteis/Projetil_habilidade1_hinokami.tscn")
const projetil_habilidade3_hinokami_instancia = preload("res://Projeteis/Projetil_habilidade3_hinokami.tscn")

var cima = Vector2.UP
var movimento = Vector2.ZERO
var velocidade_movimento = 900
var gravidade = 1200
var forca_pulo = -520

var vida = 100.0
var vida_maxima = 100.0
var regen_vida = 1.0

var energia = 100.0
var energia_maxima = 100.0
var regen_energia = 2.0

var hinokami = 0.0
var hinokami_maxima = 100.0

signal mudar_status_jogador

var estado
var olhando_para_direita = true
var pulando = false
var sofreu_dano = false
var atacando1 = false
var atacando2 = false
var habilidade1 = false
var habilidade2 = false
var habilidade3 = false
var ultimate = false
var nadando = false
var no_chao = true

var hinokami_ativado = false

var realizando_ataque = false

var segurando_tecla = false

var direcao_knockback = 1
var intensidade_knockback = 3000

var quantidade_dano = 10

func _ready():
	$Som_musica.play()
	$Hitbox_espada/colisao_espada.set_deferred("disabled", true)
	Mundo.vida_jogador = vida
	Mundo.energia_jogador = energia
	Mundo.hinokami_jogador = hinokami
	emit_signal("mudar_status_jogador", self)
	
func _process(delta: float):
	var nova_energia = min(energia + regen_energia * delta, energia_maxima)
	if nova_energia != energia:
		energia = nova_energia
		Mundo.energia_jogador = round(nova_energia)
		emit_signal("mudar_status_jogador", self)
	
	var nova_vida = min(vida + regen_vida * delta, vida_maxima)
	if nova_vida != vida:
		vida = nova_vida
		Mundo.vida_jogador = round(nova_vida)
		emit_signal("mudar_status_jogador", self)
		
	if Mundo.vida_jogador <= 0:
		Mundo.vida_jogador = 0
		
	if Mundo.hinokami_jogador >= 100:
		Mundo.hinokami_jogador = 100
		
	if vida <= 0 or Mundo.vida_jogador <= 0:
		get_tree().reload_current_scene()
		
	if Input.is_action_just_pressed("p"):
		get_tree().reload_current_scene()
		
		
	
func _physics_process(delta: float):
	movimento.y += gravidade * delta
	movimento.x = 0
	
	if realizando_ataque:
		return
	
	if !is_on_floor():
		segurando_tecla = true
	
	if !sofreu_dano:
		_get_entrada()
	
	if movimento.x == 0:
		regen_energia = 5
	else:
		regen_energia = 2
	
	movimento = move_and_slide(movimento, cima)
	
	_set_animation()
	
	plataforma_boss()
	
func _get_entrada():
	movimento.x = 0
	var direcao_movimento = int(Input.is_action_pressed("d")) - int(Input.is_action_pressed("a"))
	movimento.x = lerp(movimento.x,  velocidade_movimento * direcao_movimento, 0.2)
		
	if direcao_movimento < 0:
		$Sprite.flip_h = true
		olhando_para_direita = false
#		$Particles2D2.scale.x = -$Particles2D2.scale.x
		$Particles2D2.position.x = -30
		if sign($Position2D.position.x) == 1:
			$Position2D.position.x *= -1
	elif direcao_movimento > 0:
		$Sprite.flip_h = false
		olhando_para_direita = true
		$Particles2D2.position.x = 30
		if sign($Position2D.position.x) == -1: 
			$Position2D.position.x *= -1
		
		
		
	if Input.is_action_pressed("a"):
		realizando_ataque = false
		segurando_tecla = true
	
	if Input.is_action_just_released("a"):
		segurando_tecla = false
	
	if Input.is_action_pressed("d"):
		realizando_ataque = false
		segurando_tecla = true
	
	if Input.is_action_just_released("d"):
		segurando_tecla = false
		
	if Input.is_action_pressed("espaco") && is_on_floor():
		realizando_ataque = false
		segurando_tecla = true
		movimento.y = forca_pulo
		
	if Input.is_action_just_released("espaco") && is_on_floor():
		segurando_tecla = false
		movimento.y = forca_pulo
		
		
	if Input.is_action_just_pressed("mouse1"):
		if not segurando_tecla:
			atacando1 = true
			realizando_ataque = true
			$Som_ataque.play()
			yield($AnimationPlayer, "animation_finished")
			realizando_ataque = false
			atacando1 = false
		
	if Input.is_action_just_pressed("mouse2"):
		if not segurando_tecla:
			atacando2 = true
			realizando_ataque = true
			$Som_ataque2.play()
			yield($AnimationPlayer, "animation_finished")
			realizando_ataque = false
			atacando2 = false
		
	if Input.is_action_just_pressed("q"):
		if not segurando_tecla and energia > 15:
			energia = energia - 15
			Mundo.energia_jogador -= 15
			emit_signal("mudar_status_jogador", self)
			habilidade1 = true
			realizando_ataque = true
			$Som_agua.play()
			yield($AnimationPlayer, "animation_finished")
			realizando_ataque = false
			habilidade1 = false
		else:
			$Som_erro.play()
		
	if Input.is_action_just_pressed("w"):
		
		if not segurando_tecla and energia > 30:
			energia = energia - 30
			Mundo.energia_jogador -= 30
			emit_signal("mudar_status_jogador", self)
			habilidade2 = true
			realizando_ataque = true
			$Som_agua.play()
			$Particles2D.emitting = true
			yield($AnimationPlayer, "animation_finished")
			$Particles2D.emitting = false
			realizando_ataque = false
			habilidade2 = false
		else:
			$Som_erro.play()
		
	if Input.is_action_just_pressed("e"):
		if not segurando_tecla and energia > 50:
			energia = energia - 50
			Mundo.energia_jogador -= 50
			emit_signal("mudar_status_jogador", self)
			habilidade3 = true
			realizando_ataque = true
			$Som_agua.play()
			yield($AnimationPlayer, "animation_finished")
			realizando_ataque = false
			habilidade3 = false
		else:
			$Som_erro.play()
		
	if Input.is_action_just_pressed("r"):
		if not segurando_tecla and energia > 80:
			energia = energia - 80
			Mundo.energia_jogador -= 80
			emit_signal("mudar_status_jogador", self)
			ultimate = true
			realizando_ataque = true
			yield(get_tree().create_timer(0.7), "timeout")
			$Som_agua.play()
			yield($AnimationPlayer, "animation_finished")
			$Particles2D2.emitting = true
			yield(get_tree().create_timer(0.5), "timeout")
			$Particles2D2.emitting = false
			realizando_ataque = false
			ultimate = false
		else:
			$Som_erro.play()
			
	if Input.is_action_just_pressed("v"):
		if hinokami == 100 and Mundo.hinokami_jogador == 100 and hinokami_ativado == false:
			hinokami_ativado = true
			print("Hinokami", hinokami_ativado)
			hinokami_subtrair()
			yield(get_tree().create_timer(10), "timeout")
			hinokami_ativado = false
			print("Hinokami", hinokami_ativado)
		else:
			hinokami_ativado == false
			$Som_erro.play()
		
func hinokami_subtrair():
	while hinokami != 0 and Mundo.hinokami_jogador != 0:
		hinokami -= 10
		Mundo.hinokami_jogador -= 10
		emit_signal("mudar_status_jogador", self)
		yield(get_tree().create_timer(1), "timeout")
		
func _set_animation():
	estado = "Parado"
	
	if movimento.x == 0 and olhando_para_direita == false and sofreu_dano == false:
		estado = "Parado_esquerda"
	if !is_on_floor() and olhando_para_direita == true and sofreu_dano == false:
		estado = "Pular"
	elif !is_on_floor() and olhando_para_direita == false and sofreu_dano == false:
		estado = "Pular_esquerda"
	elif movimento.x != 0 and olhando_para_direita == true and sofreu_dano == false:
		estado = "Correr"
	elif movimento.x != 0 and olhando_para_direita == false and sofreu_dano == false:
		estado = "Correr_esquerda"
	elif atacando1 and olhando_para_direita == true and sofreu_dano == false:
		estado = "Atacar1"
	elif atacando1 and olhando_para_direita == false and sofreu_dano == false:
		estado = "Atacar1_esquerda"
	elif atacando2 and olhando_para_direita == true and sofreu_dano == false:
		estado = "Atacar2"
	elif atacando2 and olhando_para_direita == false and sofreu_dano == false:
		estado = "Atacar2_esquerda"
	elif sofreu_dano == true:
		estado = "Dano2"
	elif habilidade1 and olhando_para_direita == true and sofreu_dano == false and hinokami_ativado == false:
		estado = "Habilidade1"
	elif habilidade1 and olhando_para_direita == false and sofreu_dano == false and hinokami_ativado == false:
		estado = "Habilidade1_esquerda"
	elif habilidade1 and olhando_para_direita == true and sofreu_dano == false and hinokami_ativado == true:
		estado = "Habilidade1_Hinokami"
	elif habilidade1 and olhando_para_direita == false and sofreu_dano == false and hinokami_ativado == true:
		estado = "Habilidade1_esquerda_Hinokami"
	elif habilidade2 == true and olhando_para_direita == true and sofreu_dano == false and hinokami_ativado == false:
		estado = "Habilidade2"
	elif habilidade2 == true and olhando_para_direita == false and sofreu_dano == false and hinokami_ativado == false:
		estado = "Habilidade2_esquerda"
	elif habilidade2 == true and olhando_para_direita == true and sofreu_dano == false and hinokami_ativado == true:
		estado = "Habilidade2_Hinokami"
	elif habilidade2 == true and olhando_para_direita == false and sofreu_dano == false and hinokami_ativado == true:
		estado = "Habilidade2_esquerda_Hinokami"
	elif habilidade3 and olhando_para_direita == true and sofreu_dano == false and hinokami_ativado == false:
		estado = "Habilidade3"
	elif habilidade3 and olhando_para_direita == false and sofreu_dano == false and hinokami_ativado == false:
		estado = "Habilidade3_esquerda"
	elif habilidade3 and olhando_para_direita == true and sofreu_dano == false and hinokami_ativado == true:
		estado = "Habilidade3_Hinokami"
	elif habilidade3 and olhando_para_direita == false and sofreu_dano == false and hinokami_ativado == true:
		estado = "Habilidade3_esquerda_Hinokami"
	elif ultimate == true and olhando_para_direita == true and sofreu_dano == false and hinokami_ativado == false:
		estado = "Ultimate"
	elif ultimate == true and olhando_para_direita == false and sofreu_dano == false and hinokami_ativado == false:
		estado = "Ultimate_esquerda"
	elif !is_on_floor() and nadando == true and olhando_para_direita == true and sofreu_dano == false:
		estado = "Pular"
	elif !is_on_floor() and nadando == true and olhando_para_direita == false and sofreu_dano == false:
		estado = "Pular_esquerda"
		

	if $AnimationPlayer.assigned_animation != estado:
		$AnimationPlayer.play(estado)
		
func knockback():
	if olhando_para_direita == true:
		direcao_knockback = -1
	elif olhando_para_direita == false:
		direcao_knockback = 1
	movimento.x = direcao_knockback * intensidade_knockback
	movimento = move_and_slide(movimento)

func _tiro_hab1():
	
	var projetil1 = projetil_habilidade1_instancia.instance()
	get_parent().add_child(projetil1)
	projetil1.global_position = $Position2D.global_position
	
	if sign($Position2D.position.x) == 1:
		projetil1.set_direcao(1)
	else:
		projetil1.set_direcao(-1)

func _tiro_hab3():
	
	var projetil3 = projetil_habilidade3_instancia.instance()
	get_parent().add_child(projetil3)
	projetil3.global_position = $Position2D.global_position
	
	if sign($Position2D.position.x) == 1:
		projetil3.set_direcao(1)
	else:
		projetil3.set_direcao(-1)
		
func _tiro_hab1_hinokami():
	
	var projetil1_hinokami = projetil_habilidade1_hinokami_instancia.instance()
	get_parent().add_child(projetil1_hinokami)
	projetil1_hinokami.global_position = $Position2D.global_position
	
	if sign($Position2D.position.x) == 1:
		projetil1_hinokami.set_direcao(1)
	else:
		projetil1_hinokami.set_direcao(-1)

func _tiro_hab3_hinokami():
	
	var projetil3_hinokami = projetil_habilidade3_hinokami_instancia.instance()
	get_parent().add_child(projetil3_hinokami)
	projetil3_hinokami.global_position = $Position2D.global_position
	
	if sign($Position2D.position.x) == 1:
		projetil3_hinokami.set_direcao(1)
	else:
		projetil3_hinokami.set_direcao(-1)

func _sofreu_dano(quantidade_dano):
	if vida >= 0 or Mundo.vida_jogador >= 0:
		$Som_hurt.play()
		sofreu_dano = true
		realizando_ataque = false
		vida = vida - quantidade_dano
		Mundo.vida_jogador = vida
		emit_signal("mudar_status_jogador", self)
		print("Vida Jogador ", vida)
		print("Mundo ", Mundo.vida_jogador)
		$Hurtbox.set_deferred("disabled", true)
		yield(get_tree().create_timer(0.4), "timeout")
		$Hurtbox.set_deferred("disabled", true)
		sofreu_dano = false
#	elif vida <= 0 or Mundo.vida_jogador <= 0:
#		get_tree().reload_current_scene()

func _on_Hurtbox_area_entered(area):
	if area.is_in_group("inimigos"):
		print("JOGADOR SOFREU DANO")
#		_sofreu_dano()


func _on_Acionar_JogadorEntrou():
	$Camera2D.current = false
	$Som_musica.stop()
	$Som_boss.play()

func frameFreeze(escala_tempo, duracao):
	Engine.time_scale = escala_tempo
	yield(get_tree().create_timer(duracao * escala_tempo), "timeout")
	Engine.time_scale = 1.0

func plataforma_boss():
	for plataformas in get_slide_count():
		var colisao = get_slide_collision(plataformas)
		if colisao.collider.has_method("colidir_com"):
			colisao.collider.colidir_com(colisao, self)
			
func _on_Muzan_Muzan_morto():
	$Camera2D.current = true
	$Som_boss.stop()
	$Som_musica.play()
	
func _on_Hitbox_espada_body_entered(body):
	
	
	#Dano Normal sem Hinokami
	
	if body.is_in_group("inimigos") and atacando1 == true and hinokami_ativado == false:
		body._sofreu_dano(30)
		if hinokami < 100:
			hinokami += 50
			Mundo.hinokami_jogador += 50
		emit_signal("mudar_status_jogador", self)
	elif body.is_in_group("inimigos") and atacando2 == true and hinokami_ativado == false:
		body._sofreu_dano(50)
		if hinokami < 100:
			hinokami += 10
			Mundo.hinokami_jogador += 10
		emit_signal("mudar_status_jogador", self)
	elif body.is_in_group("inimigos") and habilidade2 == true and hinokami_ativado == false:
		body._sofreu_dano(60)
		if hinokami < 100:
			hinokami += 10
			Mundo.hinokami_jogador += 10
		emit_signal("mudar_status_jogador", self)
	elif body.is_in_group("inimigos") and ultimate == true and hinokami_ativado == false:
		body._sofreu_dano(200)
		if hinokami < 100:
			hinokami += 10
			Mundo.hinokami_jogador += 10
		emit_signal("mudar_status_jogador", self)
	
	#Dano Normal com Hinokami
	elif body.is_in_group("inimigos") and atacando1 == true and hinokami_ativado == true:
		body._sofreu_dano(60)
		emit_signal("mudar_status_jogador", self)
	elif body.is_in_group("inimigos") and atacando2 == true and hinokami_ativado == true:
		body._sofreu_dano(100)
		emit_signal("mudar_status_jogador", self)
	elif body.is_in_group("inimigos") and habilidade2 == true and hinokami_ativado == true:
		body._sofreu_dano(120)
		emit_signal("mudar_status_jogador", self)
	elif body.is_in_group("inimigos") and ultimate == true and hinokami_ativado == true:
		body._sofreu_dano(400)
		emit_signal("mudar_status_jogador", self)
		
		
	# Dano para o muzan sem Hinokami
	
	
	elif atacando1 == true and body.is_in_group("muzan") and hinokami_ativado == false:
		body._sofreu_dano(25, 0.2)
		if hinokami < 100:
			hinokami += 10
			Mundo.hinokami_jogador += 10
		emit_signal("mudar_status_jogador", self)
	elif atacando2 == true and body.is_in_group("muzan") and hinokami_ativado == false:
		body._sofreu_dano(50, 0.8)
		if hinokami < 100:
			hinokami += 10
			Mundo.hinokami_jogador += 10
		emit_signal("mudar_status_jogador", self)
	elif habilidade2 == true and body.is_in_group("muzan") and hinokami_ativado == false:
		body._sofreu_dano(55, 0.6)
		if hinokami < 100:
			hinokami += 10
			Mundo.hinokami_jogador += 10
		emit_signal("mudar_status_jogador", self)
	elif ultimate == true and body.is_in_group("muzan") and hinokami_ativado == false:
		body._sofreu_dano(180, 1)
		if hinokami < 100:
			hinokami += 10
			Mundo.hinokami_jogador += 10
		emit_signal("mudar_status_jogador", self)
		
		
	# Dano para o muzan com Hinokami
	
	
	elif atacando1 == true and body.is_in_group("muzan") and hinokami_ativado == true:
		body._sofreu_dano(50, 0.2)
		emit_signal("mudar_status_jogador", self)
	elif atacando2 == true and body.is_in_group("muzan") and hinokami_ativado == true:
		body._sofreu_dano(100, 0.8)
		emit_signal("mudar_status_jogador", self)
	elif habilidade2 == true and body.is_in_group("muzan") and hinokami_ativado == true:
		body._sofreu_dano(110, 0.6)
		emit_signal("mudar_status_jogador", self)
	elif ultimate == true and body.is_in_group("muzan") and hinokami_ativado == true:
		body._sofreu_dano(360, 1)
		emit_signal("mudar_status_jogador", self)
