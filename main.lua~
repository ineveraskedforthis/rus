love.window.setMode(1280, 720)
ui = require "milky.milky"
ui.set_reference_screen_dimensions(1280, 720)
nodes = {}
price = {}

connections = {}
node_to_connection = {}
node_node_connection = {}

free_agent_id = 1
agents = {}

node_name_rects = {}
node_model_rects = {}

SCALE = 5 


selected_node = nil

--- CAMERA ---
SCREEN_CENTER = {x= 1280 / 2, y= 720 / 2}

CAMERA = {x= 0, y= 0}
CAMERA_SPEED = {x= 0, y= 0}
CAMERA_FRICTION = 0.5
CAMERA_DIR = {x = 0, y = 0}

ZOOM = 1
ZOOM_SPEED = 0
ZOOM_FRICTION = 0.1
ZOOM_DIR = 0



function connect(a, b)
	table.insert(connections, {a, b})
	if node_to_connection[a] == nil then
		node_to_connection[a] = {}
		node_node_connection[a] = {}
	end
	if node_to_connection[b] == nil then
		node_to_connection[b] = {}
		node_node_connection[b] = {}
	end

	node_node_connection[a][b] = true
	node_node_connection[b][a] = true
	table.insert(node_to_connection[a], b)
	table.insert(node_to_connection[b], a)
end

function create_node(name, x, y, price_furs, price_cloth) 
	price[name] = {}
	price[name]["furs"] = price_furs
	price[name]["cloth"] = price_cloth

	nodes[name] = {}
	nodes[name].x = x
	nodes[name].y = y
	nodes[name].name = name
	
	node_model_rects[name] = ui.rect(
		x - SCALE, 
		y - SCALE, 
		SCALE * 2, 
		SCALE * 2)
	node_name_rects[name] = ui.rect(
		x - 50, 
		y - SCALE * 2 , 
		100 , 
		SCALE)
end

function create_agent(name, node)
	agents[free_agent_id] = {}
	agents[free_agent_id].name = name
	agents[free_agent_id].node = node
	free_agent_id = free_agent_id + 1

	return free_agent_id - 1
end

function event_hanseatic_traders()

end

function buy()

end

function sell()

end

function effect_change_price(region, good, dx) 
	price[region][good] = price[region][good] + dx
end

function love.load()
	local font_size = ui.font_size(14)
	local font_to_use = love.graphics.newFont(font_size)
	love.graphics.setFont(font_to_use)

	create_node("Novgorod", 	200, 100, 	10,  10)
	create_node("Torzhok",		200, 160,	12,  15)

	create_node("Tver", 		210, 180,	15,  15)
	create_node("Volok Lamsky",	180, 210,       15,  15)
	create_node("Yaroslavl",	300, 190,       15,  15)
	create_node("Rostov",		280, 220,       15,  15)

	create_node("Kostroma",		340, 270,	15,15)
	create_node("Nizhny Novgorod",  350, 300,	15,15)
	create_node("Vladimir",		250, 290,	15,15)
	

	create_node("Bulgaria",		600, 320,	15,15)

	
	create_node("Visby",		40,  40,	20,  5)
	create_node("Riga",		50,  100, 	20,  5)
	create_node("Pskov",		120, 120,	12, 12)
	create_node("Neva",		200, 50,	12, 12)



	connect("Tver", "Yaroslavl")
	connect("Tver", "Volok Lamsky")
	connect("Tver", "Torzhok")
	connect("Volok Lamsky", "Vladimir")

	connect("Yaroslavl", "Rostov")
	connect("Yaroslavl", "Kostroma")
	
	connect("Nizhny Novgorod", "Vladimir")
	connect("Nizhny Novgorod", "Bulgaria")
	connect("Nizhny Novgorod", "Kostroma")
	
	connect("Novgorod", "Pskov")
	connect("Novgorod", "Neva")
	connect("Novgorod", "Torzhok")
	
	connect("Riga", "Pskov")

	player_id = create_agent('Player', 'Novgorod')
	player = agents[player_id]

	local_prices = ui.rect(1280 - 505, 005, 500, 200)
end

function love.update(dt)
	---  CAMERA UPDATES ---
	ZOOM_SPEED = math.min(5, math.max(-5, ZOOM_SPEED + dt * ZOOM_DIR))
	ZOOM = math.min(math.max(ZOOM * math.exp(ZOOM_SPEED * dt), 0), 10)
	ZOOM_SPEED = ZOOM_SPEED * math.exp(-dt) * (1 - ZOOM_FRICTION)
	
	CAMERA_SPEED.x = math.min(500, math.max(-500, CAMERA_SPEED.x + 5000 * dt * CAMERA_DIR.x))
	CAMERA_SPEED.y = math.min(500, math.max(-500, CAMERA_SPEED.y + 5000 * dt * CAMERA_DIR.y))

	CAMERA.x = math.min(math.max(CAMERA.x + CAMERA_SPEED.x * dt))
	CAMERA.y = math.min(math.max(CAMERA.y + CAMERA_SPEED.y * dt))

	CAMERA_SPEED.x = CAMERA_SPEED.x * (1 - CAMERA_FRICTION)
	CAMERA_SPEED.y = CAMERA_SPEED.y * (1 - CAMERA_FRICTION)
end

display = {}

function apply_zoom(p)
	return {
		x= (p.x - SCREEN_CENTER.x) * ZOOM + SCREEN_CENTER.x,
		y= (p.y - SCREEN_CENTER.y) * ZOOM + SCREEN_CENTER.y
	}
end

function apply_camera(p) 
	return {
	x= (p.x - CAMERA.x),
	y= (p.y - CAMERA.y)
	}
end

function love.draw()
	for name, node in pairs(nodes) do
		display[name] = apply_zoom(apply_camera(node)) 	
		local rect = node_model_rects[name]
		rect.x = display[name].x - SCALE * ZOOM
		rect.y = display[name].y - SCALE * ZOOM
		rect.width = SCALE * 2 * ZOOM
		rect.height = SCALE * 2 * ZOOM

		local name_rect = node_name_rects[name]
		name_rect.x = display[name].x - 50 
		name_rect.y = display[name].y - SCALE
	end

	love.graphics.setColor(0.3, 0.7, 0.8)
	ui.outline(local_prices)

	love.graphics.setColor(0, 0.2, 0.2)
	for name, node in pairs(nodes) do
		ui.outline(node_model_rects[name])
	end

	for _, connection in pairs(connections) do
		local node1 = display[connection[1]]
		local node2 = display[connection[2]]
		love.graphics.line(node1.x, node1.y, node2.x, node2.y)
	end


	draw_player()

	love.graphics.setColor(1, 1, 1)
	if (selected_node ~= nil) then
		love.graphics.circle('line',
		selected_node.x, selected_node.y, 15)
	end


	love.graphics.setLineWidth(2)
	love.graphics.setColor(1, 0.4, 0.4)
	for name, node in pairs(nodes) do
		ui.centered_text(name, node_name_rects[name])
	end

	ui.finalize_frame()
end

function draw_player()
	love.graphics.setColor(0.3, 0.7, 0.8)
	local node = display[player.node]
	love.graphics.circle('line', node.x, node.y, 10)
end


function love.keypressed(key)
	ui.on_keypressed(key)
	if (key == "j") then
		ZOOM_DIR = -1
	end
	if (key == "k") then
		ZOOM_DIR = 1
	end

	if (key == "w") then
		CAMERA_DIR.y = -1
	end
	if (key == "s") then
		CAMERA_DIR.y = 1
	end
	if (key == "a") then
		CAMERA_DIR.x = -1
	end
	if (key == "d") then
		CAMERA_DIR.x = 1
	end
end

function love.keyreleased(key)
	if (key == "j") and ZOOM_DIR == -1 then
		ZOOM_DIR = 0
	end
	if (key == "k") and ZOOM_DIR == 1 then
		ZOOM_DIR = 0
	end
	
	if (key == "w") and CAMERA_DIR.y == -1 then
		CAMERA_DIR.y = 0
	end
	if (key == "s") and CAMERA_DIR.y == 1 then
		CAMERA_DIR.y = 0
	end
	if (key == "a") and CAMERA_DIR.x == -1 then
		CAMERA_DIR.x = 0
	end
	if (key == "d") and CAMERA_DIR.x == 1 then
		CAMERA_DIR.x = 0
	end
	ui.on_keyreleased(key)
end

function love.mousepressed(x, y, button, istouch, presses)
	ui.on_mousepressed(x, y, button, istouch, presses)
end

function love.mousereleased(x, y, button, istouch, presses)
	ui.on_mousereleased(x, y, button, istouch, presses)
end

function love.mousemoved(x, y, dx, dy, istouch)
	ui.on_mousemoved(x, y, dx, dy, istouch)

	selected_node = nil
	for name, node in pairs(nodes) do
		if   (node.x - x) * (node.x - x)
		   + (node.y - y) * (node.y - y) < 400 then
			selected_node = node
			break
		end
	end

end

function love.wheelmoved(x, y)
	ui.on_wheelmoved(x, y)
end
