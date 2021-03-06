--$Name:ESCAPE OF THE CAT$
--$Name(ru):ПОБЕГ КОТА$
--$Version:0.4$
instead_version "1.9.0"
require "sprites"
require "timer"
require "kbd"
require "sound"
require "prefs"
require "click"
click.bg = true
click.press = true

last_ticks = 0

SEMICOL="#103030"

main.nam = '!!!';
main.dsc = function(s)
	p (_("warning:Please, go to settings and switch on own themes feature!"))
end

function init()
	if not prefs.game_record then
		prefs.game_record = 0
	end
	set_music 'snd/music.ogg'
	fn = sprite.font("font.ttf", 16);
	fn8 = sprite.font("8bit.ttf", 32);
	fn_big = sprite.font("font.ttf", 28);
	hero.spr = sprite.load "pic/cat.png"
	hero.spr_left = sprite.scale(hero.spr, -1.0, 1, false)
	heart_spr = sprite.load "pic/heart.png"
	heart_bonus_spr = heart_spr;
	score_spr = sprite.text (fn, _"Score:Distance: ", 'black');
	hiscore_spr = sprite.text (fn, _"Hiscore:Record: ", 'black');
	title_spr = sprite.text (fn8, "ESCAPE OF THE CAT", 'black');
	press_spr = sprite.text (fn, _"space:PRESS SPACE", 'black');
	gameover_spr = sprite.text (fn, _"gameover:GAME OVER", 'black');
	continue_spr = sprite.text (fn_big, _"continue:CONTINUE?", 'black');
	titles_spr = {
		sprite.text (fn, _"help1:KEYS ARE: LEFT RIGHT SPACE or UP", 'black');
		sprite.text (fn, _"help2:ESCAPE FOR MENU", 'black');
	}
	local i
	ending_spr = { }
	for i = 1, #ending_txt do
		table.insert(ending_spr, sprite.text(fn, _('end'..tostring(i)..':'..ending_txt[i]), 'white'));
	end
	hook_keys('right', 'left', 'space', 'up', 'return', '0',
		'1', '2', '3', '4', '5', '6', '7', '8', '9', 'escape', 'f1' );
	hero:state(DEAD)
	game:state(INTRO);
end

GAME = 0
CHANGE_LEVEL = 1
GAMEOVER = 2
INTRO = 3
CONTMAP = 99

LIVES = 3

global {
	game_state = 0;
	game_move = 0;
	game_lifes = LIVES;
	game_dist = 0;
	bg_color = 'white';
}
game.dist = function(s, n)
	local od = game_dist
	if n then
		game_dist = math.floor(n)
	end
	return od
end

game.state = function(s, n, st)
	local os = game_state
	local om = game_move
	if n then
		game_state = n
		if st then
			game_move = st
		else
			game_move = 0
		end
		if n == INTRO then
			hero:state(WALK)
			hero.x = 0
			hero.y = 400
			hero.dir = 1
			key_right = true
			key_left = false
		elseif os == INTRO then
			key_left = false
			key_right = false
			key_space = false
			key_input = {}
			map:dist(0)
			set_music 'snd/music.ogg'
		end
	end
	return os, om
end

game.step = function(s, n)
	game_move = game_move + 1
end

function start()
	timer:set(20);
	if game_state == GAME then
		game:state(CHANGE_LEVEL, 16);
		map:select()
	end
	if game_state ~= INTRO then
		key_state, key_right, key_space = false, false, false
	end
end

key_input = {}
key_space_pass = true
mouse_ctrl = { false, false, false }

function check_fingers()
	if not use_fingers then
		return
	end

	local k,v

	local dx = 640 / 6;
	local dx2 = dx * 2;

	game:kbd(false, 'right')
	game:kbd(false, 'left')
	game:kbd(false, 'up')

	local fng = finger:list()
	for k,v in ipairs(fng) do
		local x, y = v.x, v.y
		if x >= dx and x < dx2 then
			game:kbd(true, 'right')
		elseif x < dx then
			game:kbd(true, 'left')
		end
		if x >= 640/2 then
			game:kbd(true, 'up')
		end
	end
end

if stead.finger_pos then
	require "finger"
	game.finger = function()
		use_fingers = true
	end
end

game.click = function(s, press, x, y)
	if use_fingers then
		return
	end
	mouse_press = press
	if not press then
		mouse()
	end
end


mouse = function()
	local x, y = stead.mouse_pos()
	mouse_ctrl[1] = false
	mouse_ctrl[2] = false
	mouse_ctrl[3] = false
	if x > 640 / 2 + 160 then
		mouse_ctrl[3] = mouse_press
	elseif x <= 640 / 2 - 160 then
		mouse_ctrl[1] = mouse_press
	end
	if y < 480 / 2 - 120 then
		mouse_ctrl[2] = mouse_press
	end
	game:kbd(mouse_ctrl[1], 'left')
	game:kbd(mouse_ctrl[3], 'right')
	game:kbd(mouse_ctrl[2], 'up')
end

game.kbd = function(s, down, key)
	if math.abs(stead.ticks() - last_ticks) > 100 then -- workaround of INSTEAD bug
		timer:set(20)
	end
	if key == 'escape' or key == 'f1' then
		key_left = false
		key_right = false
		key_space = false
		key_input = {}
	end
	if key == 'up' then key = 'space' end
	local st = game:state()
	if st == INTRO then
		if down and key == "space" then
			game:state(CHANGE_LEVEL, 16);
			hero:state(DEAD)
			map:select(1)
			game_lifes = LIVES
			game:dist(0)
		end
		return
	end
	if down then
		if st == GAMEOVER then
			if key == "space" then
				game:state(INTRO)
			end
			return
		end
		if key >= '0' and key <= '9' then
			if not lev_num then lev_num = '' end
			lev_num = lev_num .. key
		elseif key == 'return' and prefs.unlock then
			if tonumber(lev_num) then
				local n = tonumber(lev_num)
				if n > 0 and n <= #maps then
					set_music 'snd/music.ogg'
					game:state(CHANGE_LEVEL, 16)
					hero:state(DEAD)
					map:select(n)
					game:dist(0)
					game_lifes = LIVES
				end
				lev_num = nil
			end
		else
			if key == 'left' or key == 'right' and key_input[1] ~= key then
				table.insert(key_input, 1, key)
				if #key_input >=3 then
					table.remove(key_input, 3)
				end
			elseif key == 'space' then
				if key_space_pass then
					key_space = true;
					key_space_pass = false
				end
			end
			lev_num = nil
		end
	else
		if key == 'left' or key == 'right'  then
			if key_input[2] == key then
				table.remove(key_input, 2)
			end
			if key_input[1] == key then
				table.remove(key_input, 1)
			end
		elseif key == 'space' then
			key_space = false;
			key_space_pass = true;
		end
	end
	if key_input[1] == 'left' then
		key_left, key_right = true, false
	elseif key_input[1] == 'right' then
		key_left, key_right = false, true
	else
		key_left, key_right = false, false
	end
end

BLOCK = 1
WATER = 2
EMERGENCY = 3
SEMIBLOCK = 4
SEMI_TO = 22
MINE_TO = 50
MINE_DIST = 100
BRIDGE = 5
FAKE=6
HEART=7
ROPE = 8
SNOW = 9
INVI = 10 
MINE = 11

WALK = 1
JUMP = 2
FALL = 3
DROWN = 4
DEAD = 5
FLY = 6

R = 0.75

JUMP_SPEED = 5
SPEED_RUN = 5
MAX_SPEEDX = 5
MIN_SPEED = (1.5 / R)


global {
    G = 0.5,
    RGX = 0.45,
    GX = 0.25
}


BW = 16
BH = 16


global {
}
hero = obj {
	nam = 'hero';
	var {
		move = 0;
		x = 10;
		y = 0;
		speed_x = 0;
		st = WALK;
		dir = 1;
		jump_speed = 0;
		h = 19 * 3 - 8;
		w = 23 * 3 - 20;
		xoff = 10;
		yoff = 8;
	};
	state = function(s, n)
		local os = s.st
		if n then
			if n ~= os then
				s.move = 0
			end
			s.st = n
			if (n == FLY or n == DROWN) and s.move == 0 then
				sound.play(mew_snd)
			end
			if n == JUMP or n == FLY then
				s.jump_speed = math.abs(s.speed_x)* 0.75 + JUMP_SPEED 
			end
		end
		return os
	end;
	distance = function(s, x, y)
		local d1 = hero.x + hero.w / 2 - x
		local d2 = hero.y + hero.h / 2 - y 
		local r = math.sqrt(d1 * d1 + d2 * d2)
		return r
	end;
	alive = function(s)
		return not (s.st == DROWN or s.st == FLY or s.st == DEAD)
	end;
	life = function (s)
		local block_x, block_y
		if s:state() == JUMP then
			s.move = s.move + 1
			local d = s.jump_speed - hero.move * G;
			if d <= 0 then
				d = 0
			end
			s.x, s.y, block_x, block_y = map:move(s.x, s.y, 
				s.speed_x, -d, s.w, s.h);
			if block_x then
				s.speed_x = s.speed_x * R
			end
			if d <= 0 or block_y then
				if s:alive() then
					s:state(FALL)
				end
			end
		elseif s:state() == FALL then
			s.move = s.move + 1
			local d = s.move * G;
			if d >= BH then d = BH - 1 elseif d <= -BH then d = -BH + 1 end
			s.x, s.y, block_x, block_y = map:move(s.x, s.y, 
				s.speed_x, d, 
				s.w, s.h);
			if block_x then
				s.speed_x = s.speed_x * R
			end
			if s.y > 480 then
				s:state(DEAD)
			elseif block_y then
				if s:alive() then
					s:state(WALK);
				end
			end
		elseif s:state() == DROWN then
			s.move = s.move + 2
			if s.move >= 19 * 3 then
				s:state(DEAD)
			end
		elseif s:state() == FLY then
			s.move = s.move + 2
			local d = s.jump_speed - s.move * G;
			s.y = s.y - d
			if s.y > 480 then
				s:state(DEAD)
			end
		elseif s:state() == WALK then
			local x, y
			if s.speed_x ~= 0 then
				s.move = s.move + 1
				s.x, s.y, block_x, block_y = map:move(s.x, s.y, 
					s.speed_x, 0, 
					s.w, s.h);
				if block_x then
					s.speed_x = 0
				end
			else
				x, y, block_x, block_y = map:move(s.x, s.y, 0, 0, s.w, s.h);
			end
			if not block_y then
				s:state(FALL)
			else
				s:input()
			end
		else
			return false
		end
		return true;
	end;
	input = function(s)
		if s:state() == WALK then
			if key_right or key_left then
				if key_right then
					s.dir = 1
					if s.speed_x < 0 then
						s.speed_x = s.speed_x + RGX
					else
						s.speed_x = s.speed_x + GX
					end
					if s.speed_x > MAX_SPEEDX then
						s.speed_x = MAX_SPEEDX
					end
				else
					s.dir = -1
					if s.speed_x > 0 then
						s.speed_x = s.speed_x - RGX
					else
						s.speed_x = s.speed_x - GX
					end
					if s.speed_x < -MAX_SPEEDX then
						s.speed_x = -MAX_SPEEDX
					end
				end
			else
				local gx = RGX
				if s.speed_x ~= 0 then
					if s.speed_x > 0 then
						gx = - gx
					end
					s.speed_x = s.speed_x + gx
					if gx < 0 and s.speed_x < 0 or gx > 0 and s.speed_x > 0 then
						s.speed_x = 0
					end
				end
			end
			if key_space then
				key_space = false
				if math.abs(s.speed_x) == GX then
					if key_right then s.speed_x = MIN_SPEED 
					elseif key_left then s.speed_x = -MIN_SPEED end
				end
				s:state(JUMP)
			end
		end
	end;
	draw = function (s)
		local x, y, state, fx, fy, fw, fh
		x = s.x - s.xoff
		y = s.y - s.yoff
		if s:state() == WALK or s:state() == FLY then
			if math.abs(s.speed_x) >= SPEED_RUN then
				state = (math.floor(s.move / 10)) % 2 +  2
			else
				state = (math.floor(s.move / 10)) % 2 
			end
		elseif s:state() == JUMP then
			state = 2
		elseif s:state() == FALL then
			state = 3
		elseif s:state() == DROWN then
			y = s.y - s.yoff + s.move
			state = 0
			fx = 0
			fy = 0
			fw = 23 * 3
			fh = 19 * 3 - s.move
		else
			state = s:state()
		end

		local xoff = state * (23 * 3)
		if s.dir < 0 then
			xoff = (3 - state) * (27 * 3)
		else
			xoff = state * (27 * 3)
		end
		local yoff = 0;
		local w = 23 * 3;
		local h = 19 * 3;
		if fx then xoff = xoff + fx end
		if fy then yoff = yoff + fy end
		if fw then w = fw end
		if fh then h = fh end
		if s.dir < 0 then
			sprite.draw(hero.spr_left, xoff, yoff, w, h, sprite.screen(), x, y);
		else
			sprite.draw(hero.spr, xoff, yoff, w, h, sprite.screen(), x, y);
		end
	end;
	collision = function(s, x, y, w, h)
		if not s:alive() then
			return
		end
		if s.x + s.w <= x then
			return
		end
		if s.y + s.h <= y then
			return
		end
		if s.x > x + w then
			return
		end
		if s.y > y + h then
			return
		end
		return true
	end
}
game.timer = function(s)
	local st, m, i, x, y;
	last_ticks = stead.ticks()

	check_fingers();

	if mouse_press then
		mouse()
	end

	st, m = game:state()

	if st == INTRO then
		sprite.fill(sprite.screen(), "")
		hero:draw();
		hero:life();
		local w, h = sprite.size(title_spr)
		sprite.draw(title_spr, sprite.screen(), (640 - w) / 2 + 1 - rnd(2), 100 + 1 - rnd(2));
		w, h = sprite.size(press_spr);
		sprite.draw(press_spr, sprite.screen(), (640 - w) / 2 + 1 - rnd(2), 300 + 1 - rnd(2));
		if not title_pos then title_pos = 1 end
		if hero.move % 150 == 0 then title_pos = title_pos + 1 end
		if title_pos > #titles_spr then title_pos = 1 end
		w, h = sprite.size(titles_spr[title_pos])
		sprite.draw(titles_spr[title_pos], sprite.screen(), (640 - w) / 2, 480 - h);
		if hero.move % rnd(200) == 0 then
			if rnd(50) > 25 then
				key_left, key_right = true, false
			else
				key_left, key_right = false, true
			end
		end
		if hero.x > 640 - hero.w * 2  then
			key_left = true
			key_right = false
		elseif hero.x < hero.w then
			key_right = true
			key_left = false
		end
		return
	end

	sprite.fill(sprite.screen(), bg_color)

	map:before()
	map:show()
	map:life()
	hero:draw()
	map:after()

	if st == GAME or (st == CHANGE_LEVEL and m >= 16) then
		hero:life();
	end

	for i=1, game_lifes - 1 do
		sprite.draw(heart_spr, sprite.screen(), (i - 1) * 16, 48 + 4);
	end

	if map.nr ~= CONTMAP then
		sprite.draw(map.title, sprite.screen(), 0, 0);
	end
	sprite.draw(score_spr, sprite.screen(), 0, 16);
	sprite.draw(hiscore_spr, sprite.screen(), 0, 32);

	if old_score ~= game:dist() + map:dist() then
		old_score = game_dist + map:dist()
		game_score = old_score
		if dist_spr then sprite.free(dist_spr) end
		dist_spr = sprite.text(fn, string.format("%d", game_score), "black");
		if prefs.game_record < game_score then
			prefs.game_record = game_score
		end
		if record_spr and prefs.game_record == game_score then 
			sprite.free(record_spr); 
			record_spr = false
		end
		if not record_spr then
			record_spr = sprite.text(fn, string.format("%d", prefs.game_record), "black");
		end
	end

	x,y = sprite.size(score_spr);
	sprite.draw(dist_spr, sprite.screen(), x + 4, 16);
	x,y = sprite.size(hiscore_spr);
	sprite.draw(record_spr, sprite.screen(), x + 4, 32);

	if st == GAMEOVER then
		local w, h = sprite.size(gameover_spr);
		if blanker then
			sprite.fill(sprite.screen(), (640 - w)/2 - 2, (480 - h)/2 - 2, w + 2, h + 2, 'white')
		end
		blanker = not blanker
		sprite.draw(gameover_spr, sprite.screen(), (640 - w)/2, (480 - h)/2)
	end

	if st == CHANGE_LEVEL and m < 16 then
		local y
		for y = 0, 29 do
			sprite.fill(sprite.screen(), 0, y * 16 , 640, m, 'black')
		end
		game:step();
		return
	elseif st == CHANGE_LEVEL then
		if hero:state() == DEAD then
			if game_lifes <= 0 then
				map:select(CONTMAP)
			else
				map:select()
			end
		elseif hero.x >= 640 then
			game:dist(game:dist() + map:dist())
			map:next()
		end
	end

	if hero.x / BW > map:dist() and map.nr ~= CONTMAP then
		map:dist(math.floor(hero.x / BW))
	end

	if hero:state() == DEAD then
		if game_lifes > 0 then
			game_lifes = game_lifes - 1
			if game_lifes <= 0 then
				game:state(CHANGE_LEVEL)
			else
				game:state(CHANGE_LEVEL)
			end
		end
	elseif hero.x >= 640 then
		game:state(CHANGE_LEVEL)
	end

	if st == CHANGE_LEVEL and m >= 16 then
		local y
		for y = 0, 29 do
			sprite.fill(sprite.screen(), 0, y * 16 + m - 16 , 640, 16 - (m - 16), 'black')
		end
		game:step();
		if m >= 31 then
			game:state(GAME)
		end
		return
	end
end

dofile "maps.lua"
dofile "i18n.lua"
dofile "sounds.lua"
