extends KinematicBody2D

const projetil_habilidade1_instancia = preload("res://Projeteis/Projetil_habilidade1.tscn")
const projetil_habilidade3_instancia = preload("res://Projeteis/Projetil_habilidade3.tscn")
const projetil_habilidade1_hinokami_instancia = preload("res://Projeteis/Projetil_habilidade1_hinokami.tscn")
const projetil_habilidade3_hinokami_instancia = preload("res://Projeteis/Projetil_habilidade3_hinokami.tscn")

# Variaves de movimento
var cima = Vector2.UP
var movimento = Vector2.ZERO
var velocidade_movimento = 900
var gravidade = 1200
var forca_pulo = -520

# Variaveis de vida
var vida = 200.0
var vida_maxima = 200.0
var regen_vida = 2.0

# Variaveis de energia
var energia = 100.0
var energia_maxima = 100.0
var regen_energia = 2.0

# Variaveis de habilidades
var hinokami = 0.0
var hinokami_maxima = 100.0

var cooldown_hab1 = 4.0
var habilidade1_cooldown_pronto = true

var cooldown_hab2 = 5.0
var habilidade2_cooldown_pronto = true

var cooldown_hab3 = 6.0
var habilidade3_cooldown_pronto = true

var cooldown_ultimate = 12.0
var ultimate_cooldown_pronto = true

# Variaveis de estado
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
var morto = false

signal jogador_morto

var hinokami_ativado = false

var realizando_ataque = false

var segurando_tecla = false

# Variaveis de knockback
var direcao_knockback = 1
var intensidade_knockback = 6000

# Variaveis de dano
var quantidade_dano = 10

func _ready():
	$Hitbox_espada/colisao_espada.set_deferred("disabled", true)
	$colisao_jogador.set_deferred("disabled", false)
	$Hurtbox.monitoring = true
	Mundo.vida_jogador = vida
	Mundo.vida_maxima_jogador = vida_maxima
	Mundo.energia_jogador = energia
	Mundo.hinokami_jogador = hinokami
	Mundo.hinokami_ativado = false
	Mundo.habilidade1_cooldown_pronto = true
	Mundo.habilidade2_cooldown_pronto = true
	Mundo.habilidade3_cooldown_pronto = true
	Mundo.ultimate_cooldown_pronto = true
	emit_signal("mudar_status_jogador", self)

func _process(delta: float):
	atualizar_barra_vida(delta)
	atualizar_barra_energia(delta)
	
	if Mundo.vida_jogador <= 0:
		Mundo.vida_jogador = 0
	
	if vida <= 0:
		vida = 0
	
	if Mundo.hinokami_jogador >= 100:
		Mundo.hinokami_jogador = 100
	
	if hinokami >= 100:
		hinokami = 100
	
	if vida <= 0 or Mundo.vida_jogador <= 0:
		morto = true
		#if nadando == false:
		realizando_ataque = true
		$Hitbox_espada.monitoring = false
		$Hurtbox.monitoring = false
		emit_signal("jogador_morto")
		yield(get_tree().create_timer(1.5), "timeout")
		get_tree().reload_current_scene()
	
	if Input.is_action_just_pressed("p"):
		get_tree().reload_current_scene()

func _physics_process(delta: float):
	#set_process_input(false)
	movimento.y += gravidade * delta
	movimento.x = 0
	
	if nadando == true: 
		gravidade = 400
	else:
		gravidade = 1200
	
	if !sofreu_dano and realizando_ataque == false and morto == false:
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
		$Particles2D2.position.x = -30
		if sign($Position2D.position.x) == 1:
			$Position2D.position.x *= -1
	elif direcao_movimento > 0:
		$Sprite.flip_h = false
		olhando_para_direita = true
		$Particles2D2.position.x = 30
		if sign($Position2D.position.x) == -1: 
			$Position2D.position.x *= -1

	if Input.is_action_pressed("espaco") && is_on_floor():
		realizando_ataque = false
		$Som_jump.play()
		movimento.y = forca_pulo

	if Input.is_action_pressed("espaco") && nadando == true:
		realizando_ataque = false
		movimento.y = -100

	if Input.is_action_just_pressed("mouse1"):
		if not segurando_tecla:
			Mundo.ataque1_cooldown_pronto = false
			$Cooldown_ataque1.start()
			atacando1 = true
			realizando_ataque = true
			$Som_ataque.play()
			if nadando == true:
				set_physics_process(false)
			yield($AnimationPlayer, "animation_finished")
			if nadando == true:
				set_physics_process(true)
			realizando_ataque = false
			atacando1 = false

	if Input.is_action_just_pressed("mouse2") && is_on_floor():
		if not segurando_tecla:
			Mundo.ataque2_cooldown_pronto = false
			$Cooldown_ataque2.start()
			atacando2 = true
			realizando_ataque = true
			$Som_ataque2.play()
			yield($AnimationPlayer, "animation_finished")
			realizando_ataque = false
			atacando2 = false

	if Input.is_action_just_pressed("q") && is_on_floor() and Mundo.habilidade1_cooldown_pronto == true:
		if not segurando_tecla and energia > 8:
			Mundo.habilidade1_cooldown_pronto = false
			$Cooldown_hab1.start()
			energia = energia - 8
			Mundo.energia_jogador -= 8
			emit_signal("mudar_status_jogador", self)
			habilidade1 = true
			realizando_ataque = true
			$Som_agua.play()
			yield($AnimationPlayer, "animation_finished")
			realizando_ataque = false
			habilidade1 = false
		else:
			$Som_erro.play()

	if Input.is_action_just_pressed("w") and Mundo.habilidade2_cooldown_pronto == true:
		if not segurando_tecla and energia > 15:
			Mundo.habilidade2_cooldown_pronto = false
			$Cooldown_hab2.start()
			energia = energia - 15
			Mundo.energia_jogador -= 15
			emit_signal("mudar_status_jogador", self)
			habilidade2 = true
			realizando_ataque = true
			$Som_agua.play()
			$Particles2D.emitting = true
			if nadando == true:
				set_physics_process(false)
			yield($AnimationPlayer, "animation_finished")
			if nadando == true:
				set_physics_process(true)
			Input.set_deferred("disabled", false)
			realizando_ataque = false
			$Particles2D.emitting = false
			realizando_ataque = false
			habilidade2 = false
		else:
			$Som_erro.play()

	if Input.is_action_just_pressed("e") && is_on_floor() and Mundo.habilidade3_cooldown_pronto == true:
		if not segurando_tecla and energia > 25:
			Mundo.habilidade3_cooldown_pronto = false
			$Cooldown_hab3.start()
			energia = energia - 25
			Mundo.energia_jogador -= 25
			emit_signal("mudar_status_jogador", self)
			habilidade3 = true
			realizando_ataque = true
			$Som_agua.play()
			yield($AnimationPlayer, "animation_finished")
			realizando_ataque = false
			habilidade3 = false
		else:
			$Som_erro.play()

	if Input.is_action_just_pressed("r") and Mundo.ultimate_cooldown_pronto == true:
		if not segurando_tecla and energia > 40:
			Mundo.ultimate_cooldown_pronto = false
			$Cooldown_ultimate.start()
			energia = energia - 40
			Mundo.energia_jogador -= 40
			emit_signal("mudar_status_jogador", self)
			ultimate = true
			realizando_ataque = true
			yield(get_tree().create_timer(0.7), "timeout")
			$Som_agua.play()
			if nadando == true:
				set_physics_process(false)
			yield($AnimationPlayer, "animation_finished")
			if nadando == true:
				set_physics_process(true)
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
			vida_maxima = 400.0
			vida = 400.0
			Mundo.hinokami_ativado = true
			Mundo.vida_jogador = 400
			Mundo.vida_maxima_jogador = 400
			emit_signal("mudar_status_jogador", self)
			hinokami_subtrair()
			yield(get_tree().create_timer(10), "timeout")
			hinokami_ativado = false
			Mundo.hinokami_ativado = false
			vida_maxima = 200.0
			vida = 200.0
			Mundo.vida_jogador = 200
			Mundo.vida_maxima_jogador = 200
			emit_signal("mudar_status_jogador", self)
		else:
			hinokami_ativado == false
			Mundo.hinokami_ativado = false
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
	if !is_on_floor() and olhando_para_direita == true and sofreu_dano == false and atacando1 == false and habilidade2 == false and ultimate == false and nadando == false:
		estado = "Pular"
	elif !is_on_floor() and olhando_para_direita == false and sofreu_dano == false and atacando1 == false and habilidade2 == false and ultimate == false and nadando == false:
		estado = "Pular_esquerda"
	elif movimento.x != 0 and olhando_para_direita == true and sofreu_dano == false and atacando1 == false and habilidade2 == false and ultimate == false and nadando == false:
		estado = "Correr"
	elif movimento.x != 0 and olhando_para_direita == false and sofreu_dano == false and atacando1 == false and habilidade2 == false and ultimate == false and nadando == false:
		estado = "Correr_esquerda"
	elif atacando1 and olhando_para_direita == true and sofreu_dano == false:
		estado = "Atacar1"
	elif atacando1 and olhando_para_direita == false and sofreu_dano == false:
		estado = "Atacar1_esquerda"
	elif atacando2 and olhando_para_direita == true and sofreu_dano == false and is_on_floor():
		estado = "Atacar2"
	elif atacando2 and olhando_para_direita == false and sofreu_dano == false and is_on_floor():
		estado = "Atacar2_esquerda"
	elif sofreu_dano == true and olhando_para_direita == true:
		estado = "Dano2"
	elif sofreu_dano == true and olhando_para_direita == false:
		estado = "Dano2_esquerda"
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
	elif ultimate == true and olhando_para_direita == true and sofreu_dano == false and hinokami_ativado == true:
		estado = "Ultimate_Hinokami"
	elif ultimate == true and olhando_para_direita == false and sofreu_dano == false and hinokami_ativado == true:
		estado = "Ultimate_esquerda_Hinokami"
	elif !is_on_floor() and olhando_para_direita == true and sofreu_dano == false and nadando == false:
		estado = "Pular"
	elif !is_on_floor() and olhando_para_direita == false and sofreu_dano == false and nadando == false:
		estado = "Pular_esquerda"
	elif nadando == true and olhando_para_direita == true and morto == false:
		estado = "Nadar"
	elif nadando == true and olhando_para_direita == false and morto == false:
		estado = "Nadar_esquerda"
	elif morto == true:
		estado = "Morto"

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

func sofreu_dano(quantidade_dano):
	if (vida > 0 or Mundo.vida_jogador > 0) and morto == false:
		$Som_hurt.play()
		sofreu_dano = true
		realizando_ataque = false
		vida = vida - quantidade_dano
		Mundo.vida_jogador = vida
		emit_signal("mudar_status_jogador", self)
		$Hurtbox.set_deferred("disabled", true)
		yield(get_tree().create_timer(0.4), "timeout")
		$Hurtbox.set_deferred("disabled", true)
		sofreu_dano = false

func _on_Hurtbox_area_entered(area):
	if area.is_in_group("inimigos"):
		pass

func _on_Acionar_JogadorEntrou():
	$Camera2D.current = false

func plataforma_boss():
	for plataformas in get_slide_count():
		var colisao = get_slide_collision(plataformas)
		if colisao.collider.has_method("colidir_com"):
			colisao.collider.colidir_com(colisao, self)

func _on_Muzan_Muzan_morto():
	$Camera2D.current = true

func _on_Hitbox_espada_body_entered(body):
	
	
	#Dano Normal sem Hinokami
	
	if body.is_in_group("inimigos") and atacando1 == true and hinokami_ativado == false:
		body.sofreu_dano(30)
		if hinokami < 100:
			hinokami += 5
			Mundo.hinokami_jogador += 5
		emit_signal("mudar_status_jogador", self)
	elif body.is_in_group("inimigos") and atacando2 == true and hinokami_ativado == false:
		body.sofreu_dano(50)
		if hinokami < 100:
			hinokami += 5
			Mundo.hinokami_jogador += 5
		emit_signal("mudar_status_jogador", self)
	elif body.is_in_group("inimigos") and habilidade2 == true and hinokami_ativado == false:
		body.sofreu_dano(60)
		if hinokami < 100:
			hinokami += 5
			Mundo.hinokami_jogador += 5
		emit_signal("mudar_status_jogador", self)
	elif body.is_in_group("inimigos") and ultimate == true and hinokami_ativado == false:
		body.sofreu_dano(200)
		if hinokami < 100:
			hinokami += 5
			Mundo.hinokami_jogador += 5
		emit_signal("mudar_status_jogador", self)
	
	#Dano Normal com Hinokami
	elif body.is_in_group("inimigos") and atacando1 == true and hinokami_ativado == true:
		body.sofreu_dano(60)
		emit_signal("mudar_status_jogador", self)
	elif body.is_in_group("inimigos") and atacando2 == true and hinokami_ativado == true:
		body.sofreu_dano(100)
		emit_signal("mudar_status_jogador", self)
	elif body.is_in_group("inimigos") and habilidade2 == true and hinokami_ativado == true:
		body.sofreu_dano(120)
		emit_signal("mudar_status_jogador", self)
	elif body.is_in_group("inimigos") and ultimate == true and hinokami_ativado == true:
		body.sofreu_dano(400)
		emit_signal("mudar_status_jogador", self)
		
		
	# Dano para o muzan sem Hinokami e modo normal
	
	
	elif atacando1 == true and body.is_in_group("muzan") and hinokami_ativado == false and Mundo.muzan_normal == true:
		body.sofreu_dano(30)
		if hinokami < 100:
			hinokami += 10
			Mundo.hinokami_jogador += 10
		emit_signal("mudar_status_jogador", self)
	elif atacando2 == true and body.is_in_group("muzan") and hinokami_ativado == false and Mundo.muzan_normal == true:
		body.sofreu_dano(50)
		if hinokami < 100:
			hinokami += 10
			Mundo.hinokami_jogador += 10
		emit_signal("mudar_status_jogador", self)
	elif habilidade2 == true and body.is_in_group("muzan") and hinokami_ativado == false and Mundo.muzan_normal == true:
		body.sofreu_dano(60)
		if hinokami < 100:
			hinokami += 10
			Mundo.hinokami_jogador += 10
		emit_signal("mudar_status_jogador", self)
	elif ultimate == true and body.is_in_group("muzan") and hinokami_ativado == false and Mundo.muzan_normal == true:
		body.sofreu_dano(200)
		if hinokami < 100:
			hinokami += 10
			Mundo.hinokami_jogador += 10
		emit_signal("mudar_status_jogador", self)
		
		
	# Dano para o muzan sem Hinokami e modo oni
	
	
	elif atacando1 == true and body.is_in_group("muzan") and hinokami_ativado == false and Mundo.muzan_normal == false:
		body.sofreu_dano(25)
		if hinokami < 100:
			hinokami += 10
			Mundo.hinokami_jogador += 10
		emit_signal("mudar_status_jogador", self)
	elif atacando2 == true and body.is_in_group("muzan") and hinokami_ativado == false and Mundo.muzan_normal == false:
		body.sofreu_dano(50)
		if hinokami < 100:
			hinokami += 10
			Mundo.hinokami_jogador += 10
		emit_signal("mudar_status_jogador", self)
	elif habilidade2 == true and body.is_in_group("muzan") and hinokami_ativado == false and Mundo.muzan_normal == false:
		body.sofreu_dano(55)
		if hinokami < 100:
			hinokami += 10
			Mundo.hinokami_jogador += 10
		emit_signal("mudar_status_jogador", self)
	elif ultimate == true and body.is_in_group("muzan") and hinokami_ativado == false and Mundo.muzan_normal == false:
		body.sofreu_dano(180)
		if hinokami < 100:
			hinokami += 10
			Mundo.hinokami_jogador += 10
		emit_signal("mudar_status_jogador", self)
		
		
	# Dano para o muzan com Hinokami e modo normal
	
	
	elif atacando1 == true and body.is_in_group("muzan") and hinokami_ativado == true and Mundo.muzan_normal == true:
		body.sofreu_dano(50)
		emit_signal("mudar_status_jogador", self)
	elif atacando2 == true and body.is_in_group("muzan") and hinokami_ativado == true and Mundo.muzan_normal == true:
		body.sofreu_dano(100)
		emit_signal("mudar_status_jogador", self)
	elif habilidade2 == true and body.is_in_group("muzan") and hinokami_ativado == true and Mundo.muzan_normal == true:
		body.sofreu_dano(110)
		emit_signal("mudar_status_jogador", self)
	elif ultimate == true and body.is_in_group("muzan") and hinokami_ativado == true and Mundo.muzan_normal == true:
		body.sofreu_dano(360)
		emit_signal("mudar_status_jogador", self)
		
		
	# Dano para o muzan com Hinokami e modo oni
	
	
	elif atacando1 == true and body.is_in_group("muzan") and hinokami_ativado == true and Mundo.muzan_normal == false:
		body.sofreu_dano(40)
		emit_signal("mudar_status_jogador", self)
	elif atacando2 == true and body.is_in_group("muzan") and hinokami_ativado == true and Mundo.muzan_normal == false:
		body.sofreu_dano(90)
		emit_signal("mudar_status_jogador", self)
	elif habilidade2 == true and body.is_in_group("muzan") and hinokami_ativado == true and Mundo.muzan_normal == false:
		body.sofreu_dano(100)
		emit_signal("mudar_status_jogador", self)
	elif ultimate == true and body.is_in_group("muzan") and hinokami_ativado == true and Mundo.muzan_normal == false:
		body.sofreu_dano(320)
		emit_signal("mudar_status_jogador", self)

func _on_Cooldown_ataque1_timeout():
	Mundo.ataque1_cooldown_pronto = true

func _on_Cooldown_ataque2_timeout():
	Mundo.ataque2_cooldown_pronto = true

func _on_Cooldown_hab1_timeout():
	Mundo.habilidade1_cooldown_pronto = true

func _on_Cooldown_hab2_timeout():
	Mundo.habilidade2_cooldown_pronto = true

func _on_Cooldown_hab3_timeout():
	Mundo.habilidade3_cooldown_pronto = true

func _on_Cooldown_ultimate_timeout():
	Mundo.ultimate_cooldown_pronto = true

func dentro_agua():
	if nadando == true:
		$Som_dive.play()
		$Som_underwater.play()
	elif nadando == false:
		$Som_underwater.stop()

func _on_Agua_body_entered(body):
	if body.name == "Jogador":
		nadando = true
		dentro_agua()

func _on_Agua_body_exited(body):
	if body.name == "Jogador":
		nadando = false
		dentro_agua()

func _on_Agua2_body_entered(body):
	if body.name == "Jogador":
		nadando = true
		dentro_agua()

func _on_Agua2_body_exited(body):
	if body.name == "Jogador":
		nadando = false
		dentro_agua()

func _on_Agua3_body_entered(body):
	if body.name == "Jogador":
		nadando = true
		dentro_agua()

func _on_Agua3_body_exited(body):
	if body.name == "Jogador":
		nadando = false
		dentro_agua()

func _on_Guerreiro_trevas_Guerreiro_trevas_morto():
	$Camera2D.current = true

func _on_Agua4_body_entered(body):
	if body.name == "Jogador":
		nadando = true
		dentro_agua()

func _on_Agua4_body_exited(body):
	if body.name == "Jogador":
		nadando = false
		dentro_agua()

func _on_Agua5_body_entered(body):
	if body.name == "Jogador":
		nadando = true
		dentro_agua()

func _on_Agua5_body_exited(body):
	if body.name == "Jogador":
		nadando = false
		dentro_agua()

func _on_Acionar_02_JogadorEntrou():
	$Camera2D.current = false

func _on_Portador_morte_Portador_morte_morto():
	$Camera2D.current = true

func atualizar_barra_vida(delta: float):
	var nova_vida = min(vida + regen_vida * delta, vida_maxima)
	if nova_vida != vida && vida > 0 && !morto:
		vida = nova_vida
		Mundo.vida_jogador = round(nova_vida)
		emit_signal("mudar_status_jogador", self)

func atualizar_barra_energia(delta: float):
	var nova_energia = min(energia + regen_energia * delta, energia_maxima)
	if nova_energia != energia && energia > 0 && !morto:
		energia = nova_energia
		Mundo.energia_jogador = round(nova_energia)
		emit_signal("mudar_status_jogador", self)
