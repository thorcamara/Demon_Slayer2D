extends KinematicBody2D

onready var jogador = get_node("/root/Level_01/Jogador") 

signal Muzan_morto

var movimento = Vector2(0, 0)
var velocidade_movimento = 100
var gravidade = 50

var vida = 1000.0
var vida_maxima = 1000.0
var regen_vida = 10.0

signal mudar_status_muzan

var estado

var modo_oni = false

var direcao

var sofreu_dano = false
var movendo_para_esquerda = true

var dentro_alcance = false

var ataque_escolhido = 0
var ataque_escolhido_oni = 0

var direcao_knockback = 1
var intensidade_knockback = 2000

var quantidade_dano = 10

var stun_bd = 0.4

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
	if $AnimationPlayer.current_animation == "Aparecer":
		return
	elif $AnimationPlayer.current_animation == "Aparecer_Oni":
		return
	elif $AnimationPlayer.current_animation == "Ataque_1":
		return
	elif $AnimationPlayer.current_animation == "Ataque_1_Direita":
		return
	elif $AnimationPlayer.current_animation == "Ataque_2":
		return
	elif $AnimationPlayer.current_animation == "Ataque_2_Direita":
		return
	elif $AnimationPlayer.current_animation == "Chute":
		return
	elif $AnimationPlayer.current_animation == "Chute_Direita":
		return
	elif $AnimationPlayer.current_animation == "Chute_pulando":
		return
	elif $AnimationPlayer.current_animation == "Chute_pulando_Direita":
		return
	elif $AnimationPlayer.current_animation == "Dano":
		return
	elif $AnimationPlayer.current_animation == "Ataque_1_Oni":
		return
	elif $AnimationPlayer.current_animation == "Ataque_1_Oni_Direita":
		return
	elif $AnimationPlayer.current_animation == "Ataque_2_Oni":
		return
	elif $AnimationPlayer.current_animation == "Ataque_2_Oni_Direita":
		return
	elif $AnimationPlayer.current_animation == "Ataque_3_Oni":
		return
	elif $AnimationPlayer.current_animation == "Ataque_3_Oni_Direita":
		return
	elif $AnimationPlayer.current_animation == "Ataque_Chicote_1_Oni":
		return
	elif $AnimationPlayer.current_animation == "Ataque_Chicote_1_Oni_Direita":
		return
	elif $AnimationPlayer.current_animation == "Ataque_Chicote_2_Oni":
		return
	elif $AnimationPlayer.current_animation == "Ataque_Chicote_2_Oni_Direita":
		return
	elif $AnimationPlayer.current_animation == "Ataque_Chicote_3_Oni":
		return
	elif $AnimationPlayer.current_animation == "Ataque_Chicote_3_Oni_Direita":
		return
	elif $AnimationPlayer.current_animation == "Dano_Oni":
		return
	
	if jogador:
		direcao = (jogador.position - position).normalized()
		if not is_on_floor():
			direcao.y += gravidade
	
	move_and_slide(direcao * velocidade_movimento)
		
	flipar()
	esta_dentro_alcance()
	modo_oni()
	set_animacao()
	
	var nova_vida = min(vida + regen_vida * delta, vida_maxima)
	if nova_vida != vida:
		vida = nova_vida
		emit_signal("mudar_status_muzan", self)

func flipar():
	if direcao.x > 0:
		$Sprite.flip_h = false
		movendo_para_esquerda = false
		$Particles2D.position.x = -14
	elif direcao.x < 0:
		$Sprite.flip_h = true
		movendo_para_esquerda = true
		$Particles2D.position.x = 14

func correr():
	if modo_oni == false: 
		$AnimationPlayer.play("Correr")
	elif modo_oni == true: 
		$AnimationPlayer.play("Correr_Oni")

func hit():
	$Detector_ataque.monitoring = true

func fim_do_hit():
	$Detector_ataque.monitoring = false

func _on_Detector_jogador_body_entered(body):
	esta_dentro_alcance()

func esta_dentro_alcance():
	var sobrepondo_corpos = $Detector_jogador.get_overlapping_bodies()
	
	for corpo in sobrepondo_corpos:
		if corpo.name == "Jogador": 
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
					break
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
					break
				break

func modo_oni():
	emit_signal("mudar_status_muzan", self)
	if vida <= 500:
		modo_oni = true
		if movendo_para_esquerda == true:
			$AnimationPlayer.play("Aparecer_Oni")
		elif movendo_para_esquerda == false:
			$AnimationPlayer.play("Aparecer_Oni_Direita")
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
		
	#Modo Oni
	if !sofreu_dano and modo_oni == true:
		if direcao.x != 0: 
			if movendo_para_esquerda == true:
				$AnimationPlayer.play("Correr_Oni")
			elif movendo_para_esquerda == false:
				$AnimationPlayer.play("Correr_Oni_Direita")
	elif sofreu_dano == true and modo_oni == true:
		$AnimationPlayer.play("Dano_Oni")
	

func _on_Hurtbox_area_entered(area):
	if area.is_in_group("projetil1"):
		_sofreu_dano(200, 0.3)
	elif area.is_in_group("projetil3"):
		_sofreu_dano(40, 0.3)
	elif area.is_in_group("projetil1_hinokami"):
		_sofreu_dano(60, 0.3)
	elif area.is_in_group("projetil3_hinokami"):
		_sofreu_dano(100, 0.3)

func _sofreu_dano(quantidade_dano, stun_bd):
	$AnimationPlayer.clear_queue()
	$Particles2D.emitting = true
	vida = vida - quantidade_dano
	emit_signal("mudar_status_muzan", self)
	$Som_dano.play()
	sofreu_dano = true
	yield(get_tree().create_timer(stun_bd), "timeout")
	$Particles2D.emitting = false
	sofreu_dano = false
	if vida < 0:
		$AnimationPlayer.play("Morte_Oni")
		yield($AnimationPlayer, "animation_finished")
		emit_signal("Muzan_morto")
		queue_free()

func _ataque_aleatorio():
	var atq_ale = RandomNumberGenerator.new()
	atq_ale.randomize()
	ataque_escolhido = atq_ale.randi_range(1, 4)
	#print("ERRADO", ataque_escolhido)

func _ataque_aleatorio_oni():
	var atq_ale = RandomNumberGenerator.new()
	atq_ale.randomize()
	ataque_escolhido_oni = atq_ale.randi_range(1, 6)
	#print("Oni ", ataque_escolhido_oni)

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
	if body.name == "Jogador" and ataque_escolhido == 1:
		body._sofreu_dano(45)
	elif body.name == "Jogador" and ataque_escolhido == 2:
		body._sofreu_dano(35)
	elif body.name == "Jogador" and ataque_escolhido == 3:
		body._sofreu_dano(40)
	elif body.name == "Jogador" and ataque_escolhido == 4:
		body._sofreu_dano(55)

func knockback():
	if sign(scale.x) == 1:
		direcao_knockback = 1
	elif sign(scale.x) == -1:
		direcao_knockback = -1
		
	movimento.x = direcao_knockback * intensidade_knockback
	movimento = move_and_slide(movimento)
