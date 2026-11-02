local W, H = 1280, 720
local palette = {
  bg = {0.035, 0.055, 0.085}, panel = {0.065, 0.095, 0.135}, line = {0.16, 0.22, 0.29},
  white = {0.91, 0.95, 0.98}, muted = {0.48, 0.57, 0.66}, cyan = {0.25, 0.88, 0.92},
  coral = {1.0, 0.43, 0.36}, gold = {1.0, 0.79, 0.38}
}
local game = {state = 'menu', score1 = 0, score2 = 0, rally = 0, serveDirection = 1, hitFlash = 0, shake = 0}
local player1, player2, ball
local font, smallFont, scoreFont, titleFont

local function setColor(c, a)
  love.graphics.setColor(c[1], c[2], c[3], a or 1)
end

local function resetBall(direction)
  ball = {x = W / 2 - 10, y = H / 2 - 10, width = 20, height = 20,
    dx = 430 * (direction or game.serveDirection), dy = love.math.random(-190, 190)}
  if math.abs(ball.dy) < 70 then ball.dy = ball.dy < 0 and -100 or 100 end
  game.state = 'serve'
end

local function resetMatch()
  player1 = {x = 58, y = H / 2 - 62, width = 15, height = 124, speed = 510}
  player2 = {x = W - 73, y = H / 2 - 62, width = 15, height = 124, speed = 510}
  game.score1, game.score2, game.rally, game.serveDirection = 0, 0, 0, 1
  resetBall(1)
end

function love.load()
  love.window.setMode(W, H, {resizable = false, vsync = 1})
  love.window.setTitle('RALLY — Arcade Pong')
  love.graphics.setDefaultFilter('linear', 'linear')
  font = love.graphics.newFont(18)
  smallFont = love.graphics.newFont(13)
  scoreFont = love.graphics.newFont(76)
  titleFont = love.graphics.newFont(54)
  love.graphics.setFont(font)
  love.math.setRandomSeed(os.time())
  resetMatch()
  game.state = 'menu'
end

local function clampPaddles(dt)
  if love.keyboard.isDown('w') then player1.y = player1.y - player1.speed * dt end
  if love.keyboard.isDown('s') then player1.y = player1.y + player1.speed * dt end
  if love.keyboard.isDown('up') then player2.y = player2.y - player2.speed * dt end
  if love.keyboard.isDown('down') then player2.y = player2.y + player2.speed * dt end
  player1.y = math.max(34, math.min(H - 34 - player1.height, player1.y))
  player2.y = math.max(34, math.min(H - 34 - player2.height, player2.y))
end

local function overlaps(a, b)
  return a.x < b.x + b.width and a.x + a.width > b.x and
    a.y < b.y + b.height and a.y + a.height > b.y
end

local function paddleBounce(paddle, direction)
  ball.x = direction == 1 and paddle.x + paddle.width + 1 or paddle.x - ball.width - 1
  local offset = (ball.y + ball.height / 2 - (paddle.y + paddle.height / 2)) / (paddle.height / 2)
  ball.dx = direction * math.min(math.abs(ball.dx) * 1.055, 900)
  ball.dy = math.max(-520, math.min(520, ball.dy + offset * 145))
  game.rally = game.rally + 1
  game.hitFlash = 0.12
end

local function scorePoint(player)
  if player == 1 then game.score1 = game.score1 + 1; game.serveDirection = 1
  else game.score2 = game.score2 + 1; game.serveDirection = -1 end
  game.rally = 0
  if game.score1 >= 7 or game.score2 >= 7 then game.state = 'gameover'
  else resetBall(game.serveDirection) end
end

function love.update(dt)
  dt = math.min(dt, 1 / 30)
  game.hitFlash = math.max(0, game.hitFlash - dt)
  game.shake = math.max(0, game.shake - dt * 22)
  if game.state == 'menu' or game.state == 'gameover' then return end
  clampPaddles(dt)
  if game.state ~= 'playing' then return end

  ball.x = ball.x + ball.dx * dt
  ball.y = ball.y + ball.dy * dt
  if ball.y <= 34 then ball.y = 34; ball.dy = math.abs(ball.dy); game.hitFlash = 0.08 end
  if ball.y + ball.height >= H - 34 then ball.y = H - 34 - ball.height; ball.dy = -math.abs(ball.dy); game.hitFlash = 0.08 end
  if ball.dx < 0 and overlaps(ball, player1) then paddleBounce(player1, 1) end
  if ball.dx > 0 and overlaps(ball, player2) then paddleBounce(player2, -1) end
  if ball.x + ball.width < 0 then scorePoint(2) end
  if ball.x > W then scorePoint(1) end
end

function love.keypressed(key)
  if key == 'escape' then
    if game.state == 'playing' or game.state == 'serve' then game.state = 'paused'
    elseif game.state == 'paused' then game.state = 'playing'
    else love.event.quit() end
  elseif key == 'space' then
    if game.state == 'menu' then game.state = 'serve'
    elseif game.state == 'serve' then game.state = 'playing'
    elseif game.state == 'paused' then game.state = 'playing'
    elseif game.state == 'gameover' then resetMatch() end
  elseif key == 'r' then resetMatch() end
end

local function drawTextCentered(text, y, f, color)
  love.graphics.setFont(f); setColor(color)
  love.graphics.printf(text, 0, y, W, 'center')
end

local function drawPaddle(p, color)
  setColor(color, 0.15); love.graphics.rectangle('fill', p.x - 8, p.y - 6, p.width + 16, p.height + 12, 9)
  setColor(color); love.graphics.rectangle('fill', p.x, p.y, p.width, p.height, 6)
end

local function drawArena()
  setColor(palette.bg); love.graphics.clear(palette.bg[1], palette.bg[2], palette.bg[3], 1)
  -- subtle top/bottom rails and center court line
  setColor(palette.line); love.graphics.rectangle('fill', 32, 33, W - 64, 1); love.graphics.rectangle('fill', 32, H - 34, W - 64, 1)
  setColor(palette.line, 0.7)
  for y = 54, H - 60, 25 do love.graphics.rectangle('fill', W / 2 - 1, y, 2, 11, 1) end
  -- score panels
  setColor(palette.panel); love.graphics.rectangle('fill', W / 2 - 214, 54, 180, 118, 14); love.graphics.rectangle('fill', W / 2 + 34, 54, 180, 118, 14)
  setColor(palette.cyan); love.graphics.setFont(smallFont); love.graphics.printf('PLAYER 01', W / 2 - 214, 67, 180, 'center')
  setColor(palette.coral); love.graphics.printf('PLAYER 02', W / 2 + 34, 67, 180, 'center')
  love.graphics.setFont(scoreFont); setColor(palette.white); love.graphics.printf(tostring(game.score1), W / 2 - 214, 81, 180, 'center'); love.graphics.printf(tostring(game.score2), W / 2 + 34, 81, 180, 'center')
  love.graphics.setFont(smallFont); setColor(palette.muted); love.graphics.printf('FIRST TO 7', 0, 190, W, 'center')
  drawPaddle(player1, palette.cyan); drawPaddle(player2, palette.coral)
  if game.state == 'playing' or game.state == 'paused' or game.state == 'serve' then
    if game.hitFlash > 0 then setColor(palette.gold) else setColor(palette.white) end
    love.graphics.rectangle('fill', ball.x, ball.y, ball.width, ball.height, 5)
  end
  setColor(palette.muted); love.graphics.setFont(smallFont)
  love.graphics.print('W  /  S', 54, H - 25); love.graphics.printf('ARROW KEYS', W - 178, H - 25, 124, 'right')
  if game.rally > 0 then setColor(palette.gold); love.graphics.printf('RALLY  '..game.rally, 0, H - 25, W, 'center') end
end

local function overlay(title, subtitle, prompt)
  setColor({0.02, 0.035, 0.055}, 0.86); love.graphics.rectangle('fill', 0, 0, W, H)
  setColor(palette.panel); love.graphics.rectangle('fill', W / 2 - 280, H / 2 - 155, 560, 310, 22)
  setColor(palette.line); love.graphics.rectangle('line', W / 2 - 280, H / 2 - 155, 560, 310, 22)
  drawTextCentered('R A L L Y', H / 2 - 113, smallFont, palette.cyan)
  drawTextCentered(title, H / 2 - 78, titleFont, palette.white)
  drawTextCentered(subtitle, H / 2 - 8, font, palette.muted)
  setColor(palette.cyan); love.graphics.rectangle('fill', W / 2 - 108, H / 2 + 58, 216, 48, 12)
  drawTextCentered(prompt, H / 2 + 72, smallFont, palette.bg)
  drawTextCentered('ESC  PAUSE     •     R  RESTART', H / 2 + 125, smallFont, palette.muted)
end

function love.draw()
  drawArena()
  if game.state == 'menu' then overlay('PONG', 'A clean, competitive arcade classic.', 'SPACE  TO PLAY')
  elseif game.state == 'serve' then overlay('READY?', 'First to seven points takes the match.', 'SPACE  TO SERVE')
  elseif game.state == 'paused' then overlay('PAUSED', 'Take a breath. The rally is waiting.', 'SPACE  TO RESUME')
  elseif game.state == 'gameover' then
    local winner = game.score1 > game.score2 and 'PLAYER 01 WINS' or 'PLAYER 02 WINS'
    overlay(winner, 'Final score     '..game.score1..'  —  '..game.score2, 'SPACE  TO REMATCH')
  end
end

