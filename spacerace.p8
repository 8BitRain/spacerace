pico-8 cartridge // http://www.pico-8.com
version 27
__lua__

local spaceship
local score
local board_top
local board_right
local board_left
local spaceship_starting_y
local asteroids
local game_state
local level_transition
local level_transition_time

function _init() 
    board_top=0
    board_right=128
    board_left=0
    spaceship_starting_y=110
    spaceship=make_spaceship()
    asteroids={}
    game_state=0
    level_transition=false
    level_transition_time=0

    for i=1,25 do
        local direction = i % 2 == 0 and 1 or -1
        add(asteroids, make_asteroid(rnd(120),rnd(90),direction))
    end
end

function _update()
    if game_state == 1 then
        update_game()
    else
        update_menu()
    end
end

function update_game()
    if level_transition then 
        level_transition_time+=1
        if level_transition_time > 50 then
            level_transition=false
            level_transition_time=0
        end
    end

    spaceship:update()
    local asteroid
    for asteroid in all(asteroids) do
        asteroid:update()
        spaceship:check_for_collision(asteroid)
    end
end

function update_menu()
    if btn(4) or btn(5) then
        game_state = 1
    end
end

function _draw() 
    cls()
    draw_sky()
    if game_state == 1 then
        draw_game()
    else
        draw_menu()
    end
end

function draw_game()
    spaceship:draw()
    for asteroid in all(asteroids) do
        asteroid:draw()
    end
end

function draw_menu()
    centered_print("space race", 64, 64, 7)
    centered_print("press \x97 to play",64,96,7)
end

function draw_sky()
    -- thanks to trasevol_dog https://www.patreon.com/posts/pico-8-bach-day-17944892
    local cols={12,12,12,12,13,5,1,1,1,0,0}
    local ptrns={0b0111101111011110, 0b0110001110011100, 0b0100001000011000, 0b0000001000010000}
    local y=120
    for i=0,#cols-2 do
        color(cols[i+1]*16+cols[i+2])
        for j=0,3 do
            fillp(ptrns[j+1])
            rectfill(0,y,127,y-1)
            y-=2
        end
    end
    fillp()
end

function make_spaceship()
    return {
        x=64,
        y=spaceship_starting_y,
        speed=2,
        score=0,
        width=8,
        radius=4,
        update=function(self)
            if not level_transition then
                if btn(3) and self.y<spaceship_starting_y then
                    self.y+=self.speed
                end
                if btn(2) then
                    self.y-=self.speed
                end
            end

            if self.y == board_top then
                self:advance()
            end
        end,
        advance=function(self)
            self.score+=1
            sfx(1)
            level_transition=true
            self.y=spaceship_starting_y
        end,
        draw=function(self)
            if not level_transition then
                spr(1,self.x-3,self.y-4)
            end
            print(self.score, self.x-2*self.width,spaceship_starting_y,7)
        end,
        check_for_collision=function(self,asteroid)
            if circles_overlapping(self.x,self.y,self.radius,asteroid.x,asteroid.y,asteroid.radius) then 
                self.y=spaceship_starting_y
                sfx(0)
            end
        end
    }
end

function make_asteroid(starting_x,starting_y,right_or_left)
    return {
        x=starting_x,
        y=starting_y,
        radius=1.5,
        direction=right_or_left,
        update=function(self)
            self.x+=self.direction
            if self.x > board_right then
                self.x=board_left
            end
            if self.x < board_left then
                self.x=board_right
            end
        end,
        draw=function(self)
            circfill(self.x,self.y,self.radius,7)
        end
    }
end

function circles_overlapping(x1,y1,r1,x2,y2,r2)
    local dx=x2-x1
    local dy=y2-y1
    local distance=sqrt(dx*dx+dy*dy)
    return distance < (r1+r2)
end

function centered_print(text,x,y,col)
    outlined_print(text, x-#text*2, y, col, 5)
end

function outlined_print(text,x,y,col,outline_col)
    print(text,x-1,y,outline_col)
    print(text,x+1,y,outline_col)
    print(text,x,y-1,outline_col)
    print(text,x,y+1,outline_col)

    print(text,x,y,col)
end

__gfx__
00000000000770000aaaaa0000000000444444400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000776700aafffaa0044444444fffff400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0070070007776770af3f3fa000fffff44f5f5f400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0007700000776700afffffaa00f4f4f04fffff400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0007700000776700aff8ff0a00fffff04ff8ff400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0070070007776770a0fff00000ff8ff0407a70400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000777777770eeeee00011151114faaaf400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000980098000eee00000011100407a70040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
0001000000000000000000000000000002f0502e0502d0502c0502a05024050230501e0001e000200001d00000000000000000000000000000000000000000000000000000000000000000000000000000000000
000600000d6500e6500e650106500e6500f6500f650106500f6500f650106500e6500e6500d6500d6500e65010650116501265014650166501765018650186501a6501c6501e6501f6502365025650276502a650
