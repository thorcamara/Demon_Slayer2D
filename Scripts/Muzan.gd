extends KinematicBody2D

onready var jogador = get_node("/root/Level_01/Jogador") 

signal Muzan_morto

var movimento = Vector2(0, 0)
var velocidade_movimento = 100
var gravidade = 50

var vida = 1500.0
var vida_maxima = 1500.0
var regen_vida = 5.0

signal mudar_status_muzan

var estado

var modo_oni = false

var direcao

var sofreu_dano = false
var movendo_para_esquerda = true
var dentro_alcance = false
var morto = false

var ataque_escolhido = 0
var ataque_escolhido_oni = 0

var direcao_knockback = 1
var intensidade_knockback = 2000

var quantidade_dano = 10

var sobrepondo_corpos

var knockbacking = false

func _ready():
	set_process(false)
	hide()
	$CollisionShape2D.set_deferred("disabled", true)
	$Hurtbox.monitoring = false
	$Hurtbox/CollisionShape2D.set_deferred("disabled", true)
	$Detector_jogador.monitoring = false
	$Detector_jogador/CollisionShape2D.set_deferred("disabled", true)
	$Detector_ataque.monitoring = false
	$Detector_ataque/CollisionShape2D.set_deferred("disabled", true)
	
func _process(delta: float):
	if $AnimationPlayer.current_animation in (["Aparecer", "Aparecer_Oni", "Aparecer_Oni_Direita","Ataque_1", "Ataque_1_Direita", 
	"Ataque_2", "Ataque_2_Direita","Chute", "Chute_Direita", "Chute_pulando", "Chute_pulando_Direita", "Dano", "Ataque_1_Oni", 
	"Ataque_1_Oni_Direita", "Ataque_2_Oni", "Ataque_2_Oni_Direita", "Ataque_3_Oni", "Ataque_3_Oni_Direita", "Ataque_Chicote_1_Oni", 
	"Ataque_Chicote_1_Oni_Direita", "Ataque_Chicote_2_Oni", "Ataque_Chicote_2_Oni_Direita", "Ataque_Chicote_3_Oni", 
	"Ataque_Chicote_3_Oni_Direita", "Dano_Oni", "Dano_Oni_Direita", "Morte_Oni"]):
		return
		
	if morto == false and jogador:
		direcao = (jogador.position - position).normalized()
		if not is_on_floor():
			direcao.y += gravidade
		
	move_and_slide(direcao * velocidade_movimento)
		
	flipar()
	modo_oni()
	set_animacao()
	atualizar_barra_vida(delta)

func flipar():
	if direcao.x > 0:
		$Sprite.flip_h = false
		movendo_para_esquerda = false
		$Particles2D.scale.x = -$Particles2D.scale.x
		$Particles2D.position.x = -$Particles2D.position.x
	elif direcao.x < 0:
		$Sprite.flip_h = true
		movendo_para_esquerda = true

func correr():
	if modo_oni == false and ataque_escolhido != 0 and !sofreu_dano and vida > 0 and morto == false: 
		$AnimationPlayer.play("Correr")
	elif modo_oni == true and !sofreu_dano and vida > 0: 
		$AnimationPlayer.play("Correr_Oni")

func hit():
	$Detector_ataque.monitoring = true

func fim_do_hit():
	$Detector_ataque.monitoring = false

func _on_Detector_jogador_body_entered(body):
	if body.name == "Jogador":
		dentro_alcance = true
		esta_dentro_alcance(body)

func _on_Detector_jogador_body_exited(body):
	if body.name == "Jogador":
		dentro_alcance = false
	
func esta_dentro_alcance(body):
	sobrepondo_corpos = $Detector_jogador.get_overlapping_bodies()
	
	while dentro_alcance == true and sobrepondo_corpos:
		if body.name == "Jogador": 
			if modo_oni == false:
				_ataque_aleatorio()
				if !sofreu_dano:
					if ataque_escolhido == 1 and movendo_para_esquerda == true:
						$AnimationPlayer.play("Ataque_1")
					elif ataque_escolhido == 1 and movendo_para_esquerda == false:
						$AnimationPlayer.play("Ataque_1_Direita")
					elif ataque_escolhido == 2 and movendo_para_esquerda == true:
						$AnimationPlayer.play("Ataque_2")
					elif ataque_escolhido == 2 and movendo_para_esquerda == false:
						$AnimationPlayer.play("Ataque_2_Direita")
					elif ataque_escolhido == 3 and movendo_para_esquerda == true:
						$AnimationPlayer.play("Chute")
					elif ataque_escolhido == 3 and movendo_para_esquerda == false:
						$AnimationPlayer.play("Chute_Direita")
					elif ataque_escolhido == 4 and movendo_para_esquerda == true:
						$AnimationPlayer.play("Chute_pulando")
					elif ataque_escolhido == 4 and movendo_para_esquerda == false:
						$AnimationPlayer.play("Chute_pulando_Direita")
					$Som_ataque.play()
					yield(get_tree().create_timer(0.5), "timeout")
					#break
				break
			elif modo_oni == true:
				_ataque_aleatorio_oni()
				if !sofreu_dano:
					if ataque_escolhido_oni == 1 and movendo_para_esquerda == true:
						$AnimationPlayer.play("Ataque_1_Oni")
					elif ataque_escolhido_oni == 1 and movendo_para_esquerda == false:
						$AnimationPlayer.play("Ataque_1_Oni_Direita")
					elif ataque_escolhido_oni == 2 and movendo_para_esquerda == true:
						$AnimationPlayer.play("Ataque_2_Oni")
					elif ataque_escolhido_oni == 2 and movendo_para_esquerda == false:
						$AnimationPlayer.play("Ataque_2_Oni_Direita")
					elif ataque_escolhido_oni == 3 and movendo_para_esquerda == true:
						$AnimationPlayer.play("Ataque_3_Oni")
					elif ataque_escolhido_oni == 3 and movendo_para_esquerda == false:
						$AnimationPlayer.play("Ataque_3_Oni_Direita")
					elif ataque_escolhido_oni == 4 and movendo_para_esquerda == true:
						$AnimationPlayer.play("Ataque_Chicote_1_Oni")
					elif ataque_escolhido_oni == 4 and movendo_para_esquerda == false:
						$AnimationPlayer.play("Ataque_Chicote_1_Oni_Direita")
					elif ataque_escolhido_oni == 5 and movendo_para_esquerda == true:
						$AnimationPlayer.play("Ataque_Chicote_2_Oni")
					elif ataque_escolhido_oni == 5 and movendo_para_esquerda == false:
						$AnimationPlayer.play("Ataque_Chicote_2_Oni_Direita")
					elif ataque_escolhido_oni == 6 and movendo_para_esquerda == true:
						$AnimationPlayer.play("Ataque_Chicote_3_Oni")
					elif ataque_escolhido_oni == 6 and movendo_para_esquerda == false:
						$AnimationPlayer.play("Ataque_Chicote_3_Oni_Direita")
					$Som_ataque.play()
					yield(get_tree().create_timer(0.5), "timeout")
					break
				break

func modo_oni():
	emit_signal("mudar_status_muzan", self)
	if vida <= 750 and modo_oni == false:
		if movendo_para_esquerda == true:
			modo_oni = true
			$AnimationPlayer.clear_queue()
			$AnimationPlayer.play("Aparecer_Oni")
			$Som_oni.play()
			yield($AnimationPlayer, "animation_finished")
			Mundo.muzan_normal = true
		elif movendo_para_esquerda == false:
			modo_oni = true
			$AnimationPlayer.clear_queue()
			$AnimationPlayer.play("Aparecer_Oni_Direita")
			$Som_oni.play()
			yield($AnimationPlayer, "animation_finished")
			Mundo.muzan_normal = false
		yield(get_tree().create_timer(3), "timeout")
	else:
		false

func set_animacao():
	
	if !sofreu_dano and modo_oni == false:
		if direcao.x != 0: 
			if movendo_para_esquerda == true:
				$AnimationPlayer.play("Correr")
			elif movendo_para_esquerda == false:
				$AnimationPlayer.play("Correr_Direita")
	elif sofreu_dano == true and modo_oni == false:
		$AnimationPlayer.play("Dano")
		$AnimationPlayer.playback_speed = 0.5
		yield(get_tree().create_timer(0.8), "timeout")
		$AnimationPlayer.playback_speed = 1
		
	#Modo Oni
	if !sofreu_dano and modo_oni == true:
		if direcao.x != 0: 
			if movendo_para_esquerda == true:
				$AnimationPlayer.play("Correr_Oni")
			elif movendo_para_esquerda == false:
				$AnimationPlayer.play("Correr_Oni_Direita")
	elif sofreu_dano == true and modo_oni == true:
		$AnimationPlayer.play("Dano_Oni")
		$AnimationPlayer.playback_speed = 0.5
		yield(get_tree().create_timer(0.8), "timeout")
		$AnimationPlayer.playback_speed = 1

func _on_Hurtbox_area_entered(area):
	var grupos_projetil = {
		"Projetil_habilidade1": 20,
		"Projetil_habilidade3": 40,
		"Projetil_habilidade1_hinokami": 60,
		"Projetil_habilidade3_hinokami": 100,
	}
	
	if area.name in grupos_projetil:
		sofreu_dano(grupos_projetil[area.name])

func morrer():
	morto = true
	$Particles2D.emitting = false
	$Detector_jogador.monitoring = false
	$AnimationPlayer.clear_queue()
	$AnimationPlayer.play("Morte_Oni")
	$Som_oni.play()
	yield($AnimationPlayer, "animation_finished")
	yield($Som_oni, "finished")
	emit_signal("Muzan_morto")
	set_process(false)
	queue_free()

func sofreu_dano(quantidade_dano):
	if vida > 0:
		$AnimationPlayer.clear_queue()
		$Particles2D.emitting = true
		vida = vida - quantidade_dano
		emit_signal("mudar_status_muzan", self)
		$Som_dano.play()
		sofreu_dano = true
		yield(get_tree().create_timer(0.4), "timeout")
		$Particles2D.emitting = false
		sofreu_dano = false
	if vida <= 0:
		morrer()

func _ataque_aleatorio():
	var atq_ale = RandomNumberGenerator.new()
	atq_ale.randomize()
	ataque_escolhido = atq_ale.randi_range(1, 4)

func _ataque_aleatorio_oni():
	var atq_ale = RandomNumberGenerator.new()
	atq_ale.randomize()
	ataque_escolhido_oni = atq_ale.randi_range(1, 6)

func _on_Acionar_JogadorEntrou():
	show()
	$AnimationPlayer.play("Aparecer")
	$Hurtbox.monitoring = false
	yield(get_tree().create_timer(2), "timeout")
	set_process(true)
	$Hurtbox.monitoring = true
	
	$CollisionShape2D.set_deferred("disabled", false)
	$Hurtbox/CollisionShape2D.set_deferred("disabled", false)
	$Detector_jogador.monitoring = true
	$Detector_jogador/CollisionShape2D.set_deferred("disabled", false)
	$Detector_ataque.monitoring = true
	$Detector_ataque/CollisionShape2D.set_deferred("disabled", false)

func _on_Detector_ataque_body_entered(body):
	# Dano Modo normal
	
	# Ataque 1
	if body.name == "Jogador" and ataque_escolhido == 1:
		body.sofreu_dano(37)
	# Ataque 2
	elif body.name == "Jogador" and ataque_escolhido == 2:
		body.sofreu_dano(27)
	# Chute
	elif body.name == "Jogador" and ataque_escolhido == 3:
		body.sofreu_dano(32)
	# Chute pulando
	elif body.name == "Jogador" and ataque_escolhido == 4:
		body.sofreu_dano(47)
	
	# Dano Modo Oni
	
	#Ataque 1
	elif body.name == "Jogador" and ataque_escolhido_oni == 1:
		body.sofreu_dano(37)
	#Ataque 2
	elif body.name == "Jogador" and ataque_escolhido_oni == 2:
		body.sofreu_dano(47)
	#Ataque 3
	elif body.name == "Jogador" and ataque_escolhido_oni == 3:
		body.sofreu_dano(47)
	#Ataque chicote 1
	elif body.name == "Jogador" and ataque_escolhido_oni == 4:
		body.sofreu_dano(57)
	#Ataque chicote 2
	elif body.name == "Jogador" and ataque_escolhido_oni == 5:
		body.sofreu_dano(52)
	#Ataque chicote 3
	elif body.name == "Jogador" and ataque_escolhido_oni == 6:
		body.sofreu_dano(70)

func knockback():
	if sign(scale.x) == 1:
		direcao_knockback = 1
	elif sign(scale.x) == -1:
		direcao_knockback = -1

	if knockbacking == false:
		movimento.x = direcao_knockback * intensidade_knockback
		movimento = move_and_slide(movimento)
		knockbacking = true
		yield(get_tree().create_timer(1), "timeout")
		knockbacking = false

func _on_Jogador_jogador_morto() -> void:
	if modo_oni == false:
		set_process(false)
		$AnimationPlayer.play("Aparecer")
		$Som_oni.play()
		yield($Som_oni, "finished")
		yield($AnimationPlayer, "animation_finished")
	elif modo_oni == true:
		set_process(false)
		if movendo_para_esquerda == true:
			$AnimationPlayer.play("Aparecer_Oni")
			$Som_oni.play()
			yield($Som_oni, "finished")
			yield($AnimationPlayer, "animation_finished")
		elif movendo_para_esquerda == false:
			$AnimationPlayer.play("Aparecer_Oni_Direita")
			$Som_oni.play()
			yield($Som_oni, "finished")
			yield($AnimationPlayer, "animation_finished")

func atualizar_barra_vida(delta: float):
	# Atualiza a vida do cogumelo com base na taxa de regeneração
	var nova_vida = min(vida + regen_vida * delta, vida_maxima)
	if nova_vida != vida && vida > 0 && !morto:
		vida = nova_vida
		emit_signal("mudar_status_muzan", self)
