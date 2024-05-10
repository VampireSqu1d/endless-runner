extends CharacterBody2D

class_name Dino

@export var GRAVITY : int = 4200
@export var JUMP_SPEED: int = -1800

func _physics_process(delta):
	velocity.y += GRAVITY * delta
	if not get_parent().game_running:
		$AnimatedSprite2D.play("Idle")
	else:
		if is_on_floor():
			$RunnigCol.disabled = false
			if Input.is_action_pressed("jump") or Input.is_action_pressed("ui_up"):
				velocity.y = JUMP_SPEED
				$JumpSound.play()
			elif Input.is_action_pressed("ui_down"):
				$AnimatedSprite2D.play("ducking")
				$DuckingCol.disabled = false
				$RunnigCol.disabled = true
			else:
				$AnimatedSprite2D.play("running")
				$DuckingCol.disabled = true
		else: 
			$AnimatedSprite2D.play("jumping")
		
	move_and_slide()
