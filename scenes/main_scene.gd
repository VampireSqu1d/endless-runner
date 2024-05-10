extends Node

const DINO_START_POS := Vector2i(150, 485)
const CAM_START_POS := Vector2i(576, 324)

var barrel = preload("res://scenes/barrel.tscn")
var stump = preload("res://scenes/stump.tscn")
var bird = preload("res://scenes/bird.tscn")
var rock = preload("res://scenes/rock.tscn")
var obstacle_types = [barrel, stump, rock] 
var obstacles : Array
var bird_heights = [200, 390]


var speed : float
@export var START_SPEED: float = 10.0
@export var MAX_SPEED: int  = 25
@export var SPEED_MODIFIER: int = 5000
const SCORE_MODIFIER: int = 10

var ground_height
var screen_size: Vector2i
var score : int
var high_score : int
var game_running: bool = false
var last_obs : Area2D

@onready var dino = %Dino as Dino
@onready var cam = %Camera2D as Camera2D
@onready var ground = %Ground
@onready var HUD = %HUD as CanvasLayer

func _ready():
	ground_height = ground.get_node("Sprite2D").texture.get_height()
	screen_size = get_window().size
	new_game()
	


func new_game():
	score = 0
	dino.position = DINO_START_POS
	dino.velocity = Vector2i(0, 0)
	cam.position = CAM_START_POS
	$Ground.position = Vector2i(0, 552)
	HUD.get_node("StartLabel").visible = true
	


func _process(delta):
	if game_running:
		if speed < MAX_SPEED:
			speed = START_SPEED + score / SPEED_MODIFIER
		
		dino.position.x += speed
		cam.position.x += speed
		
		generate_obs()
		
		score += speed
		show_score()
		if cam.position.x - ground.position.x > screen_size.x * 1.5:
			ground.position.x += screen_size.x
		
		for obs in obstacles:
			if obs.position.x < (cam.position.x - screen_size.x):
				obs.queue_free()
				obstacles.erase(obs)
		
	else:
		if Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("jump"):
			game_running = true
			HUD.get_node("StartLabel").visible = false
	


func clear_obs():
	for obs in obstacles:
		if obs.position.x < (cam.position.x - screen_size.x):
			obs.queue_free()
			obstacles.erase(obs)


func show_score():
	HUD.get_node("ScoreLabel").text = "Score: " + str(score / SCORE_MODIFIER )
	


func generate_obs():
	var obs
	var obs_x: int
	var obs_y: int
	if obstacles.is_empty() or last_obs.position.x < score + randi_range(300, 400):
		var obs_type = obstacle_types[randi() % obstacle_types.size()]

		obs = obs_type.instantiate()
		var obstacle_height = obs.get_node("Sprite2D").texture.get_height()
		var obstacle_scale = obs.get_node("Sprite2D").scale
		obs_x = screen_size.x + score + 100
		obs_y = screen_size.y - ground_height - (obstacle_height * obstacle_scale.y / 2) + 5
		last_obs = obs
		add_obs(obs, obs_x, obs_y)
	
		if score > 1000:
			if (randi() % 3) == 0:
				obs = bird.instantiate()
				obs_x = screen_size.x + score + 100
				obs_y = bird_heights[randi() % bird_heights.size()]
				add_obs(obs, obs_x, obs_y)


func add_obs(obs, x, y):
	obs.position = Vector2i(x, y)
	obs.body_entered.connect(hit_obs)
	add_child(obs)
	obstacles.append(obs)


func hit_obs(body):
	print("hit obstcle")
	game_over()
	


func update_highscore():
	if (score > high_score):
		high_score = score
		HUD.get_node("HighScore").text = "HighScore: " + str(high_score / SCORE_MODIFIER)

func game_over():
	game_running = false
	update_highscore()
	HUD.get_node("ScoreLabel").text = "Score: 0"
	
	last_obs.position.x = 1250
	new_game()
	
