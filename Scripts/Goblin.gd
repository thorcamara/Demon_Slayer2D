extends KinematicBody2D


var movimento = Vector2(0, 0)
var velocidade_movimento = 50
var gravidade = 10

var vida = 100.0
var vida_maxima = 100.0
var regen_vida = 1.0

signal mudar_status_goblin

var sofreu_dano = false
var movendo_para_esquerda = false

var dentro_alcance = false

var quantidade_dano = 10

onready var bomba_instancia = preload("res://Projeteis/Bomba.tscn")

func _ready():
	$AnimationPlayer.play("Correr")
	$Vida/Barra.color = Color(0.04, 0.50, 0.10, 1)
	
func _process(delta: float):
	if $AnimationPlayer.current_animation == "Atacar":
		return
	elif $AnimationPlayer.current_animation == "Atacar2":
		return
		
	mover_inimigo()
	detectar_mudar_direcao()
	esta_dentro_alcance()
	esta_dentro_alcance2()
	cor_barra()
	
	var nova_vida = min(vida + regen_vida * delta, vida_maxima)
	if nova_vida != vida:
		vida = nova_vida
		emit_signal("mudar_status_goblin", self)
		
func mover_inimigo():
	movimento.x = -velocidade_movimento if movendo_para_esquerda else velocidade_movimento
	movimento.y += gravidade
	if !sofreu_dano:
		$AnimationPlayer.play("Correr")
	
	movimento = move_and_slide(movimento, Vector2.UP)

func detectar_mudar_direcao():
	if $RayCast2D.is_colliding() and is_on_floor():
		movendo_para_esquerda = !movendo_para_esquerda
		scale.x = -scale.x
		
	if not $RayCast2D2.is_colliding() and is_on_floor():
		movendo_para_esquerda = !movendo_para_esquerda
		scale.x = -scale.x
		

func andar():
	if dentro_alcance == false:
		$AnimationPlayer.play("Correr")

func atirou():
	$Detector_jogador_bomba.monitoring = false
	
func terminou_atirar():
	$Detector_jogador_bomba.monitoring = true
	
func hit():
	$Detector_ataque.monitoring = true

func fim_do_hit():
	$Detector_ataque.monitoring = false
	
func _atirar_bomba():
	atirou()
	var bomba = bomba_instancia.instance()
	get_parent().add_child(bomba)
	bomba.global_position = $Position2D.global_position
	
	if movendo_para_esquerda:
		bomba.direcao = -1
	else:
		bomba.direcao = 1

func _on_Detector_jogador_bomba_body_entered(body):
#	if !sofreu_dano and body.name == "Jogador":
#		$Detector_jogador_bomba.monitoring = false
#		$AnimationPlayer.play("Atacar")
	esta_dentro_alcance2()
		
func esta_dentro_alcance2():
	var sobrepondo_corpos = $Detector_jogador_bomba.get_overlapping_bodies()
	
	for corpo in sobrepondo_corpos:
		if corpo.name == "Jogador":
			dentro_alcance = true
			if !sofreu_dano:
				$AnimationPlayer.play("Atacar")
				yield($AnimationPlayer, "animation_finished")
			break
		else:
			dentro_alcance = false

func _on_Hurtbox_area_entered(area):
	if area.is_in_group("projetil1"):
		_sofreu_dano(20)
	elif area.is_in_group("projetil3"):
		_sofreu_dano(40)
	elif area.is_in_group("projetil1_hinokami"):
		_sofreu_dano(60)
	elif area.is_in_group("projetil3_hinokami"):
		_sofreu_dano(100)
		
func _sofreu_dano(quantidade_dano):
	$AnimationPlayer.clear_queue()
	$Particles2D.emitting = true
	vida = vida - quantidade_dano
	emit_signal("mudar_status_goblin", self)
	$AnimationPlayer.play("Dano")
	$Som_dano.play()
	sofreu_dano = true
	velocidade_movimento = 0
	yield($AnimationPlayer, "animation_finished")
	$Particles2D.emitting = false
	velocidade_movimento = 50
	sofreu_dano = false
	if vida < 0:
		queue_free()

func _on_Detector_jogador_ataque_body_entered(body):
	esta_dentro_alcance()

func esta_dentro_alcance():
	var sobrepondo_corpos = $Detector_jogador_ataque.get_overlapping_bodies()
	
	for corpo in sobrepondo_corpos:
		if corpo.name == "Jogador":
			dentro_alcance = true
			if !sofreu_dano:
				$AnimationPlayer.play("Atacar2")
				yield($AnimationPlayer, "animation_finished")
			break
		else:
			dentro_alcance = false

func _on_Detector_ataque_body_entered(body):
	if body.name == "Jogador":
		body._sofreu_dano(35)

func cor_barra():
	if $Vida/Barra.rect_size.x >= 28:
		$Vida/Barra.color = Color(0.04, 0.50, 0.10, 1.00)
	elif $Vida/Barra.rect_size.x < 14 and $Vida/Barra.rect_size.x > 7:
		$Vida/Barra.color = Color(1.00, 0.50, 0.10, 1.00)
	elif $Vida/Barra.rect_size.x < 7:
		$Vida/Barra.color = Color(0.76, 0.00, 0.00, 1.00)


func _on_Goblin_mudar_status_goblin(var Goblin):
	$Vida/Barra.rect_size.x = 28 * Goblin.vida / Goblin.vida_maxima
