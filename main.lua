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
	nodes[name].x = x*2
	nodes[name].y = y*2
	nodes[name].name = name
	
	node_model_rects[name] = ui.rect(
		x*2 - SCALE, 
		y*2 - SCALE, 
		SCALE * 2, 
		SCALE * 2)
	node_name_rects[name] = ui.rect(
		x*2 - 50, 
		y*2 - SCALE * 2 , 
		50 * 2, 
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
end

function love.update(dt)

end

function love.draw()
	love.graphics.setColor(0, 0.2, 0.2)
	for name, node in pairs(nodes) do
		ui.outline(node_model_rects[name])
	end

	for _, connection in pairs(connections) do
		print(connection[1], connection[2])
		local node1 = nodes[connection[1]]
		local node2 = nodes[connection[2]]
		love.graphics.line(node1.x, node1.y, node2.x, node2.y)
	end


	draw_player()

	love.graphics.setLineWidth(2)
	love.graphics.setColor(1, 0.4, 0.4)
	for name, node in pairs(nodes) do
		ui.centered_text(name, node_name_rects[name])
	end

	ui.finalize_frame()
end

function draw_player()
	local node = nodes[player.node]
	love.graphics.circle('line', node.x, node.y, 10)
end


function love.keypressed(key)
	ui.on_keypressed(key)
end

function love.keyreleased(key)
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
end

function love.wheelmoved(x, y)
	ui.on_wheelmoved(x, y)
end