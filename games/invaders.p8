pico-8 cartridge // http://www.pico-8.com
version 19
__lua__
-- based on 2darray's code
-- see https://www.lexaloffle.com/bbs/?tid=28005

player={}
player.x=64
player.y=120
player.vx=0
player.vy=0
player.a=.5
player.health=1

bullets={}

enemies={}
enemydir=1
enemyspeed=1

particles={}

shake=0
shakedecay=1/15
shakeamp=4

camx=0
camy=0
camstiff=.3

function _init()
	for i=10,50,10 do
		for j=10,50,10 do
			makeenemy(i,j)
		end
	end
end

function _update()
	updatebullets()
	updateplayer()
	updateenemies()
	updateparticles()
	updatecamshake()
end

function _draw()
	cls()
	drawenemies()
	drawplayer()
	drawparticles()
	drawbullets()
end

-- player

function updateplayer()
	if btn(0) then
		player.vx-=player.a
	end
	if btn(1) then
		player.vx+=player.a
	end
	if btnp(4) then
		makepbullet()
	end
	
	player.vx*=.9
	
	player.x+=player.vx
	if player.x-4<0 then
		player.x=4
		player.vx=0
	end
	if player.x+4>127 then
		player.x=123
		player.vx=0
	end
end

function drawplayer()
	spr(1,player.x-4,player.y-4)
end

-- bullets

bflipper=true
function makepbullet()
	bullet={}
	if bflipper==true then
		bullet.x=player.x
		bflipper=false
	else
		bullet.x=player.x-1
		bflipper=true
	end
	
	bullet.ox=bullet.x
	bullet.oy=bullet.y
	
	bullet.y=player.y-5
	bullet.isplayer=true
	add(bullets,bullet)
end

function makeebullet(x,y)
	b={}
	b.x=x
	b.y=y
	b.vx=(rnd(1)-.5)*.25
	b.vy=1.5+rnd(1.5)
	b.isplayer=false
	add(bullets,b)
end

function updatebullets()
	for bullet in all(bullets) do
		local deleteme=false
		bullet.ox=bullet.x
		bullet.oy=bullet.y
		
		if bullet.isplayer==true then
			bullet.y-=8
			didhit,hitobj=checkpbullethit(bullet)
			if didhit then
				deleteme=true
				hitobj.health-=1
			end
			if bullet.y<-10 then
				deleteme=true
			end
			
		else -- enemy bullet
		
			bullet.x+=bullet.vx
			bullet.y+=bullet.vy
			
			if checkebullethit(bullet)==true then
				player.health-=1
				makeflash(bullet.x,bullet.y,7,.3)
				shake=1
				deleteme=true
			end	
			
			if bullet.y>135 then
				del(bullets,bullet)
			end
			
		end
		
		if deleteme==true then
			del(bullets,bullet)
		end	
	end
end

function drawbullets()
	for bullet in all(bullets) do
		if bullet.isplayer==true then
			line(bullet.x, bullet.y,
			     bullet.x, bullet.y-4,
			     11)
		else
			circfill(bullet.x,bullet.y,rnd(4),8+rnd(3))		
		end
	end
end

-- returns bool,lasthit
-- bool: whether bullet hit
-- lasthit: the obj it hit or nil
function checkpbullethit(bullet)
	for enemy in all(enemies) do
		if bullet.x>enemy.x-4 and
			  bullet.x<enemy.x+4 and
				 bullet.oy>enemy.y-4 and
					bullet.y<enemy.y+4 
		then
			return true,enemy
		end
	end
	return false,nil
end


function checkebullethit(bullet)
	if bullet.x>player.x-4 and
	   bullet.x<player.x+4 and
	   bullet.oy>player.y-4 and
	   bullet.y<player.y+4
	then
		return true
	end
	return false
end

-- enemies

function makeenemy(x,y)
	enemy={}
	enemy.tx=x -- targetx
	enemy.ty=y -- targety
	enemy.x=x
	enemy.y=y
	enemy.health=1
	enemy.shoottimer=30+rnd(50)
	add(enemies,enemy)
end

function updateenemies()
	local changedir=false
	for enemy in all(enemies) do
		enemy.tx+=enemydir*enemyspeed
		if enemy.tx > 120 or
		   enemy.tx < 8   then
			changedir=true
		end
		
		enemy.x+=(enemy.tx-enemy.x)*.1
		enemy.y+=(enemy.ty-enemy.y)*.1
		
		enemy.shoottimer-=1
		if enemy.shoottimer<=0 then
			enemy.shoottimer=30+rnd(50)
			makeebullet(enemy.x,enemy.y)
		end
		
		if enemy.health<=0 then
			del(enemies,enemy)
			makesparks(enemy.x,enemy.y,15)
			makeflash(enemy.x,enemy.y,10,.5)
		end
	end
	if changedir==true then
		enemydir*=-1
		moveenemiesdown()
	end
end

function drawenemies()
	for enemy in all(enemies) do
		spr(2, enemy.x-4, enemy.y-4)
	end
end

function moveenemiesdown()
	for e in all(enemies) do 
		e.ty+=10
	end
end



-- particles

function makeflash(x,y,size,lifetime)
	p={}
	p.type="flash"
	p.x=x
	p.y=y
	p.size=size
	p.startsize=size
	p.life=1
	p.decayrate=1/(lifetime*30)
	add(particles,p)
end

function makesparks(x,y,count)
	local i
	for i=1,count do
		p={}
		p.type="sparks"
		p.x=x
		p.y=y
		p.ox=x
		p.oy=y
		p.vx=rnd(6)-3
		p.vy=rnd(6)-3
		p.life=1
		local lifetime=10+rnd(20)
		p.decayrate=1/lifetime
		add(particles,p)
	end
end

function updateparticles()
	for p in all(particles) do 
		if p.type=="flash" then
			-- smoothstep
			local t=p.life
			t=3*t*t-2*t*t*t
			--
			p.size=p.startsize*t
		elseif p.type=="sparks" then
			p.vy+=.3
			p.vx*=.95
			p.vy*=.95
			p.ox=p.x
			p.oy=p.y
			p.x+=p.vx
			p.y+=p.vy
		end
		
		p.life-=p.decayrate
		if p.life<0 then
			del(particles,p)
		end
	end
end

function drawparticles()
	for p in all(particles) do
		if p.type=="flash" then
			circfill(p.x,p.y,p.size,7)
		elseif p.type=="sparks" then
			local col
			if p.life>.75 then
				col=7
			elseif p.life>.5 then
				col=10
			elseif p.life>.25 then
				col=9
			else
				col=2
			end
			
			line(p.x,p.y,p.ox,p.oy,col)
		end
	end
end

-- utilities

function updatecamshake()
	shake-=shakedecay
	
	local shakex,shakey
	if shake<0 then
		shake=0
		shakex=0
		shakey=0
	else
		shakex=rnd(shake*shakeamp*2)-shakeamp
		shakey=rnd(shake*shakeamp*2)-shakeamp
	end
	
	camx+=(shakex-camx)*camstiff
	camy+=(shakey-camy)*camstiff
	camera(camx,camy)
end
__gfx__
00000000000550000900009000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000005dd5000090090000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700005665000999999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000511661159909909900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000576dd6750999999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700561dd1659999999900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000d71dd17d9090090900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000088008809000000900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
