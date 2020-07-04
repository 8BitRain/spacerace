pico-8 cartridge // http://www.pico-8.com
version 27
__lua__

local spaceship
local score
local board_top
local board_right
local board_left
local spaceship_starting_y
local astroids

function _init() 
    board_top=0
    board_right=128
    board_left=0
    spaceship_starting_y=110
    spaceship=make_spaceship()
    astroids={
        make_astroid(0, 10),
        make_astroid(70, 20),
        make_astroid(30, 30),
        make_astroid(80, 43),
        make_astroid(15, 50),
        make_astroid(90, 55),
        make_astroid(100, 60),
        make_astroid(60, 75),
        make_astroid(73, 81),
        make_astroid(120,90),

        make_astroid(33, 28),
        make_astroid(63, 17),
        make_astroid(127, 95),
        make_astroid(66, 89),
        make_astroid(79, 24),
        make_astroid(120,24)
    }

end

function _update()
    spaceship:update()
    local astroid
    for astroid in all(astroids) do
        astroid:update()
        spaceship:check_for_collision(astroid)
    end
end

function _draw() 
    cls()   
    spaceship:draw()
    for astroid in all(astroids) do
        astroid:draw()
    end
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
            if btn(3) then
                self.y+=self.speed
            end
            if btn(2) then
                self.y-=self.speed
            end

            if self.y == board_top then
                self.score+=1
                self.y=spaceship_starting_y
            end
        end,
        draw=function(self)
            spr(1,self.x-3,self.y-4)
            print(self.score, self.x-2*self.width,spaceship_starting_y,7)
        end,
        check_for_collision=function(self,astroid)
            if circles_overlapping(self.x,self.y,self.radius,astroid.x,astroid.y,astroid.radius) then 
                self.y=spaceship_starting_y
            end
        end
    }
end

function make_astroid(starting_x,starting_y)
    return {
        x=starting_x,
        y=starting_y,
        radius=1.5,
        update=function(self)
            self.x+=1
            if self.x == board_right then
                self.x=board_left
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

__gfx__
00000000000770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000007767000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700077767700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000007767000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000007767000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700077767700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000777777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000098009800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
