pico-8 cartridge // http://www.pico-8.com
version 27
__lua__
-- x-zero
-- by paranoid cactus

-- prefab map blocks
-- [1][2]=x,y offset into pico-8 map for top left tile of prefab (all prefabs are 16x16 tiles)
-- scr: position to draw terminal screen
-- sp: special prefab for boss chamber and entrance corridor
prefabs={{{112,16}},{{0,0,scr={52,72}},sp={80,32}},{{16,0,scr={84,80}}},{{32,0}},{{48,0,scr={52,72}}},{{64,0},{0,32},sp={64,32}},{{80,0}},{{96,0}},{{112,0,scr={44,48}}},{{0,16}},{{16,16},{16,32}},{{32,16}},{{48,16}},{{64,16}},{{80,16}},{{96,16}}}

-- fully solid prefab block
nullmap={paths=0,visited=false,keytaken=false,mbx=112,mby=16}

-- sprites used to draw minimap [1]=spritesheet x,[2]=spritesheet y,fx=flip x axis,fy=flip y axis
mapbits={{0,13},{5,8},{0,11},{0,8,fx=true,fy=true},{5,8,fx=true},{4,8},{0,8,fy=true},{4,10,fy=true},{0,11,fy=true},{0,8,fx=true},{0,10},{2,10,fx=true},{0,8},{4,10},{2,10},{2,8}}

-- player sprite parts {x,y,w,h}
psprs={{0,0,6,8},{6,0,8,4},{14,0,7,6},{21,0,4,6},{25,0,5,6},{30,0,8,6},{38,0,8,6},{46,0,4,6},{50,0,5,6},{55,0,8,6},{63,0,8,6},{70,0,8,7},{78,0,8,6},{86,0,7,7}}

-- player animations {index in psprs,x draw offset, y draw offset}
pstand={{{3,0,-6},{1,0,-13},{2,2,-8}}}
prun={{{4,1,-6},{1,1,-14},{2,3,-9}},{{5,1,-6},{1,1,-14},{2,3,-10}},{{6,-1,-6},{1,1,-13},{2,3,-10}},{{7,-1,-6},{1,1,-13},{2,3,-9}},{{8,1,-6},{1,1,-14},{2,3,-9}},{{9,1,-6},{1,1,-14},{2,3,-10}},{{10,-1,-6},{1,1,-13},{2,3,-10}},{{11,-1,-6},{1,1,-13},{2,3,-9}}}
pjump={{{12,-1,-6},{1,0,-14},{2,2,-9}},{{13,-1,-6},{1,0,-13},{2,2,-9}},{{14,-1,-6},{1,0,-14},{2,2,-11}}}

-- gun sprites (3 aiming directions)
gsprs={{93,0,7,6,oy=0,by=5,a=0},{6,0,8,4,oy=0,by=0,a=0},{100,0,7,7,oy=-4,by=-4,a=0}}

-- bullet sprites
bsprs={{11,4,3,5,ox=-1,oy=-1},{8,8,3,5,fx=1,ox=-1,oy=-1},{11,9,4,4,fx=1,ox=-1,oy=-1},{14,6,5,3,fx=1,ox=-1,oy=-1},{6,5,5,3,fx=1,ox=-1,oy=-1},{14,6,5,3,fx=1,fy=1,ox=-1,oy=-1},{11,9,4,4,fx=1,fy=1,ox=-1,oy=-2},{8,8,3,5,fx=1,fy=1,ox=-1,oy=-3},{11,4,3,5,fy=1,ox=-1,oy=-3},{8,8,3,5,fy=1,ox=-1,oy=-3},{11,9,4,4,fy=1,ox=-2,oy=-2},{14,6,5,3,fy=1,ox=-3,oy=-1},{6,5,5,3,ox=-3,oy=-1},{14,6,5,3,ox=-3,oy=-1},{11,9,4,4,ox=-2,oy=-1},{8,8,3,5,ox=-1,oy=-1}}

-- gun data (was going to have multiple weapon types but didn't get implemented)
gun={rate=10,spd=3,sprs=bsprs,bullets={0,0.0625,-0.0625,0.125,-0.125}}

-- boss bullet sprites
ebsprs={{86,21,5,5,ox=-2,oy=-2},{90,21,5,5,ox=-2,oy=-2,fx=1},{90,21,5,5,ox=-2,oy=-2},anms={1,1,2,2,3,3}}

-- flying enemy
enemy1={fly=1,hp=3,hbx1=-1,hby1=-9,hbx2=9,hby2=1,sprs={{119,0,9,7,ox=0,oy=-8},{110,0,9,8,ox=0,oy=-8},{120,7,8,5,ox=0,oy=-5}},anms={1,1,2,3,3,3,2}}

-- walking enemy
enemy2={hp=5,hbx1=-5,hby1=-11,hbx2=11,hby2=1,sprs={{14,22,16,10,ox=-6,oy=-10},{0,14,15,9,ox=-5,oy=-9},{30,22,16,10,ox=-6,oy=-10},{46,22,15,10,ox=-6,oy=-10},
{15,12,15,10,ox=-6,oy=-10},{0,23,14,9,ox=-5,oy=-9},{30,12,15,10,ox=-6,oy=-10},{45,12,16,10,ox=-6,oy=-10}},anms={1,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8}}

-- 3rd enemy type that never got implemented
enemy3={fly=1,shoot=1,hp=5,hbx1=-4,hby1=-8,hbx2=4,hby2=1,sprs={{76,6,9,8,ox=-4,oy=-8}},anms={1}}


-- power up
pickuppowerup={prop="bcount",propadd=2,propmax="maxbullets",sprs={{33,6,8,6,ox=-4,oy=-6},{41,6,8,6,ox=-4,oy=-6},{48,6,6,6,ox=-3,oy=-6},{54,6,4,6,ox=-2,oy=-6},{54,6,4,6,fx=1,ox=-2,oy=-6},{48,6,6,6,fx=1,ox=-3,oy=-6},{41,6,8,6,fx=1,ox=-4,oy=-6}}}
-- health pickup
pickuphealth={prop="hp",propadd=1,propmax="maxhp",sprs={{120,12,5,4,ox=-2,oy=-4}}}
-- pickup types
pickuptypes={pickuppowerup,pickuphealth}


-- fade palette used for paranoid cactus logo (default pico-8 palette)
fadepal={
{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,129,0,130,130,129,129,0,130,130},{0,0,0,129,128,128,129,1,128,2,136,1,1,129,2,136},{0,129,130,1,130,130,1,141,130,136,8,131,131,130,136,8},{0,129,130,131,132,133,141,13,2,8,137,3,140,2,8,142},{0,1,2,131,136,133,13,6,136,137,9,139,13,141,142,143},{0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15}}

-- fade palette used for game
fadepal2={
{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,128,0,130,130,0,129,0,0,0},{0,0,0,0,0,128,128,133,128,2,136,0,1,128,0,0},{0,0,0,128,0,133,133,5,130,136,8,129,131,130,128,0},{0,129,128,130,128,133,5,134,2,8,137,1,140,2,133,0},{0,1,133,2,130,5,134,6,136,137,9,131,13,141,5,128},{0,1,133,136,141,5,6,7,8,142,10,140,12,13,134,128}}

function _init()
	-- l,t,r,b: (left,top,right,bottom) indicate which directions of a map cell have paths. can be added together to determine which map block is used
	-- w,h: width,height of map in map blocks (16x16 tiles)
	-- fdi,fpt,fpo,fpd: used for fading screen palette - palette index, fade time, origin index, destination index
	l,t,r,b,w,h,fpi,fpt,fpo,fpd=1,2,4,8,20,6,7,0,7,1
	nextmode,gamemode,waittimer,flashtime,jbtn,sbtn=0,-1,30,0,4,5
	sfx(42)
	menuitem(2,"swap controls",function() jbtn,sbtn=sbtn,jbtn end)
end

function _update60()
	-- timer used for anything that flashes/blinks
	flashtime=(flashtime+1)%16
	-- if we are going to change game modes but have a wait timer
	if gamemode~=nextmode and waittimer>0 then
		waittimer-=1
		return
	end
	-- if screen palette is transitioning (ie fading in or out)
	if fpi~=fpd then
		-- fade screen
		fpt=min(1,fpt+0.05)
		fpi=flr(lerp(fpo,fpd,fpt))
	elseif fpd==1 then
		-- when screen has finished fading change game mode
		gamemode,fpt,fpo,fpd,fadepal=nextmode,0,1,7,fadepal2
		if gamemode==0 then
			-- switching to title screen
			-- clear user memory so we can use it to store the x brush stroke image
			memset(0x4300,0,0x1b00)
			-- initialise the brush for drawing the x
			brushx,brushy,brushxv,brushyv,brushyd,brushw,bossevent,waittimer=34,20,1.2,1.2,96,2.5,false,1
			-- remove "end game" menu item from system menu
			menuitem(1)
		else
			-- non title screen mode
			-- add "end game" to system menu
			menuitem(1,"end game",function() changemode(0) end)
			if gamemode==2 then
				-- game over so fade music
				music(-1,3000)
				waittimer=580
			elseif gamemode==3 then
				-- victory music
				music(22)
			end
		end
	else
		if gamemode==0 then
			if waittimer==1 then
				-- title music
				music(18)
			end
			if waittimer>0 then
				waittimer-=1
				return
			end
			if brushyd<112 and brushy>=brushyd then
				-- initialise second brush stroke
				brushx,brushy,brushxv,brushyd,brushw=102,18,-1.4,256,4
			end
			if btnp(4) or btnp(5) then
				-- start game
				changemode(1)
				genmap()
				music(0,0,6)
			end
		elseif gamemode==1 then
			if waitfunc then
				waittimer-=1
			else
				-- only update player if we don't have a wait timer (wait timer is set when the player dies or kills the boss)
				player:update()
			end
			-- mark player's position on map as visited
			local mg=mgr[flr(player.x/128)+1][flr(player.y/128)+1]
			mg.visited=true
			-- update all the things
			for e in all(enemies) do
				e:update()
			end
			for b in all(bullets) do
				b:update()
			end
			for p in all(particles) do
				p:update()
			end
			for p in all(pickups) do
				p:update()
			end
			if boss then
				boss:update()
				-- fixed camera position on boss fight
				local camxd,camyd=mg.x*128-128,mg.y*128-128
				camx,camy=camx+(camxd-camx)*0.025,camy+(camyd-camy)*0.025
			else
				-- scroll camera
				camx,camy=flr(player.x-64),flr(player.y-64)
			end
			-- wait timer has expired and we have a function to call then call that function
			if waitfunc and waittimer==0 then
				waitfunc()
				waitfunc=nil
			end
		elseif gamemode==2 then
			-- game over
			if waittimer>0 then
				waittimer-=1
			end
			if btnp(4) or btnp(5) or waittimer==0 then
				changemode(0)
			end
		elseif gamemode==3 then
			-- victory
			if btnp(4) or btnp(5) then
				changemode(0)
			end
		end
	end
end

function changemode(v)
	-- prepare to fade screen and switch game modes
	nextmode,fpt,fpo,fpd=v,0,7,1
end

function _draw()
	if gamemode==-1 then
		-- paranoid cactus logo
		cls()
		sspr(0,96,29,12,49,59)
		sspr(86,119,10,9,59,50)
	elseif gamemode==0 then
		-- title screen
		cls()
		-- copy user memory to screen memory
		memcpy(0x6280,0x4300,0x1b00)
		if waittimer==0 and brushy<brushyd then
			-- draw a peice of the x brush stroke
			for i=0,4 do
				circfill(brushx,brushy,brushw+rnd(3),8)
				brushx+=brushxv
				brushy+=brushyv
				brushw-=0.085
			end
			-- copy screen memory to user memory
			memcpy(0x4300,0x6280,0x1b00)
		end
		if brushy<256 and brushy>250 then
			-- flash screen when "zero" appears
			cls(8)
		elseif brushy>=256 then
			-- finished drawing brush strokes so display "zero"
			sspr(0,108,86,20,21,39)
			print("press 🅾️ or ❎ to start",18,112,flashtime>8 and 1 or 11)
			-- corrupt screen a little bit
			if flrrnd(48)==0 then
				corruptlines(flrrnd(10))
			end
		end
	elseif gamemode==1 then
		cls()
		-- draw parallax background
		for bgx=0,4 do
			for bgy=0,3 do
				map(118,56,flr(-camx*0.5%80)+bgx*80-80,flr(-camy*0.5%64)+bgy*64-64,10,8)
			end
		end
		
		-- draw map
		palt(0,false)
		palt(10,true)
		-- find out the map block that the top left of the screen is in
		local mbixl,mbiyt=getmbxy(camx,camy)
		-- draw each visible map block
		for mbix=mbixl,mbixl+1 do
			for mbiy=mbiyt,mbiyt+1 do
				-- determine which section of the pico-8 map to draw for this prefab block
				local mb,mbscrx,mbscry=(mbix<1 or mbix>#mgr or mbiy<1 or mbiy>#mgr[mbix]) and nullmap or mgr[mbix][mbiy],-camx+(mbixl-1)*128+(mbix-mbixl)*128,-camy+(mbiyt-1)*128+(mbiy-mbiyt)*128
				-- draw the block
				map(mb.mbx,mb.mby,mbscrx,mbscry,16,16,mb.key and 0x3 or 1)
				-- if there is a terminal and it hasn't been hacked then draw the flashing screen
				if mb.key and not mb.keytaken then
					pal(11,10)
					if flashtime<8 then
						pal(9,8)
						pal(8,2)
						pal(6,9)
					end
					sspr(96,11,8,5,mbscrx+mb.scr[1],mbscry+mb.scr[2])
					pal(11,11)
					pal(9,9)
					pal(8,8)
					pal(6,6)
				end
			end
		end
		palt()
		if door then
			door:draw()
		end
		for p in all(pickups) do
			p:draw()
		end
		for b in all(bullets) do
			b:draw()
		end
		if boss then
			boss:draw()
		end
		if not waitfunc or (boss and boss.hp<=0) then
			player:draw()
		end
		for e in all(activeenemies) do
			e:draw()
		end
		for p in all(particles) do
			p:draw()
		end
		-- hud map
		if not boss then
			rectfill(127-w*2,0,127,h*2,15)
			for mx=1,#mgr do
				for my=1,#mgr[mx] do
					local mg=mgr[mx][my]
					if mg.visited then
						local mb=mapbits[mg.paths+1]
						sspr(mb[1],mb[2],3,3,125-w*2+mx*2,my*2-2,3,3,mb.fx,mb.fy)			
					end
					if mg.key then
						pset(126-w*2+mx*2,my*2-1,mg.keytaken and 1 or 3)
					end
					if mg.boss and keycount==0 then
						pset(126-w*2+mx*2,my*2-1,flashtime<8 and 8 or 10)
					end
				end
			end
			pset(128-w*2+flr(player.x/128)*2,flr(player.y/128)*2+1,11)
		end
		-- player ui
		rectfill(0,0,player.maxhp*3+6,5,15)
		sspr(120,12,5,4,1,1)
		for i=1,player.maxhp do
			rectfill(4+i*3,1,5+i*3,4,0)
			if player.hp>=i then
				sspr(125,12,2,4,4+i*3,1)
			end
		end
		rectfill(25,0,40,5,15)
		for i=1,player.lives do
			sspr(0,0,5,4,20+i*5,1)
		end
		-- boss health bar
		if boss then
			rectfill(13,124,114,127,15)
			rectfill(14,125,113,126,0)
			if boss.hp>0 then
				rectfill(14,125,13+ceil(boss.hp/1.5),126,8)
			end
		end
		
		-- if player was hit or is hacking then corrupt the screen
		if player.hit>0 then
			corruptlines(3)
		end
		if player.hackt>0 then
			corruptlines(1+flrrnd(player.hackt/6))
		end
	elseif gamemode==2 then
		-- game over
		cls()
		sspr(29,96,39,12,45,57)
		corruptlines(6)
	elseif gamemode==3 then
		-- win
		cls()
		sspr(68,64,60,44,34,40)
	end
	-- screen pallete
	for i=1,16 do
		pal(i-1,fadepal[fpi][i],1)
	end
end

function corruptlines(n)
	-- randomly copy bits of screen memory around
	for i=0,n do
		memcpy(0x6000+flrrnd(0x1fc0),0x6000+flrrnd(0x1fc0),flrrnd(64))
		local addr=0x6000+flrrnd(0x1fc0)
		poke4(addr,bxor(peek4(addr),0xffff.ffff))
	end
end

function new_player(x,y)
	local jtm,anm,anmf,flp,onground,ft,nft,canjmp,btm,gunf,guna,hackdonet,canhack=0,pstand,1,false,false,4,4,true,0,1,0,0,false
	return {
		sx=x,sy=y,x=x,y=y,vx=0,vy=0,maxbullets=5,bcount=1,hit=0,maxhp=5,hp=5,invulnerable=0,lives=3,hackt=0,
		update=function(p)
			-- find which map block player is in
			local mbix,mbiy,mg=getmb(p.x,p.y)
			-- see if player is in front of terminal
			canhack=onground and mg and mg.key and not mg.keytaken and mfget(p.x,p.y-1,2)
			-- see if we've triggered the boss fight
			if not bossevent and mg and mfget(p.x,p.y-1,3) then
				music(23,0,3)
				bossevent,p.sx,p.sy=true,p.x,p.y
				spawn_boss((mbix-1)*128+100,(mbiy-1)*128+32)
				for e in all(activeenemies) do
					e:kill(true)
				end
				spawn_door(mbix*128-124,mbiy*128-64)
			end
			-- see if player has fallen into the boss pit
			if mg and mfget(p.x,p.y-6,5) then
				p:hurt()
				p.x,p.y,p.vx,p.vy=p.sx,p.sy,0,0
			end
			
			if btn(3) then
				-- if we're in front of a hackable terminal
				if canhack then
					guna,gunf,p.vx,p.vy=flp and 0.25 or 0.75,2,0,0
					if p.hackt==0 then
						sfx(41,3)
					end
					-- increment hack timer
					p.hackt+=1
					if p.hackt>=128 then
						-- hacking complete
						mg.keytaken,hackdonet,p.hackt=true,120,0
						sfx(42,3)
						keycount-=1
						-- open door when all terminals are hacked
						if keycount==0 then
							door=nil
						end
					end
				else
					-- aim down
					guna,gunf,p.hackt=flp and 0.375 or 0.625,1,0
				end
			elseif btn(2) then
				-- aim up
				guna,gunf,p.hackt=flp and 0.125 or 0.875,3,0
			else
				-- aim forward
				guna,gunf,p.hackt=flp and 0.25 or 0.75,2,0
			end
			-- if not hacking
			if p.hackt==0 then
				sfx(41,-2)
				-- move
				if btn(0) then
					p.vx,flp=max(p.vx-0.25,-1.5),true
				elseif btn(1) then
					p.vx,flp=min(p.vx+0.25,1.5),false
				elseif onground then
					p.vx*=0.5
				else
					p.vx*=0.95
				end
				-- jump
				if btn(jbtn) then
					if onground and canjmp then
						p.vy-=1.25
						-- jtm: counts down while player is holding jump for variable height jump
						-- canjmp: keeps track of whether the player has released the jump button
						jtm,canjmp=8,false
					elseif jtm>0 then
						-- increase jump velocity while player holds jump
						p.vy-=0.2
					end
				else
					-- not pressing jump so kill jump time and allow jump
					jtm,canjmp=0,true
				end
			end
			
			if jtm==0 then
				-- only apply gravity when jump height isn't increasing
				p.vy+=0.15
			else
				-- reduce jump timer
				jtm-=1
			end
			-- cap fall speed
			p.vy=min(p.vy,3)
			-- collide with map
			p.x,p.y,p.vx,p.vy,onground=collideworld(p.x,p.y,p.vx,p.vy,8,14)

			p.x+=p.vx
			p.y+=p.vy
			
			-- set animation sequence and frame
			if not onground then
				-- not on ground so use jump sequence set frame to 1
				anm,anmf=pjump,1
				if p.vy>1.3 then
					-- if going down use frame 3
					anmf=3
				elseif p.vy>-1 then
					-- if near peak of jump use frame 2
					anmf=2
				end
			elseif abs(p.vx)>0.01 then
				-- if on ground and moving use run sequence
				-- set time til next frame based on velocity
				nft=flr(6-(abs(p.vx)*2))
				-- set run sequence
				if anm~=prun then
					anm,anmf,ft=prun,0,1
				end
				ft-=1
				-- if frame timer hits 0 increment frame
				if ft==0 then
					ft,anmf=nft,anmf%#anm+1
				end
			else
				-- standing still
				anm,anmf=pstand,1
			end
			
			-- shooting
			if p.hackt==0 and btn(sbtn) and btm==0 then
				-- set gun sprite based on the aim direction
				gspr=gsprs[gunf]
				-- spawn bullets (bcount is bullets player has upgraded to
				for i=1,p.bcount do
					local b=gun.bullets[i]
					-- angle of bullet
					local a=((guna+b)%1)
					-- x,y velocity of bullet
					local bvx,bvy=sin(a)*gun.spd,-cos(a)*gun.spd
					new_bullet(p.x+(flp and -1 or 9),p.y+anm[anmf][3][3]+gspr.by,bvx,bvy,a,bsprs,player)
				end
				-- fire rate counter
				btm=gun.rate
			end
			btm=max(0,btm-1)
			-- hack complete message timer
			hackdonet=max(hackdonet-1,0)
			-- hit damage flash timer
			p.hit=max(p.hit-1,0)
			-- invulnerabilty timer
			p.invulnerable=max(p.invulnerable-1,0)
			
			-- if not invulnerable check enemy collision
			if p.invulnerable==0 then
				-- only check against active enemies
				for e in all(activeenemies) do
					if not (p.x+4<e.x+e.hbx1+3 or p.x-4>e.x+e.hbx2-3 or p.y-2<e.y+e.hby1+3 or p.y-10>e.y+e.hby2-3) then
						p:hurt()
						break
					end
				end
			end
			-- check collision with pickups
			for pu in all(pickups) do
				if not (p.x+4<pu.x-3 or p.x-4>pu.x+3 or p.y<pu.y-3 or p.y-12>pu.y) then
					local putype=pu.pickuptype
					-- increment property the pickup affects
					p[putype.prop]=min(p[putype.prop]+putype.propadd,p[putype.propmax])
					del(pickups,pu)
					sfx(44)
				end
			end
			
			if p.hp<=0 then
				playerdie()
			end
		end,
		hurt=function(p)
			p.hp-=1
			p.invulnerable,p.hit,p.hackt=129,10,0
			p.bcount=max(1,p.bcount-2)
			sfx(40)
		end,
		reset=function(p)
			-- reset when player dies but still has lives
			p.x,p.y,p.vx,p.vy,p.bcount,p.hit,p.maxhp,p.hp,p.invulnerable,jtm,anm,anmf,flp,onground,ft,nft,canjmp,btm,gunf,guna,p.hackt=p.sx,p.sy,0,0,1,0,5,5,120,0,pstand,1,false,false,4,4,true,0,1,0,0
		end,
		draw=function(p)
			-- don't draw if dead
			if p.hp<=0 then
				return
			end
			-- only draw if we're not invulnerable blink frame
			if p.invulnerable%20<10 then
				-- set pallete to white if hit
				if p.hit>0 then
					for c=0,15 do
						pal(c,7)
					end
				end
				if p.hackt>0 then
					-- special sprite for hacking
					sspr(85,7,11,14,p.x-camx,p.y-14-camy)
				else
					-- each layer in frame
					for i=1,#anm[anmf] do
						local af,ox=anm[anmf][i],0
						-- layer 2 is gun so switch depending on aim
						local s=anm[anmf][i][1]==2 and gsprs[gunf] or psprs[af[1]]
						-- y offset from position to draw
						local oy=af[3]+(s.oy or 0)
						-- if flipped adjust x offset for sprite
						if flp then
							ox=8-(af[2]+s[3])
						else
							ox=af[2]
						end
						sspr(s[1],s[2],s[3],s[4],p.x+ox-camx,p.y+oy-camy,s[3],s[4],flp)
					end
				end
				pal()
			end
			
			-- hack message
			if p.hackt>0 then
				rectfill(54,38,82,46,15)
				rectfill(55,45,81,45,0)
				rectfill(55,45,55+min(p.hackt/4.6,26),45,8)
				print("hacking",55,39,3)
			elseif hackdonet>0 then
				rectfill(54,38,82,46,1)
				rectfill(55,45,81,45,12)
				print("success",55,39,11)
			elseif canhack then
				rectfill(60,38,76,44,15)
				print("hack",61,39,3)
				sspr(89,26,7,6,65,31)
			end
		end
	}
end

function new_enemy(x,y,enemytype)
	local sprs,anm,anmf,flp,active,dest,destt=enemytype.sprs,enemytype.anms,1,false,false,player,1
	return add(enemies,{sx=x,sy=y,x=x,y=y,vx=0,vy=0,hit=0,hp=enemytype.hp,hbx1=enemytype.hbx1,hby1=enemytype.hby1,hbx2=enemytype.hbx2,hby2=enemytype.hby2,fly=enemytype.fly,dir=1,
		update=function(p)
			-- distance from player
			local dx,dy=player.x-p.x,player.y-4-p.y
			local nearplayer=abs(dx)<80 and abs(dy)<80
			-- if not dead
			if p.hp>0 then
				-- only update if near player
				if nearplayer then
					-- if enemy was previously inactive add to active list
					--   the active enemies list is used for performance optimisation.
					--   inactive enemies won't be drawn or used when checking collision with the player or bullets.
					if not active then
						add(activeenemies,p)
						active=true
					end
					
					-- if this is a flying enemy
					if p.fly then
						-- timer before we choose a new destination
						destt=max(destt-1,-30)
						if destt==0 then
							-- set player as destination
							dest=player
						end
						-- direction to destination
						dx,dy=dest.x-p.x,dest.y-4-p.y
						-- get direction vector
						local nx,ny=normalize(dx,dy,0.25)
						-- set velocity to head towards destination
						p.vx=mid(p.vx+nx*0.25,-0.5,0.5)
						p.vy=mid(p.vy+ny,-0.5,0.5)
						if destt==-30 then
							-- see if we're on top of another flying enemy
							for e in all(activeenemies) do
								if e~=p and e.fly and abs(p.x-e.x)<4 and abs(p.y-e.y)<4 then
									-- we are overlapping another flyng enemy so choose a random destination to fly to get away from them
									local dir=rnd(1)
									dest,destt={x=p.x+sin(dir)*24,y=p.y-cos(dir)*24},30
									break
								end
							end
						end
					else
						-- walking enemy
						-- turn if hit wall or reach edge of platform
						if p.vx==0 or not is_solid(p.x+p.vx+(p.dir<0 and p.hbx1+5 or p.hbx2-2),p.y+2) then
							p.dir=-p.dir
						end
						p.vx=p.dir*0.5
						p.vy=0.5
					end
					-- increment anim frame
					anmf=(anmf+1)%(#anm*2)
					-- flip if moving left
					if p.vx<0 then
						flp=true
					else
						flp=false
					end
					-- hit flash timer
					p.hit=max(p.hit-1,0)
					-- collide with map
					p.x,p.y,p.vx,p.vy=collideworld(p.x,p.y,p.vx,p.vy,8,8)
					p.x+=p.vx
					p.y+=p.vy
				elseif active then
					-- too far from player so deactivate
					del(activeenemies,p)
					active=false
				end
			else
				-- enemy is dead
				
				-- remove from active enemies list
				if active then
					del(activeenemies,p)
					active=false
				end
				-- decrease hp (used for respawn timer)
				p.hp-=1
				if p.hp==-5940 and not nearplayer then
					-- don't respawn if too far away from player
					p.hp=-5939
				end
				if p.hp<=-6000 then
					-- respawn
					p.x,p.y,p.vx,p.vy,p.hp=p.sx,p.sy,0,0,enemytype.hp
				elseif p.hp<-5940 and p.hp%3==0 and nearplayer then
					-- create respawn particle effect
					local a=rnd(1)
					local vx,vy=sin(a),-cos(a)
					new_particle(p.sx+vx*8,p.sy+vy*8-5,-vx*0.25,-vy*0.25,rnd(1)>0.5 and 6 or 7,32,0,true)
				end
			end
		end,
		reset=function(p)
			-- reset when player dies but still has lives
			p.x,p.y,p.vx,p.vy,p.hit,p.hp,active=p.sx,p.sy,0,0,0,enemytype.hp,false
		end,
		kill=function(e,nodrop)
			e.hp=0
			sfx(43)
			-- explode
			local cols={2,8,9}
			for i=0,8 do
				new_particle(e.x,e.y-5,(rnd(2)-1)*0.75,-rnd(2),cols[flrrnd(3)+1],30+flrrnd(30),0.15)
			end
			-- nodrop is true when enemies are killed before boss fight starts
			if not nodrop then
				-- if the drop table is empty create a new one
				if #droptable==0 then
					-- for every 31 enemies killed your guaranteed to get 2 powerups and 1 heart
					droptable={0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,2}
				end
				-- randomly pull entry from drop table
				local drop=droptable[flrrnd(#droptable)+1]
				del(droptable,drop)
				-- if the entry wasn't nothing then spawn pickup
				if drop>0 then
					new_pickup(e.x+2,e.y-4,pickuptypes[drop])
				end
			end
		end,
		draw=function(p)
			-- if not dead draw enemy
			if p.hp>0 then
				-- get animation frame
				local s,ox=sprs[anm[flr(anmf/2)+1]],0
				-- adjust x draw offset if flipped
				if flp then
					ox=8-(s.ox+s[3])
				else
					ox=s.ox
				end
				-- set pal to white if hit
				if p.hit>0 then
					for c=0,15 do
						pal(c,7)
					end
				end
				sspr(s[1],s[2],s[3],s[4],p.x+ox-camx,p.y+s.oy-camy,s[3],s[4],flp)
				pal()
			end
		end
	})
end

function spawn_boss(x,y)
	-- boss sequence {a=action to perform,t=action duration,y=move to position}
	local seq,seqv,seqi,seqt,py,dy,prevhp={{a=3,t=90},{a=2,t=45,y=y-32},{a=3,t=90},{a=2,t=45,y=y+24},{a=3,t=90},{a=2,t=45,y=y+52},{a=3,t=90},{a=4,t=45},{a=1,t=160},{a=4,t=45},{a=1,t=160},{a=4,t=45},{a=1,t=160},{a=2,t=45,y=y}},{a=2,y=y,t=180},0,0,y+100,y,150
	local beam=0
	boss={x=x,y=y+100,sx=x,sy=y,hp=150,hit=0,
		update=function(p)
			if prevhp<=0 then
				-- boss is dying
				sfx(61,-2)
				beam,p.hit=0,0
				-- create explosion every 8 frames
				if waittimer%8==0 then
					local ppx,ppy=flrrnd(20),flrrnd(32)
					for i=0,16 do
						local a=rnd(1)
						local vx,vy=sin(a),-cos(a)
						new_particle(p.x-5+ppx,p.y+ppy,-vx,-vy,rnd(1)>0.5 and 7 or 10,15+flrrnd(8),0,true)
					end
					sfx(43)
				end
				return
			end
			-- move to next action in sequence when current timer has expired
			if seqt>=seqv.t then
				-- increment sequence index
				seqi=(seqi%#seq)+1
				-- get next sequence entry, set timer to 0 and remember our y offset so we can lerp from it
				seqv,seqt,py=seq[seqi],0,p.y
				-- stop beam sound if it was playing
				sfx(61,-2)
				beam=0
				-- get y position for aiming at player
				if player.y<=y then
					dy=y-32
				elseif player.y<=y+32 then
					dy=y
				elseif player.y<=y+56 then
					dy=y+24
				else
					dy=y+52
				end
			end
			-- sequence timer
			seqt+=1
			-- execute current action
			if seqv.a==1 then
				-- action 1: fire big beam
				if seqt<30 and seqt%2==0 then
					-- weapon warm up particles
					local a=rnd(1)
					local vx,vy=sin(a),-cos(a)
					new_particle(p.x-5+vx*8,p.y+24+vy*8,-vx*0.5,-vy*0.5,rnd(1)>0.5 and 9 or 8,15,0,true)
				end
				if seqt>30 and seqt<40 then
					-- red warning line
					new_particle(p.x-5,p.y+24,-7-rnd(4),0,8,10,0,true)
					new_particle(p.x-112,p.y+24,7+rnd(4),0,8,10,0,true)
				end
				if seqt==52 then
					sfx(61,2)
				end
				if seqt>60 then
					-- fire beam
					if seqt%4==0 then
						local a=rnd(1)
						local vx,vy=sin(a),-cos(a)
						new_particle(p.x-5,p.y+24,-vx*0.75,-vy*0.75,7,15,0,true)
					end
					-- wiggle beam width
					if beam>10 then
						beam-=2
					else
						beam+=1
					end
					-- check if beam hit player
					if player.invulnerable==0 and not (player.y<p.y+24-beam or player.y-12>p.y+24+beam) then
						player:hurt()
					end
				end
			elseif seqv.a==3 then
				-- action 3: fire blue bullets
				if seqt<30 and seqt%2==0 then
					-- warm up warning particles
					local a=rnd(1)
					local vx,vy=sin(a),-cos(a)
					new_particle(p.x-5+vx*8,p.y+24+vy*8,-vx*0.5,-vy*0.5,rnd(1)>0.5 and 11 or 12,15,0,true)
				end
				if seqt>30 and seqt%10==0 then
					-- fire
					new_bullet(p.x-4,p.y+25,-1.5,0,0.25,ebsprs,boss)
					new_bullet(p.x-4,p.y+25,-1.4,-0.5,0.25,ebsprs,boss)
					new_bullet(p.x-4,p.y+25,-1.4,0.5,0.25,ebsprs,boss)
				end
			elseif seqv.a==2 then
				-- action 2: move to scripted position
				p.y=smoothlerp(py,seqv.y,seqt/seqv.t)
			elseif seqv.a==4 then
				-- action 4: move to aim at player
				p.y=smoothlerp(py,dy,seqt/seqv.t)
			end
			p.hit=max(p.hit-1,0)
			-- speed up sequence as boss looses hp
			if prevhp~=p.hp and p.hp%10==0 then
				for i=1,#seq do
					seq[i].t-=(i%2==1 and 0 or 2)
				end
			end
			-- remember boss's hp from this frame to check if it decreased
			prevhp=p.hp
			-- boss died
			if prevhp<=0 then
				waitfunc,waittimer,player.invulnerable,beam,p.hit=wingame,360,360,0,0
			end
		end,
		draw=function(p)
			if p.hit>0 then
				for c=0,15 do
					pal(c,7)
				end
			end
			sspr(57,42,13,14,p.x-camx,p.y-camy)
			pal()
			sspr(61,7,24,22,p.x-camx-6,p.y-camy+13)
			-- draw beam
			if beam>0 then
				for i=1,3 do
					local bw,col=beam*(1-i/6),i==1 and 9 or (i==2 and 10 or 7)
					circfill(p.x-bw-6-camx,p.y+25-camy,bw,col)
					rectfill(0,p.y+25-bw-camy,p.x-bw-6-camx,p.y+25+bw-camy,col)
				end
			end
		end
	}
end

function spawn_door(x,y)
	-- door to boss chamber
	door={x=x,y=y,
		draw=function(p)
			-- electrical zappy thing
			local x1,x2,x1p,x2p=0,0,x+flrrnd(8)-4-camx,x+flrrnd(8)-4-camx
			for i=0,5 do
				x1,x2=x+flrrnd(8)-4-camx,x+flrrnd(8)-4-camx
				line(x1p,y-i*4-camy-1,x1,y-i*4-camy-4,11)
				line(x2p,y-i*4-camy-1,x2,y-i*4-camy-4,12)
				x1p,x2p=x1,x2
			end
		end
	}
end

function new_bullet(x,y,vx,vy,a,bullettype,owner)
	local anmf,anmfi=1,1
	add(bullets,{x=x,y=y,vx=vx,vy=vy,a=a,t=80,
		update=function(p)
			p.x+=p.vx
			p.y+=p.vy
			p.t-=1
			-- animate bullet
			if bullettype.anms then
				anmfi=(anmfi%#bullettype.anms)+1
				anmf=bullettype.anms[anmfi]
			else
				anmf=flr((p.a)*16)%16+1
			end
			-- hit is used to determine if the bullet should be deleted
			local hit=p.t<=0 or abs(p.x-player.x)>112 or abs(p.y-player.y)>112
			-- player's bullet
			if owner==player then
				if boss then
					-- hit boss's head
					if p.x>boss.x and p.x<boss.x+12 and p.y>boss.y-1 and p.y<boss.y+16 then
						boss.hp-=1
						boss.hit,hit=5,true
					end
					-- hit boss's body
					if (p.x>boss.x-2 and p.x<boss.x+12 and p.y>boss.y+14 and p.y<boss.y+20) or
						(p.x>boss.x-5 and p.x<boss.x+15 and p.y>boss.y+19 and p.y<boss.y+34) then
						hit=true
					end
					if hit then
						-- hit splash and sfx
						sfx(35)
						for i=0,3 do
							new_particle(p.x,p.y,(rnd(2)-1)*0.5,(rnd(2)-1)*0.5,10,10+flrrnd(5),0,true)
						end
					end
				end
				-- see if we hit an enemy
				for e in all(activeenemies) do
					if e.hp>0 and p.x>e.x+e.hbx1 and p.x<e.x+e.hbx2 and p.y>e.y+e.hby1 and p.y<e.y+e.hby2 then
						e.hit,hit=5,true
						e.hp-=1
						if e.hp==0 then
							e:kill()
						else
							sfx(35)
							for i=0,3 do
								new_particle(p.x,p.y,(rnd(2)-1)*0.5,(rnd(2)-1)*0.5,10,10+flrrnd(5),0,true)
							end
						end
						break
					end
				end
			-- boss's bullet so see if it hit player
			elseif player.invulnerable==0 and p.x>player.x-2 and p.x<player.x+6 and p.y>player.y-13 and p.y<player.y then
				player:hurt()
				hit=true
				for i=0,4 do
					new_particle(p.x,p.y,(rnd(2)-1)*0.5,(rnd(2)-1)*0.5,12,10+flrrnd(5),0,true)
				end
			end
			-- if it hit someone or it hit a wall then delete
			if hit or is_solid(p.x,p.y) then
				del(bullets,p)
			end
		end,
		draw=function(p)
			local s=bullettype[anmf]
			sspr(s[1],s[2],s[3],s[4],p.x+s.ox-camx,p.y+s.oy-camy,s[3],s[4],s.fx,s.fy)
		end
		})
end

function new_pickup(x,y,pickuptype)
	add(pickups,{x=flr(x),y=flr(y),vy=-1,anmf=0,pickuptype=pickuptype,
		update=function(p)
			-- if pickup hasn't hit floor
			if not p.stop then
				local d1,d2,collision=0,0,false
				-- fall
				p.vy=mid(-3,p.vy+0.2,3)
				-- check collision
				p.x,p.y,d1,d2,collision=collideworld(p.x,p.y,0,p.vy,6,4)
				if collision then
					-- bounce
					p.vy=-p.vy*0.5
					-- if bounce amount is very small then stop pickup from moving
					if abs(p.vy)<0.05 then
						p.stop,p.vy,p.y=true,0,flr(p.y)
					end
				end
				p.y+=p.vy
			end
			-- set animation frame
			p.anmf=(p.anmf+1)%(#p.pickuptype.sprs*3)
		end,
		draw=function(p)
			local s=p.pickuptype.sprs[flr(p.anmf/3)+1]
			sspr(s[1],s[2],s[3],s[4],p.x+s.ox-camx,p.y+s.oy-camy,s[3],s[4],s.fx,s.fy)
		end
	})
end

function new_particle(x,y,vx,vy,c,t,g,nonsolid)
	add(particles,{x=x,y=y,vx=vx,vy=vy,c=c or 8,st=t or 60,t=t or 60,g=g or 0.2,nonsolid=nonsolid,
		update=function(p)
			p.vy=min(p.vy+g,7)
			
			-- if particle is solid then bounce
			if not nonsolid then
				if (p.vx>0 or p.vx<0) and is_solid(p.x+p.vx,p.y) then
					p.vx=-p.vx*0.75
					p.vy*=0.9
				end
				if (p.vy>0 or p.vy<0) and is_solid(p.x,p.y+p.vy) then
					p.vy=-p.vy*0.75
					p.vx*=0.9
				end
			end
			
			p.x+=p.vx
			p.y+=p.vy
			
			-- delete when its timer expires
			p.t-=1
			if p.t==0 then
				del(particles,p)
			end
		end,
		draw=function(p)
			local x,y,s=p.x-camx,p.y-camy,flr(p.t/p.st+0.5)
			rectfill(x,y,x+s,y+s,c)
		end
	})
end

function collideworld(x,y,vx,vy,w,h)
	local hhalf,topclip,onground=flr(h/2),h>8 and h-7 or 7,false
	-- only check collision in direction we are moving
	if vx<0 and (is_solid(x+vx,y-1) or is_solid(x+vx,y-hhalf) or is_solid(x+vx,y-(h-1))) then
		x,vx=flr((x+vx)/8)*8+8,0
	end
	if vx>0 and (is_solid(x+vx+w,y-1) or is_solid(x+vx+w,y-hhalf) or is_solid(x+vx+w,y-(h-1))) then
		x,vx=flr((x+vx)/8)*8+8-w,0
	end
	if vy>0 and (is_solid(x,y+vy) or is_solid(x+w-1,y+vy)) then
		-- hit the floor so set onground to true
		y,vy,onground=flr((y+vy)/8)*8,0,true
	end
	if vy<0 and (is_solid(x,y+vy-h) or is_solid(x+w-1,y+vy-h)) then
		y,vy=flr((y+vy)/8)*8+topclip,0
	end
	return x,y,vx,vy,onground
end

function getmbxy(x,y)
	return flr(x/128)+1,flr(y/128)+1
end

function getmb(x,y)
	-- get index into map table
	local mbix,mbiy=getmbxy(x,y)
	-- return x and y index and map block (if outside the map return full solid block)
	return mbix,mbiy,(mbix<1 or mbix>#mgr or mbiy<1 or mbiy>#mgr[mbix]) and nullmap or mgr[mbix][mbiy]
end

function mfget(x,y,f)
	-- get map block from table
	local mbix,mbiy,mb=getmb(x,y)
	-- see if tile on map block is solid
	return fget(mget(flr(x/8)-(mbix-1)*16+mb.mbx,flr(y/8)-(mbiy-1)*16+mb.mby),f)
end

function is_solid(x,y)
	return mfget(x,y,0) or (door and mfget(x,y,4))
end

function playerdie()
	player.lives-=1
	waittimer,waitfunc=240,resetgame
	sfx(41,-2)
	sfx(61,-2)
	sfx(43)
	local cols={1,11,12}
	for i=0,48 do
		new_particle(player.x,player.y-5,(rnd(4)-2),-rnd(4),cols[flrrnd(3)+1],60+flrrnd(90),0.15)
	end
end

function resetgame()
	if player.lives==0 then
		-- game over
		changemode(2)
	else
		-- reset everything and put player back at start
		bullets,activeenemies,particles,pickups={},{},{},{}
		for e in all(enemies) do
			e:reset()
		end
		player:reset()
		if boss then
			-- boss fight so reset the boss and give player max weapon
			player.bcount=5
			spawn_boss(boss.sx,boss.sy)
			music(23,0,3)
		end
	end
end

function wingame()
	changemode(3)
end

function genmap()
	mgr,sx,sy,bullets,enemies,activeenemies,particles,pickups,droptable,keycount,exity={},1,1+flrrnd(h),{},{},{},{},{},{},0,flrrnd(h-1)+1
	-- initialise map grid
	for x=1,w do
		mgr[x]={}
		local removed=(x-1)%3
		for y=1,h do
			-- initialise map cell
			mgr[x][y]={dirs={x~=1 and l,y~=1 and t,x~=w and r,y~=h and b},paths=0,visited=false,x=x,y=y,keytaken=false,frame=-1,dist=0}
			-- right 2 columns of the map
			if x>=w-1 then
				mgr[x][y].visited=true
				-- if this is the row for the exit
				if y==exity then
					mgr[x][y].sp=true
					mgr[x][y].paths=l
					-- second from right is corridor to boss
					if x==w-1 then
						mgr[x][y].paths+=r
						mgr[x-1][y].paths=r
						mgr[x-1][y].dirs[3]=nil
						mgr[x-1][y].endpoint=true
						spawn_door(x*128-60,y*128-64)
						new_pickup(x*128-8,y*128-60,pickuptypes[2])
						new_pickup(x*128-16,y*128-60,pickuptypes[1])
						new_pickup(x*128-24,y*128-60,pickuptypes[2])
						new_pickup(x*128-32,y*128-60,pickuptypes[1])
						new_pickup(x*128-40,y*128-60,pickuptypes[2])
					else
						-- far right is the boss room
						mgr[x][y].boss=true
					end
				end
			-- randomly place solid (non-corridor) areas into map
			elseif x<w-2 and removed>0 and flrrnd(3)==0 then
				mgr[x][y].visited=true
				removed-=1
			end
		end
	end
	-- start poisiton
	mgr[sx][sy].start=true
	-- recurively step through map to create maze
	stepmaze(sx,sy,0)
	-- setup completed maze for gameplay
	for x=1,w do
		for y=1,h do
			local mb=mgr[x][y]
			-- choose prefab block to use
			local prefab=prefabs[mb.paths+1]
			local prefabi=flrrnd(#prefab)+1
			-- visited: used for minimap to know where player has been
			-- enemies: the enemies that spawn here
			-- mbx and mby: the x and y coords for prefab in pico-8 map memory
			-- scr: contains details for computer terminal
			mb.visited,mb.enemies,mb.mbx,mb.mby,mb.scr=false,{},prefab[prefabi][1],prefab[prefabi][2],prefab[prefabi].scr
			-- if this is boss room or entrance corridor
			if mb.sp then
				mb.mbx,mb.mby=prefab.sp[1],prefab.sp[2]
			end
			-- randomise enemy placements
			if mb.dist>0 then
				-- enemy count increases further away from player start
				local ecount=mid(0,ceil((mb.dist-1)/3),12)
				for i=1,ecount do
					-- pick location within this block
					-- x postion increments across block for each enemy
					local px,py=flr((i-1)*ecount/12)+1,flrrnd(12)+1
					-- if it's not a wall
					if not fget(mget(mb.mbx+px,mb.mby+py),0) then
						-- start by choosing flying enemy
						local et=enemy1
						if i%4==0 then
							-- check for ground below enemy
							for ey=py,15 do
								-- if we find ground change to walking enemy
								if fget(mget(mb.mbx+px,mb.mby+ey),0) then
									et,py=enemy2,ey-1
									break
								end
							end
						end
						-- add enemy
						add(mb.enemies,new_enemy(x*128-128+px*8,y*128-120+py*8,et))
					end
				end
			end
		end
    end
	-- create player, remember total number of terminals
	player,keycounttotal=new_player(sx*128-64,sy*128-64),keycount
	camx,camy,flashtime=player.x-64,player.y-64,0
end

function stepmaze(x,y,dist)
	local m=mgr[x][y]
	-- if cell hasn't been visited
	if not m.visited then
		-- mark as visited and record distance from start
		m.dist,m.visited=dist,true
		-- keep track of how many times we couldn't move from this cell to determine when we hit a deadend
		local failcount=#m.dirs
		-- while there are directions we haven't tried to move
		while #m.dirs>0 do
			-- choose direction and remove from the list
			local dir,rsx,rsy=del(m.dirs,m.dirs[flrrnd(#m.dirs)+1]),(x-1)*8,(y-1)*8
			-- try moving in chosen direction
			if dir==l then
				failcount-=setstepvals(m,x-1,y,l,r,dist)
			elseif dir==t then
				failcount-=setstepvals(m,x,y-1,t,b,dist)
			elseif dir==r then
				failcount-=setstepvals(m,x+1,y,r,l,dist)
			elseif dir==b then
				failcount-=setstepvals(m,x,y+1,b,t,dist)
			elseif not dir then
				failcount-=1
			end
		end
		-- if deadend add terminal
		if failcount==0 and not m.endpoint then
			m.key=true
			keycount+=1
		end
		return true
	end
end

function setstepvals(m1,mx,my,dir,backdir,dist)
	if stepmaze(mx,my,dist+1) then
		local m2=mgr[mx][my]
		-- if we succeeded set a path between cells
		m1.paths+=dir
		m2.paths+=backdir
		return 0
	end
	return 1
end

function flrrnd(a)
	return flr(rnd(a))
end

function normalize(x,y,mul)
	local l,m=sqrt(x*x+y*y),mul or 1
	if l<=0 then
		return 0,0
	end
	return x/l*m,y/l*m
end

function lerp(a,b,t)
	return a+(b-a)*t
end

function smoothlerp(a,b,t)
	return a+(b-a)*(t*t*(3-2*t))
end

__gfx__
00cc000677666701111000111011100001110000011100011101110000111000001110001111100011110000111100e6000000000700000000000e0000000070
0c76c00eeee7ce0b1111001b111bbc0011bbcb0001bb000bb11b11100bb111100b111000b1111100b1111000b11100667000000066e0000ee000e6e077000766
0c6830cb7c1bb00cb111001bc111cb011111bc00111cb001c1bc1b100cb111b00cb11100cb10b100cb111100cb111c7e6700000767c000666e00676666700660
01bcc001cb00000cb01b07ccb1b7b00b1100cb01b10bc0c1cbbcb100cb100b10bc101b00cb00b00bcb00b17ccc011bc0e6600076ecb000777788777066788000
bc111b000000a0cb000b0cb10b10c0c100007ccb1000cbb0cbcb0b07b0000cb7cb000b1cb000cb7cb000b0c1bb0b1000c767066e000000777698966003898930
c7b111008909797c000cb00cbcb0000b000000b000007c007c7c0000c000000c00000cb7b00000c00000cb00000b0000bce00e7c000000676639a96008339a90
0cb11189a7a8a80009a666e5005e500050170071001700610d7d1007d00000000000000c0000000000000000000cb0000000cbcb000000066e0383e030003830
0111100089009008a79eee500e65e50561719917117199161799d0d7910000000004ddd44111111400000000cb0000000000000000000000e000000000388000
fff2ffff09a0808980000665e6506e0e67d9aa9d7d79aa96d7aa9197a900000000466667dd4444420000000c76b0000000000000aaaaaaaaaaaaaaaa07798960
f222222f079009a0000e6e5005006e5607d9aa9d7d79aa96d7aa9197a900000004dddd64222222222000000c6cb0000000000000aaaaaaaaaaaaaaaa76639a96
f2f2ffff8a0087900000500000006e0e01719917117199161799d0d791000000044444d2222222221000000b1110000000000000aaaaaaaaaaaaaaaa766038e6
f2f2222098009800000000000000000000170071001700610d7d1007d00000000444444222222222100000c16c1b000077699999aaaaaaaaaaaaaaaa06000000
f2f2f2f0800800000000000033300000000000899930000000000089993000000dddddd2222d444422000c7bccb6b00069888888aaaaaaaaaaaaaaaa98093bc0
fff0000000000000000000989a93000000008997788000000000997798800000dddddd4222d2222222100c6bcbbcc00099bb9b99aaaaaaaaaaaaaaaa89883c70
000003998999000000003879778800000038a79a939a0000003a79a9839a000ddddd64222d222222221001b1b1b1b60088888888aa1dddddd44441aa08830bc0
00098a7977988000000399a9a939a0000399aa89338b9000099aa898328b90d6667642222421224dd4440011cb11c7e099999999aad10000000014aa003001b0
009a9aa9a9839a000039a8989828b90839a98988823890009a9898888238904444462222242222211110000bb1b0bc70aaaaaaaaaad076d4222204aaaaaaaaaa
0389989898328b900838938883238930099388889223800389388888900382d6244d22222421224d4444001b11b10e6eaaaad444aad041ffffff04aaddd4aaaa
8038938888823890802389089320380008922008900003808932022089000dff614d2222242212211110001c00c10067aaad41f14ad02222222204ad1f1d4aaa
3008900238900383002289039022000003903000800000039302002008000dff6144222222422222221000bc00cb00e6aaad4dff4a40ffffffff04ad62fd1aaa
00082000289000000320830080030000083800093300000830023023900002dd124d222222211111111001c7006c1000aaad4fff4a402222222204ad22f41aaa
009320023080000008000900900080000090000008000000900080080000002224dd4221d6d4444444400000b000b000aaa441f14a410000000014a41f141aaa
0000800800090000000000033330000000000038999000000000000899300001111111121d6ddd444444000c7c00c7cbaaaa4444aa144444444441aa4441aaaa
000003989a93000000000898999800000000398979880000000009897980004ddddd4422f1d42222222210b777b07770aaaa11aaaa1f1201f10201aaaa11aaaa
00038979778800000003a7977989a00000098797a839a00000038797a89a006262642222ff4222222222100c7c0bc7c0aaa44111a1f01021f012f01a14411aaa
003899a9a939a0000098aa9a9838b900009a9a9a9838b90000399a9a938b90d1d1d42222ff42222222221000b00000b0aad611111114444444444ddddddd6daa
0839a8989828b90009a98989832389088389898983338900039a89898238904242442222f41111111111000000777760aadd6111111144444444ddddddd6d4aa
802993888323890038938888882038300388938882003800838938888223800111124222211111111110000007722276aaddd6dddddd4ddddddd6666666d44aa
300890089220380808932023890000000238900892000038023890398220000000000001441100000000000007725576aad400000000000000000000000044aa
00039000922000300982202208900000002080009300000022039009802000000000004ddd4410000000000006775776aad40f0f0f00fffffffff2222222d4aa
003830038030000083030003008000000309000388000000300088038300000000000000000000000000000005666662aad4f0f0f0f0fffffffff2222222d4aa
000090090008000090008008000900000080000009000000080009009000000000000000000000000000000000555220aa4400000000000000000fffffff44aa
e6666666666666667777776e666666666666666667777776666e6666666666e50000000000000000001001000010010000000000ffffffff0000f0000ff00000
77777777777777776eeeeee6777777777777777776eeee6e777e77777777776e00000000000000001110010000100111ffffff00ffffffff000000000ff00000
776eeeeeeeeeeeee51111115eeeeeeeeeeeeeeee6e5665e5ee6e76eeeeeeee6e0000000000000000000000000000000000000000ffffffff00fffffffff00000
66ee5115151515151e666e51ee5ee5eee665e5ee65576555ee656eee5115eee5000aa0000003300010eeeeeeeeeee501ffffff00ffffffff0fffffffff000000
e6e516611e1e1e1e16eeeee15516516556e15155e516d15555e5655516e15555000aa000000330000e5555555555555000000000ffffffff0ff0000000000000
ee546e5e1d1d1d1d1e5555d1541e41e551115155e51d415555d5e5556e5e554d0000000000000000e55e2555555e2554ffffff00ffffffff0ff0f00000000000
5dd4e55d040404040e5444d04d1ed1e444444444541111d444d1e444e44d4dd40000000000000000e55245555552455d00000000ffffffff0ff0f000ffffff00
a1114dd40000000005dddd40dd05d05ddddddddd4dddddd4ddd154dd4dd4111a0000000000000000e55555544555554dffffff00ffffffff0ff0f000ffffff00
05e52110001001000010000000000000001004000000251000000000000000000000000055521000e554d01000012554ffffff00ffffffffffffff00ffffff00
5e66e5d4101101010550151005ee552010100d4111105e40025555200000000000000000e5554011e554d0101102554dffffff00f0000f0ff0000f00ffffff00
05e521100000010002105e410e221140000100000010241005eeee500000001110000000e555d000e555d0100005554dffffff00f0ff0f0ff0ff0f00ffffff00
5e66e5d414001000054012100e252040110011111010241102e5554000004dd444100000e555d001e555d0011005554dffffff00f0000f0ff0000f00ffffff00
05e521100001025102105e4105124040001000000010241001444410000d6d4100110000e5e24500e5e245000055e24dffffff00fffffffff0ff0f00ffffff00
5e66e5d4001005e405401210051000400251251000105e40000000000046741000001000e5245e50e5245e5005e5244dffffff00fffffffff0ff0f00ffffff00
05e521100010014100005e410244441005e45e40001024100010010000d7d40000001000e55555e4e55555e44e55554dffffff00fffffffff0000f00f0f00f00
5e66e5d40010000000101410000000000141241000100000001001000166979698000100e555554de555554dd455554dffffff00ffffffffffffff00ffffff00
022211100040010000100000001000000000000000100100000000000469666769800100545445dde555554de555554d0ff0f000ffffffff0ff0f0000ff0f000
e676e5d414d0010110101111110011110e510e50104dd40102552240046869696930010021e11e14e55444dde522114d0ff0f000f00fffff0ff0f00000000000
5e6e546d0000040000100000000100000e210e200000000000000000046238989830010021611611e5422220e55ee54d0ff0f000fffffffffff0f000ffffffff
25e544d110000d411110000111100111052105201105201102552240046100238320040022612611e52e66e4e522114d0ff0f000f00ffffffff0f000ffffffff
0222111001000400000000100000010005210520000240000000000004d100000800040052e12e14e5154ddde55ee54d0ff0f000ffffffff0000f00000000000
e676e5d4001001000252010000d0252005410540000000000255224004d400000200040055e15e14e5511110e522114d0ff0f000ffffffff0ff0f0000ff0f000
5e6e546d00100100024101000040241005410540004dd400000000000d6766dd44114d006e55e55ee555eeeee55ee54d0ff0f000ffffffff0000f0000ff0f000
25e544d100100100000001000010000000000000001001000010010004ddd4411111140076666666e555554de555554d0ff0f000ffffffff0ff0f0000ff0f000
022211100010010000066e0000eeeeeeeeee5000e555554d0010010000000000e555554de555554de555554d5dddd44d00000000000000000000f00000000000
e676e5d411100100006e55e00e55555555555500e555554d0010010000eee500e555554de555554de555554d0222224d00000000ff0000000000f000fffff0f0
5e6e546d0000000006e1115ee5554444444555eee555555d001001000e555540e555554de5e254d0e555554d06ee524d0f0f0f00ff000000ff00f000fffff0f0
5e6e546deeeeeeeeee5150e5554ddddddddd5555e55e2555ee16e16ee55e255e555e254de5244d01e55e254d0e55414d0f000f00ff0ffff0fff0f000fffff0f0
5e6e546455555555555100e554d2121212124555e5524555551e51e5555245555552454de555d010e552454d0e54d14d0f0f0f00ff0ffff00ff0f000fffff0f0
25e544d1555445555555ee554d15151515151455e555555555255255555555555555544de554d010e555554d054dd14d00000000000000000ff0f00000000000
0222111044d1144444444444daa4a4a4a4a4aa455e4444444444444444444444444444d4e554d000e555554d0111114dffffff00000ff0f00ff0f0000ff0fff0
5e6e5d65dda54a4dddddddddaaaaaaaaaaaaaaa4a4dddddddddddddddddddddddddddd4ae554d010e555554d5eeee54dffffff00000000000ff0f00000000000
17672737471777375447776727176777a70000000000000000000000000000a70000000000000000000000000001bccccb000000000000000000000000000000
27177767b4653616361565363655561654141414146444346474000000000054000000000000000000000000011bcc6776cb0000000000000000000000000000
00000000000000000000000000000000a700000000000000000000000000009700000000000000000000000011bcc666776cb000000000000000000000000000
00000000075656363526662635161645060000000000000000000000000000050000000000000000000000001bbccccc66ccb000000000000000000000000000
00000000000000000000000000000000b60000000000000000000000000000a50000000000000000000000011bbbc6677777c000000000000000000000000000
000000000536463606151655064546160500000000000000000000000000009600000000000000000000000b1bbccd38888d7000000000000000000000000000
0000000000000000000000000000000057043464447400000000000464245487000000000000000000000001c1cd33889978d400000000000000000000000000
0000000006361656052656360516262606000000000000000000000000000097000000000000000000000001b1c3389889693d00000000000000000000000000
0000000000000000000000000000000026b5000000000000000000051565163600000000000000000000000011b3388888993d01111000000000000000000000
00000000044434740704641454143474079494002474000000000000000000a500000000000000000000000010b3338889693d01bbc6cb000000000000000000
0000000000000000000000000000000016a7000000000000000000962636361600000000000000000011bb1000bc333367763c001bc6676b0000000000000000
00000000000000008400000000000000849494000000000000000000000000b6000000000000000011bccc10011bc6bcbbcbc6000bbc6776c100000000000000
0000000000000000000000000000000036b7000000000000000000073655162600000000000000011bcccb010011bb6bc67c1b0001bc66776cb0000000000000
00000000000000008400000000000000849494000000000000000000000000b70000000000000011bccc6b0100001bb1bccb101000bbc66666cb000000000000
0000000434740000000004147400000016060000000000000434445426663625000000000000011bccc6c100b100011011110c00001bbbcc66ccb00000000000
000000000000000084000000000000008494940000000000000000000000000500000000000001bbcc67b1000bb1000001b6c100000bbc6777776b0000000000
000000000000000000000000000000003605000000000000000000075636352600000000000011bcc667b101b01bbccc676b1bb10001c6cb111bc61000000000
00000000000000000704442454346474072474000000000000000000000000050000000000001bbc667c10011bb111111bbcccbb0000b10000011bc000000000
00000000000000000000000000000000560500000000000000000096461545360000000000011bcc667b10001bbcb11bcccc66cb10000000000001c000000000
00000000000000000526165605552636050000000000000000000000000000b7000000000001bbcc667b100011bbc1bcbcc6776b10000000000000b000000000
000000000000000000000000000000001696000000000000000000a736165636000000000011bbcc6761100011bbb1bbbbccc6c1100000011100001000000000
00000000000000000636462606456566060000000000000000000000000000b6000000000011bcc667c10000011bb1bbbbbbccb1100100111b10010000000000
00000000000414643444740000000000a45444141474000000000057672767b400000000001bcc7776b10000011b101bbbbbbb1110100011bb10100000000000
00000000043414147425262635265615070000000004240000000000000000970000000001bc110000000100001100011bbbb1110000117777776eee20000000
00000000000636265516060000000000a60000000000000000000000000000b7000000000b1000111000007666667760011176e66e6667666667e55550000000
00000000064556552636561526253616060000000000000000000000000000a5000000000100011bb10007666667e55e00176e66e66667666667500250000000
00000000000516455626050000000000a70000000000000000000000000000a7000000000001101b11007777777e5e666e776776777767666667500250000000
000000000526461526161555261526460500000000000000000000000000009600000000000bb111100076eee67552522266e66e6666e7666667555550000000
00000000000625265636060000000000b60000000000000000000000000000a60000000000b6c1b6b1007e5e5e65e666e5eeeeeeeeeee7e666e7500250000000
00000000071516262645661626563655060000000000000000000000000000050000000000bcbb676b1065255e6522552566666665eee6eeeee6500250000000
34141424447465362615044434143444a70000000000044434740000000000a700000000001b1cc67cb0e22e25655eeee6777776525556eeeee6555550000000
3414146474263636164516151616263654344414146454644474b3b3b3b3b3540000000000011bbc67cb112522e2022226eeeee625eee6eeeee6500250000000
7777000000000bb330000000000700099888000009988880099988880000009988800000000011bbbc61bbc6bbb000000e55555e22222e5eee56500250000000
5655700000000bb33000000700070098000000009800833009830808300009800000000000001111bb1bbc6767cb0011055bcbc100000255555ee55520000000
07067676067676367606760606770983000000098333333008330303330098333000000000000011110bbc66bbb0000001bc7c6b100002255555222200000000
077767570757573757075707075708330083300833003330033300033300833000000000000000001101bc6c6cb001bb001cb6bcbb1100000000000000000000
0755067777067777070676070677733333333003330033300333000333003333333300000000000000011bcbbb0000011001bbbbb11000000000000000000000
05000555550555550505550505555000000000000000000000000000000000000000000000000000000011bbcb00100010000111000011000000000000000000
00000770000000007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000755067606700770707067600000998888009980099800009988800099988888077a0077a0077a000077aaa007777aaa00077aaaa00777aaaaa0077a0077a
000070007570750075070707550000980083300983009830009800000009830083307a9007a9007a90007a000000007a900007a00a99007a900a99007a900799
00007000677767706706770567000983003330083300833009833300000833333300a9900a9900a99007a900000000a990007a90099900a999999000a9999999
00005777555555505505556776000833003300003300333008330000000333003300099009990099900a9900000000999000a990099000999009900000000999
00000555000000000000005555000333333000000333333003333333300333003330009999990099900999999990009990009999990000999009990099999999
00000bbbbbbbbbbbbbbbbb0bbbbbbbbbbbbbbbbb0000bbbbbbbbbbbbbbbbb0000000bbbbbbbbbbbbbbb000000000000000000000000000000000000000000000
0000dbbbbbbbbbbbbbbbd40dbbbbbbbbbbbbbbbbd000dbbbbbbbbbbbbbbbbd00000dbbbbbbbbbbbbbbbd00000000000000000000000000000000000000000000
000dbbbbbbbbbbbbbbbd440dbbbbbbbbbbbbbbbbbd00dbbbbbbbbbbbbbbbbbd000dbbbbbbbbbbbbbbbbbd0000000000000000000000000000000000000000000
00766c6cccddbbbbbbd4140dbbbdc66c6cccccccccc0dbbbdc66c6cccdbbbbbd0dbbbdc66c6ccccccdbbbd000000000000000000000000000000000000000000
00d44444441bbbbbbc41140dbbbd14444444444444d0dbbbd1444444d4dbbbbd0dbbbd14444441144dbbbd000000000000000000000000000000000000000000
0041111111bbbbbbc411100dbbbd1111111111111140dbbbd1111111414bbbbd0dbbbd111111bb111dbbbd0000000000000000000000c4d5c7c5e4e6d4f4f7e5
004111111bbbbbbc4111000dbbbd1dbbbbbd11111110dbbbd1dbbbbbbbbbbbbd0dbbbd11111bd4111dbbbd000000000000000000000000000000000000000000
00000000bbbbbbc41110000dbbbd0d6cccc6c0000000dbbbd0c6cdbbbbbddc6c0dbbbd0000bc41000dbbbd0000000000000000000000f7d4f6d6f6f7f4d5d4f6
0000000bbbbbbc411100000dbbbd04444444d0000000dbbbd0d444dbbbbb144d0dbbbd000dc411000dbbbd000000000000000000000000000000000000000000
000000bbbbbbd4111000000dbbbd0111111110000000dbbbd04111bdbbbbb1140dbbbd00014110000dbbbd0000000000000000000000c5c7d4e5f4c5d6f5e4e6
00000dbbbbbbbbbbbbbb000dbbbbbbbbbbbbbbbbb000dbbbd011111dbbbbbb110dbbbbbbbbbbbbbbbbbbbd000000000000000000000000000000000000000000
0000dbbbbbbbbbbbbbbbb00dbbbbbbbbbbbbbbbbbb00dbbbd000001bdbbbbbb00dbbbbbbbbbbbbbbbbbbbd0000b30000000000000000d7c5d5c5d7c5f5e7c6c4
000dbbbbbbbbbbbbbbbbbb0dbbbbbbbbbbbbbbbbbbb0dbbbd0000011dbbbbbbb0dbbbbbbbbbbbbbbbbbbbc00676b300000000000000000000000000000000000
00cbbbbbbbbbbbbbbbbbbbd1cbbbbbbbbbbbbbbbbbbd1cbbd0000001bdbbbbbbd1cbbbbbbbbbbbbbbbbbc400717676000000297a9820d4e7d7f6d4e4f6f6c5d5
06bbbbbbbbbbbbbbbbbbbbbd16bbbbbbbbbbbbbbbbbbd16bd00000011cbbbbbbbd16bbbbbbbbbbbbbbbc41006767170000009a90003000000000000000000000
766c6ccccccccccccccccccc61766c6cccccccccccccc617600000001766c6cccc617766c6cccccccc6411000bb67600000890bb1003e6c6c5f7d6e5c4f5f6e6
d44444444444444444444444d1d444444444444444444d1d400000001d44444444d1d4444444444444d111b30b11300000090b7cb10800000000000000000000
d1111111111111111111111141d11111111111111111141d400000001d1111111141d111111111111141103b3b2230b300080dc6d409f6d4c7c4d7e4e7f7f4c6
41111111111111111111111141411111111111111111141440000000041111111141411111111111114100033bbb333300008966699000000000000000000000
41111111111111111111111140411111111111111111140440000000041111111140411111111111114000000b333330000014dcd410d6c5f5e4f7c5c6e4d5d4
__label__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000001dccccd00000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000011dcc6776c1000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000011dcc666776c100000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000001ddccccc66ccd00000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000011dddc6677777c00000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000d1ddccd28888d710000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000001c1cd22889978d20000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000001d1c2289889692d0000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000011d2288888992d0111100000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000010d2228889692d01ddc6cd00000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000011dd1000dc222267762c001dc6676d000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000011dccc10011dc6dcddcdc6000ddc6776c10000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000011dcccd010011dd6dc67c1d0001dc66776cd000000000000000008880000000000000000000000000
000000000000000000000000000000008880000000000011dccc6d0100001dd1dccd101000ddc66666cd00000000000000888888800000000000000000000000
00000000000000000000000000000008888880000000011dccc6c100d100011011110c00001dddcc66ccd0000000000008888888880000000000000000000000
0000000000000000000000000000088888888800000001ddcc67d1000dd1000001d6c100000ddc6777776d000000000888888888888000000000000000000000
0000000000000000000000000000888888888880000011dcc667d101d01ddccc676d1dd10001c6cd111dc6100000008888888888888800000000000000000000
000000000000000000000000000888888888888000001ddc667c10011dd111111ddcccdd0000d10000011dc00000088888888888888800000000000000000000
000000000000000000000000000888888888888800011dcc667d10001ddcd11dcccc66cd10000000000001c00000888888888888888880000000000000000000
00000000000000000000000000888888888888888001ddcc667d100011ddc1dcdcc6776d10000000000000d00008888888888888888880000000000000000000
00000000000000000000000000888888888888888811ddcc6761100011ddd1ddddccc6c110000001110000100088888888888888888880000000000000000000
00000000000000000000000000888888888888888811dcc667c10000011dd1ddddddccd1100100111d1001000088888888888888888880000000000000000000
0000000000000000000000000000888888888888881dcc7776d10000011d101ddddddd1110100011dd1010008888888888888888888880000000000000000000
000000000000000000000000000000888888888881dc110000000100001100011dddd1110000117777776ddd8888888888888888880800000000000000000000
00000000000000000000000000000008888888888d1000111000007666667760011176d66d6667666667d5555888888888888888000000000000000000000000
00000000000000000000000000000000888888888100011dd10007666667d55d00176d66d6666766666750125888888888888880000000000000000000000000
00000000000000000000000000000000088888888001101d11007777777d5d666d77677677776766666750125888888888880000000000000000000000000000
0000000000000000000000000000000000008888880dd111100076ddd67552521166d66d6666d766666755555888888888800000000000000000000000000000
000000000000000000000000000000000000088888d6c1d6d1007d5d5d65d666d5ddddddddddd7d666d750125888888888000000000000000000000000000000
000000000000000000000000000000000000008888dcdd676d1065255d6521552566666665ddd6ddddd650125888888800000000000000000000000000000000
0000000000000000000000000000000000000008881d1cc67cd0d22d25655dddd6777776525556ddddd655555888800000000000000000000000000000000000
000000000000000000000000000000000000000888811ddc67cd111512d1011226ddddd625ddd6ddddd650125888000000000000000000000000000000000000
0000000000000000000000000000000000000000888811dddc61ddc6ddd000000d55555d12222d5ddd5650125888000000000000000000000000000000000000
000000000000000000000000000000000000000000881111dd1ddc6767cd0011055dcdc100111255555dd5552880000000000000000000000000000000000000
000000000000000000000000000000000000000000088811110ddc66ddd0000001dc7c6d10000025555522228800000000000000000000000000000000000000
0000000000000000000000000000000000000000000088881101dc6c6cd001dd001cd6dcdd110008888888880000000000000000000000000000000000000000
00000000000000000000000000000000000000000000888888011dcddd0000011001ddddd1100008888888800000000000000000000000000000000000000000
000000000000000000000000000000000000000000000088888011dd000010001000011100001100888880000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000888000000000000000000000000000000888000000000000000000000000000000000000000000000
00000000000000000000000000ccccccccccccccccc0ccccccccccccccccc0000ccccccccccccccccc0000000ccccccccccccccc000000000000000000000000
00000000000000000000000006ccccccccccccccc6206cccccccccccccccc60006cccccccccccccccc6000006ccccccccccccccc600000000000000000000000
0000000000000000000000006ccccccccccccccc62206ccccccccccccccccc6006ccccccccccccccccc60006ccccccccccccccccc60000000000000000000000
000000000000000000000007776766666cccccc621206ccc667767666666666606ccc6677676666ccccc606ccc6677676666666ccc6000000000000000000000
00000000000000000000000d22222221cccccc6211206ccc612222222222222d06ccc61222222d26cccc606ccc6122222211226ccc6000000000000000000000
0000000000000000000000021111111cccccc62111006ccc611111111111111286ccc61111111212cccc606ccc6111111cc1116ccc6000000000000000000000
000000000000000000000002111111cccccc621110006ccc616ccccc6111111186ccc616cccccccccccc606ccc611111c621116ccc6000000000000000000000
00000000000000000000000000000cccccc6211100006ccc606766667688888886ccc686766ccccc6667606ccc60000c6210006ccc6000000000000000000000
0000000000000000000000000000cccccc62111000006ccc602222222d88888886ccc68d2226ccccc122d06ccc6000662110006ccc6000000000000000000000
000000000000000000000000000cccccc621110000006ccc601111111108888886ccc682111d6ccccc11206ccc6000121100006ccc6000000000000000000000
000000000000000000000000006cccccccccccccc0006ccccccccccccccccc8886ccc68111116cccccc1106ccccccccccccccccccc6000000000000000000000
00000000000000000000000006cccccccccccccccc006cccccccccccccccccc886ccc6800001d6cccccc006ccccccccccccccccccc6000000000000000000000
0000000000000000000000006cccccccccccccccccc06ccccccccccccccccccc86ccc688000116ccccccc06ccccccccccccccccccc6000000000000000000000
000000000000000000000006ccccccccccccccccccc616cccccccccccccccccc616cc68880001d6cccccc616ccccccccccccccccc62000000000000000000000
00000000000000000000007ccccccccccccccccccccc617cccccccccccccccccc617c6888000116ccccccc617ccccccccccccccc621000000000000000000000
00000000000000000000077767666666666666666666671777676666666666666671778888000177767666671777767666666667211000000000000000000000
000000000000000000000d22222222222222222222222d1d222222222222222222d1d288888001d22222222d1d2222222222222d111000000000000000000000
000000000000000000000d1111111111111111111111121d11111111111111111121d288888001d1111111121d11111111111112110000000000000000000000
00000000000000000000021111111111111111111111121211111111111111111121228888880021111111121211111111111112100000000000000000000000
00000000000000000000021111111111111111111111120211111111111111111120220888888021111111120211111111111112000000000000000000000000
00000000000000000000000000000000000000000000000008888888888000000000000088888000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000088888888800000000000000088888880000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000888888880000000000000000088888888000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000088888888880000000000000000008888888000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000888888888800000000000000000000088888800000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000008888888888000000000000000000000008888880000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000008888888880000000000000000000000000888888800000000000000000000000000000000000000000000
00000000000000000000000000000000000000000888888888000000000000000000000000000888888880000000000000000000000000000000000000000000
00000000000000000000000000000000000000008888888880000000000000000000000000000088888888000000000000000000000000000000000000000000
00000000000000000000000000000000000000088888888800000000000000000000000000000008888888000000000000000000000000000000000000000000
00000000000000000000000000000000000000888888880000000000000000000000000000000000088888800000000000000000000000000000000000000000
00000000000000000000000000000000000008888888800000000000000000000000000000000000008888880000000000000000000000000000000000000000
00000000000000000000000000000000000088888880000000000000000000000000000000000000000088888000000000000000000000000000000000000000
00000000000000000000000000000000000088888800000000000000000000000000000000000000000008088000000000000000000000000000000000000000
00000000000000000000000000000000000888880000000000000000000000000000000000000000000000808800000000000000000000000000000000000000
00000000000000000000000000000000008880800000000000000000000000000000000000000000000000088880000000000000000000000000000000000000
00000000000000000000000000000000888800000000000000000000000000000000000000000000000000000888000000000000000000000000000000000000
00000000000000000000000000000008888000000000000000000000000000000000000000000000000000000088000000000000000000000000000000000000
00000000000000000000000000000088880000000000000000000000000000000000000000000000000000000008888000000000000000000000000000000000
00000000000000000000000000008888800000000000000000000000000000000000000000000000000000000000088800000000000000000000000000000000
00000000000000000000000000088888880000000000000000000000000000000000000000000000000000000000088880000000000000000000000000000000
00000000000000000000000000088888800000000000000000000000000000000000000000000000000000000000008880000000000000000000000000000000
00000000000000000000000000888888000000000000000000000000000000000000000000000000000000000000000880000000000000000000000000000000
00000000000000000000000008880800000000000000000000000000000000000000000000000000000000000000000008000000000000000000000000000000
00000000000000000000000088808000000000000000000000000000000000000000000000000000000000000000000000880000000000000000000000000000
000000000000000000000008880000000000000000000000000000000000000b3000000000000000000000000000000000080000000000000000000000000000
0000000000000000000008800000000000000000000000000000000000000676b300000000000000000000000000000000000800000000000000000000000000
00000000000000000008888000000000000000000000000000000000000007176760000000000000000000000000000000000000000000000000000000000000
00000000000000000008888000000000000000000000000000000000000006767170000000000000000000000000000000000000000000000000000000000000
00000000000000000088880000000000000000000000000000000000000000bb6760000000000000000000000000000000000008800000000000000000000000
00000000000000000088000000000000000000000000000000000000000b30b11300000000000000000000000000000000000000800000000000000000000000
000000000000000000000000000000000000000000000000000000000003b3b2230b300000000000000000000000000000000000000000000000000000000000
00000000000000088000000000000000000000000000000000000000000033bbb333300000000000000000000000000000000000000000000000000000000000
00000000000000888000000000000000000000000000000000000000000000b33333000000000000000000000000000000000000000800000000000000000000
00000000000008080000000000000000000000000000000007777000000000bb3300000000007000000000000000000000000000000000000000000000000000
00000000000088000000000000000000000000000000000005655700000000bb3300000070007000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000706767606767636760676060677000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000777675707575737570757070757000000000000000000000000000000000000000000000000000
00000000080000000000000000000000000000000000000000755067777067777070676070677700000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000500055555055555050555050555500000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000077000000000700000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000755067606700770707067600000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000700075707500750707075500000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000700067776770670677056700000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000577755555550550555677600000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000055500000000000000555500000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

__gff__
0000000000000000000000000000000000000000000000000000000000020200000000000000000000000000020202020000000000000000000000200206060201010101010101011008010100000000010101010101010000010101000000000101010101010100000101010000000001010101010101010101010100000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
7176727776714b6154656362515253546b00000000000000000000000000007b7800000000000000000000000000006b6354616154625662634a727176737477717672737471777345747776727176777a0000000000000000000000000000757800000000000000000000000000007564635561655161526263546164666351
0000000000006a5155666256616263647a0000000000000000000000000000790000000000000000000000000000006a65536365665163526270000000000000000000000000000000000000000000007b0000000000000000000000000000000000000000000000000000000000000051536661625462616665555362656354
00000000000075737476714b655455626b00000000000000000000000000005a0000000000000000000000000000007b6166614a777277767178000000000000000000000000000000000000000000006a0000000000000000000000000000000000000000000000000000000000000052615362525566546465635162635662
00000000000000000000007a635666657a000000000000000000404141464447000000404344470000000042434644785452557a00000000000000000000000000000000000000000000000000000000754243470000000000000000000000000000004046470000000040464700000054614a7177767271737476774b516661
00000000000000000000007b616555547b000000000000000000595366546264000000000000000000000060615162526262517b00000000000000000000000000000000000000000000000000000000636652600000000000000000000000000000000000000000000000000000000055517b00000000000000000075764b63
00000000000000000000006b53556566450000004041470000006a6362656155000000000000000000000050616553635664634500000000000000000000000000000000000000000000000000000000635462690000000000000000000000000000000000000000000000000000000051657a00001d1e000000000000007951
00000000000000000000007061566251500000000000000000007b5156526654000000000000000000000070626261625166626000000000000000000000000000404441470000000000000000000000555156700000000000000000000000000000000000000000000000000000000063546a002c2d2e2f0000000000005a63
004043470000000000000070556151626000000000000000000075727671774b404147000000000040434678526561665362615000000000000000404147000000000000000000000000000000000000656351754446470000000040434700000000000000004044434700000000000055516b003c3d3e3f0000000000006b65
0000000000001d1e0000006b515253545000000000000000000000000000007a000000000000000000007052626562515551536000001d1e0000000000000000000000000000000000004043470000006153525162625b0000000000000000000000000000005962665b00000000000062517544464541424700000000006a63
00000000002c2d2e2f00007b61626364404344470000000000001d1e00000070000000000000000000006955636263556262546a002c2d2e2f00000000000000000000000000000000000000000000005166566552536b0000000000000000000000000000007953556a00000000000064615654625000000000000000007a62
00000000003c3d3e3f00006a655455626354656000000000002c2d2e2f000050000000000000000000006b62636352615266627b003c3d3e3f00000000000000000000000000000000000000000000006163616353617a0000000000000000000000000000005961617a00000000000061635161526900000000000000007964
000040434445444146464347635652656166626000000000003c3d3e3f000070000000404644470000007063636654536662514041464344454441464700000000000000404446470000000000000000635551666362404442464447000000000040434700006a6364690000404347004a71737476780000000000404342744b
000070545556615556515262566155565152534046414146454141434244477800000000000000000000795551545351545163515253545556615556700000000000000000000000000000000000000051545163556263615153635b00000000000000000000795654600000000000007a00000000000000000000000000006b
0000506465665565546162636455655161626364665565665456656152515561000000000000000000005a5155666555666461616263646566556566500000000000000000000000000000000000000065516351625451645561567a000000000000000000005a52657b0000000000007a00000000000000000000000000007b
0000706251615662515355546166625165545562615662516553636454615463000000000000000000007b62565451616563636554556251615662517000000000000000000000000000000000000000616154635455625663655469000000000000000000006963616b0000000000007a000000000000000000000000000079
464447655255615162546456556151626356666555615162566362666163566541414345434141424644476361546551526163635666655255615162454046444141414346444243464643444341434454626263626366515261514041414246444643454443786655754346424446437a00000000004044434700000000005a
717677764b62636362546165565556537a00000000000000000000000000007a7800000000000000000000000000007a51616152656651566362514a76717776717374774b62636251634a77727671777a0000000000000000000000000000757800000000000000000000000000007563656354636154566151616662526163
000000007953546161545663556162617a0000000000000000000000000000790000000000000000000000000000006a6251516462524a727374727800000000000000007954625152646b00000000007a0000000000000000000000000000000000000000000000000000000000000064616561665163655162555261636365
000000005a61615156615561625166546b00000000000000000000000000005a000000000000000000000000000000696154616463547a000000000000000000000000005a62616266516a00000000006b0000000000000000000000000000000000000000000000000000000000000053515562626255636663616162615264
0000000045545161636551555164555475464342000000000000004044464378000000404347000000004044464141476366566562517b00000000000000000000000000757172767374780000000000754641434700000000004046434700000000000000000000000040464347000055545366516163646651636262625662
000000006066525351615251565366616264527000000000000000000000706500000000000000000000605262636155616362634a767800000000000000000000000000000000000000000000000000525452635b00000000000000000000000000000000000000000000000000000064545153625151556361516262635255
000000005051666663545164566565616151655000000000000000000000606600000000000000000000706352625466636463616b000000000000000000000000000000000000000000000000000000625366566a00000000000000000000000000000000000000000000000000000051665552526151545465625455535161
0000000069526563615661636263536663555160000000000000000000006961000000000000000000006062616256615151665660000000000000000000000000000000000000000000000000000000516165646900000000000000000000000000000000000000000000000000000064636661655166526263546164666351
000000007571767271737471774b615161536345434141470000000000007a630000000000000040424645744b6156555152666470000000000000000000000000000000000000000000000000000000624a72764544424700000000000000000000000040414700000000000000000051536661625462615565555362656354
000000000000000000000000007b52526364627a000000000000000000007b540000000000000000000000006a636156624a767745434141470000000000000000000000000000000000000000000000516b00000000000000000000000000000000000000000000000000000000000052615362525566546466635162626262
000000000000000000000000007a61566552636b0000000000000000000070620000000000000000000000007a545552636a000000000000000000000000000000004041464700000000000000000000647b00000000000000000000000000000000000000000000000000000000000052566154616561645461656652615151
000000000000000000000000006b5451616654450000000000000000000050510000000000000000000000007b6164614a78000000000000000000000000000000000000000000000000000000000000637000000000000000000000000000000000000000000000000000000000000052635151636552626261525153615166
000000000000000000000000006a65624a77767800000000000040434146424b0000404147000000000000007571724b7b00000000000000000000404647000000000000000000000040444543470000617000000000000000000040414700000040424700000000004043464447000062525161616555636661646364515163
0000000000000000000000000075764b7b000000000000000000000000000069000000000000000000000000000000796000000000000000000000000000000000000000000000000000000000000000636900000000000000000000000000000000000000000000000000000000000054536665666354645163556356516166
000000000000000000000000000000796b00000000000000000000000000007a0000000000000000000000000000005a50000000000000000000000000000000000000000000000000000000000000004a7800000000000000000000000000000000000000000000000000000000000056636662556162515462515453625251
0000000000000000000000000000005a7a00000000000000000000000000007a0000000000000000000000000000006b6a000000000000000000000000000000000000000000000000000000000000007a0000000000000000000000000000000000000000000000000000000000000066545553645151635353525163565263
4700000000004046434700000000007a6a00000000004041470000000000006b4700000000000040464700000000007a7a000000000040464246470000000040470000000000404341470000000000407a0000000000004043444700000000404700000000404641414647000000004051515164636163626361626462556251
__sfx__
01010f103c62030611306150c1700c1700c1700c1700c1700c1700c1700c1700c1700c1700c1610c1510c14100000000000000000000000000000000000000000000000000000000000000000000000000000000
01010f103c6303c621306213061124611246110c1700c1700c1700c1700c1700c1700c1700c1610c1510c14100000000000000000000000000000000000000000000000000000000000000000000000000000000
01010f100c1300c1710c1700c1700c1700c1700c1700c1700c1700c1700c1700c1700c1700c1610c1510c14100000000000000000000000000000000000000000000000000000000000000000000000000000000
0102000718420184210c0600c04118310183100c02000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011c01031842118411184210000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010203041845018461184511844118200184001820000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010300002461018610006150000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000011812000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010e000003870001000386503873039700061503865038730797000615038703061503a75078703061503a7502870001000286502873029600061502865028730596000615028703061502a75058703061502a75
010e000018d301dd301fd301fd211fd221fd221fd221fd121fd111fd15000000000018d3018d211fd301fd2122d4022d3222d3221d4021d4021d401dd401dd311dd221dd221dd221dd121dd111dd151dd401fd40
010e00201b0401f040240401b0401f040240401b0401f040240401b0401f040240401b0401f040240401f0401a0401e040230401a0401e040230401a0401e040230401a0401e040230401a0401e040230401e040
010e000020d4020d3220d321fd301fd311fd301bd401bd311bd221bd221bd221bd151dd001dd001bd401dd401ad401ad311ad311ad311fd401fd311fd311fd211dd401dd311dd311dd3123d4023d3123d3123d31
010e000018620186100c6100061500a4000a51000000000000a60000000ca400ca5100000000000ca500ca6100a60000000ca600ca71000000000000a60000000ca600ca7100000000000ca600ca710000000000
010e000024d4024d3124d211fd401fd311fd221fd221fd221fd221fd221fd111fd151fd401fd4024d4024d4022d4022d3222d3221d4021d3121d301dd401dd311dd221dd221dd221dd221dd111dd151dd401fd40
010e000020d4020d3220d321fd401fd311fd301bd401bd311bd221bd221bd221bd151bd0500d0018d401fd4023d4023d3223d3224d4024d3124d2126d4026d2126d2226d2226d2226d1123d4023d3123d3023d21
010e0000273102b3103031033310273102b3103031033310273102b3103031033310273102b310303103331026310293102e3103231026310293102e3103231026310293102e3103231026310293102e31032310
010e000024310273102c3103031024310273102c3103031024310273102c3103031024310273102c3103031026310293102b3102f31026310293102b3102f31026310293102b3102f31026310293102b3102f310
010e000000870001000086500873009700061500865008730397000615008703061500a75038703061500a750287000100028650e8500e840006150286002800029600b8500b8403061502870028600b8500b840
010e000024220242151f22024220242212422124222242112222022221222111d2201d2201d2111d2201d2111b2201b2211b2112022020222202221b2201b2111a2201a2211a2111f2201f2221f2222322023211
010e00001f4201f415184201f4201f4211f4211f4221f4111d4201d4211d41116420164201641116420164111442014421144111b4201b4221b42214420144111342013421134111a4201a4221a4221d4201d411
010e000000870009700000007870078500000000960008700297002950246150297002950246150297002870038700397000000088700885000000039600387002870029602461507870079600c6150b9600b870
010e001000a60000000ca600ca71000000000000a60000000ca600ca7100000000000ca600ca71000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010e000018740187101f7401f71027740277101f7401f71026740267101f7401f710277402771026740267101f7401f710277402771026740267101f7401f7102b7402b7101f7401f71027740277102674026710
010e00000cb300cb300cb400cb400cb500cb500cb500cb600cb600cb600cb600cb600cb600cb500cb500cb500cb400cb400cb400cb500cb500cb500cb600cb600cb600cb600cb600cb500cb500cb500cb400cb40
010e001003a60006000fa600fa71030000300003a60030000fa600fa7103000030000fa600fa71030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000
010e00001b7401b71022740227102a7402a7102274022710297402971022740227102a7402a710297402971022740227102a7402a710297402971022740227102e7402e71022740227102a7402a7102974029710
010e00000fb300fb300fb400fb400fb500fb500fb500fb600fb600fb600fb600fb500fb500fb500fb400fb400fb300fb300fb400fb400fb500fb500fb500fb600fb600fb600fb600fb500fb500fb500fb400fb40
010e000002a60006000ea600ea71020000200002a60020000ea600ea7102000020000ea600ea71020000200002a60006000ea600ea71020000200002a60020000786007a600a960306250a8600a8601296030625
010e00001a7401a71022740227102b7402b71022740227102a7402a71022740227102b7402b7102a7402a71022740227102b7402b7102a7402a71022740227102e7402e71022740227102b7402b7102a7402a710
010e00000eb300eb300eb400eb400eb500eb500eb500eb600eb600eb600eb600eb500eb500eb500eb400eb400eb300eb300eb400eb400eb500eb500eb500eb600eb600eb600eb600eb500eb500eb500eb400eb40
010e00001fd401fd401fd401fd401fd401fd401fd401fd311fc401fc401fc311fc211fc301fc301fc211fc111fc201fc201fc111fc151fc101fc101fc101fc151bd401bd401bd401bd311fd401fd401fd401fd31
010e00001a7401a71023740237102a7402a7102374023710297402971023740237102a7402a710297402971023740237102a7402a710297402971023740237102f7402f71023740237102a7402a7102974029710
010e00001ed301ed411ed401ed401ed401ed401ed401ed311ec401ec401ec311ec211ec301ec301ec211ec111ec201ec201ec111ec151ec101ec101ec101ec1522d3022d3022d4122d4022d3122d3022c4022c40
010e000023d3023d4123d4023d4023d4023d4023d4023d3123c4023c4023c3123c2123c3023c3023c2123c1123c2023c2023c1123c1523c1023c101ed201ed311ec411ec4023d3023d4123d4023d3123c4023c40
010e000022d3022d4122d4022d4022d4022d4022d4022d3122c4022c4022c3122c2122c3022c3022c2122c1122c2022c2022c1122c1522c1022c1022c1022c151fd201fd311fd411fd3122d3022d3022d4122d41
0101000018670183300c070000250cb0013b0013b000cb000fb001b7001b7000cb000cb001f7001f70018b000cb0018700187000cb000cb000cb000cb000cb0013b0013b000cb0018b0000000000000000000000
010e001002a60006000ea600ea71020000200002a60020000ea600ea7102000020000ea600ea71020000200002a60006000ea600ea71020000200002a60020000686006a600b960306250b8600b8601296030625
010e00001442014420144200f4200f4200f4200f4200f4200f4200f4200f4200f4100f4200f420114201142013420134201342013420134201342007420074200b4200b4200b4200b4200e4200e4200e4200e420
010e000020d4020d3220d321fd401fd311fd301bd401bd311bd221bd221bd221bd151bd0500d0018d4018d3117d4017d3217d3217d2217d2217d1118d4018d211ad401ad321ad221ad1117d3017d3217d3217d21
010e000018d4018d3118d2218d2218d2218d2218d2218d1218d1218d1218d1218d1218d1218d150cb100cb100cb200cb200cb300cb300cb400cb400cb500cb500cb600cb600cb600cb500cb500cb500cb400cb40
0102000024670006710c0701e1510c241061310012100015000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0108002030026180551f057260562b025230502705621035270552005625057180552e030280551d05627050260571e0572a035280562705023057250571f050240562f025200561f0572305020055250561f056
01080000240602402024060240202406024020240602402024070180710c071000710006100051010410004101041000310103100021010110001500000000000000000000000000000000000000000000000000
01030000070732465016220226400c210186210c6110c6110c6110c61500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010300002407024320243112b0702b3202b3113007030320303113031500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011800002214022151221502215022141221311d13022140241402415124150241412413124135241302614027140271512715027141261502614122140221512614026151261412613124140241512414124121
01180000241402414026140261512713027141271412713129130291412714027151261502615026141261312213022141241502414026140261512615026131221502214126140261512414024151241411d135
0118002030e6024e1030e6024e1030e6024e1030e6030e5330e6324e1030e6024e1030e6024e1030e6030e5330e6324e1030e6024e1030e6024e1030e6030e5330e6324e1030e6024e1030e6030e5330e6330e43
010c00001d1401d1511d1511d1501d1501d1501d1411d1401d1401d1401d1311d1301d1301d1301d1211d1201d1201d1201d1111d1101d1101d1101d1101d1151d1401d1401d1311d1301d1411d1401d1311d121
011800003c624246253c624246252610024640186310c6210c6110061100615000000000022100221002410024100241001d1001d100000001d1001d1001d1001d1001d1001d1001d1001d1401d1311d1411d131
01180000021300213002130021300213002130021300213005130051300513005130051300513005130051300a1300a1300a1300a1300a1300a1300a1300a1300713007130071300713005130051300513005130
011800001d7401d7401d7401d7401d7401d7401d7401d74021740217402174021740217402174021740217401d7401d7401d7401d7401d7401d7401d7401d7402274022740227402274021740217402174021740
011800000513005130051300513007130071300713007130071300713007130071300a1300a1300a1300a1300a1300a1300a1300a130051300513005130051300513005130051300513000130001300013000130
011800002174021740217402174024740247402474024740247402474024740247401f7401f7401f7401f7401f7401f7401f7401f740227402274022740227402274022740227402274021740217402174021740
010c00000013000130001300013000130001300013000130001300013000130001300013000130001300013000130001300013000130001300013000130001300013000130001300013000130001300013000130
010c00002174021740217402174021740217402174021740217402174021740217402174021740217402174021740217402174021740217402174021740217402174021740217402174021740217402174021740
0118002030e0024e0030e0024e0030e000c0730002000011000000000030e1024e0030e1024e0030e1030e1330e2324e0030e2024e1030e3024e1030e3030e3330e4324e1030e4024e1030e4030e5330e6330e43
0118000000f000000000000000000000000000000000000000f1400f1000f1000f1000f2100f2000f2000f2000f3100f3000f3000f3000f4100f4000f4000f4000f5100f5000f5000f5000f6100f6000f6000f60
01060000000000000000000000000000000000000000000000000000000000000000000000000000000000001d1401d1511d1501d1501d1501d1501d1411d1401d1401d1401d1411d1401d1401d1401d1511d151
011000001e4351d4351e4451f4451f4351e4351d4351e4451f4351e4351f44520445204351f4351e4351f445204351f435204452144521435204351f43520445214352043521445224452243521435204351f445
011000000c8500c9500c8500d9500d8500c9500d9500c8500d8500d9500d8500e9500e8500d9500e9500d9500e8500e9500e8500f9500f8500e9500f9500e8500f8500f9500fa5010850109500f950108500f950
010218200021001013022200302304230050330624007043012500d2531843024433182630c2730007012060180500a4600807006450040600344002050014400104000430000300042000040004300003000420
0110000022340223312232121340213312132120340203312032020321203112031020310203111f3301f3212034020331203211f3401f3311f3211e3401e3311e3211e3211e3111e3111d4151d4251d4351d445
000900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 15161744
01 18191a44
00 15161744
00 18191a44
00 15171e44
00 181a2044
00 241d2144
00 1b1d2244
00 08090f44
00 110b1044
00 080d0f44
00 110e1044
00 14121344
00 080d0f44
00 110b1044
00 080d0f44
00 11261044
02 0c162744
00 38313944
01 2f2d3233
00 2f2e3435
02 2f303637
02 3a2f4f44
00 3f20211e
01 3b3c7d44
00 3b3c7d44
02 3e3c7d44
00 41424344
03 3e20211e
00 22232444

