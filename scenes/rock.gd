extends Area2D

signal dino_crshed_rock


func _on_body_entered(body):
	dino_crshed_rock.emit()
