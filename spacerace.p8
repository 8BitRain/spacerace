pico-8 cartridge // http://www.pico-8.com
version 27
__lua__

local score
local spaceship_starting_y
local game_state -- "menu", "playing", "over", or "victorious"
local level_transition
local level_transition_time
local game_objects
local lives_remaining
local score

function _init() 
    -- constants
    spaceship_starting_y=110
    
    -- game state
    game_state="menu"
    level_transition=false
    level_transition_time=0
    lives_remaining=3
    score=0

    -- game objects
    game_objects={}
    for i=1,24 do
        local direction = i % 2 == 0 and 1 or -1
        make_asteroid(rnd(120),rnd(90),direction)
    end
    make_spaceship()
end

function _update()
    if game_state == "playing" then
        update_game()
    elseif game_state == "menu" then
        update_menu()
    end
end

function update_game()
    deal_with_level_transition()

    local obj
    for obj in all(game_objects) do
        obj:update()
    end

    foreach_game_object_of_kind("particle", function(particle)
        if particle.y > 128 or particle:is_expired() then
            del(game_objects, particle)
        end
    end)
end

function deal_with_level_transition()
    if level_transition then 
        level_transition_time+=1
        if level_transition_time > 17 then
            level_transition=false
            level_transition_time=0
        end
    end
end

function update_menu()
    if btn(4) or btn(5) then
        game_state = "playing"
    end
end

function _draw() 
    cls()
    draw_sky()
    if game_state == "playing" then
        draw_game()
    elseif game_state == "victorious" then
        draw_win_screen()
    elseif game_state == "menu" then
        draw_menu()
    elseif game_state == "over" then
        draw_game_over()
    end
end

function draw_game()
    local obj
    for obj in all(game_objects) do
        obj:draw()
    end

    print("lives: "..lives_remaining, 4, spaceship_starting_y+8, 7)
    print("score: " ..score, 93, spaceship_starting_y+8, 7)
end

function draw_menu()
    centered_print("space race", 64, 70, 7)
    centered_print("press \x97 to play", 64, 96, 7)
end

function draw_win_screen()
    centered_print("you win!!!!", 64, 70, 7)
end

function draw_game_over()
    centered_print("game over :(", 64, 70, 7)
end

function draw_sky()
    -- thanks to trasevol_dog https://www.patreon.com/posts/pico-8-bach-day-17944892
    local cols={12,12,12,12,13,5,1,1,1,0,0}
    local ptrns={0b0111101111011110, 0b0110001110011100, 0b0100001000011000, 0b0000001000010000}
    local y=128
    for i=0,#cols-2 do
        color(cols[i+1]*16+cols[i+2])
        for j=0,3 do
            fillp(ptrns[j+1])
            rectfill(0,y,128,y-1)
            y-=2
        end
    end
    fillp()
end

function make_particle(x,y,_direction)
    make_game_object("particle", x,y, {
        c=y,
        direction=_direction,
        lifetime=0,
        speed=.5,
        draw=function(self)
            local col
            if (self.lifetime <2) then
                col= 7
            elseif self.lifetime<5 then
                col=10
            else
                col=9
            end
            pset(self.x,self.y,col)
        end,
        update=function(self)
            if self.direction == 0 then
                self.y+=2.5*rnd(1)
            else
                self.x+=self.direction*self.speed
                self.y=(self.lifetime*self.lifetime)*rnd(4)*.1+self.c
            end
            
            self.lifetime+=1
        end,
        is_expired=function(self)
            return self.lifetime >= 7
        end
    })
end

function make_spaceship()
    make_game_object("spaceship", 64, spaceship_starting_y, {
        velocity=0,
        speed=1.7,
        width=8,
        radius=4,
        update=function(self)
            if not level_transition then
                -- air resistance
                self.velocity*=.6

                if btn(3) and self.y != spaceship_starting_y then
                    -- cut engine and freefall
                    self.velocity=self.speed
                else
                    self:fire_thrusters()
                end

                -- gravity
                self.velocity+=0.1

                if btn(2) then
                    self.velocity=-self.speed
                end

                self.y+=self.velocity
                self.y=min(self.y,spaceship_starting_y)
            end

            if self.y <= 0 then
                self:score_point()
            end

            foreach_game_object_of_kind("asteroid", function(asteroid)
                self:check_for_collision(asteroid)
            end)
        end,
        score_point=function(self)
            score+=1
            level_transition=true
            self.y=spaceship_starting_y
            self.velocity=0
            if score >= 10 then
                game_state= "victorious"
                sfx(3)
            else
                sfx(2)
            end
        end,
        draw=function(self)
            if not level_transition then
                spr(1,self.x-3,self.y-4)
            end
        end,
        check_for_collision=function(self,asteroid)
            if circles_overlapping(self.x,self.y,self.radius,asteroid.x,asteroid.y,asteroid.radius) then 
                self.y=spaceship_starting_y
                lives_remaining-=1
                if lives_remaining < 0 then
                    game_state= "over"
                end
                sfx(0)
            end
        end,
        fire_thrusters=function(self)
            fire_thruster(self.x+3, self.y+4)
            fire_thruster(self.x-2, self.y+4)
        end
    })
end

function fire_thruster(x,y) 
    make_particle(x,y,1)
    make_particle(x,y,0)
    make_particle(x,y,-1)
end

function make_asteroid(x,y,right_or_left)
    make_game_object("asteroid", x, y, {
        radius=1.5,
        direction=right_or_left,
        update=function(self)
            self.x+=self.direction
            if self.x > 128 then
                self.x=0
            end
            if self.x < 0 then
                self.x=128
            end
        end,
        draw=function(self)
            circfill(self.x,self.y,self.radius,7)
        end
    })
end

function circles_overlapping(x1,y1,r1,x2,y2,r2)
    local dx=x2-x1
    local dy=y2-y1
    local distance=dx*dx+dy*dy
    return distance < (r1+r2)*(r1+r2)
end

-- shared game_object things
function make_game_object(kind,x,y,props)
    local obj = {
        kind=kind,
        x=x,
        y=y,
        draw=function(self)
        end,
        update=function(self)
        end
    }

    -- add aditional object properties
    for k,v in pairs(props) do
        obj[k] = v
    end

    -- add new object to list of game objects
    add(game_objects, obj)
end

function foreach_game_object_of_kind(kind, callback)
    local obj
    for obj in all(game_objects) do
        if obj.kind == kind then
            callback(obj)
        end
    end
end

-- fancy printing
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
010b00000c7600e760137601874018730007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
010e000010760107000070010740177601770018762187521f7501f7551c7401c7401873018735247700070000700007000070000700007000070000700007000070000700007000070000700007000070000700
