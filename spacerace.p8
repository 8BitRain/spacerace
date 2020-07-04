pico-8 cartridge // http://www.pico-8.com
version 27
__lua__

local spaceship
local score
local board_top
local board_right
local board_left
local spaceship_starting_y
local astroid

function _init() 
    board_top=0
    board_right=128
    board_left=0
    spaceship_starting_y=110
    spaceship=make_spaceship()
    astroid=make_astroid()
end

function _update()
    spaceship:update()
    astroid:update()
end

function _draw() 
    cls()   
    spaceship:draw()
    astroid:draw()
end

function make_spaceship()
    return {
        x=64,
        y=spaceship_starting_y,
        speed=2,
        score=0,
        width=8,
        update=function(self)
            if btn(3) then
                self.y+=self.speed
            end
            if btn(2) then
                self.y-=self.speed
            end

            if self.y == board_top then
                self.score+=1
                self.y=110
            end
        end,
        draw=function(self)
            spr(1,self.x,self.y)
            print(self.score, self.x-2*self.width,spaceship_starting_y,7)
        end
    }
end

function make_astroid()
    return {
        x=64,
        y=64,
        width=2,
        update=function(self)
            self.x+=1
            if self.x == board_right then
                self.x=board_left
            end
        end,
        draw=function(self)
            circfill(self.x,self.y,self.width,7)
        end
    }

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
