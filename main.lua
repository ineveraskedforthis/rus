love.window.setMode(1280, 720)
local ui = require "milky.milky"
ui.set_reference_screen_dimensions(1280, 720)

---@type table<NodeID, Node>
NODES = {}
PRICE = {}

CONNECTIONS = {}
NODE_TO_CONNECTION = {}
NODE_NODE_CONNECTION = {}

---@alias AgentID number
---@alias NodeID string

---@type AgentID
FREE_AGENT_ID = 1

---@alias time number

---@class Agent
---@field name string
---@field capacity number
---@field node NodeID
---@field target_node NodeID
---@field travel_time time

---@type table<AgentID, Agent>
AGENTS = {}

NODE_NAME_RECTS = {}
NODE_MODEL_RECTS = {}

SCALE = 5


SELECTED_NODE = nil

--- CAMERA ---
SCREEN_CENTER = {x= 1280 / 2, y= 720 / 2}

CAMERA = {x= -300, y= -100}
CAMERA_SPEED = {x= 0, y= 0}
CAMERA_FRICTION = 0.5
CAMERA_DIR = {x = 0, y = 0}

ZOOM = 1
ZOOM_SPEED = 0
ZOOM_FRICTION = 0.1
ZOOM_DIR = 0



function Connect(a, b)
	table.insert(CONNECTIONS, {a, b})
	if NODE_TO_CONNECTION[a] == nil then
		NODE_TO_CONNECTION[a] = {}
		NODE_NODE_CONNECTION[a] = {}
	end
	if NODE_TO_CONNECTION[b] == nil then
		NODE_TO_CONNECTION[b] = {}
		NODE_NODE_CONNECTION[b] = {}
	end

	NODE_NODE_CONNECTION[a][b] = true
	NODE_NODE_CONNECTION[b][a] = true
	table.insert(NODE_TO_CONNECTION[a], b)
	table.insert(NODE_TO_CONNECTION[b], a)
end

GOODS = {
	"furs", "cloth",
	"silver", "iron",
	"wine", "farms", "honey"
}

CONSUMER_GOODS = {"cloth", "wine", "honey", "farms"}
MILITARY_GOODS = {"iron"}
LUXURY_GOODS = {"furs", "silver"}

INDUSTRY_SIZE = {}
INDUSTRY_PSIZE = {}
STOCK = {}

---@class Node
---@field x number
---@field y number
---@field population number
---@field name string
---@field prosperity number

---returns estimation for travel time between two nodes 
---@param a NodeID
---@param b NodeID
---@return time
function Travel_time(a, b)
  A = NODES[a]
  B = NODES[b]

  return math.abs(A.x - B.x) + math.abs(A.y - B.y)
end

function Create_node(name, x, y, population)
	PRICE[name] = {}
	INDUSTRY_SIZE[name] = {}
	INDUSTRY_PSIZE[name] = {}
	STOCK[name] = {}

	for _, item in pairs(GOODS) do
		PRICE[name][item] = 15
		INDUSTRY_SIZE[name][item] = 0
		INDUSTRY_PSIZE[name][item] = 0
		STOCK[name][item] = 0
	end

	NODES[name] = {}
	NODES[name].x = x
	NODES[name].y = y
	NODES[name].population = population
	NODES[name].name = name
	NODES[name].prosperity = 25

	NODE_MODEL_RECTS[name] = ui.rect(
		x - SCALE,
		y - SCALE,
		SCALE * 2,
		SCALE * 2)
	NODE_NAME_RECTS[name] = ui.rect(
		x - 50,
		y - SCALE * 2 ,
		100 ,
		SCALE)
end

function Add_potential_industry(node, industry, size)
	INDUSTRY_PSIZE[node][industry] = INDUSTRY_PSIZE[node][industry] + size
end

function Add_industry(node, industry, size)
	INDUSTRY_SIZE[node][industry] = INDUSTRY_SIZE[node][industry] + size
end

function Update_local_base_price()
	for node, node_entity in pairs(NODES) do
		local production = {}
		local consumption = {}
		for _, goods in pairs(CONSUMER_GOODS) do
			consumption[goods] = node_entity.population / 1000
		end
  	for _, goods in pairs(LUXURY_GOODS) do
		  consumption[goods] = node_entity.population / 1000 * node_entity.prosperity / 100
	  end
  	for _, goods in pairs(MILITARY_GOODS) do
		  consumption[goods] = node_entity.population / 10000
	  end
	  for _, goods in pairs(GOODS) do
		  production[goods] = INDUSTRY_SIZE[node][goods] + 0.1
  	end
	  for _, goods in pairs(GOODS) do
      local demand = math.max(10, consumption[goods]) / (math.max(1, PRICE[node][goods]))
		  local price_drift = (demand - production[goods]) / (demand + production[goods]) * 2
      price_drift = math.floor(price_drift + 0.5)
      PRICE[node][goods] = math.max(1, math.floor((PRICE[node][goods] + price_drift)))
	  end
	end
end

---Creates new 
---@param name string
---@param node NodeID
---@return AgentID
function Create_agent(name, node)
	AGENTS[FREE_AGENT_ID] = {}
	AGENTS[FREE_AGENT_ID].name = name
	AGENTS[FREE_AGENT_ID].node = node
  AGENTS[FREE_AGENT_ID].target_node = node
	AGENTS[FREE_AGENT_ID].capacity = 5
  AGENTS[FREE_AGENT_ID].travel_time = 0
	FREE_AGENT_ID = FREE_AGENT_ID + 1

	return FREE_AGENT_ID - 1
end

function Event_hanseatic_traders()

end

---Moves player to node
---@param node NodeID
function Player_move(node)
  if PLAYER.target_node ~= PLAYER.node then
    return
  end
	if NODE_NODE_CONNECTION[node][PLAYER.node] then
		PLAYER.target_node = node
    Update_player_local_paths()
	end
end

function Player_update(dt)
  if PLAYER.target_node ~= PLAYER.node then
    PLAYER.travel_time = PLAYER.travel_time + dt * 100
  end

  if PLAYER.travel_time > Travel_time(PLAYER.node, PLAYER.target_node) then
    PLAYER.node = PLAYER.target_node
    PLAYER.travel_time = 0
    Update_player_local_paths()
  end
end

function Player_draw()
  if PLAYER.node == PLAYER.target_node then
    local x = DISPLAY[PLAYER.node].x
    local y = DISPLAY[PLAYER.node].y
    love.graphics.circle('line', x, y, 10)
    return
  end
  local ratio = PLAYER.travel_time / Travel_time(PLAYER.node, PLAYER.target_node)
  local x = DISPLAY[PLAYER.node].x * (1 - ratio) + DISPLAY[PLAYER.target_node].x * ratio
  local y = DISPLAY[PLAYER.node].y * (1 - ratio) + DISPLAY[PLAYER.target_node].y * ratio
  love.graphics.circle('line', x, y, 10)
  love.graphics.circle('line', DISPLAY[PLAYER.target_node].x, DISPLAY[PLAYER.target_node].y, 20)
end

TRADE_ROUTES = {}
TRADE_ROUTES_BY_START = {}
TRADE_ROUTES_BY_END = {}


Trade_route = {}
Trade_route.new = function(start_node, end_node, good, owner)
  local trade_route = {}

  trade_route.start = start_node

  return trade_route
end

---Establish trade route, which buys good in a start node and sells in the end node
---@param start_node Node
---@param end_node Node
---@param good goods
---@param owner Agent
function Establish_trade_route(start_node, end_node, good, owner)
  TRADE_ROUTES.push(trade_route)

  return trade_route
end


function love.load()
	local font_size = ui.font_size(14)
	local font_to_use = love.graphics.newFont(font_size)
	love.graphics.setFont(font_to_use)

	Create_node("Novgorod", 200, 100, 40000)
  Add_industry("Novgorod", "furs", 50)
  Add_industry("Novgorod", "cloth", 10)
  Add_industry("Novgorod", "iron", 10)
  Add_industry("Novgorod", "farms", 5)
  Add_industry("Novgorod", "honey", 10)

	Create_node("Torzhok",		200, 160,	  2000)

	Create_node("Tver", 		210, 180,	 10000)
	Create_node("Volok Lamsky",	180, 210,          500)
	Create_node("Yaroslavl",	300, 190,        15000)
	Create_node("Rostov",		280, 220,         8000)

	Create_node("Kostroma",		340, 270,	  2000)
	Create_node("Nizhny Novgorod",  350, 300,	  9000)
	Create_node("Vladimir",		250, 290,	 25000)


	Create_node("Bulgaria",		600, 320,	100000)



	Create_node("Visby",		40,  40,	  4000)
	Create_node("Riga",		50,  100,	 20000)
	Create_node("Pskov",		120, 120,	 20000)
	Create_node("Neva",		200, 50,	   700)
  Add_industry("Neva", "iron", 40)


	Connect("Tver", "Yaroslavl")
	Connect("Tver", "Volok Lamsky")
	Connect("Tver", "Torzhok")
	Connect("Volok Lamsky", "Vladimir")

	Connect("Yaroslavl", "Rostov")
	Connect("Yaroslavl", "Kostroma")

	Connect("Nizhny Novgorod", "Vladimir")
	Connect("Nizhny Novgorod", "Bulgaria")
	Connect("Nizhny Novgorod", "Kostroma")

	Connect("Novgorod", "Pskov")
	Connect("Novgorod", "Neva")
	Connect("Novgorod", "Torzhok")

	Connect("Riga", "Pskov")

	PLAYER_ID = Create_agent('Player', 'Novgorod')
	PLAYER = AGENTS[PLAYER_ID]

	LOCAL_ACTIONS = ui.rect(1280 - 505, 005, 500, 200)
	LOCAL_PRICES = {}
	MARGINS = 4
	HEIGHTS = 20
	for _, item in ipairs(GOODS) do
		LOCAL_PRICES[item] = {}
		LOCAL_PRICES[item].label = LOCAL_ACTIONS:subrect(MARGINS, MARGINS + (_ - 1) * HEIGHTS, 100, HEIGHTS, "left", "up")
		LOCAL_PRICES[item].price = LOCAL_ACTIONS:subrect(MARGINS * 2 + 100, MARGINS + (_ - 1) * HEIGHTS, 100, HEIGHTS, "left", "up")
	end

	LOCAL_PATHS = ui.rect(5, 5, 300, 600)
	Update_local_base_price()

	Update_player_local_paths()
end

function Update_player_local_paths()
	local node = PLAYER.node
  LOCAL_PATHS_UI_LIST = {}
	for _, target in pairs(NODE_TO_CONNECTION[node]) do
		local action_move_rect = LOCAL_PATHS:subrect(5, _ * 30, 290, 20, 'left', 'up')
		LOCAL_PATHS_UI_LIST[target] = action_move_rect
	end
end

PRICE_UPDATE_TIMER = 0


function love.update(dt)
	---  CAMERA UPDATES ---
	ZOOM_SPEED = math.min(500, math.max(-500, ZOOM_SPEED + dt * ZOOM_DIR * 50 ))
	ZOOM = math.min(math.max(ZOOM * math.exp(ZOOM_SPEED * dt), 0), 5)
	ZOOM_SPEED = ZOOM_SPEED * math.exp(-dt) * (1 - ZOOM_FRICTION)

	CAMERA_SPEED.x = math.min(500, math.max(-500, CAMERA_SPEED.x + 5000 * dt * CAMERA_DIR.x))
	CAMERA_SPEED.y = math.min(500, math.max(-500, CAMERA_SPEED.y + 5000 * dt * CAMERA_DIR.y))

	CAMERA.x = math.min(math.max(CAMERA.x + CAMERA_SPEED.x * dt))
	CAMERA.y = math.min(math.max(CAMERA.y + CAMERA_SPEED.y * dt))

	CAMERA_SPEED.x = CAMERA_SPEED.x * (1 - CAMERA_FRICTION)
	CAMERA_SPEED.y = CAMERA_SPEED.y * (1 - CAMERA_FRICTION)

	PRICE_UPDATE_TIMER = PRICE_UPDATE_TIMER + dt
	if (PRICE_UPDATE_TIMER > 0.1) then
		Update_local_base_price()
		PRICE_UPDATE_TIMER = 0
	end

  Player_update(dt)
end

DISPLAY = {}

function APPLY_ZOOM(p)
	return {
		x= (p.x - SCREEN_CENTER.x) * ZOOM + SCREEN_CENTER.x,
		y= (p.y - SCREEN_CENTER.y) * ZOOM + SCREEN_CENTER.y
	}
end


function APPLY_CAMERA(p)
	return {
	x= (p.x - CAMERA.x),
	y= (p.y - CAMERA.y)
	}
end

function love.draw()
	--- creating display node rectangles
	for name, node in pairs(NODES) do
		DISPLAY[name] = APPLY_ZOOM(APPLY_CAMERA(node))
		local rect = NODE_MODEL_RECTS[name]

		SIZE = math.sqrt(node.population / 5000)

		rect.x = DISPLAY[name].x - SCALE * ZOOM * SIZE
		rect.y = DISPLAY[name].y - SCALE * ZOOM * SIZE
		rect.width = SCALE * 2 * ZOOM * SIZE
		rect.height = SCALE * 2 * ZOOM * SIZE

		local name_rect = NODE_NAME_RECTS[name]
		name_rect.x = DISPLAY[name].x - 50
		name_rect.y = DISPLAY[name].y - SCALE
	end


	love.graphics.setColor(0, 0.2, 0.2)
	for name, node in pairs(NODES) do
		ui.outline(NODE_MODEL_RECTS[name])
	end

	for _, connection in pairs(CONNECTIONS) do
		local node1 = DISPLAY[connection[1]]
		local node2 = DISPLAY[connection[2]]
		love.graphics.line(node1.x, node1.y, node2.x, node2.y)
	end

  Player_draw()

	love.graphics.setColor(1, 1, 1)
	if (SELECTED_NODE ~= nil) then
		love.graphics.circle('line',
		DISPLAY[SELECTED_NODE.name].x, DISPLAY[SELECTED_NODE.name].y, 15)
	end


	love.graphics.setLineWidth(2)
	love.graphics.setColor(1, 0.4, 0.4)
	for name, node in pairs(NODES) do
		ui.centered_text(name, NODE_NAME_RECTS[name])
	end

	love.graphics.setColor(0.3, 0.7, 0.8)
	ui.outline(LOCAL_ACTIONS)
	for _, item in pairs(GOODS) do
		ui.outline( LOCAL_PRICES[item].label )
		ui.text( item, LOCAL_PRICES[item].label, 'left', 'center' )
		ui.outline( LOCAL_PRICES[item].price )

		ui.text(
			PRICE[PLAYER.node][item],
			LOCAL_PRICES[item].price,
			"right",
      "center"
		)
	end

  ui.outline(LOCAL_PATHS)
  for node, rect in pairs(LOCAL_PATHS_UI_LIST) do
    ui.outline(rect)
    if ui.text_button( node, rect ) then
      Player_move(node)
    end
  end

	ui.finalize_frame()
end

--- draw small grid instead of rectangle depending on population
function DRAW_CITY()
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

	SELECTED_NODE = nil
	for name, raw_node in pairs(NODES) do
		local node = APPLY_ZOOM(APPLY_CAMERA(raw_node))
		if   (node.x - x) * (node.x - x)
		   + (node.y - y) * (node.y - y) < 400 then
			SELECTED_NODE = raw_node
			break
		end
	end

end

function love.wheelmoved(x, y)
	ui.on_wheelmoved(x, y)
end
