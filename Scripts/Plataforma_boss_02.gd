extends KinematicBody2D

onready var resetar_posicao = global_position

var movimento = Vector2.ZERO
var gravidade = 720
var acionada = false
export var resetar_timer = 5.0

func _ready():
	set_physics_process(false)

func _physics_process(delta: float):
	movimento.y += gravidade * delta
	position += movimento * delta

func colidir_com(colisao: KinematicCollision2D, collider: KinematicBody2D):
	if !acionada:
		acionada = true
		$AnimationPlayer.play("Ativada")
		movimento = Vector2.ZERO


func _on_AnimationPlayer_animation_finished(anim_name):
	set_physics_process(true)
	$Timer.start(resetar_timer)



func _on_Timer_timeout():
	set_physics_process(false)
	yield(get_tree(), "physics_frame")
	var layer_temporaria = collision_layer
	collision_layer = 0
	global_position = resetar_posicao
	yield(get_tree(), "physics_frame")
	collision_layer = layer_temporaria
	acionada = false
	
	
	


func _on_Guerreiro_trevas_Guerreiro_trevas_morto():
	pass # Replace with function body.
