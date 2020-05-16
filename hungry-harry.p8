pico-8 cartridge // http://www.pico-8.com
version 27
__lua__
-- hungry harry 3d
-- by palo blanco games
-- rocco panella




-- player and camera code

--container object for actors
actor={}
function actor:new(o)
	--use this for making subclasses
	o=o or {}
	o.x = o.x or 0
	o.y = o.y or 0
	o.z = o.z or 0
	o.drawx,o.drawy,o.drawz = o.x,o.y,o.z
	o.dx = o.dx or 0
	o.dy = o.dy or 0
	o.dz = o.dz or 0
	o.ddx,o.ddy,o.ddz = 0,0,0 -- for incidental momentum
	o.g = o.g or false
	o.stun = o.stun or false
	o.stunt = o.stunt or 0
	o.tt = o.tt or 0 --generic timer
	o.grav = o.grav or 0.2
	o.jump = o.jump or 3
	o.speed = o.speed or 1
	o.mag = 0
	o.ang = o.ang or 0.75
	o.dead,o.attack=false,false
	o.r = o.r or 1 --range
	o.attackang=o.ang
	o.sprite = o.sprite or 1
	o.spritedraw = o.spritedraw or o.sprite
	o.spritex = 8*(o.sprite%16)
	o.spritey = 8*flr(o.sprite/16)
	o.spritesize = o.spritesize or 8
	o.dsize = o.dsize or o.spritesize
	o.shadow = o.shadow or true
	o.inv = false
	o.invt = 0
	--o.say = o.say or false
	o.hb = o.hb or 4
	o.super = o.super or false
	o.supert = o.supert or 0
	o.st = 0 -- used for timing animations
	o.children={} -- child sprites
	o.tongues={} --holder for tongues
	o.mom = o.mom or nil
	o.walkframe,o.flipframe,o.flipme,o.canjump = 0,false,false,false
	o.speedframe = 4
	o.camx,o.camy,o.camz,o.cx,o.cy,o.floor,o.camfloor = 1,1,1,1,1,1,1
	o.bf = false
	o.xmax,o.pix8,o.xpix,o.ypix,o.ypixf = 1,1,1,1,1
	o.white = false
	-- stats
	o.health = o.health or 100
	o.hasfeet = o.hasfeet or false
	-- wall values
	o.w = {}
	o.wo = {}
	for i=0,4,1 do
	o.w[i] = false
	o.wo[i] = false
	end
	setmetatable(o,self)
	self.__index=self
	return o
end

function actor:inst(o)
	--use this to actually create an instance ingame
	o=o or {}
	local a={}
	for k,v in pairs(self) do
		a[k] = v
	end
	-- special loop
	for k,v in pairs(o) do
		a[k] = v
	end
	setmetatable(a,self)
	self.__index=self
	return a
end


function actor:update_early()
	--replace with behavior
	--specific to subclass
end

function actor:update_late()
	--default behavior is setting
	--draw variables
	self.drawx=self.x+0.5
	self.drawy=self.y+3.5
	self.drawz=self.z
	if self.stun then
		self.drawx+=-1+2*rnd()
		self.drawy+=-1+2*rnd()
	end
end


function tand(ang)
	if (ang == 90 or ang == 270) return 0
	angn = -ang/360
	return (sin(angn)/cos(angn))
end

function simplexy(xx,yy)
	return flr(xx/8), flr(yy/8)
end

function mapget(x,y)
	xx,yy = simplexy(x,y)
	if (xx < 0 or yy < 0 or xx >=128 or yy >= 64) return 0
	return band(mget(xx,yy),15)
end

function getpixid(id)
	--px = 8*(id%16)
	--py = 8*flr(id/16)
	return 8*(id%16),8*flr(id/16)
end

--drawing constants
fov=60
shrink = tand(fov/2)
nearplane,farplane,simpleplane,widthplane=3,18,15,16 -- in blocks
draw_table={}

function sort_by_y(tab)
	local newtab = {}
	done=false
	while not done do
  done=true
		for k,v in pairs(tab) do
	  if k > 1 then
	  	if v.y < tab[k-1].y then
	  		local temp = tab[k-1]
	  		tab[k-1],tab[k],done = v,temp,false
	  		--tab[k] = temp
	  		--done=false
	  	end
	  end
		end
	end
	return tab
end

-- collision handler
function bump(act,hero)
	-- perform exact collisions
	myx,myy,myz,myid = hero.x,hero.y,hero.z,hero.sprite
	hb2=0
	if (myid == 53) hb2=2
	for k,v in pairs(act) do
		hisx,hisy,hisz,hisid = v.x,v.y,v.z,v.sprite
		if hisid != myid then
			if abs(myx-hisx) <= v.hb+hb2 and abs(myy-hisy) <= v.hb+hb2 and abs(myz-hisz) <= v.hb then
				--check id of other
				--implement activity
				--consider hb as actor trait	
				--do hero, then tongue
				if myid == 38 then
					if hisid == 37 then
						v.dead=true
						v:make_spit(52,5)
						health+=5
						hero.white = 10
						sfx(6)
					elseif hisid == 73 then
						--v.dead=true
						v.z = 3000
						v:make_spit(52,5)
						health+=5
						hero.white = 10
						player.super = true
						player.supert = 210
						sfx(7)
					elseif hisid == 64 then
						hero:stunme(0.25)
					elseif hisid == 105 then
						hero:stunme(hero.ang)
						v:make_spit(52,5)
						v.dead=true
						health+=-10
					elseif hisid == 89 then
						transition = true
						ttime = 90	
						v.dead=true
						levelsbeat+=1
						if (hard) health+=150
					elseif hisid == 104 then
						if hero.dz <=0 then
							hero.dz = 4.2
							sfx(3)
						end 				
					elseif hisid == 106 or
						hisid == 120 or
						hisid == 72 then
					elseif hisid > 64 then
						hero:stunme(hero.ang)
						v:stunme(0.5+hero.ang)
						health+=-10
					end 
				-- tongue
				elseif myid == 53 then
					if hisid == 37 then
						v.dead=true
						v:make_spit(52,5)
						health+=5
						player.white = 10
						sfx(6)
					elseif hisid == 73 then
						v.z = 3000
						v:make_spit(52,5)
						health+=5
						hero.white = 10				 
				  		player.super = true
				  		player.supert = 240
				  		sfx(7)
				 	elseif hisid == 64 then
						if player.super then
							v.dead=true
							v:make_spit(52,5)
							health+=5
							player.white = 10
							sfx(6)
					 	else
					 		player:stunme(0.25)
					 	end
					-- elseif hisid >=89 and hisid<=106 then
					elseif hisid == 106 or hisid == 89 or hisid == 105 or hisid == 104 then
					elseif hisid == 120 then
						if v.tt<=0 then
							v:make_pickup(1)
							sfx(12)
							v.health+=-1
							v.dz=2
							v.tt = 6
							if v.health <=0 then
								v.dead=true
								v:make_pickup(4)
								giftfind+=1
							end
						end
					elseif hisid > 64 then
						v.dead=true
						v:make_spit(52,5)
						health+=5
						player.white = 10
						sfx(6)
					end
				end
			end
		end
	end
end

-->8
-- init

function actor_crawl()
	-- grab all the actors
	-- replace their tile with
	-- the above position on map
	giftcount,giftfind,akey = 0,0,{}
	actor_list,block_list,dummy_list = {},{},{}
	akey[33],akey[49],akey[34],akey[37] = bridge,door,hero,pickup
	-- akey[49] = door
	-- akey[34] = hero
	-- akey[37] = pickup
	akey[74],akey[98],akey[100],akey[50],akey[89],akey[73] = dummy,dumfire,spinfire,blocker,portal,pepper
	--- akey[98] = dumfire
	-- akey[100] = spinfire
	-- akey[50],akey[89],akey[73] = blocker,portal,pepper
	-- akey[89] = portal
	-- akey[73] = pepper
	akey[106],akey[104],akey[120] = friend,spring,gift
	-- akey[104] = spring
	-- akey[120] = gift
	if (hard) akey[37],akey[89] = dummy,dummy
	--for yy=0,64,1 do
	for yy=1+levely0/8,levely1/8,1 do
		--for xx=0,16,1 do
		for xx=levelx0/8,levelx1/8,1 do
			tile = mget(xx,yy)
			--herohandler
			if akey[tile] == hero then
				tileup=mget(xx,yy-1)
				mset(xx,yy,tileup)
					player = hero:inst({x=xx*8,
				y=yy*8,
				z=band(tileup,15)*8+8,})
			-- blocks
			elseif akey[tile] == bridge or
				akey[tile] == door then
				bb=akey[tile]:inst({x=xx*8,
				y=yy*8})
				bb:init()
				add(block_list,bb) 		
			
			elseif akey[tile] == blocker then
				tileup=mget(xx,yy-1)
				mset(xx,yy,tileup)
				act = blocker:inst({x=xx*8,y=yy*8,z=band(tileup,15)*8+8})
				add(actor_list,act)
				bb=door:inst({x=xx*8,
				y=yy*8})
				bb:init()
				add(block_list,bb) 
			else
				for kk,vv in pairs(akey) do
					if tile == kk then
						tileup=mget(xx,yy-1)
						mset(xx,yy,tileup)
						act = vv:inst({x=xx*8,y=yy*8,z=band(tileup,15)*8+8})
						add(actor_list,act)
						if (tile == 120) giftcount+=1
						if (act.sprite == 96) add(dummy_list,act)
					end
				end
			end
		end
	end
	if (gameover != 2) giftcountall+=giftcount
	if hard then
		mymom=dummy_list[1+flr(rnd()*#dummy_list)]
		port=portal:inst({mom=mymom,x=mymom.x,y=mymom.y})
		--port.mom = dummy_list[flr(1+rnd()*#dummy_list)]
		add(actor_list,port)
	end
	return actor_list,player, block_list
end


function actor:make_feet()
	-- initialize harry's feet
	footl = hfeet:inst({x=player.x,
	y=player.y,
	mom=self,
	shadow=false})
	footr = hfeet:inst({x=player.x,
	y=player.y,
	mom=self,
	shadow=false,
	flipme=true})
	add(actor_list,footl)
	add(actor_list,footr)
end


function load_level()
	--reload the map
	reload(0x1000,0x1000,0x2000)
	for yy=-1+levely0/8,
	-1+levely1/8,1 do
		xx=levelx1/8
		mset(xx,yy,0)
	end
	for xx=-1+levelx0/8,
	1+levelx1/8,1 do
		yy=levely1/8
		mset(xx,yy,0)
	end
 actor_list,player,block_list = actor_crawl()
	add(actor_list,player)
	startx,starty=player.x,player.y
	--starty=player.y
	for aa in all(actor_list) do
		if (aa.hasfeet)aa:make_feet()
	end
	cam3dx,cam3dy = player.x+4, player.y+7*8
 cam3dz = player.z+30*4
 cam3dxmid,cam3dymid=64,16--where the horizon is
 music(0)

 leveltime,ht=0,0
end

function _init()
	gtime,gtimedec,gameover=0,0,0 --o is neither, 1 is lose, 2 is win
	-----
	ttime=90
	--wt=0
	hard=false
	------
	health,healthloss,healthrate=100,1,30
	--healthloss=1
	--healthrate=30 --reduce for faster health loss
	worldtime,leveltime,worldmin,worldsec=0,0,0,0
	--leveltime=0
	--worldmin=0
	--worldsec=0
	giftcount,giftfind,giftcountall,giftfindall,levelsbeat=0,0,0,0,0
	--giftfind=0
	--giftcountall=0
	--giftfindall=0
	--startx,starty=0,0
	--starty=0
	--actor_list,player,block_list,cam3d=load_level()
	load_zone(1)
	load_level()
end


-->8
-- update

function actor:stunme(ang)
	self.stun=true
	self.stunt=15
	self.dx = -2*self.speed*cos(ang)
	self.dy = -2*self.speed*sin(ang)
	--self:make_spit(31,5)
	if (self.sprite == 38) sfx(5)
end

function actor:collide()
	--self.w0={}
	self.w0=self.w
 	self.w={}
	for kk=0,4 do
		self.w[kk]=false
	end
	sl,sr,su,sd,self.bf=false,false,false,false,false
	--check block list
	for _,b in pairs(local_blocks) do
	 if abs(b.x-self.x)<8 then
	  if abs(b.y-self.y)<8 then
				if (self.z > b.z*(8+1)-1) self.bf = b.z*8
	   if self.z < b.z2*8-3 and
	   self.z > b.z2*8-6 and
	   self.dz > 0 then
	    self.dz=0
			 	self.z=b.z2*8-6
 				self.g=false
 				self.w[4]=false
	   elseif self.z > b.z*8+4 and
	   self.z < b.z*8+8 and
	   self.dz < 0 then
	    self.dz=0
			 	self.z=b.z*8+8
 				self.g=true
 				self.w[4]=true
	   elseif self.z > b.z2*8-6 and
	   self.z < b.z*8+6 then
	    xx = self.x-b.x
	    yy = self.y-b.y	    	   
	   	if abs(xx) > abs(yy) then
	   	 if (xx < 0) sl=true
	   	 if (xx > 0) sr=true
	   	else
	   	 if (yy < 0) su=true
	   	 if (yy > 0) sd=true	   	
	   	end
	   end
	   if (self.z < b.z2*8) add(front_blocks,b)
	  end
	 end
	end
	
	
		--snap floor
 ff1 = mapget(self.x+2,self.y+2)*8+8
 ff2 = mapget(self.x+2,self.y+5)*8+8
 ff3 = mapget(self.x+5,self.y+2)*8+8
 ff4 = mapget(self.x+5,self.y+5)*8+8
 ff=max(ff1,max(ff2,max(ff3,ff4)))
 if (self.z < ff and self.z > ff-4) 	self.dz,self.z,self.g,self.w[4]=0,ff,true,true
-- 	self.z=ff
-- 	self.g=true
-- 	self.w[4]=true
-- end
 --force upwards from negative space
 if (self.z < 0)	self.dz,self.z,self.g,self.w[4]=0,ff,true,true
-- 	self.z=ff
-- 	self.g=true
-- 	self.w[4]=true
-- end

	--snap up
	if self.dy >= 0 then
		if (mapget(self.x+2,self.y+8)*8+8 > self.z 
		or mapget(self.x+5,self.y+8)*8+8 > self.z 
		or self.y+8 > levely1) or su then
			self.dy = 0
			self.y = 8*(flr(self.y/8))
			self.w[3] = true
		end
	end
	
	--snap down
	if self.dy <= 0 then
		if (mapget(self.x+2,self.y-1)*8+8 > self.z 
	 or mapget(self.x+5,self.y-1)*8+8 > self.z)
	 or self.y < levely0+8 or sd then
			self.dy = 0
				--self.ground = true
			self.y = 8*(flr((self.y+4)/8))
			self.w[2] = true
		end
	end
	
			--snap right
	if self.dx <= 0 then
		if (mapget(self.x,self.y+2)*8+8 > self.z 
	 or mapget(self.x,self.y+5)*8+8 > self.z 
	 or self.x < levelx0) or sr then
			self.dx = 0
			self.x = 8*(flr((self.x+4)/8))
			self.w[0] = true
		end
	end
	
	--snap left
	if self.dx >= 0 then
		if (mapget(self.x+7,self.y+2)*8+8 > self.z  
		or mapget(self.x+7,self.y+5)*8+8 > self.z 
		or self.x+7 > levelx1) or sl then
			self.dx = 0
			self.x = 8*(flr((self.x)/8))+1
			self.w[1] = true
		end
	end
	
end

function actor:update()
	-- oo updater
	-- physics
	-- player physics
	self.dz += -self.grav
	self.z += self.dz 
	self.x += self.dx
	self.y += self.dy
	self.g = false
	if self.stun then
		self.mag = sqrt(self.dx^2 + self.dy^2)
		if self.mag > 0 then
			red = self.mag*0.8
			if (red < 0.1) red = 0
			self.dx*=red/self.mag
			self.dy*=red/self.mag
		end
	end
	--collision code
		self:collide()
	self.spritex,self.spritey=getpixid(self.spritedraw)
	--self.tt+=1
end

function actor:get_entry()
	local entries={}
	if self.shadow then
		local thisshadowactor={self.xpix,self.ypixf,self.pix8,24,16,8,self.flipframe,false}
	 add(entries,thisshadowactor)
	end
	if (self.super and (self.supert>45 or self.supert%4>1)) self.white = 8
	if (self.stunt%4>1) self.white=7
 local thisentryactor={self.xpix,self.ypix,self.pix8,self.spritex,self.spritey,self.spritesize,self.flipframe,self.white}
 add(entries,thisentryactor)
 self.white=false
 return entries
end

function actor:camera_update()
 -- camera position & shadow
	self.camy = cam3dy-self.drawy
	self.camx = self.drawx-cam3dx
	self.camz = self.drawz-cam3dz
	self.cx, self.cy = simplexy(self.x+3,self.drawy)
	self.floor=band(mget(self.cx,self.cy),15)
	--if (self.w[4]) self.floor=self.z/8-1
	if (self.bf) self.floor=self.bf/8
	self.camfloor=self.floor*8+8-2-cam3dz
	self.xmax = shrink*self.camy
	self.pix8 = 64*self.dsize/(self.xmax)
	self.xpix = 64*(self.camx/self.xmax)+cam3dxmid
	self.ypix = cam3dymid-64*((self.camz+8)/self.xmax)
	self.ypixf = cam3dymid-64*((self.camfloor+8)/self.xmax) 
end


function cam_update(player)
 cam3dx += (player.x+4-cam3dx+24*player.dx)/16
 cam3dy += (player.y+7*8-cam3dy+24*player.dy)/18
 cam3dz += (player.z+8*4-cam3dz)/16
 cam3dx = min(levelx1-20,max(levelx0+20,cam3dx))
 cam3dy = min(levely1+32,max(levely0+80,cam3dy))
 cam3dz = min(cam3dz,(16+8)*8)
end

function get_local_actors()
	local local_list={}
	bnd=10*8
	for _,act in pairs(actor_list) do
		if abs(act.x-player.x) < bnd and abs(act.y-player.y) < bnd then
			add(local_list,act)
		end
	end
	local_list = sort_by_y(local_list)
	return local_list
end

function get_local_blocks()
	local local_list={}
	bnd=10*8
	for _,act in pairs(block_list) do
		if abs(act.x-player.x) < bnd and abs(act.y-player.y) < bnd then
			add(local_list,act)
		end
	end
	return local_list
end


function _update()
 --player_update()
 -- actors
 local_list = get_local_actors()
 local_blocks = get_local_blocks()
 -- blocks that need to be
 -- rendered in front of player
 front_blocks = {}
 for _,each in pairs(local_list) do
 	if (not each.stun)	each:update_early()
 	each.stunt = max(each.stunt-1,0)
 	if (each.stunt <= 0) each.stun=false
 	each:update()
 	each:update_late()
 	if each.dead then
 		del(local_list,each)
 		del(actor_list,each)
 	end
 end
 
 ht+=1
	if ht == healthrate and not transition then
		health+=-healthloss
		ht=-1
	end
 
 --hardmode activate!
-- if zonenow == 1 and
-- worldtime == 1 and
-- worldsec == 25 and
-- btn(1) and btn(3) and btn(5) then
--  transition,hard,hardcount=true,true,0
-- end
 
 if transition then
 	ttime += -1
 	player.z += 4
 	player.dz = 0
 	if ttime <= 1 then
 	 ttime=90
 	 transition = false
 	 hop_zone()
 	end 	
 end
 --bump
 bump(local_list,player)
 for _,t in pairs(player.tongues) do
 	bump(local_list,t)
 end
 
 -- fix the camera
 cam_update(player)
 
 -- fix actors locations for camera
 -- player_cam_update()
 for _,each in pairs(local_list) do
 	each:camera_update()
 end
 
 worldsec+=1
 ws=flr(worldsec/30)
 worldtime+=ws
 if (not transition) leveltime+=ws
 worldsec%=30
 worldmin+=flr(worldtime/60)
 worldtime%=60
	
	if (health < 0) gameover=1
	--gameover
	if gameover>0 then
	 function a()
	 	if gtime < 1 then
	 	--play music
	 	end
	 	gtime+=1
	 	if (gtime > 30 and btnp(5)) then
	 		run()
	 	end
		end
		_update = a
	end
end
-->8
-- draw

function draw_world_all()
	mx,my = simplexy(cam3dx,cam3dy)
	drawbacks=0
	for yd=max(max(my-farplane,0),levely0/8+1),min(my-nearplane,levely1/8),1 do
		dist,db=cam3dy-8*(yd+1),cam3dy-8*(yd)
		-- db = cam3dy-8*(yd)
		xmax,xb=shrink*dist,shrink*db
		-- xb = shrink*db
		pixb,pix8=64*(8/xb),64*(8/xmax)
		-- pix8=64*(8/xmax)
		delz=8-cam3dz
		ypixmain=cam3dymid-64*(delz+8)/xmax
		ypixmainb=cam3dymid-64*(delz+8)/xb
		nearp=my-nearplane
		curplane,upl = nearp-yd,0
		-- upl = 0
		wp = flr((nearp-yd)/2) + widthplane/2
		for xd=max(levelx0/8,mx-(wp)),min(mx+(wp),levelx1/8),1 do
			id=band(mget(xd,yd),15)
			left=band(mget(xd-1,yd),15)
			if (xd == levelx0/8) left=0
			up=band(mget(xd,yd-1),15)
			tex=2*lshr(band(mget(xd,yd),16),4)
			delx=(xd*8)-cam3dx
			xpix=64*(delx/xmax)+cam3dxmid
			xpixb=64*(delx/xb)+cam3dxmid
			ypix=ypixmain+pix8*(1-id)
	  		ypixb=ypixmainb+pixb*(1-id)
			--ypixb=ypixmainb+pixb*(1-id)
			if id > 0 then
		 		-- floor
				if ypixb < 128 and ypix > ypixb and curplane < simpleplane then
				--thisentryfloor={xpixb,ypixb,pixb,xpix,ypix,pix8}
				--add(thisrowfloor,thisentryfloor)
				delxnow,delynow,delp=xpix-xpixb,ypix-ypixb,pix8-pixb
					--delynow=ypix-ypixb
					--delp=pix8-pixb
					for pdy=0,delynow,2 do
						xstart=xpixb+delxnow*(pdy/delynow)
						xlen=pixb+delp*(pdy/delynow)
						spstart=8+8*(tex+(pdy/delynow))
						sspr(xps,spstart,8,1,xstart,ypixb+pdy,xlen+1,2)
					end
				end
		 	end
			if up > id then
				--front
				for zd=max(id+1,1),up,1 do
					-- go up a level for z
					--push the y out too
					ypixb=ypixmainb+pixb*(1-zd)--64*(1-(delz+8)/xmax)
					if ypixb+pixb >0 and ypixb < 130 then
						sspr(xps,0,8,8,xpixb,ypixb,pixb+1,pixb+1)
					end
				end
				line(xpixb,ypixb,xpixb+pixb,ypixb,lc)
				line(xpixb,ypixb+pixb*(up-id),xpixb+pixb,ypixb+pixb*(up-id),lc)
			end
			if up<id then
				line(xpixb,ypixb,xpixb+pixb,ypixb,lc)
				if drawbacks > 0 then
					fillp(0b0011110000111100.1)
					rectfill(xpixb,ypixb+pixb,xpixb+pixb,ypixb+(id-up)*pixb,lc)
					fillp()
				end
			end
			if xpixb < xpix then
				--left		
				edge=false
				for zd=max(left+1,1),id,1 do
					edge=true
					ypix=ypixmain+pix8*(1-zd)--64*(1-(delz+8)/xmax)
					--xpixb=64*(delx/xb)+cam3d.xmid
					ypixb=ypixmainb+pixb*(1-zd)
					if curplane < simpleplane and ypix > -20 and ypix < 140 and xpix > 64 then
						delxnow,delynow,delp = xpix-xpixb, ypix-ypixb, pix8-pixb
						-- delxnow=xpix-xpixb
						-- delynow=ypix-ypixb
						-- delp=pix8-pixb
						if delxnow > 0 then
							for pdx=0,delxnow,2 do
								ystart=ypixb+delynow*(pdx/delxnow)
								ylen=pixb+delp*(pdx/delxnow)
								spstart=xps+8*(pdx/delxnow)
								sspr(spstart,16,1,8,xpixb+pdx,ystart,2,ylen+1)
							end
						end
					end
				end
				-- edge
				ypixb=ypixmainb+pixb*(1-id)
				ypix=ypixmain+pix8*(1-id)
				if edge then
					line(xpixb,ypixb,xpix,ypix,lc)
					line(xpixb,ypixb+pixb*(id-left),xpix,ypix+pix8*(id-left),lc)
				end
				-- corner
				t1=min(id,upl)
				if (t1>left) line(xpixb,ypixmainb-pixb*(t1-1),xpixb,ypixmainb-pixb*(left-1),lc)		
				-- empty back
				t2=max(left,up)
				if (t2<id) line(xpixb,ypixb,xpixb,ypixb+pixb*(id-t2),lc)		
				-- far edge
				if (left>id) line(xpixb,ypixb+pixb*(id-left),xpix,ypix+pix8*(id-left),lc)
			else
				-- right walls
				edge=false
				for zd=max(id+1,1),left,1 do
					edge=true
					ypix=ypixmain+pix8*(1-zd) -- 64*(1-(delz+8)/xmax)
					-- xpixb=64*(delx/xb)+cam3d.xmid
					ypixb=ypixmainb+pixb*(1-zd)
					if curplane < simpleplane and ypix > -20 and ypix < 140 and xpix < 64 then
						-- thisentryrw = {xpixb,ypixb,pixb,xpix,ypix,pix8}
						if xpixb>0 then  
							-- add(thisrowrw,thisentryrw)
							delxnow, delynow, delp = xpix-xpixb, ypix-ypixb, pix8-pixb
							-- delynow=ypix-ypixb
							-- delp=pix8-pixb
							-- delxnow = xpix-xpixb
							if delxnow < 0 then
								for pdx=0,delxnow,-2 do
									ystart = ypixb + delynow*(pdx/delxnow)
									ylen = pixb + delp*(pdx/delxnow)
									spstart = xps + 8*(pdx/delxnow)
									--sspr(spstart,16,1,8,xpixb+pixb+pdx,ystart,1,ylen+1)
									sspr(spstart,16,1,8,xpixb+pdx-1,ystart,2,ylen+2)
								end
							end
						end
					end
				end
				-- edge
				ypixb = ypixmainb + pixb*(1-id)
				ypix  = ypixmain +  pix8*(1-id)
				if edge then
					line(xpixb,ypixb,xpix,ypix,lc)
					line(xpixb,ypixb-pixb*(left-id),xpix,ypix-pix8*(left-id),lc)
				end
		
				t1 = min(left,up)
				if (t1>id)  line(xpixb,ypixmainb-pixb*(t1-1),xpixb,ypixmainb-pixb*(id-1),lc)		
				-- empty back
				t2 = max(max(id,upl),up)
				if (t2<left) line(xpixb,ypixb-pixb*(left-id),xpixb,ypixb-pixb*(t2-id),lc)
				-- far edge
				if (left<id) line(xpixb,ypixb,xpix,ypix,lc)
			end
		-- dif bw ul and up	
		v1 = max(max(upl,id),left)
		v2 = max(max(up,id),left)
		if (v1!=v2) line(xpixb,ypixmainb-pixb*(v1-1),xpixb,ypixmainb-pixb*(v2-1),lc)		
		-- stick extra lines now
		upl=up 
		end -- this ends the x loops
	if yd < my-nearplane-1 then
	for _,b in pairs(local_blocks) do
		if b.cy == yd then
			delx=(b.cx*8)-cam3dx
			xpix=64*(delx/xmax)+cam3dxmid
			xpixb=64*(delx/xb)+cam3dxmid
			ypix=ypixmain+pix8*(1-b.z)
	ypixb=ypixmainb+pixb*(1-b.z)
	--top
	if ypix > cam3dymid then
		delxnow,delynow,delp=xpix-xpixb,ypix-ypixb,pix8-pixb
		--delxnow=xpix-xpixb
		--delynow=ypix-ypixb
		--delp=pix8-pixb
		for pdy=0,delynow,2 do
			xstart=xpixb+delxnow*(pdy/delynow)
			xlen=pixb+delp*(pdy/delynow)
			--spstart=b.sptopy+8*(0+(pdy/delynow))
			spstart=8+8*(0+(pdy/delynow))
			sspr(xps,spstart,8,1,xstart,ypixb+pdy,xlen+1,2)
			end
	end
	--sides
	for i=b.z,b.z2,-1 do
		if xpixb < xpix and b.lineleft then
			delxnow,delynow,delp=xpix-xpixb,ypix-ypixb,pix8-pixb
			--delxnow=xpix-xpixb
			--delynow=ypix-ypixb
			--delp=pix8-pixb
			if delxnow > 0 then
				for pdx=0,delxnow,2 do
					ystart=ypixb+delynow*(pdx/delxnow)
					ylen=pixb+delp*(pdx/delxnow)
					--spstart=b.spwallx+8*(pdx/delxnow)
					spstart=xps+8*(pdx/delxnow)
					sspr(spstart,16,1,8,xpixb+pdx,ystart,2,ylen+1)
				end
			end
		elseif xpixb+pixb > xpix +pix8 and b.lineright then
			delxnow,delynow,delp=xpix-xpixb,ypix-ypixb,pix8-pixb
			-- delynow=ypix-ypixb
			-- delp=pix8-pixb
			-- delxnow = xpix+pix8-(xpixb+pixb)
			if delxnow < 0 then
				for pdx=0,delxnow,-2 do
					ystart=ypixb+delynow*(pdx/delxnow)
					ylen=pixb+delp*(pdx/delxnow)
					--spstart=b.spwallx+8*(pdx/delxnow)
					spstart=xps+8*(pdx/delxnow)
					--sspr(spstart,16,1,8,xpixb+pixb+pdx,ystart,1,ylen+1)
					sspr(spstart,16,1,8,xpixb+pixb+pdx-1,ystart,2,ylen+1)
				end
			end
		end
	  	--front
	  	if (b.linedown) sspr(xps,0,8,8,xpix,ypix,pix8+1,pix8+1)
	  	line(xpix,ypix,xpix+pix8,ypix,lc)
	  	line(xpix,ypix+pix8,xpix+pix8,ypix+pix8,lc)
	  	ypix=ypix+pix8
	  	ypixb=ypixb+pixb
	end
	end
	end
	end
	--add actors if appropriate
	drawbacks += -1
	if (player.cy == yd) drawbacks=2
		for _,a in pairs(local_list) do
			if a.cy == yd then
				char = a:get_entry()
				for _,e in pairs(char) do
					-- add(thisrowactor,e)
					if e[8] == 8 then
						pal(12,8)
					elseif (e[8]) then
						palw(e[8])
					end
					sspr(e[4],e[5],e[6],e[6],e[1],e[2],e[3],e[3],e[7])
					pal()	
				end
			end
		end
		for _,b in pairs(front_blocks) do
			if b.cy == yd then
				delx=(b.cx*8)-cam3dx
				xpix=64*(delx/xmax)+cam3dxmid				
				ypix=ypixmain+pix8*(1-b.z2)
				if b.linedown then
					sspr(xps,0,8,8,xpix,ypix,pix8+1,pix8+1)
					line(xpix,ypix,xpix+pix8,ypix,lc)
					line(xpix,ypix+pix8,xpix+pix8,ypix+pix8,lc)
				end
			end
		end
	end
end


plist={0b0000000000000000,
0b0001000001000000,
0b0101000001010000,
0b0101101001011010,
0b1111111111111111}

function draw_floor()
	dl={11,21,31,41,51}
	-- c1=3
	-- c2=5
	ylist={}
	
	for _,yd in pairs(dl) do
		distc=8*(yd)
		xm=shrink*distc
		delz=-cam3dz
		ypixmain=cam3dymid-64*(8+delz)/xm
		add(ylist,ypixmain)	
	end
	yold=127
	i=1
	for _,yp in pairs(ylist) do
		fillp(plist[i])
		rectfill(0,yp,127,yold,c2*16+c1)--0x5f)
		yold=yp
		i+=1
	end
	fillp()
	-- draw some guide lines
	ypl,xml={},{}
	-- xml={}
	for yd=11,3,-1 do
		distc=8*yd+(cam3dy%8)
		xm=shrink*distc
		delz=-cam3dz
		ypixmain=cam3dymid-64*(8+delz)/xm
		line(0,ypixmain,127,ypixmain,c2)
		add(ypl,ypixmain)
		add(xml,xm)
	end
	for xd=-5,5,1 do
		xr = xd*8 - cam3dx%8
		x1 = (xr/xml[1])*64+64
		x2 = (xr/xml[#xml])*64+64
		line(x1,ypl[1],x2,ypl[#ypl],c2)
	end
end

-------------
-- draw utilities
-------------

function palw(w)
	for i=1,15,1 do
		pal(i,w)
	end
end

function oprint(str,xnew,y)
	-- xnew = x--+8-#str*2
	for xx=xnew-1,xnew+1,1 do
		for yy=y-1,y+1,1 do
			print(str,xx,yy,0)
		end
	end
	print(str,xnew,y,7)
end

skyc,sunc=9,15
--sunc=15
function _draw()
	--draw_table = draw_world_update(cam3d)
	ustat4=stat(1)
	cls(skyc)
	circfill(64,20,10,sunc)
	draw_floor()
	ustat2=stat(1)
	-- draw_tab()
	draw_world_all()
	ustat3=stat(1)
	-- print(stat(1))

	color(7)
	rectfill(0,0,127,8,1)
	rect(0,0,127,8,12)
--	print("b4 draw: "..ustat)
--	print("drawstart: "..ustat4)
--	print("floor: "..ustat2)
	print("hunger: "..health.."     level: "..(1+levelsbeat),2,2,7)
	--print(#player.tongues)
	--print("b4 draw"..ustat4)
	if ((abs(player.x-startx)+abs(player.y-starty) < 8) and not transition) oprint(zone[zonenow][1],0,0)
	if gameover>0 then
		_draw = endtext[gameover]
	end
	if transition then
	 if hard then
	 	oprint([[
			
			
			
			      !!!hard mode!!!
			
			
 		   mary gets hungrier!!   
			   
     		
     		     	
     		     			   
   hunger rate: ]] ..40*healthloss/healthrate.. [[ /sec ]] 			   
	,0,0)
	 else
	 
	 	oprint([[
			
			
			
			
 		   you beat the level!!   
			   
     			   
     			   
     			   
     		time: ]]..leveltime..[[
     		     	
     		     			   
       gifts found: ]] ..giftfind.. [[ of ]]..giftcount 			   
	,0,0)
		end
	end

end

endtext={function()
 cls(1)
	oprint([[
			
			
			
			
		   oh no, mary starved!!   
			   
     			   game over
     			   
     		
     		
     			   
           you beat ]] ..levelsbeat.. [[			   
			
						 	  	  levels
						 	  	
						 	  	
						 	  	
    				press x to restart
		]],0,0)
	end,
	function()
	cls(1)
	oprint([[
			
			
			
			
	        mary saved the 
		     love of her life!!   
			   
     			     you win! ;)
     			   
     		gifts: ]]..giftfindall..[[ of ]]..giftcountall..[[     		
     		
       end health: ]]..health..[[     			   
       
       end time: ]] ..worldmin.. [[ min  ]] ..worldtime..[[ sec
       
       
       
       
    				press x to restart       
       ]]
,0,0)
	end
	}
-->8
-- actor types

--player
hero = actor:new({sprite=38,
 spritesize=16,
 hasfeet=true,
 dsize=8})

htable={42,108,110,108,42,40,38,40}
	
function hero:update_early()
	--reset some stuff
	self.dx,self.dy=0,0
	--self.dy=0
	if self.supert > 0 then
	 self.supert += -1
	 if (self.supert<=0) self.super=false
	end
	-- self.dz=0
	--controls for player
	mult=50
	if (self.attack) mult = 0.5
	if not transition then
		if (btn(0)) self.dx=-self.speed*mult
		if (btn(1)) self.dx=self.speed*mult
		if (btn(2)) self.dy=-self.speed*mult
		if (btn(3)) self.dy=self.speed*mult
	end
	self.dy += self.ddy
	self.dx += self.ddx
	self.mag = sqrt((self.dx^2)+(self.dy^2))
	if (self.mag > 0) self.ang = atan2(self.dx,self.dy)
	local direct=flr((8*self.ang)%8)
 	bonus=sqrt(abs(self.ddx)^2+abs(self.ddy)^2)
	if self.mag > 1+bonus then
		self.dx *= 1/self.mag
		self.dy *= 1/self.mag
	end
 	-- jumping
 	if btn(4) and self.g then
		if self.attack and self.mag == 0 then
			self.dz=self.jump*1.35
			sfx(2)
		elseif self.attack and self.mag>0 then
			self.ddx = 1*cos(self.ang)
			self.ddy = 1*sin(self.ang)
			self.dz=self.jump
			sfx(2)
		else
			self.dz=self.jump
			sfx(1)
		end
	end
	-- tongue
	--if (btnp(5)) draw_on = (draw_on+1)%5
 	if btnp(5) and (not self.attack or (self.g and self.tt > 3)) then
		if self.tt > 0 then
			self.ang=self.attackang
			for _,t in pairs(self.tongues) do
				t.dead=true
			end
		end
		self:make_tongue(3)
		self:make_tongue(7)
		self.tt=0
		self.attack=true
		self.attackang=self.ang
		sfx(4)
		if not self.g then
			self.dz = self.jump*0.75
		end
 	end
 
	-- tongue handler
	if self.attack then
		self.ang = self.attackang+(self.tt/10)
		direct = flr((8*self.ang%8))
		self.tt+=1
		if self.tt > 10 and self.g then
			self.attack=false
			self.tt,self.ddy,self.ddx=0,0,0
			-- self.ddy=0
			-- self.ddx=0
		end
	end
 
	-- animation timer
	if (self.dx == 0 and self.dy == 0) self.st=0
	--drawing
	self.spritedraw = htable[direct+1]
	if (direct>2 and direct<6) self.flipframe=true
	if (direct>6 or direct<2) self.flipframe=false
end

function hero:update_late()
	self.drawx,self.drawy,self.drawz=self.x,self.y+3,self.z
	--self.drawy=self.y+3
	--self.drawz=self.z
	if (not self.g) self.st=0
	if (self.mag == 0) self.st = 0
	--if self.st%8 >= 4 then
	--	self.drawz += 1
	--end
	height =1-(0.5*(1+sin(0.75+(self.st%6)/6)))^3
	self.drawz += height
	self.st+=1
	if (self.st%6 == 2) sfx(0)
		if self.stun then
			self.drawx+=-1+2*rnd()
			self.drawy+=-1+2*rnd()
		end
		--health
		--self.ht+=1
		--if self.ht == healthrate and not transition then
		--	health+=-1
		--	self.ht=-1
		--end
	end

	--dummy
	dummy = actor:new({sprite=96,
	spritesize=16,
	dsize=8})
	
	function dummy:update_early()
	if self.g then
		self.dz = 0.7
	end
end

--gift
gift = actor:new({sprite=120,
	spritesize=8,
	health=5+10*flr(rnd()),
	grav=0.3
})
 
function gift:update_early()
	if self.g then
		self.dz = 1.2
	end
	if (self.tt>0) self.tt+=-1
end

function actor:make_pickup(n)
	for nn=1,n,1 do
		local ang = rnd()
		local dx = 0.5*cos(ang)
		local dy = 0.5*sin(ang)
		mypick = pickup:inst({x=self.x,
		y=self.y,
		z=self.z+6,
		dx=dx,
		dy=dy,
		dz=0.75+rnd(),
		})
		add(actor_list,mypick)
	end
end

--dumfire
dumfire = actor:new({sprite=98,
 spritesize=16,
 dsize=8})
 
function dumfire:update_early()
	if self.g then
		self.dz = 0.7
	end
	self.tt+=1
	ft=60
	if zonenow == 9 then
		ft=30
		self.spritedraw=66
		self.dsize=12
	end
	if self.tt%ft == 0 then
		newfire=fireball:inst({
		x=self.x,
		y=self.y,
		z=self.z})
		add(actor_list,newfire)
	end
end

--fireball
fireball = actor:new({sprite=105,
 spritesize=8,
 grav=0.1})
 
function fireball:update_early()
	self.tt+=1
	newang=atan2(player.x-self.x,player.y-self.y)
	if self.tt < 15 then
		self.dx+=0.1*cos(newang)
		self.dy+=0.1*sin(newang)
	end
	if self.w[0] or
	self.w[1] then
		self.dx=cos(newang)
		self.x+=self.dx
	end
	if self.w[2] or
	self.w[3] then
		self.dy=sin(newang)
		self.y+=self.dy
	end 
	if self.tt==100 or
	self.stun then
		self.dead = true
	end
end

--spinfire
spinfire = actor:new({sprite=100,
 spritesize=16,
 dsize=8})
 
function spinfire:update_early()
	if self.g then
		self.dz = 0.7
	end
	self.tt+=1
	if self.tt%60 == 0 then
		for rr=8,16,8 do 
		newfire=spinball:inst({
		x=self.x,
		y=self.y,
		z=self.z,
		mom=self,
		r=rr,
		})
		add(actor_list,newfire)
		end
	end
end

spinball = actor:new({sprite=105,
 spritesize=8,
-- r=8,
 grav=0})
 
function spinball:update_early()
	self.tt+=1
		self.x = self.mom.x
		self.y = self.mom.y
		self.z = self.mom.z
		self.x += self.r*cos(self.ang-.125+(self.tt)/60)
		self.y += self.r*sin(self.ang-.125+(self.tt)/60)
	if self.tt == 60 or self.stun or self.mom.dead then
		self.dead = true
	end
end

--spring
spring = actor:new({sprite=104,spritesize=8,})

--portal
portal = actor:new({sprite=89,grav=0.1,spritesize=8})

function portal:update_early()
	if self.g then
		self.dz = 0.7
	end
	if hard then
		if (not self.mom.dead) self.z,self.x,self.y,self.dz = self.mom.z+16,self.mom.x,self.mom.y,0
	end
end

--pepper
pepper = actor:new({sprite=73,grav=0.5,spritesize=8})

function pepper:update_early()
	if self.g then
		self.dz = 3
	end
end

--blocker
blocker = actor:new({sprite=64,
 spritesize=16,
 grav=0.5,
 hb=6,
 dsize=10})
 
function blocker:update_early()
	if self.g then
		self.dz = 2.3
	end
end

--actor's feet
hfeet = actor:new({sprite=36,dsize=4,
-- shadow = false,
})

function hfeet:update()
--	self.x = player.x+2
--	self.y = player.y
--	self.z = player.z-5
end

function hfeet:update_late()
	--flipframe true means right
	self.x = self.mom.x+2
	self.y = self.mom.y
	self.z = self.mom.z-4.5
	st=self.mom.st-1
	loop=10
	if (not self.mom.g) st = loop/4
	if self.flipme then
		self.x += -1.5*sin(self.mom.ang)
		self.y += 2*cos(self.mom.ang)
		--moving
		self.x += -1.5*sin(self.mom.ang+0.25)*sin((st%loop)/loop)
		self.y += 2*cos(self.mom.ang+0.25)*sin((st%loop)/loop)
		self.z += 1*(1+0.5*(sin(.25+(st%(loop/2))/(loop/2))))
	else
		self.x += 1.5*sin(self.mom.ang)
		self.y += -2*cos(self.mom.ang)
		--moving
		self.x += 1.5*sin(self.mom.ang+0.25)*sin((st%loop)/loop)
		self.y += -2*cos(self.mom.ang+0.25)*sin((st%loop)/loop)
		self.z += 1*(1+0.5*(sin(.25+(st%(loop/2))/(loop/2))))
	end
	self.drawx=self.x
	self.drawy=self.y+3
	self.drawz=self.z-1
end

-- actor's tongue
tongue = actor:new({sprite=53,
dsize=5})

function tongue:update()
	self.x = self.mom.x
	self.y = self.mom.y
	self.z = self.mom.z
	self.x += self.r*cos(self.ang-.125+(self.tt)/10)
	self.y += self.r*sin(self.ang-.125+(self.tt)/10)
	self.tt+= 1
	if (self.tt > 10) self.dead=true
	if (self.dead) del(self.mom.tongues,self)
end

function tongue:update_late()
	--default behavior is setting 
	--draw variables
	self.drawx=self.x+1.5
	self.drawy=self.y+3+1.5
	self.drawz=self.z-1.5
	if (rnd()>0.8) self:make_spit(52,1)
end

function actor:make_tongue(r)
	mytongue = tongue:inst({x=self.x,y=self.y,shadow = false,mom=self,ang=self.ang,r=r})
	add(actor_list,mytongue)
	add(self.tongues,mytongue)
end

-- spit particle
spit = actor:new({sprite=52,dsize=3})

function actor:make_spit(sp,loop)
	--pal(7,c)
	for i=1,loop,1 do
		local ang = rnd()
		local dx = cos(ang)
		local dy = sin(ang)
		myspit = spit:inst({x=self.x,y=self.y,z=self.z,dx=dx,dy=dy,dz=0.75+rnd(),shadow=false,sprite=sp,spritedraw=sp,})
		add(actor_list,myspit)
	end
end

function spit:update_late()
	--default behavior is setting 
	--draw variables
	self.spritex,self.spritey=getpixid(self.spritedraw)
	self.drawx=self.x+2.5
	self.drawy=self.y+3+2.5
	self.drawz=self.z-2.5
	self.tt+= 1
	if (self.tt > 6) self.dead=true
end

function spit:update()
	-- oo updater
	-- physics
	--player physics
	self.dz += -self.grav
	self.z += self.dz 
	self.x += self.dx
	self.y += self.dy
	print(self.dx, 10, 10, 0)
end

-- pickup
pickup = actor:new({sprite=37,
 dsize=8,
 shadow=true,
 hb=6,
 })
 
function pickup:update_early()
	if self.g then
 		self.dx,self.dy = 0,0
		--self.dy = 0
	end
end

-->8
-- block code
block={}
function block:new(o)
	--use this for making subclasses
	o=o or {}
	o.x = o.x or 0
	o.y = o.y or 0
	o.z = o.z or 0
	o.z2 = o.z2 or o.z
	o.cx,o.cy = 0,0
	-- o.cy = 0
 	-- visual stuff, camera pov
	o.sptop = o.sptop or 0
	o.sptopx,o.sptopy = 0,0
	-- o.sptopy = 0
	o.spwall = o.spwall or 0
	o.spwallx,o.spwally = 0,0
	-- o.spwally = 0
	o.lineup,o.linedown,o.lineleft,o.lineright = false,false,false,false
	-- o.linedown = false
	-- o.lineleft = false
	-- o.lineright = false
	setmetatable(o,self)
	self.__index=self
	return o
end

function block:inst(o)
	--use this to actually create an instance ingame
	o=o or {}
	local a={}
	for k,v in pairs(self) do
		a[k] = v
	end
	-- special loop
	for k,v in pairs(o) do
		a[k] = v
	end
	setmetatable(a,self)
	self.__index=self
	return a
end

bridge = block:new({
	sptop = 33,--16,
	spwall = 51--49
})

function bridge:init()
	xh,yh=simplexy(self.x,self.y)
	local dlist={}
	left=mget(xh-1,yh)
	if (left < 32) add(dlist,left%16)
	right=mget(xh+1,yh)
	if (right < 32) add(dlist,right%16)
	down=mget(xh,yh+1)
	-- if (down < 32) add(dlist,down%16)
	up=mget(xh,yh-1)
	if (up < 32) add(dlist,up%16)
	highest,lowest=dlist[1],dlist[1]
	--	lowest=dlist[1]
	for _,v in pairs(dlist) do
		highest=max(highest,v)
		lowest=min(lowest,v)
	end	
	nol,nor,nod = false,false,false
	for _,bb in pairs(block_list) do
		if bb.x == self.x then
			if abs(bb.y-self.y) == 8 then
				highest = bb.z
				if (bb.y > self.y) nod = true
			end
		elseif bb.y == self.y then
			if abs(bb.x-self.x) == 8 then
				highest = bb.z
				if (bb.x > self.x) nor = true
				if (bb.x < self.x) nol = true
			end
		end
	end
	xh,yh=simplexy(self.x,self.y)
	self.z,self.z2 = highest,highest
	if (left%16 < self.z and left < 32 and not nol) self.lineleft=true
	if (right%16 < self.z and right < 32 and not nor) self.lineright=true
	if (down%16 < self.z and down < 32 and not nod) self.linedown=true
	self.cx,self.cy = simplexy(self.x,self.y)
	self.sptopx = 8*(self.sptop%16)
	self.sptopy = 8*flr(self.sptop/16)
	self.spwallx = 8*(self.spwall%16)
	self.spwally = 8*flr(self.spwall/16)
	mset(xh,yh,lowest)
end

door = block:new({
	sptop=16,
	spwall=49
})

gx,gy = 8,60
ga={}
function door:init()
	xh,yh=simplexy(self.x,self.y)
	local dlist={}
	left=mget(xh-1,yh)
	if (left < 32) add(dlist,left%16)
	right=mget(xh+1,yh)
	if (right < 32) add(dlist,right%16)
	down=mget(xh,yh+1)
	-- if (down < 32) add(dlist,down%16)
	up=mget(xh,yh-1)
	if (up < 32) add(dlist,up%16)
	highest,lowest=dlist[1],dlist[1]
	-- lowest=dlist[1]
	for _,v in pairs(dlist) do
		highest=max(highest,v)
		lowest=min(lowest,v)
	end
	nol,nor,nod = false,false,false
	for _,bb in pairs(block_list) do
		if bb.x == self.x then
			if abs(bb.y-self.y) == 8 then
				highest = bb.z
				if (bb.y > self.y) nod = true
			end
		elseif bb.y == self.y then
			if abs(bb.x-self.x) == 8 then
				highest = bb.z
				if (bb.x > self.x) nor = true
				if (bb.x < self.x) nol = true
			end
		end
	end
	-- xh,yh=simplexy(self.x,self.y)
	if (xh == gx and yh == gy) ga=dlist
	self.z = highest
	if (left%16 < self.z and left < 32 and not nol) self.lineleft=true
	if (right%16 < self.z and right < 32 and not nor) self.lineright=true
	if (down%16 < self.z and down < 32 and not nod) self.linedown=true
	self.z2 = lowest+3
	self.cx,self.cy = simplexy(self.x,self.y)
	self.sptopx = 8*(self.sptop%16)
	self.sptopy = 8*flr(self.sptop/16)
	self.spwallx = 8*(self.spwall%16)
	self.spwally = 8*flr(self.spwall/16)
	mset(xh,yh,lowest)
end


-->8
-- zones
zonenow=1
themes={{
7,11,7,--highlight c
15,-- x pix start
12,6, --sky and sun
},{
1,4,2,--highlight c
0,--14,-- x pix start
12,15, --sky and sun
},{
0,11,3,--highlight c
14,-- x pix start
7,6, --sky and sun
},{
2,7,6,--highlight c
1,--14,-- x pix start
12,10, --sky and sun
}}

zone = {{--1
[[

        hungry mary 3d
        
              by
              
       redwood games
       
 credits to palo blanco games
   for the original game
 help mary save harry from
 the mushroom gang!

	move: arrow keys
	jump: z or c
	lick: x
	
	don't starve! eat mushrooms 
	and berries to survive!
]],
16,24,-1,64,--bounds
1}, -- theme
{--2
[[

       as mary continues
  to travel, she arrives at...
           the ruins

]],
0,16,-1,64,--bounds
2},
{--3
[[
     this portal was a trap!
   mary got captured but guards
   are dumb, they left a pepper
     so, she can escape from...
          castle cells
            
]],
88,106,-1,16,--bounds
3},
{--4
[[

    she,s now outside,but now
        she has to find
         a secret path
       to pass under the...
             castle
]],
106,128,-1,16,--bounds
2},
{--5
[[


      undergroud dungeon
]],
24,88,-1,16,--bounds
3},
{--6
[[


          the overpass
  ]],
88,106,15,48,--bounds
4},
{--7
[[


            canyons
]],
106,128,15,64,--bounds
1},
{--8
[[


           lost city
]],
24,88,15,64,--bounds
2},
{--9
[[


          final showdown
]],
88,106,47,64,--bounds
3}}
function load_zone(zz)
	currentzone=zone[zz]
	currenttheme=themes[currentzone[6]]
	levelx0,levelx1,levely0,levely1=currentzone[2]*8,currentzone[3]*8,currentzone[4]*8,currentzone[5]*8
	lc,c1,c2,xps,skyc,sunc=currenttheme[1],currenttheme[2],currenttheme[3],8*currenttheme[4],currenttheme[5],currenttheme[6]
end

--menu
function hop_zone()
	giftfindall+=giftfind
	zonenow += 1
	if hard then
		zonenow,healthrate=1+flr(rnd()*#zone),flr(healthrate-10/healthloss)
		if healthrate <= 15 then
			healthloss*=2
			healthrate*=2
		end
	end
	if zonenow > #zone then
		zonenow,gameover = 1,2
	end
	load_zone(zonenow)
	load_level()
end

--function starthardmode()
-- transition,hard,hardcount,health,levelsbeat=true,true,0,100,0
--end

menuitem(5,"hard mode!",function() transition,hard,hardcount,health,levelsbeat=true,true,0,100,0 end)

__gfx__
4445544453355565000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000bbb33bbb42244464
5552455535535555000aaa00000aaa00000a0a00000aaa00000aaa00000aaa00000aaa00000aaa00000a0aaa0000a0a0000a0aaa000a0aaa3335b33324424444
555245555555355300000a0000000a00000a0a00000a0000000a000000000a00000a0a00000a0a00000a0a0a0000a0a0000a000a000a0a0a3335b33344442442
2225522255555335000aaa000000aa00000aaa00000aaa00000aaa0000000a00000aaa00000aaa00000a0a0a0000a0a0000a0aaa000a00aa5553355544444224
5444444555655355000a000000000a0000000a0000000a00000a0a0000000a00000a0a0000000a00000a0a0a0000a0a0000a0a00000a000a3bbbbbb344644244
4555555255555555000aaa00000aaa0000000a00000aaa00000aaa0000000a00000aaa00000aaa00000a0aaa0000a0a0000a0aaa000a0aaab333333544444444
4555555235535533000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b333333524424422
52222225533533550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003555555342242244
544444453333ffff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003bbbbbb3b3b3b3b3
455555523333ffff000ccc00000ccc00000c0c00000ccc00000ccc00000ccc00000ccc00000ccc00000c0ccc0000c0c0000c0ccc000c0cccb33333353b3b3b3b
455555523333ffff00000c0000000c00000c0c00000c0000000c000000000c00000c0c00000c0c00000c0c0c0000c0c0000c000c000c0c0cb3333335b3b3b3b3
455555523333ffff000ccc000000cc00000ccc00000ccc00000ccc0000000c00000ccc00000ccc00000c0c0c0000c0c0000c0ccc000c00ccb33333353b3b3b3b
45555552ffff3333000c000000000c0000000c0000000c00000c0c0000000c00000c0c0000000c00000c0c0c0000c0c0000c0c00000c000cb3333335b3b3b3b3
45555552ffff3333000ccc00000ccc0000000c00000ccc00000ccc0000000c00000ccc00000ccc00000c0ccc0000c0c0000c0ccc000c0cccb33333353b3b3b3b
45555552ffff3333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b3333335b3b3b3b3
52222225ffff3333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000355555533b3b3b3b
55522555533555550080000000000000000000000081110000080000000000000000000000000000000000000000000000000000000000003335533342244444
222252225555555508eeee0000000000000000000188ee1000088111111100000000118111110000000011181110000000001111111100005555355544444444
22225222555555558ee16160000000000011110088eeeee10081eeeeeeee10000001ee88eeee10000001eee88ee110000001eeeeeee810005555355544444444
22222222555553350e11111000111100018ee81018eeeee1881eeeeeeeeee100001ee8eeeeeee100001eee8eeeeee100001eeeeeeee881005555555544444224
25555552555553550e11111001111110188888811eeeeee108eeeeeeeeeeee1001e88eeeeeeeee1001ee88eeeeeee10001eeeeeeee8eee105333333544444244
52222222555555550e71617011111111188888811e1111e11eeee161616eeee11eee8ee161616ee11eeee8eeee6161001eeeeeee88eeee103555555544444444
522222225555553300eeee000111111001888810011331101ee6111111116ee11eeeee61111116e11eeeeeee611110001eeeeeeee8ee61003555555544444422
2222222253353355008008000011110000111100001111001ee1111111111ee11eeee111111111e11eeeeee1111100001eeeeeeeeeee11005555555542242244
88888888ffffffff777777776666666600077000002222001ee1111111111ee11eeee111111111e11eeeeee1111100001eeeeeeeeeee110055333333b3b3b3b3
ddd8ddd85f5f5f5f7600006764464446077777700eeeeee01ee1111111111ee11e777111111111e11eeeeee1111100001eeeeeeeeeee1100353333333b3b3b3b
ddd8ddd8555555557600006764464466077777702eeeeee217761111111677711e777111111111e11eee77ee611110001eeeeeeee77e610035553333b3e3b3b3
ddd8ddd8f5f5f5f57660066766666666777777772eeeeee21777e611161e777101777e611111677101e777eeee61610001eeeeee777eee10333533333eae3b3b
ddd8ddd8ffffffff7666066700000000777777772eeeeee20177eee61ee67710001eeee61616777100177eeeeeeee100001eeeee77eee10033355533b3e3b3b3
ddd8ddd85f5f5f5f7600066700000000077777702eeeeee20011eeeeeeee11000001eeeeeeee11100001eeeeeeee10000001eeeeeeee1000333335333b3b3c3b
ddd8ddd8555555557666066700000000077777700eeeeee000001eeeeee1000000001eeeeee1000000001eeeeee1000000001eeeeee1000033333555b3b3cac3
ddd8ddd8f5f5f5f5777007770000000000077000002222000000011111100000000001111110000000000111111000000000011111100000333333353b3b3c3b
0000000000000000000000000000000000000000000000000000000000000000a900009a00000030000000000000000044455444cccccccc7777777700000000
00000111111000000000000110000000000000011000000000000001100000009999999900000333000000000000000055524555c7777ccc01010111000aaa00
00001cccccc100000000001ee10000000000001ee10000000000001ee10000000999a99000000888000000000000000055524555c7667ccc0101101100000a00
0001cccccccc1000000001eeee100000000001eeee100000000001eeee10000009a9999000000888000000111100000022255222cc66cccc011001100000aa00
011111111111111000001eeeeee1000000001eeeeee1000000001eeeeee1000009999a9000008880000001eeee10000054444445cccccccc0111110100000a00
1cc1111111111cc10001e1eeee1e10000001eeeeee1e10000001eeeeeeee1000099a99900008888000001eeeeee10000455555527cccc77701110110000aaa00
1ccc111cc111ccc1001ee71ee17ee100001eeeeeee71e100001eeeeeeeeee10099999999088888000001eeeeeeee1000455555527cccc7660110101100000000
1cccccccccccccc101ee777ee777ee1001eeeeeee777ee1001eeeeeeeeeeee10a900009a00880000001eeeeeeeeee10052222225cccccc660111011100000000
1cccc111111cccc101eee787787eee1001eeeeeeee787e1001eeeeeeeeeeee100099990001999910001ee1eeee1ee1004444ffff1111cccc0100001100000000
1ccc1cccccc1ccc1001eee7ee7eee100001eeeeeeee7e100001eeeeeeeeee1000999999019111111001eee1ee1eee1004444ffff1111cccc01111101000ccc00
01cc1cccccc1cc100001eeeeeeee10000001eeeeeeee10000001eeeeeeee10000991919091199911001eee1ee1eee1004444ffff1111cccc0101101100000c00
001cccccccccc100001711eeee117100000011eeee110000001711eeee11710009999990919111910001eee11eee10004444ffff1111cccc011001100000cc00
00111111111111000017731111377100000013111131000000177311113771000991119091911119000011eeee110000ffff4444cccc11110111110100000c00
000166666666100000011333333110000000133773310000000113333331100009999990911991190000171111710000ffff4444cccc111101110110000ccc00
000166666666100000000133331000000000013333100000000001333310000000900900191111910000017777100000ffff4444cccc11110110101100000000
000011111111000000000011110000000000001111000000000000111100000000990990019999100000001111000000ffff4444cccc11110111011100000000
00000000000000000000000000000000000000000000000000000000000000000088880000aaaa00000000000000000000000000000000000000000000008000
0000000000000000000000000000000000000000000000000000000000000000885555880a9999a0000011111111000000001111111100000000111111188000
000000000000000000000000000000000000000000000000000000000000000060888806a998899a00019999999910000001eeeeeee810000001eeeeeeee1800
000000111100000000000011110000000000001111000000000000000000000006000060a988999a0019999999999100001eeeeeeee88100001eeeeeeeeee188
000001dddd10000000000199991000000000018888100000000000000000000000666600a988889a019999999999991001eeeeeeee8eee1001eeeeeeeeeeee80
00001dddddd1000000001999999100000000188888810000000000000000000006000060a998899a19999161616999911eeeeeee88eeee101eeeeeeeeeeeeee1
0001dddddddd1000000199999999100000018888888810000000000000000000600000060a9999a019961111111169911eeeeeeee8ee61001eeeeeeeeeeeeee1
001dddddddddd1000019999999999100001888888888810000000000000000005555555500aaaa0019911111111119911eeeeeeeeeee11001eeeeeeeeeeeeee1
001dd1dddd1dd100001991999919910000188188881881000000000000000000008008000011110019911111111119911eeeeeeeeeee11001eeeeeeeeeeeeee1
001ddd1dd1ddd100001999199199910000188818818881000000000000000000088888800199991019911111111119911eeeeeeeeeee11001eeeeeeeeeeeeee1
001ddd1dd1ddd100001999199199910000188818818881000000000000000000dd8888dd19999d9117761111111677711eeeeeeee77e61001eeeeeeeeeeeeee1
0001ded11ded1000000199988999100000018881188810000000000000000000dee88eed19d99991177796111619777101eeeeee777eee1017eeeeeeeeeeee71
000011dddd110000000011199111000000001188881100000000000000000000888888881999d9910177999619967710001eeeee77eee100017eeeeeeeeee710
0000131111310000000018111181000000001a1111a100000000000000000000dee88eed1999999100111199991111000001eeeeeeee10000011eeeeeeee1100
00000133331000000000018888100000000001aaaa1000000000000000000000dee88eed01133110000177199177100000001eeeeee1000000001eeeeee10000
0000001111000000000000111100000000000011110000000000000000000000ddd88ddd00111100000177111177100000000111111000000000011111100000
000012120000000040401212124040009090909090909090100000f07070709470a4707070f00000000000000060006000600060000000002020004040000000
00f0b0b0000000a400000000000000000000b0b0e0000010000000870000002020202000005252520000f0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0b0a0a0a0
10203030201000a446401212124640008080909090909090100000d070a470707070702670d00000000000000000000000000000000000000000000000000000
00e0b0b0b0b0b0b0b0b01313b0b0b0b0b0b0b0b0f00000108700000000000010101010000052a4520000f0f01313f013f013f013f013f013f013f013f02323f0
1020a4a4201000a400000000000000008080808080905252100000f0707070707070707070f00000000000006060600000000000000000000000000000000000
00f0b0b0b0b0b0b0b0b01313b0b0b0b0b0b0b0b0e0000010000000000000000000000000005252520000f0000000000000000000000000000000909090a0a000
00000000000000000000000052520000808080808090525210000000f070707070707070f0000000000000006060600000000000000000000000525252000000
00f0e013e0f0e013e0f02323f0e013e0f0e013e0f0000010000000000040000000000000000000000000f0876060127070707012808080808012909090a0a087
0000000000000000000000005252000050505026265050501000000000d0f0605050f0d000000000000000005050505050505050000000000000525252000000
000000000000000000000000000000000000000000000010000094008686000070700000000000000000f0006094125252525212805246525212800000000000
000000000000000000000000000000005050508080505050100000000040d0303040d08000000000000000005050505050505050000000000000000000000000
000000000000000000000000000000000000000000000010b0b0b0b0b0b0b0b02323b0b0b0b0b0b0b0b0f0806060000090000000000040000000000000000000
a01313a0a0a0a0a0a0a0a0a0a0a0a0a05050507171505050100000006000d0201010d00060000000000000000000000000505050000000000000000000000000
000000000000000000000000000000000000000000000010707070707070707070707070707070707000f0806060000026000000000046000030302020101000
000000101013131313131313131000006060606060606060100000400000d0000000d00000400000000000000000000000505050000000000000000000000000
000000000060606000000000000000000000000000000010947052527070267052525270267052527087f0006060125050505012404040401240302020101000
000000102020304050607070707000876060606060606060100060000000f0232323f00000006000000000000071506050505050506050710000000000000000
000000000060875260606060606060605040606060000010000050505050505050505050505060600000f0006060125252525212405252521240000000000000
707070707070707070607171a0a0a0a0606060606060606010004000000000000000000000004000000000000050505050505050505050500000000000000000
000000000000000000000000000040505252000000000010000000000000000000000000000000000000f0000000000000000000000000000000000000000000
706061616171717171717171717030800000001212000000100060000000000000000000000060000000006060605040a45050a4808050600000000000000000
000000000000000000000000000052404052000000000010000040400000303000000030300000000000f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0a0a0f0f0
7060616161717171717171717170878000000012120000001000400000000000000000000000400000000060001020305050a4502680a4505000000000000000
0000000000000000000000000000003030201000000000100000404000003046000000a4300020201000f080808090a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0
a0a02323a07070707070707070703080005200121200870010004000101000000000000010104000000000602360505050a45050505050605000000000000000
000000000000000000000000000000002052520000000010000000000000000000000000000020201000f0f02323f013f013f013f013f013f013f0131313f0f0
704051514040404040404040404040808600001212000000100060401313600000006040131360000000000000605050a45050a4509450604000000000004040
400030303000003030303030300000000000000000000010000000002200005200000000000000000000f0808080202070702020606020205050000040403000
70404141414141414141414141414180505050606050505010000000000000000000000000000000000000000050a4505050505050a450604040000040404046
400030463000003030303030300000000000000000000010000000000000000000005200000000520000f08080800000704600006046000050a4000094403087
704041a441a44141a441414141a4a480505050505050505010000000000000000000000000000000000000000071506050605060506050710000000000004040
400030303000000000000030300000000000525200000010000000000000000000000000005200000000f0808080000070700000606000005050000040403000
70404052404040404040404040414150404040404040404010004687460000000000000000000052525200000000000000000000000000000000000000000000
000000000000000000000030300000000000525200000010f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f000000000007026000060a4000050a4000052523000
87408652404040404040404040414150404040404030303010000000000000000000000000000052525200000000000000000000000000000000000000520000
520000000000000000000030300000000000525200000010f000c0c0c0c0c0c0f0c0f0c0c0c0c0c000f0f0005252000000000000000000000000000030303000
70101010101013131313132020313150101020200020202010000000000000000000000000000000000000000000000000000000000000000000000000005200
000052000000000000303030303030000000000000000010f08710b0c0c0c0c0f095f0909090901000f0f0005252000000000000520000000000520020202000
701010111111001113210021a4212140101052520052522010000000000000000000000000000000000000000000000000000000000000000000000000000052
260000520000000000304630525230000000000000000010f00010b046c046c0c026c0902690a41087f0f0870000000000520000000000520000000010101000
70121011111100110021522121212140525200000000000010000040003000200000101000000000000000000000000000000000000000000000000000520000
000000000000000000303046525230000030303000000010f00010a0a09090c0c0c0c0909046901052f0f0000000000000000000000000000000000000000000
701210a4201000000000001010107171101000001046000010000040003000200000101000000000000000000000000000000000000000000000000000000000
520052000000000000305252463030303030003000000010f00010902690a49090909046a480801052f0f0f08080f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0
50121011101070121212701010105294000000000000000010000040c0b0c0b0c0b0c0b000000000005252000000000030102010201030000000000000005200
005200000000000000305252304630303030863000000010f0001090469090469090a4909070701052f0f0f08080808080808080808080808080807060606060
00121212121212121212121212121212d1d100000000d1d110004040b0a0b4a0a0a0a0c000000000000000000000000010101010101010000000000000000000
000000000000000000303030303030000030233000000010f00010909090a49090a490909060601052f0f0f0131313f013f013f013f013f013f013f02323f0f0
00000000000000000000000000000000d1d110101010d1d110004040c0a04687a0b4a0b000000052005252005200000020101022101020000000000000000000
000000000000000000000020200000000000000000000010f000102630300040400050260060601052f0f0000000000000000000000000000000000060600000
20005252000000525252520000008640f0f0f01313f0f0f010004040b0b4a0a0a0a0b4c000000052005252005200000010101010101010000000000000000000
000000000000000000000010100000000000000000000010f000102030300040400050500060601000f0f0000000404087525200501212125000525250500000
20005252000000000000000000000040f0f0f01313f0f0f010004040c0a0b487b446a0a090900000000000000000000030101010101030000000001010101010
101010000000000000000010940000000000000000000010f000101010100000000000000010101000f0f0008600405000525200120050001200525250500000
20000000000000000000000000000040f0f0f01010f0f0f010004040b0a0a0a0a0a0a0a090900000005252000000000000001052100000000000001010105210
521010000000000000000010100000000000000000000010f0000000000000000000a4000000000000f0f0005200001200000000120046005012121212120000
60101010604040404040404040404040f0101010101010f010004040c0b0c0b0c0b0c0b080800000000000000000000000001010101010101010101010000000
001010101010101010101010100000000000005252520010f00000d0d0000000a40000a40000000000f0f0005200001200000000120000000000001200000000
87131313601010101010101010101040f0108710101010f010004040000050500000606070700000000000000000000000001052105210521052105210000000
001010521010521010521010100000000000005252520010f00000a0a0000000000000000052525200f0f0005200005012121212500000000000001200000000
2010101010a4105210a4105210221040f0101010221010f010004040000050500000606070700000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000010f00000a022000000000000000052525200f0f0005200000000000000460000000000005000001020
1010101010a4101010a4101010101040f0101010101010f010000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000010f000000000000000000000000052525200f0f0000000000000000000000000000000009400001022
__label__
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111c
c171717171771117717771777111111111711177711111111111111111111171117771717177717111111111117711111111111111111111111111111111111c
c171717171717171117111717117111111711171711111111111111111111171117111717171117111171111111711111111111111111111111111111111111c
c177717171717171117711771111111111777177711111111111111111111171117711717177117111111111111711111111111111111111111111111111111c
c171717171717171717111717117111111717111711111111111111111111171117111777171117111171111111711111111111111111111111111111111111c
c171711771717177717771717111111111777111711111111111111111111177717771171177717771111111117771111111111111111111111111111111111c
c111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccc724224242244242247ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccc724444244444244447cccccccc6666666cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccc742442424442424447cccccc66666666666cccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccc744424444244444247ccccc6666666666666ccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccc744424444244444247cccc666666666666666cccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccc744444444444444447ccc66666666666666666ccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccc724224242244242247cc6666666666666666666cccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccc724444244444244447cc6666666666666666666811ccc1811cccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccc742442424442424447c6666666666666666666188e1c1188e1ccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccc744424444244444247c66666666666666666688eeee188eeee1cccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccc744424444244444247c66666666666666666618eeee118eeee1cccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccc744444444444444447c6666666666666666661e111e11e111e1cccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccc777777777777777777777777777777777777711131111113111cccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccc777777777777777777777777777777774b33b3b311111b311111ccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccc7442442442474424442442444244244777777777777777777777777cccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccc7444444444474444424444442444444744244442442444244244447cccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccc7444224444274442244444224444422744424424444244444424427cccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccc7444444444474444444444444444444744442244444422444442247cccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccc7442422442474424222442422244242746442444464424446442447cccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccc7777777777772242444224244422424744444444444444444444447cccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccc73b33b3b3b33b77777777777777777777744244222442442244244227cccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccc73b3b3bb3b3b3bb3b3b3bb3b3b3bb3b3b3b722422444224224422422447cccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccc777777777777777777777773b3b3b3b3b3b3b722444644224446422444647cccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccc74424442442444424424473b33b3bb3b33b3b744244442442444244244447cccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccc7444244444424424444277777777777777777774424424444244444424427cccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccc7444422444442244444474422444424422444474442244444422444442247cccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccc7464424446442444464474444244244444244276442444464424446442447cccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccc7444444444444444444474444422444444422474444444444444444444447cccccccccccccccccccccccccccccccccccccccc
77777777777777777777777777774424422442442224424744444224444444224742442224424422442442277777777777777777777777777777777777777777
77777777777777777777777777772242244224224442242746444244446444244724224442242244224224477777777777777777777777777777777777777777
77777777777777777777777777774424442442444424424744444444444444444742444424424442442444477777777777777777777777777777777777777777
77777777777777777777777777774442444444244244442744224422244224422744244244442444444244277777777777777777777777777777777777777777
77777777777777777777777777774444224444422444444722442244422442244744422444444224444422477777777777777777777777777777777777777777
77777777777777777777777777774644244464424444644777777777777777777764424444644244464424477777777777777777777777777777777777777777
7777777777777777777777777777444444444444444444473b33b3b3b3b33b3b3744444444444444444444477777777777777777777777777777777777777777
b7b7b7b7b7b7b7b7b7b7b7b7b7b7442442244244222442777777777777777777774244222442442244244227b7b7b7b7b7b7b7b7b7b7b7b7b7b7b7b7b7b7b7b7
7b7b7b7b7b7b7b7b7b7b7b7b7b772242244224224442247444244442444244444724224442242244224224477b7b7b7b7b7b7b7b7b7b7b7b7b7b7b7b7b7b7b7b
b7b7b7b7b7b7b7b7b7b7b7b7b7b7224446422444644224744424444244424444472444644224446422444647b7b7b7b7b7b7b7b7b7b7b7b7b7b7b7b7b7b7b7b7
7b7b7b7b7b7b7b7b7b7b7b7b7b774424442442444424427444424444444424442742444424424442442444477b7b7b7b7b7b7b7b7b7b7b7b7b7b7b7b7b7b7b7b
b7b7b7b7b7b7b7b7b7b7b7b7b7b7444244444424424444744444222444444222474424424444244444424427b7b7b7b7b7b7b7b7b7b7b7b7b7b7b7b7b7b7b7b7
7b7b7b7b7b7b7b7b7b7b7b7b7b774444224444422444447446442244446442244744422444444224444422477b7b7b7b7b7b7b7b7b7b7b7b7b7b7b7b7b7b7b7b
b7b7b7b7b7b7b7b7b7b7b7b7b7b7464424446442444464744444444444444444476442444464424446442447b7b7b7b7b7b7b7b7b7b7b7b7b7b7b7b7b7b7b7b7
7b7b7b7b7b7b7b7b7b7b7b7b7b774444444444444444447444444444444444444744444444444444444444477b7b7b7b7b7b7b7b7b7b7b7b7b7b7b7b7b7b7b7b
b7b7b7b7b7b7b7b7b7b7b7b7b7b7442442244244222442744424442244424442274244222442442244244227b7b7b7b7b7b7b7b7b7b7b7b7b7b7b7b7b7b7b7b7
bbbbbbbbbbbbbbbbb77777777777777777777777777777777777777777777777777777777777777777777777777777bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
b7b7b7b7b7b7b7b77b33b3b33b3b33b3b33bb33b3b33b3b33b3b33bb33b3b33b3b33b3b33bb33b3b33b3b33b3b33b377b7b7b7b7b7b7b7b7b7b7b7b7b7b7b7b7
bbbbbbbbbbbbbbb733b3b33b3b33b3b33b3b33b3b33b3b33b3b33b3b33b3b33b3b33b3b33b3b33b3b33b3b33b3b33b37bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
b7b7b7b7b7b7b77b33b3b33b3b33b3b33b3b33b3b33b3b33b3b33b3b33b3b33b3b33b3b33b3b33b3b33b3b33b3b33b37b7b7b7b7b7b7b7b7b7b7b7b7b7b7b7b7
bbbbbbbbbbbbb733b33b3bbb33b33b3bb3b33b33b3bbb33b33b3bbb33b33b3bb3b33b33b3bbb33b33b3bbb33b33b3bb37bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
b7b7b7b7b7b77b33b33b3bbb33b33b3bb3b33b33b3bbb33b33b3bbb33b33b3bb3b33b33b3bbb33b33b3bbb33b33b3bb3b7b7b7b7b7b7b7b7b7b7b7b7b7b7b7b7
bbbbbbbbbb77b3bb3b33b3bb3bb3b33b3bb3bb3b33b3bb3bb3b33b3bb3bb3b33b3bb3bb3b33b3bb3bb3b333bb3bb3b33bb7bbbbbbbbbbbbbbbbbbbbbbbbbbbbb
b7b7b7b7b73bb3bb3b33b3bb3bb3b33b3bb3bb3b33b3bb3bb3b33b3bb3bb3b33b3bb3bb3b33b3bb3bb3b333bb3bb3b33b777b7b7b7b7b7b7b7b7b7b7b7b7b7b7
bbbbbbbb7b3bb3bb3bbbb3bb3bb3bb3bb3bb3bb3bbbb3bb3bb3bbbb3bb3bb3bb3bb3bb3bb3bbbb3bb3bb3bb3bb3bb3bb3bb7bbbbbbbbbbbbbbbbbbbbbbbbbbbb
b7b7b777bb3bb3bb3bbbb3bb3bb3bb3bb3bb3bb3bbbb3bb3bb3bbbb3bb3bb3bb3bb3bb3bb3bbbb3bb3bb3bb3bb3bb3bb3bb377b7b7b7b7b7b7b7b7b7b7b7b7b7
bbbbb73b33b33b33b33b33b33b33b33b33b33b33b33b33b33b33b33b33b33b33b33b33b33b33b33b33b33b33b33b33b33b33b7bbbbbbbbbbbbbbbbbbbbbbbbbb
b7b7733b33b33b33b33b33b33b33b33b33b33b33b33b33b33b33b33b33b33b33b33b33b33b33b33b33b33b33b33b33b33b33b7b7b7b7b7b7b7b7b7b7b7b7b7b7
bb77b3bb33b33b3bb3bb33b33b33bb3bb33b33b3bb3bb33b33b33bb3bb33b33b3bb3bb33b33b3bb3bb33b33b33bb3bb33b33b37bbbbbbbbbbbbbbbbbbbbbbbbb
b777777777777777777777777777777777777777bb3bb33b33b3bb3bb33b33b33777777777777777777777777777777777777777b7b7b7b7b7b7b7b7b7b7b7b7
b742224444464444222444446444422244444644bb3bb33b33b3bb3bb33111811142224444464444222444446444222444446447bbbbbbbbbbbbbbbbbbbbbbbb
b72444224444442244422444444224442244444bb33b33bb33b3bb33b31eee88ee11442244444422444224444422444224444447b7b7b7b7b7b7b7b7b7b7b7b7
b74444442444224444444244422444444424442bb33b33bb33b3bb33b1eee8eeeeee144424442244444442444244444442444227bbbbbbbbbbbbbbbbbbbbbbbb
b7444444244422444444424442244444442444bb33b33bb33b3bb33b1ee88eeeeeee144424442244444442444244444442444227b7bbb7bbb7bbb7bbb7bbb7bb
b7444444422244444444442224444444444222bb33b33bb33b3bb331eeee8eeee616144442224444444444222444444444222447bbbbbbbbbbbbbbbbbbbbbbbb
b74444444222444444444422244444444442233bb33bb3bb33b33bb1eeeeeee61111444442224444444444222444444444222447bbb7bbb7bbb7bbb7bbb7bbb7
b74466444224444446644422444444664442bb33bb33b33bb33bb331eeeeee111114664442244444466444224444466444224447bbbbbbbbbbbbbbbbbbbbbbbb
b74444444444444444444444444444444444bb33bb33b33bb33bb331eeeeee111114444444444444444444444444444444444447b7bbb7bbb7bbb7bbb7bbb7bb
b744444444444444444444444444444444433bb33bb3bb33bb33bb31eeeeee111114444444444444444444444444444444444447bbbbbbbbbbbbbbbbbbbbbbbb
b724442244422222444224442222244422433bb33bb3bb33bb33bb31eee77ee61111442244422222444224442222444224442227bbb7bbb7bbb7bbb7bbb7bbb7
b742224422244444222442224444422244233bb33bb33bb33b33bb331e777eeee616124422244444222442224444222442224447bbbbbbbbbbbbbbbbbbbbbbbb
b742224422244444222442224444422244233bb33bb33bb33b33bb33b177eeeeeeee124422244444222442224444222442224447b7bbb7bbb7bbb7bbb7bbb7bb
b74222444446444422244444644442224433bb33bb33bb33b33bb33bb11eeeeeeee1124444464444222444446444222444446447bbbbbbbbbbbbbbbbbbbbbbbb
b74222444446444422244444644442224433bb33bb33bb33b33bb3311111eeeeee11111444464444222444446444222444446447bbb7bbb7bbb7bbb7bbb7bbb7
b7244422444444224442244444422444233bb33bbb33bb33b33bb331111111111111111244444422444224444422444224444447bbbbbbbbbbbbbbbbbbbbbbbb
b7444444244422444444424442244444bb33bb333bb33bb33bb33bb3311118ee8111144424442244444442444244444442444227b7bbb7bbb7bbb7bbb7bbb7bb
b7444444244422444444424442244444bb33bb333bb33bb33bb33bb3311188888811144424442244444442444244444442444227bbbbbbbbbbbbbbbbbbbbbbbb
b74444444222444444444422244444433bbb33bb33bbb33b33bbb33bb33188888814444442224444444444222444444444222447bbb7bbb7bbb7bbb7bbb7bbb7
b74444444222444444444422244444433bbb33bb33bbb33b33bbb33bb33118888114444442224444444444222444444444222447bbbbbbbbbbbbbbbbbbbbbbbb
b74466444224444446644422444444bb333bb33bb333bb33bb333bb33bb331111344664442244444466444224444466444224447b7bbb7bbb7bbb7bbb7bbb7bb
b74444444444444444444444444444bb333bb33bb333bb33bb333bb33bb333bb3344444444444444444444444444444444444447bbbbbbbbbbbbbbbbbbbbbbbb
b74444444444444444444444444444bb333bb333bb33bbb3bb333bb333bb33bbb334444444444444444444444444444444444447bbb7bbb7bbb7bbb7bbb7bbb7
b72444224442222244422444222224bb333bb333bb33bbb3bb333bb333bb33bbb334442244422222444224442222444224442227bbbbbbbbbbbbbbbbbbbbbbbb
b742224422244444222442224444433bbb33bbb33bb333b33bbb33bbb33bb333bb42224422244444222442224444222442224447b7bbb7bbb7bbb7bbb7bbb7bb
b742224422244444222442224444433bbb33bbb33bb333b33bbb33bbb33bb333bb42224422244444222442224444222442224447bbbbbbbbbbbbbbbbbbbbbbbb
b742224444464444222444446444bbb33bbb33bbb33bbb3bbb33bbb33bbb33bbb332224444464444222444446444222444446447bbb7bbb7bbb7bbb7bbb7bbb7
b74222444446444422244444644bbb33bbb33bbb33bbb3bbb33bbb33bbb33bbb3372224444464444222444446444222444446447bbbbbbbbbbbbbbbbbbbbbbbb
b72444224444442244422444444bbb33bbb33bbb33bbb3bbb33bbb33bbb33bbb3324442244444422444224444422444224444447b7bbb7bbb7bbb7bbb7bbb7bb
b7444444244422444444424442bbb33bbb33bbb33bbb33bbb33bbb33bbb33bbb3344444424442244444442444244444442444227bbbbbbbbbbbbbbbbbbbbbbbb
b7444444244422444444424442bbb33bbb33bbb33bbb33bbb33bbb33bbb33bbb3344444424442244444442444244444442444227bbb7bbb7bbb7bbb7bbb7bbb7
b744444442224444444444222333bb333bbb33bbb33bb333bb333bbb33bbb33bbb44444442224444444444222444444444222447bbbbbbbbbbbbbbbbbbbbbbbb
b744444442224444444444222333bb333bbb33bbb33bb333bb333bbb33bbb33bbb44444442224444444444222444444444222447b7bbb7bbb7bbb7bbb7bbb7bb
b74466444224444446644422bbb33bbb333bb333bb333bbb33bbb333bb333bb33344664442244444466444224444466444224447bbbbbbbbbbbbbbbbbbbbbbbb
b74444444444444444444444bbb33bbb333bb333bb333bbb33bbb333bb333bb33344444444444444444444444444444444444447bbb7bbb7bbb7bbb7bbb7bbb7
b7444444444444444444444333bbb33bbb333bbb33bbb333bbb33bbb333bbb33bbb4444444444444444444444444444444444447bbbbbbbbbbbbbbbbbbbbbbbb
b7244422444222224442244333bbb33bbb333bbb33bbb333bbb33bbb333bbb33bbb4442244422222444224442222444224442227b7bbb7bbb7bbb7bbb7bbb7bb
b742224422244444222442bbb333bb333bbb333bb333bbb333bb333bbb333bb33342224422244444222442224444222442224447bbbbbbbbbbbbbbbbbbbbbbbb
b742224422244444222442bbb333bb333bbb333bb333bbb333bb333bbb333bb33342224422244444222442224444222442224447bbb7bbb7bbb7bbb7bbb7bbb7
b74222444446444422244333bbb333bbb33bbb333bbb333bbb333bbb33bbb333bbb2224444464444222444446444222444446447bbbbbbbbbbbbbbbbbbbbbbbb
b74222444446444422244333bbb333bbb33bbb333bbb333bbb333bbb33bbb333bbb2224444464444222444446444222444446447b7bbb7bbb7bbb7bbb7bbb7bb
b7244422444444224442bbb333bbb333bb333bbb333bbb333bbb333bb333bbb33324442244444422444224444422444224444447bbbbbbbbbbbbbbbbbbbbbbbb
b7444444244422444444bbb333bbb333bb333bbb333bbb333bbb333bb333bbb33344444424442244444442444244444442444227bbb7bbb7bbb7bbb7bbb7bbb7
b744444424442244444333bbb333bbb333bbb333bbb333bbb333bbb333bbb333bbb4444424442244444442444244444442444227bbbbbbbbbbbbbbbbbbbbbbbb
77444444422244444447777777777777777777777777777777777777777777777774444442224444444444222444444444222447777777777777777777777777
b7444444422244444447bb333bbb333bbb333bbb333bbb333bbb333bbb333bbb3374444442224444444444222444444444222447bbbbbbbbbbbbbbbbbbbbbbbb
b744664442244444467bb333bbb3333bbb333bbb33bbb333bbb3333bbb333bbb3374664442244444466444224444466444224447bbb7bbb7bbb7bbb7bbb7bbb7
b744444444444444447bb333bbb3333bbb333bbb33bbb333bbb3333bbb333bbb3374444444444444444444444444444444444447bbbbbbbbbbbbbbbbbbbbbbbb
b7444444444444444733bbb333bbbb333bbb333bbb333bbb333bbbb333bbb333bb7444444444444444444444444444444444444777bbb7bbb7bbb7bbb7bbb7bb
b7244422444222224733bbb333bbbb333bbb333bbb333bbb333bbbb333bbb333bb744422444222224442244422224442244422277bbbbbbbbbbbbbbbbbbbbbbb
b742224422244444733bbbb333bbb333bbbb333bb333bbbb333bbb333bbbb333bb722244222444442224422244442224422244477bb7bbb7bbb7bbb7bbb7bbb7
b742224422244444733bbbb333bbb333bbbb333bb333bbbb333bbb333bbbb333bb72224422244444222442224444222442224447b7bbbbbbbbbbbbbbbbbbbbbb
b742224444464447bb3333bbb333bbb3333bbb333bbb3333bbb333bbb3333bbb3372224444464444222444446444222444446447b7bbbbbbbbbbbbbbbbbbbbbb
7724442244444427bb3333bbb333bbb3333bbb333bbb3333bbb333bbb3333bbb3374442244444422444224444422444224444447777777777777777777777777
b7444444244422733bbbb333bbbb333bbb3333bb333bbbb333bbbb333bbb3333bb74444424442244444442444244444442444227bb7bbbbbbbbbbbbbbbbbbbbb
b7444444244422733bbbb333bbbb333bbb3333bb333bbbb333bbbb333bbb3333bb74444424442244444442444244444442444227bbb7bbbbbbbbbbbbbbbbbbbb
b744444442224733bbbb333bbbb333bbb3333bbb333bbbb333bbbb333bbb3333bb74444442224444444444222444444444222447bbb7bbbbbbbbbbbbbbbbbbbb
7744444442224733bbbb333bbbb333bbb3333bbb333bbbb333bbbb333bbb3333bbb7444442224444444444222444444444222447bbb7bbbbbbbbbbbbbbbbbbbb
7744664442247bbbb333bbbb333bbbb333bbbb33bbbb333bbbb333bbbb333bbbb337664442244444466444224444466444224447bbbb7bbbbbbbbbbbbbbbbbbb
b744444444447bbbb333bbbb333bbbb333bbbb33bbbb333bbbb333bbbb333bbbb337444444444444444444444444444444444447bbbb7bbbbbbbbbbbbbbbbbbb
b744444444473333bbb3333bbb3333bbb3333bb3333bbb3333bbb3333bbb3333bbb7444444444444444444444444444444444447bbbbb7bbbbbbbbbbbbbbbbbb
b724442244473333bbb3333bbb3333bbb3333bb3333bbb3333bbb3333bbb3333bbb7442244422222444224442222444224442227bbbbb7bbbbbbbbbbbbbbbbbb

__gff__
0202000000000000000000000000020202020000000000000000000000000202020201000100000000000000000002020202020202020022002200220022020200000000000000000000000002020c00002200220022002200000022020204000000000000000000000000000000000000220022002200000000002200220022
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0421210421210421210421010421210419091909190919090f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f00780004040404040404030303020202010100000000
2100000000000000000000005900000078252517591807160f03040505050504030000000000030f03030303030302010000000f000000000003030303030211010f0303030300000000000004040404070708090a0a0a0f0f00000011110f0303030f0300000203030f000000044a4a4a040404030303020202010100000000
0400030300020201000000000000000015051505150515050f03040522050504030025000000030f03030303030302010000000f007800000003030303031111010f0303030421212121212104040404070708090a590a0f0f00780011110f0359030f0300250203030f000505046204044a4a0400000000000f0d0d0d0f0000
0000000000000000000000002525000004130313031303130f03040404040404032578250000030f32320f00212100000000000f00000000000300000f011111010f0303030421212121212104040404070707070a0a0a0f0f00000011220f0303030f0300000121210f0005050404044a04040400000000000d0d590d0d0000
0000000000002525000000002525000011011101110111020f03030303030303030025000000030303030f00212100000000000f00000500002100000f011164010f0303030303000000000004040404070707070707070f0f00000011110f3232320f0300000021210f00050505000000000000000f0d0d0d0f0d0d0d0f0025
7800000000252500000000000000000000000000000000000f00000000000000000000000000000364030f00132100001313000f00006200002100000f011111010f0f0f0f32320f0078000004040404040404040404040f0f002500000303030303030300250321210f00056400000000000000000d0d250d0d0b0b0b0b0000
000000000000000000000f0f31310f0f00000000000000000f68000000000000000000000000000000000f00000000000000000f00000000002100000f011111010f0000000303000000000004046404040464040468040f0f000000000000020202000000006421210f0005050500000c0a0a0a0a0f0d0d0d0f0b25250d0025
0000000f0f0f0f0f0f0f000000000f0f00001100000078000f00000025002500000000000000030003000f25250000000013130f00000321210300000f016411010f0000002121000000000004040404040404040404040f0f000000250025010101002500000021210f0000212100000a09090909090909090a000000000000
0f0f0f0f00000000000000000000000f0f0f320f0f0f0f0f0f00000000250000000000000000000000000f25250000000000000f00002100000005000f011111010f0303002121000000000004040404040404040404040f0f00000b000000000000000000000021210f0005050500000a62090909627809680a000000250000
0f00000f78002525000000000000000f0f1111110a0a0a0f0f00000025002500000000000000030078000f00001313000013130f00002100000562060f011111010f0403002121000000000000000000000000000000000f0f000064000c0c000025000000000321210f0005640500000a09090909090909090a000000000000
0f78000f0f002525000f0f0f0f0f0f0f0f6211620a0a490f0f00000000000000000000000000000000000f00000000000000000f05002100000000000f011164020f0500002121000000250000002500250000000078000f0f0b2121210c49000000000000006421210f0005050500000c09090c0a0a0a0a0a0c000025000000
0f00000f0f000000000f0f000000000f081111111105050f0f01010111110101010102020203131303030f00000000002525000f62000321212103030f011111020f0000002121000025002500000000002500000000000f0f0a0000000000000000042121212103210f0005060700780a08080a000000000000000000000909
0f0000000000000000000000000f310f781111111168050f0f01010111110101010102020203131303030f00001313002578000f00000000000003030f011111030f0600000303212121212103212121212103212121030f0f092108210700000000210000000000000f0005060700000a25250a006400000000000000002209
0f0f0f0f0f0f0f0f0f0f0f0f0f0f0000081111111105050f0f01010111111111111112121213131349030f00002121000000000f00000000000003030f016411780f4900006262212121212103212121212103212121030f0f000000002100000600210000250025000f000007070a0a0a08080a000078000000000000040508
0f0f0f0f0f0f0f0f0f0f0f0f0f0f0c0c0f1111111111110f0f01010111111111111112121213131303030f03030303030303030303020100000002020f11111111010000000000000000000000000000000000000001020f0f007825002100006400050000007800000f0000070707070707070a000000640000000000030507
0606070707040704040707040c0404780f1111111111680f0f01010101010101010102020203030303030f25250303252503030303020100000001010f11111111010025002500250025000000000000002500250001010f0f002525000621212121210000250025000f0f00070725072507250a000d00000000000001020506
0606072121042104042168042104780c0f1111111111110f010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010000000000000000000000000000000000000f0309090b0b0c0c0c0c0d020d090909091918080303
06060604044a044a0404044a044a04040f0000000000000f010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002525010078000000000005050505000000000078000f0362090a0a0c0c0c0c025902091919191917070303
060606040404040404040404040404040f0101010101010f01000000000000000000000000000000000000000000000000000000000000000000000000000f0f0f0f0e0f0e0f0e0f0e0f0e0f0e0f0e0f0e0f0e0f0f25780100000e0e0e0e00030303030000000d0d00000f781919090909090909090209091906061616062578
002121000000000000000000000000000f0000000000000f010000000000000c0c0c0b0b0a0a0a0a0a0a00000000000000000000000000000000000000000f0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0f25250100000e590e0e0d21212121212121256200000f031919191919191919641919191962061616062525
782121000000000000000000000078000f0f0f32320f0f0f010000000000000c0c0c0b0b0a0a0a0a0a0a00000000000000000000000000000000000000000f0b0b0b0b0b0b0b2525250b0b252525250b0b0b0b0b0e25250100000e0e0e0e0d212121212121210d0d00000f030505090909090909090909090906061616062525
002121000000000000000000000000001414000000001414010000000000000c0c0c0606060606060a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a00000f31310e0b0b0000000000000000000000000000780b0f2525010000252525250003030303000000212100000f036205060606060606060606060606781616060303
000606212121212121212121210606002525212121211449010000000000000c0c0c0606060678680a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a21212121210f0b0b00780000004a00004a00000000000b0b0e0000010000000000007803040506070700212100000f031515161616641616161616641616161616060303
0062622121212121212121212162060014140000000000010100000f0d0f0f3232320f0f0d0f00000000000000000000000000000000000000000a0a21212121210e0b0b0000010101000000000101000000250b0f0000010000000000000003252525640700212100000f031515060606060606060606060606060606060303
0000000000000000000000000021210014140025000000010100000f070707070c070707070f0000000000000000000000000000000000000000000000000000000f2525000000000000004a000000004a000b0b0e0000010000000a00000003030303002100212100000f031414030303030303030303030303030303036403
00000000000025250000004a0021210013130000002500010100000d0707090707070b07070d0000000000000000000000000000000000000000000000000000000e2525004a0000010000000000010101000b0b0f00000100250064090807036262030021000d0d00000f031313131313136413131313131313131313131313
0000004a00002525004a00250006060012122500000000010100000f070707070a070707070f0000000000000000000000000000000000000000000000000000000f0b0b0000000062000a0a0005000000000b0b0e00000100250021000707212121210721000c0c00000f030303030303030303030303030303030303031313
0000000000000000000000250005060001000025002500010100000d070708070707074a07070600000000000000000000000000000000000025252500000000000e0b0b0001010000000a590068212121040b0b0f00000100250021000000030303030000000b0b0a000f000000000000000000000000000000000000011212
0000040421212121040400250004040001000000000000000100000f070707074a07070707070606000600060006000600060006000000000731313106060000000f0b0b00000000004a00000000010100000b0b0e0000010025000a21210a212121210a21210a0a62000f000000000000000000250000000000250000016212
000064042121212164040025002121000f0f0f31313131310100000d07620707074a070707070600000000000000000000000000000000007831313105050000000e0b0b004a0000000000000000000000680b0b0f0000010000000000000003030303000000000000000f000000000000250000000000250000000000011111
4a0003030000000021210025002121000f0f0f00000000040100000f0707070707070707070f0000000000000000000000000006000000000000000000000000000f0b7800000101014900000001000000000b0b0e0000010000000000000003252503000000000000000f000000000000000000000000000000000000000000
000021210025250021210000002121000f0f0f00000068680100000d074a070707070707070d0000000000000000000000000000000000000202000404000000000e0b0b00780000000000000062004a00000b0b0f0000010000000a00000003252503000000000000000f0f0c0c0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f
__sfx__
010100000a1150c1150f115161151e607240011d00125001280010060100601000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200000e7570f7570f7571075710757117571375716757197571e75722757000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0002000005057030570305703057030570505707057090570b0570c0570f057120501305000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01040000077560a7560c7560e7561175615756187561b7561f7562275625756277562875600706007060000600000000000000000000000000000000000000000000000000000000000000000000000000000000
010100000d4530b4540a4510945109451094510a4510b4510d4510f45113451174511c451224512b4513045100000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000262572625725257222571e257152570f2570f2570e2570e2570f25712257172571c25722257262572a2572c2572b25729257282572725726257000000000000000000000000000000000000000000000
010100002905428051280512705127051270510135101351110511105111051100511005110051100510e0510e0510e0510e0510e0510e0511d05325053000010000000000000000000000000000000000000000
010100002905428051280512705127051270510135101351110511105111051100511005110051100512e0512e05120051200512e0512e05120051200512e0512e05120051200512e0512e0512c0512c05132000
011000000c332003021f30211332133321a3020c332003021d30200302113321c30213332003020f3320030211332003020030213332113321a3020f332003020030200302113321c3020f352003021135200302
011000000c250002001c2000f250112501a2000a2500020000200002000f2551c2050c2550020000200002001125000200002001c2050f2500020018200002000c25000200132051c20507250002000020000200
001000000f760007001c70013760167601a70018760007000070000700187601c7001676000700137600070016760007000070015700137601a70010700007001176000700117001c7000f760007000e70000700
011000000435300303003030435304353003030030304353043030435304353003030435300303003030030304353003030030304353043530030300303043530430304353043530030304353003030030300303
010100002e5562b55627556225561d5561855616556115561155600100001002700029000240002200022000000000000029000270001f0001f0001f000000002200027000290002b00000000000000000000000
__music__
01 080b4344
00 0a0b4344
00 080b4344
00 0a0b4344
00 08424344
00 0a424344
00 410b4344
02 410b4344

