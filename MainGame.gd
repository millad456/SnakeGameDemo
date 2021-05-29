extends Node2D

const SNAKE = 15 #15 is the image index number for the snake head sprite
const APPLE = 2 #2 is the image index number for the apple sprite
var spike_pos = [Vector2(2,2)] #this is the upside down apple. It is a list of position vectors that hold the position of each spike 
var apple_pos #holds the position of the apple in a vector
var snake_dir = Vector2(1,0) #essentially a velocity vector
var snake_body = [Vector2(5,10), Vector2(4,10), Vector2(3,10)] #array holding each inital position of the snake. the first index is the head
var add_apple = false


# Called when the node enters the scene tree for the first time.
func _ready():
	apple_pos = place_apple()
	#later add a function that reads the tile board and figures out where to place the spikes

func draw_spike():
	$TileMap.set_cell(spike_pos[0].x, spike_pos[0].y, 2, false, true, false)

#this function picks a random x and y position for the apple
func place_apple():
	randomize()
	var x = randi() % 20
	var y = randi() % 15
	return Vector2(x,y)

#yeah, idk why this is its own function unless you want to animate the apple/words. 
#wtv, the tutorial said to make this its own function so thats what I did
func draw_apple():
	$TileMap.set_cell(apple_pos.x, apple_pos.y, APPLE)

#will handle the graphics for the snake
func draw_snake():
	#for part in snake_body:
	#	$TileMap.set_cell(part.x, part.y, SNAKE, false,false,false);
	for i in snake_body.size():
		var block = snake_body[i]
		
		#draw the head
		if i == 0:
			var head_dir = relation2(snake_body[0], snake_body[1])
			if head_dir == 'right':
				#so in this function set_cell(block.x, block.y, 10)
				#that last number 10 refers to the index number for the image of the snake head looking right
				#and also $TileMap refers to where to draw the sprite. In this case, its the tilemap node named "TileMap" under the main game
				$TileMap.set_cell(block.x, block.y, 10)
			if head_dir == 'left':
				$TileMap.set_cell(block.x, block.y, 5)
			if head_dir == 'top':
				$TileMap.set_cell(block.x, block.y, 0)
			if head_dir == 'bottom':
				$TileMap.set_cell(block.x, block.y, 9)
		
		#okay so this entire else if statement and the else statement after are a total pain in the ass and IDK why
		#try uncommenting it and seeing what happens
		#I don't understand why that happens, I literally copied the tutorial code but changed shortened the variable names 
		#apparently that broke something? fuck me I guess
		elif i == snake_body.size() -1:
			var tail_dir = relation2(snake_body[-1], snake_body[-2])
#			if tail_dir == 'right':
#				$TileMap.set_cell(block.x, block.y, 4)
#			if tail_dir == 'left':
#				$TileMap.set_cell(block.x, block.y, 3)
#			if tail_dir == 'top':
#				$TileMap.set_cell(block.x, block.y, 8)
#			if tail_dir == 'bottom':
#				$TileMap.set_cell(block.x, block.y, 7)
#			
#		else:
#			var prev_block = snake_body[i + 1] - block
#			var next_block = snake_body[i - 1] - block
#
#			if prev_block.x == next_block.x:
#				$TileMap.set_cell(block.x, block.y, 11)
#			elif prev_block.y == next_block.y:
#				$TileMap.set_cell(block.x, block.y, 6)
			
		else:
			$TileMap.set_cell(block.x, block.y, SNAKE)

#this relation returns a direction vector between two body parts of the snake
#it basically just subtract's the vectors and finds what direction the corresponds to
func relation2(first_block:Vector2, second_block:Vector2):
	var block_relation = second_block - first_block
	if block_relation == Vector2(-1,0): return 'left'
	if block_relation == Vector2(1,0): return 'right'
	if block_relation == Vector2(0,1): return 'bottom'
	if block_relation == Vector2(0,-1): return 'top'


#You'll never guess what this function does
func move_snake():
	#means if you just collected the apple
	if add_apple:
		delete_tiles(SNAKE)
		#on that frame, don't delete the tail
		var body_copy = snake_body.slice(0,snake_body.size() - 1)
		var new_head = body_copy[0] + snake_dir
		body_copy.insert(0,new_head)
		snake_body = body_copy
		add_apple = false
	#else, delete the tail of the snake. 
	else:
		delete_tiles(SNAKE)
		var body_copy = snake_body.slice(0,snake_body.size() - 2)
		var new_head = body_copy[0] + snake_dir
		body_copy.insert(0,new_head)
		snake_body = body_copy
		
	#yeah, so its kind funny. in the games code, the snake doesn't actually move, it grows a new head, and we chop off its tail and give it the illusion of motion
	#game design is pretty fucked up isn't it?
#anyways, you can basically create a new function to move the axolotyl and animate it and stuff. So the move_snake function isn't really needed anymore

#use this function to delete a tile from the grid
func delete_tiles(id:int):
	var cells = $TileMap.get_used_cells_by_id(id)
	for cell in cells:
		$TileMap.set_cell(cell.x, cell.y, -1)

#this is where game inputs are handled. we use the "ui" controls because it allows for easier button mapping for controller support and different input styles
func _input(event):
	if Input.is_action_just_pressed("ui_up") and not snake_dir == Vector2(0,1): snake_dir = Vector2(0,-1)
	if Input.is_action_just_pressed("ui_right") and not snake_dir == Vector2(-1,0): snake_dir = Vector2(1,0)
	if Input.is_action_just_pressed("ui_left") and not snake_dir == Vector2(1,0): snake_dir = Vector2(-1,0)
	if Input.is_action_just_pressed("ui_down") and not snake_dir == Vector2(0,-1): snake_dir = Vector2(0,1)


#checks to see if the apple and snake body occupy the same tile. why the tutorial didn't use any Godot, in engine collision methods is beyond me
func check_apple_eaten():
	if apple_pos == snake_body[0]:
		apple_pos = place_apple()
		add_apple = true

func check_game_over():
	var head = snake_body[0]
	#snake lesves screen. remove this
	if head.x > 20 or head.x < 0 or head.y > 15 or head.y < 0:
		reset()
	#snake runs into its own tail
	for part in snake_body.slice(1, snake_body.size() - 1):
		if part == head:
			reset() 
	for spike in spike_pos:
		if spike == snake_body[0]:
			reset() 
	
#reset needs to reset any and all relevant variables related to the game when the player respawns
func reset():
	snake_dir = Vector2(1,0)
	snake_body = [Vector2(5,10), Vector2(4,10), Vector2(3,10)]
	add_apple = false

#this is actually the main function that keeps ge
func _on_SnakeTick_timeout():
	move_snake()
	draw_apple()
	draw_snake()
	check_apple_eaten()
	draw_spike()
	
#delta controls the number of times the game runs per second
func _process(delta):
	check_game_over()
