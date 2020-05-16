pico-8 cartridge // http://www.pico-8.com
version 27
__lua__
// main game

function _init()
 game_screen=create_screen(
 	create_game,
	 update_game, 
	 draw_game)
	 
	music(0)
	 
	current_screen=game_screen
end

// screens
current_screen=nil

function create_screen(i,u,d)
 local screen={}
 i(screen)
 screen.update=u
 screen.draw=d
 return screen
end

sin_time=0
dt=0.01667
//dt=0.03333

function _update60()
//function _update()
 sin_time+=dt
 if sin_time>100 then
  sin_time-=100
 end
 if current_screen then
  current_screen.update(current_screen)
 end
end



function _draw()
 cls()
 
 if current_screen then
  current_screen.draw(current_screen)
 end
 
 
end
-->8

camerax=0
cameray=0
camerazone=nil

map_anim_time=0

rooms={}
current_room=nil

function create_game(s)
 // setup game screen stuff
 init_particles(64)
 init_lfx(64)
 create_player(28,0)
 player.standby=true
 player.x=55*8
 player.y=26*8
 player.flame.x=player.x
 player.flame.y=player.y 
 //create_player(115*8,2*8)
 //create_player(31*8,34*8)
 //create_player(13*8,35*8)
 camerax=48*8
 cameray=16*8
 refresh_room() 


 s.shadow=0
 s.shadowtime=5
 
 s.time=0
 s.timing=true
end

function room_key(rx,ry)
 return (ry*16+rx)+1
end

was_new=false
function refresh_room()
 local rx=flr(camerax/128)
 local ry=flr(cameray/128)
 local key=room_key(rx,ry)
 // created room already?
 if rooms[key]!=nil then
  current_room=rooms[key]
  was_new = false
 else
	 was_new=true
	 if player.standby==false then
		 room_whisper+=1
		 if room_whisper>=whisp_loc[whisp_loc_i] then
		  whisper()
		  whisp_loc_i+=1
		 end
		end
  current_room={}
  current_room.flames={}
  add(current_room.flames,player.flame)
  current_room.things={}
  add(current_room.things,player)
  // create stuff
	 
	 // special
	 //powerup
	 if rx==4 and ry==0 then
	  create_powerup(72*8,11*8)
	 end
	 
	 for x=0,16 do
	  for y=0,16 do
	   local mx=rx*16+x
	   local my=ry*16+y
	   local t=mget(mx,my)
	   
	   // flames
	   if t==16 then
		   create_flame_source(mx*8+4,my*8+4,current_room.flames)
		   mset(mx,my,50)
		  end
		  
		  // sprongs
		  if t>=59 and t<=62 then
		   create_spring(mx*8+4,my*8+4,t)
		  end
		  
		  // convayers
		  if t==36 or t==39 then
		   create_convayer(mx,my,t==39)
		  end
		  
		  // checkpoint
		  if t==112 then
		   local ch={}
		   ch.x=mx*8+8
		   ch.y=my*8
		   current_room.checkpoint=ch
		  end
		  
		  // eyeballs
		  if t==086 then
		   create_eyeball(mx*8,my*8)
		  end
		  
	  end
	 end
	 rooms[key]=current_room

 end
 
 // update thing list
 flame_sources=current_room.flames
 things=current_room.things
end

show_checkpoint=false
starting=false

function update_game(s)

 show_checkpoint=false
 
 map_anim_time+=dt
 if map_anim_time>0.05 then
  animate_map()
  map_anim_time-=0.05
 end
 
 if player.standby then
  player.dc=2
  player.flame.tpow=1
  if starting==false then
   if btn(4) then
	   starting=true
	   sfx(4)
	  end
  else
   s.shadow+=dt*4
   if s.shadow>=s.shadowtime then
    s.shadow=0
    player.standby=false
    starting=false
    player.x=player.respawnx
    player.y=player.respawny
    player.flame.x=player.x
    player.flame.y=player.y
    player.wrapwarped=true
    update_lfx()
   end
  end
 else
 
	 if (player.flame.pow<=0.2) and player.dead==false and player.showtime==false then
	  s.shadow+=dt
	  s.shadow=min(s.shadowtime,s.shadow)
	 else
	  s.shadow*=0.9
	 end
	 
	 if player.showtime then
	  s.shadow=0
	 end
	 if s.shadow>=s.shadowtime and player.dead==false then
	  kill_player()
	 end
	end


 update_the_show()
	update_things()
	update_collapsers()
	update_flame_sources()
	update_lfx()
	update_pfx()
	update_whisper()
	
	// camera
	local cx=flr(player.x/128)*128
	local cy=flr(player.y/128)*128
	if cx!=camerax or cy!=cameray then
	 camerax=cx
	 cameray=cy
	 refresh_room()
	end
	
	update_message()
	
 if	s.timing then
	 s.time+=dt
	else
	 
	end
	
end

function draw_game(s)
 // draw base
 
 if screen_shake then
	 camera(camerax+sin(sin_time*4)*2,cameray+sin(sin_time*4.4)*2)
	else
 	camera(camerax,cameray)
	end

 if player.showtime then
  pal()
  draw_the_show()
 elseif player.can_slide then
  pal_dark()
 else
		pal_vdark()
	end
 map(camerax/8,cameray/8,camerax,cameray,16,16)
// pal()
 
 if player.showtime==false then
 // draw light (low)
 	pal_dark()
 	draw_light(player.flame.x,player.flame.y,player.flame.l*player.flame.pow)
 
 	// green checkpoint light
 	if current_room.checkpoint then
 	 pal_green()
 	 draw_light(current_room.checkpoint.x,current_room.checkpoint.y,16)
 	end
 
 	// draw lights (high)
 	pal()
 	for l in all(flame_sources) do
 	 draw_light(l.x,l.y,l.l*l.pow*0.8)
 	end
 end
 
 draw_lfx()
 draw_flame_sources()
 draw_things()
 draw_pfx()
 
 if player.showtime == false and s.shadow>0 then
	 draw_shadow(s.shadow,s.shadowtime)
	end

 // debug stuff
 camera()
 draw_message()
 draw_whisper()
 
 if player.standby then
  local tcs={4,9,10}
  local tc=tcs[flr(abs(sin(sin_time)*#tcs))+1]
  printo("solais",64-3*4,24,tc,1)
   printo("by malcolm brown",64-8*4,98,9,0)
   printo("for ld46",64-4*4,106,5,0)
   if starting==false then
	   printo("press z to begin",64-8*4,64,tc,0)
	  end
 end
 
 if stage!=nil and stage==7 then
  local t=current_screen.time
  local mins=flr(t/60)
  local secs=flr(t)%60
  
  if secs<10 then
   print("time: "..mins..":0"..secs,32,96,10)  
  else
   print("time: "..mins..":"..secs,32,96,10)  
  end

 end
end

function draw_light(ilx,ily,ilr)
 local lx=round(ilx)
 local ly=round(ily)
 local lr=ilr
 local hlr=lr/2
 local lsx=lx-lr
 local lsy=ly-lr
 local p=0
 for y=ly-lr,ly+lr do
  // scanline circle!
	 local vx=sqrt((lr*lr)-((y-ly)*(y-ly)))
  local lx1=round(lx-vx+0.5)
  local lx2=round(lx+vx+0.5)
  tline(lx1,
  						y,
  						lx2,
  						y,
  						lx1/8,y/8,1/8,0)
  						
  p+=(1/lr * 0.25)
 end
end

function pal_vdark()
 pal(1,0)
 pal(2,0)
 pal(3,0)
 pal(4,1)
 pal(5,0)
 pal(6,1)
 pal(7,1)
 pal(8,1)
 pal(9,1)
 pal(10,2)
 pal(11,0)
 pal(12,0)
 pal(13,1)
 pal(14,1)
 pal(15,2)
end

function pal_dark()
 pal(1,0)
 pal(2,1)
 pal(3,1)
 pal(4,2)
 pal(5,1)
 pal(6,5)
 pal(7,5)
 pal(8,2)
 pal(9,2)
 pal(10,4)
 pal(11,1)
 pal(12,1)
 pal(13,1)
 pal(14,2)
 pal(15,4)
end

function pal_green()

 pal(1,1)
 pal(2,1)
 pal(3,3)
 pal(4,3)
 pal(5,3)
 pal(6,11)
 pal(7,10)
 pal(8,11)
 pal(9,3)
 pal(10,10)
 pal(11,11)
 pal(12,11)
 pal(13,3)
 pal(14,3)
 pal(15,11)             
end 

function pal_outline(c)
 for i=0,15 do
  pal(i,c)
 end
end

function round(x)
 if x-flr(x)>=0.5 then return ceil(x) else return flr(x) end
end

wooble_time=0

function animate_map()
 local show_wooble=false
 wooble_time+=dt
 if wooble_time>=0.05 then
  show_wooble=true
  wooble_time-=0.05
 end
 
 for x=0,16 do
  for y=0,16 do
   local tx=flr(camerax/8)+x
   local ty=flr(cameray/8)+y
   local t=mget(tx,ty)
   
   // waterfall
   if t>=32 and t<=35 then
    mset(tx,ty,t==35 and 32 or t+1)
   elseif t>=40 and t<=45 then
   // water
    mset(tx,ty,t==45 and 40 or t+1)   
   elseif show_wooble and t>=112 and t<=113 then
    create_pfx(
     tx*8+rnd(8),ty*8,
     pfx_wooble,0.5,
     rrnd(0.1),-rnd(0.2),
     0,-0.001)
   // checkpoint
   end
   
  end
 end
end

function draw_shadow(s,st)
 pal(1,0)
 
 local p=s/st
 local r=168*(1-p)
 local lx=player.x-r
 local rx=player.x+r
 local uy=player.y-r
 local by=player.y+r
 
 //top
 rectfill(player.x-128,player.y-128,player.x+128,uy,1)

 //bot
 rectfill(player.x-128,by,player.x+128,player.y+128,1)
 // left
 rectfill(player.x-128,player.y-128,lx,player.y+128,1)
 // right
 rectfill(rx,player.y-128,player.x+128,player.y+128,1)

 // circle
 sspr(16,32,32,32,lx-1,uy-1,r*2+2,r*2+2)
 pal()
end

function printo(t,x,y,c,co)
 print(t,x-1,y,co)
 print(t,x+1,y,co)
 print(t,x,y-1,co)
 print(t,x,y+1,co)
 print(t,x,y,c)    
end

-->8
// player movement + general entity stuff

things={}
player=nil
grav=0.05
//grav=0.1

function create_player(x,y)
 player=create_thing(x,y,
  update_player,
  draw_player)
 
 // player setup
 player.s=1
 player.fx=false
 player.landed=false
 player.vy=0
 player.vx=0
 player.ax=0.25
 player.maxvxnat=1
 player.maxvx=10
 player.maxvy=10
 player.j=1.2
 player.ctime=0 // coyote time!
 player.ctimemax=0.2
 
 // animation
 player.f_i={1} // idle
 player.f_w={2,3,4,3} // walk
 player.f_j={5} // jump
 player.f_f={6} // fall
 player.f_l={7} // land
 player.f=player.f_i
 player.ft=0
 player.ff=0
 player.fps=0.15
 
 player.sx=1
 player.sy=1
 
 player.dead=false
 player.respawnx=x
 player.respawny=y
 player.respawn_time=0
 player.respawn_time_max=2
 player.respawn_anim=0
 
 player.outline=0

 // player flame
 player.flame=create_flame_source(player.x,player.y)
 player.flame.s=8
 player.flame.r=32
 player.flame.fx=false
 player.flame.outline=0
 player.flame.pow=1
 player.flame.pfall=0.002
 
 player.convayed=false
 player.showtime=false
 
 player.line_t=0
 
 player.can_slide=false
 player.wslidedx=0
  
 // frames disable controls
 player.dc=0
 
 // light
 player.lr=16
 
 return player
end

function update_player(p)

 if p.dead then
  local dfs={12,28}
  p.s=dfs[flr(sin_time*4)%2+1]
  p.sx=1
  p.sy=1
  p.vx+=grav*0.5
  p.y-=abs(p.vx)
  if p.y<cameray then
  	p.dead=false
  	p.x=p.respawnx
  	p.y=p.respawny
  	p.vx=0
  	p.vy=0
  	p.flame.tpow=1
  	p.flame.x=p.x
  	p.flame.y=p.y
  	sfx(4)
   // respawn time.
  end
  return
 end
 
 if p.disabled then
  return
 end
 
 local controls=true
 if p.dc>0 then
	 p.dc-=1
	 controls=false
	end
 
 local dx=0
 if controls then
	 if btn(0) then dx=-1
	 elseif btn(1) then dx=1
		end
 end
 
 if dx!=0 then
  p.fx=dx<0
  if abs(p.vx)<p.maxvxnat or sgn(p.vx)!=dx then
	  p.vx+=dx*p.ax
	 end
  p.f=p.f_w // walk anim
 elseif controls then
  p.f=p.f_i // idle
  // decel
  if p.vx>0 then
   p.vx=max(0,p.vx-p.ax*0.5)
  elseif p.vx<0 then
   p.vx=min(0,p.vx+p.ax*0.5)  
  end
 end
 
 p.vx=max(min(p.maxvx,p.vx),-p.maxvx)
 p.x+=p.vx
 // wall collision
 collide_walls(p)
 
 // falling
 if p.landed==false then
  local ay=grav
  if p.wslidedx != 0 and p.vy>0 then
   ay*=0.25
   spawn_dust_pfx(p.x-p.wslidedx*4,p.y)
  end
  p.vy+=ay
  p.ctime=min(p.ctime+dt,p.ctimemax)
  if p.vy<-0.5 then
   p.f=p.f_j // jump anim
  elseif p.vy>0.5 then
   p.f=p.f_f // fall anim
  else
   p.f=p.f_i // idle 
  end
 else
  p.ctime=0
  p.vy=0
 end
 
 // wall-sliding
 if not p.landed and p.vy>0.1 and p.wslidedx != 0 and btn(4) and controls then
   p.vy=-p.j
   p.vx=p.wslidedx*1.5
	  p.y-=1
	  p.x+=p.wslidedx*2
	  p.ctime=p.ctimemax
	  squish(p,0.5,1.5)
	  sfx(0)
 else
	 // normal jomping!
	 
	 if (p.landed or p.ctime<p.ctimemax) and btn(4) and controls then
	  spawn_dust_cloud(p.x,p.y+4,3)
	  p.vy=-p.j
	  p.y-=2
	  p.ctime=p.ctimemax
	  squish(p,0.5,1.5)
	  sfx(0)
	 end
 end
 
 
 
 p.vy=max(min(p.maxvy,p.vy),-p.maxvy)
 p.y+=p.vy
 
 // wrapwarp
 p.wrapwarped=false
 if p.y>=512 then
  p.y-=512
  p.x+=128
  p.flame.x=p.x
  p.flame.y=p.y
  p.wrapwarped=true
 end
 
 p.convayed=false
 collide_floors(p)
 collide_ceiling(p)
 
 collide_things(p)
 
 // special tiles
 local mapt=mget(flr(p.x/8),flr(p.y/8))
 if fget(mapt,1) then
  if p.flame.tpow>0 then
   sfx(6)
  end
  p.flame.tpow=0
  spawn_splash_pfx(p.x,p.y-4,1)
 end
 
 // kicking off the ending
 if p.showtime==false and p.landed and flr(p.x/128)==7 and flr(p.y/128)==3 then
  begin_the_show()
 end
 
 
 // animate your arse
 animate(p)
 
 // move the flame source
 p.flame.x+=((p.x+(p.fx and 3 or -2))-p.flame.x)*0.4
 p.flame.y+=(p.y-p.flame.y)*0.4
 
 // flame line trail
 p.line_t+=dt
 if p.line_t >= 0.1 then
  create_lfx(p.flame.x,p.flame.y,
   lfx_flame,
   0.7*p.flame.pow,
   rrnd(0.01),-rnd(0.01),
   rrnd(0.01),-0.01)
   p.line_t-=0.1
 end
 
 // check flame source collisions
 local ftx0=flr(p.x/8)
 local fty0=flr(p.y/8)
 for f in all(flame_sources) do
  if f != p.flame and f.active then
   local ftx1=flr(f.x/8)
   local fty1=flr(f.y/8)
   if ftx0==ftx1 and fty0==fty1 then
    // relight
    if p.flame.tpow<0.9 then
     sfx(5)
    end
    p.flame.tpow=1
    
   end
  end
 end

end

function collide_things(t)
 for o in all(things) do
  if o!=t and o.active and o.collide then
   // 
   local lx=flr((t.x-4)/8)
   local rx=flr((t.x+4)/8)
   local uy=flr((t.y-4)/8)
   local by=flr((t.y+4)/8)
   local otx=flr(o.x/8)
   local oty=flr(o.y/8)
   if (otx==lx or otx==rx) and
      (oty==uy or oty==by) then
    o.collide(o,t)
   end
  end
 end
end

function animate(t)
	if t.ft!=nil then
 	t.ft+=t.fps
	 t.ft=t.ft%(#t.f)
	 t.ff=flr(t.ft)
	 t.s=t.f[t.ff+1]
	end
 
 // animate squish
 t.sx=move_to(t.sx,1,0.05)
 t.sy=move_to(t.sy,1,0.05)
end

function move_to(s,d,v)
 if s>d then
  return max(d,s-v)
 elseif s<d then
  return min(d,s+v) 
 end
 return d
end

function squish(t,sx,sy)
 t.sx=sx
 t.sy=sy
end

function draw_player(p)
 draw_spriteso(p)
 
 // draw torch
 draw_spriteo(p.flame)
end


// collision
function collide_floors(t)
 local tx=t.x
 local ty=t.y+5
 local hit=collide_solid(tx,ty)
 if hit and (t.landed or t.vy>=0) then
  t.y=flr(ty/8)*8-5
  if t.landed==false then
   squish(t,1.5,0.5)
   spawn_dust_cloud(t.x,t.y+4,3)
   sfx(1)
  end
  local mtx=flr(tx/8)
  local mty=flr(ty/8)
  // spikes
  if mget(mtx,mty)==55 then
   kill_player()
  // collapsers
  elseif fget(mget(mtx,mty),4) then
   start_collapse(mtx,mty)
  // checkpoint
  elseif mget(mtx,mty)==112 or mget(mtx,mty)==113 then
   local rx=flr(mtx/16)
   local ry=flr(mty/16)
   if t.lastrespawnx!=rx or t.lastrespawny!=ry then
    show_message("checkpoint")
    t.lastrespawnx=rx
    t.lastrespawny=ry
    sfx(2)
   end
   
   t.respawnx=t.x
   t.respawny=t.y
   t.flame.tpow=1
   show_checkpoint=true
  elseif mget(mtx,mty)>=36 and mget(mtx,mty)<=39 then
   // get convayer thing
   for ot in all(things) do
    if ot.convayer and ot.tx==mtx and ot.ty==mty then
     t.x+=(ot.f and -0.5 or 0.5)
     t.convayed=true
    end
   end
  end
  // 
  t.landed=true
  
 else 
  t.landed=false
 end
end

function collide_walls(t)
 local txl=t.x-4
 local txr=t.x+4
 local ty=t.y
 
 t.wslidedx=0
 
 if collide_solid(txl,ty,3) then
  t.x=flr(txl/8)*8+12
  local ml=mget(txl/8,ty/8)
  if ml==57 and (t.vx<0 or t.convayed) then
   kill_player()
  end
  t.vx=0
  if t.can_slide then
   t.wslidedx=1
  end
 elseif collide_solid(txr,ty,3) then
   
  t.x=flr(txr/8)*8-4
  local mr=mget(txr/8,ty/8)
  if mr==56 and (t.vx>0 or t.convayed) then
   kill_player()
  end
  t.vx=0
  if t.can_slide then
   t.wslidedx=-1
  end
 end
end

function collide_ceiling(t)
 local tx=t.x
 local ty=t.y-4
 local hit=collide_solid(tx,ty,3)
 if hit then
  t.vy=0
  t.y=flr(ty/8)*8+12
 end
end

function collide_solid(x,y,im)

 local tile=mget(flr(x/8),flr(y/8))
 local f=fget(tile,0)
 if im!=nil and fget(tile,im)==true then
  return false
 else
	 return f
	end
end



// sprite drawing
function draw_sprite(s)
 spr(s.s,s.x-4,s.y-4,1,1,s.fx,s.fy)
end

function draw_spriteo(s)

 // outline
 pal_outline(s.outline)
 for dx=-1,1 do
  for dy=-1,1 do
   if abs(dx+dy)==1 then
	   spr(s.s,s.x-4+dx,s.y-4+dy,1,1,s.fx,s.fy)
	  end
  end
 end
 
 pal()
 spr(s.s,s.x-4,s.y-4,1,1,s.fx,s.fy)
end

function draw_spriteso(s)
// outline

 local sx=(s.s*8)%128
 local sy=flr(s.s/16)*8
 local sw=8
 local sh=8
 local w=8*s.sx
 local h=8*s.sy
 local hw=w/2
 local hh=h/2
 local oy=-hh+sh/2

 pal_outline(s.outline)
 for dx=-1,1 do
  for dy=-1,1 do
   if abs(dx+dy)==1 then
				sspr	(sx,sy,sw,sh,s.x-hw+dx,s.y-hh+dy+oy,w,h,s.fx,s.fy)   
	  end
  end
 end
 
 pal()
	sspr	(sx,sy,sw,sh,s.x-hw,s.y-hh+oy,w,h,s.fx,s.fy)   
end



// thing stuff

function create_thing(x,y,u,d,ta)
 local t={}
 t.u=u
 t.d=d
 t.x=x
 t.y=y
 t.fx=false
 t.fy=false
 t.sx=1
 t.sy=1
 t.active=true
 if ta==nil then
	 add(things,t)
	else
	 add(ta,t)
 end
 return t
end

function update_things()
 for t in all(things) do
  if t.active and t.u then
	  t.u(t)
	 end
 end
end

function draw_things()
 for t in all(things) do
  if t.active and t.d then
	  t.d(t)
	 end
 end
end

// ---- deaaaaath ----
function kill_player()
 player.dead=true
 player.vx=-1
 spawn_sparkles(player.x,player.y)
 sfx(3)
end

function respawn_player()

end
-->8
// particles

pfx={}
pfx_next=0

// line fx
lfx={}
lfx_next=0

lfx_flame={7,10,9,4,2}

pfx_flames={17,18,19,20,21}
pfx_dust={22,23,24,25}
pfx_sparkles={80,81,96,97}
pfx_splash={70,71,72,73}
pfx_wooble={120,121,122}

// flame sources
flame_sources={}

function init_particles(c)
 for i=0,c do
  local p={}
  p.x=0
  p.y=0
  p.vx=0
  p.vy=0
  p.ax=0
  p.ay=0
  p.l=0
  p.t=0
  p.active=false
  
  // anim
  p.f=nil
  add(pfx,p)
 end
 
end

function create_pfx(x,y,f,l,vx,vy,ax,ay)
 local p = pfx[pfx_next+1]
 p.active=true
 p.t=0
 p.l=l
 p.x=x
 p.y=y
 p.vx=vx
 p.vy=vy
 p.ax=ax
 p.ay=ay
 p.f=f
 p.fx=rnd(1)>0.5
 p.fy=rnd(1)>0.5
 
 pfx_next=(pfx_next+1)%(#pfx)
end

function create_flame(x,y)
  create_pfx(x,y,
   pfx_flames,
   1,
   rrnd(0.125),-rnd(0.15),
   0.0, -0.005)
end

function rrnd(x)
 return rnd(x)-rnd(x)
end

function update_pfx()
 for p in all(pfx) do
  if p.active then
   p.t+=0.01667
   
   if p.t>p.l then
    p.active=false
   else
    p.vx+=p.ax
    p.vy+=p.ay
    p.x+=p.vx
    p.y+=p.vy
    
    local pt=min(1,p.t/p.l)
    local ft=flr(pt*(#p.f))
    p.ff=p.f[ft+1]
   end
  end
 end
end

function draw_pfx()
 for p in all(pfx) do
  if p.active then
   spr(p.ff,p.x-4,p.y-4,1,1,p.fx,p.fy)
  end
 end
end

// particle_source
function create_flame_source(x,y,t)
 local s={}
 s.x=x
 s.y=y
 s.t=0
 s.r=24
 s.l=s.r
 s.tl=s.r
 s.tt=0
 s.active=true
 s.pow=1
 s.tpow=1
 s.pfall=0
 s.s=16
 s.outline=0
 if t==nil then
	 add(flame_sources,s)
	else
	 add(t,s)
	end
 return s
end

function update_flame_sources()
 local hz=0.1
 for s in all(flame_sources) do
  // particles
  s.t+=0.01667*s.pow
  
  s.tpow-=s.pfall
  s.tpow=max(0,s.tpow)
  s.pow+=(s.tpow-s.pow)*0.1
   
  if s.t>hz then
   s.t-=hz
   create_flame(s.x,s.y)
  end
  
  //if s.pfall != 0 then
   
  //end

  
  // light
  s.tt+=dt
  if s.tt>0.1 then
   s.tt-=0.1
   s.tl=s.r+rrnd(1.5)*s.pow
  end
  s.l+=(s.tl-s.l)*0.1
 end 
end

function draw_flame_sources()
 for f in all(flame_sources) do
  if f.active and f!=player.flame then
   draw_spriteo(f)
  end
 end
end

// light fx
function init_lfx(c)
 for i=0,c do
  local l={}
  l.x0=0
  l.x1=0
  l.y0=0
  l.y1=0
  l.l=0
  l.t=0
  l.ct=nil
  l.c=0
  l.active=false
  l.th=1
  add(lfx,l)
 end
end

function create_lfx(x0,y0,c,li,vx,vy,ax,ay)
 local l = lfx[lfx_next+1]
 l.active=true
 l.t=0
 l.l=li
 l.x=x0
 l.y=y0
 l.vx=vx
 l.vy=vy
 l.ax=ax
 l.ay=ay
 l.ct=c
 l.c=l.ct[1]
 
 lfx_next=(lfx_next+1)%(#lfx)
end

function update_lfx()
 for l in all(lfx) do
  if l.active then
   l.t+=dt
   if l.t>=l.l then
    l.active=false
   else
    local pt=min(1,l.t/l.l)
    local ft=flr(pt*(#l.ct))
    l.c=l.ct[ft+1]
    
    // add noise to points?
    l.vx+=l.ax
    l.vy+=l.ay
    l.x+=l.vx
    l.y+=l.vy
    
    if player.wrapwarped then
     l.x+=128
     l.y-=512
    end
   end
  end
 end
end

function draw_lfx()
 local count=#lfx
 for i=0,count do
  local l=lfx[i+1]
  if l and l.active then
   // start
   for j=0,128 do
    local p0=lfx[((i+j+0)%#lfx)+1]
    local p1=lfx[((i+j+1)%#lfx)+1]
    if p1.active then
     line(p0.x,p0.y,p1.x,p1.y,p0.c)
     line(p0.x,p0.y-1,p1.x,p1.y-1,p0.c)
    else
     return
    end
   end

  end
 end
end

// function dust
function spawn_dust_cloud(x,y,n)
 for i=0,n do
  spawn_dust_pfx(x+rrnd(8),y)
 end
end

function spawn_dust_pfx(x,y)
 create_pfx(x+rrnd(2),y+rrnd(2),
   pfx_dust,
   1+rrnd(0.25),
   rrnd(0.125),0,
   0.0, -0.005)
end

// splash
function spawn_splish_pfx(x,y)
 create_pfx(x+rrnd(2),y+rrnd(2),
   pfx_splash,
   0.25+rnd(0.5),
   rrnd(0.2),rrnd(0.2),
   0.0,0.005)
end

function spawn_splash_pfx(x,y,n)
 for i=0,n do
  spawn_splish_pfx(x+rrnd(4),y+rrnd(4))
 end
end

// sparkles
function spawn_sparkle(x,y)
 create_pfx(x,y,
   pfx_sparkles,
   1,
   0,0,
   0.0,0.005)
end

function spawn_sparkles(x,y)
 for i=0,2,0.1 do
  local vx=sin(i)
  local vy=cos(i)
  create_pfx(x,y,
   pfx_sparkles,
   1,
   vx,vy,
   0.0,0.005)
 end
 
end
-->8
// springs


function create_spring(x,y,t)
 local dx=0
 local dy=-1
 if t==60 then
  dx=-1
  dy=0
 elseif t==61 then
  dy=1
 elseif t==62 then
  dx=1
  dy=0
 end
 
 local s=create_thing(x,y,update_spring,draw_spring,current_room.things)
 s.dx=dx
 s.dy=dy
 s.s=t
 s.collide=collide_spring
 mset(x/8,y/8,50)
end

function update_spring(s)
 animate(s)
end

function collide_spring(t,ot)
 // jump player
 spawn_dust_cloud(ot.x,ot.y+4,3)
 local dx=t.dx
 local dy=t.dy
 local sp=2
 ot.vy=dy*sp
 ot.vx=dx*sp
 ot.x+=dx*2
 ot.y+=dy*2
 ot.ctime=ot.ctimemax
 ot.dc=3
 squish(ot,0.5,1.5)
 sfx(8)
 // srpgin squish
 squish(t,dy!=0 and 1.5 or 0.5,dy!=0 and 0.5 or 1.5)
end

function draw_spring(s)
 draw_spriteso(s)
end

// collapses
collapsers={}



function start_collapse(tx,ty)
 for c in all(collapsers) do
  if c.tx==tx and c.ty==ty then
   return
  end
 end
 
 local c={}
 c.tx=tx
 c.ty=ty
 c.l=1
 c.active=true
 c.dustt=0
 c.respawn=false
 c.respawnt=0
 add(collapsers,c)
 sfx(9)
 
end

function update_collapsers()
 local rx=flr(player.x/128)
 local ry=flr(player.y/128)
 for c in all(collapsers) do
  if c.active then
   local crx=flr(c.tx/16)
   local cry=flr(c.ty/16)
   local same_room=rx==crx and ry==cry
   if c.respawn==false then
   	c.l-=dt
   
   	c.dustt+=dt
   	if c.dustt>0.1 then
   	 spawn_dust_pfx(c.tx*8+4,c.ty*8+4)
   	 c.dustt-=0.1
   	end
   
   	if c.l<=0 then
   	 // destroy tile
   	 mset(c.tx,c.ty,49)
   	 spawn_dust_cloud(c.tx*8+4,c.ty*8+4,6)
   	 c.respawn=true
   	  if same_room then
	   	  sfx(10)
	   	 end
   	 //del(collapsers,c)
   	end
   else
    c.respawnt+=dt
    if c.respawnt>5 then
     mset(c.tx,c.ty,54)
   	 spawn_dust_cloud(c.tx*8+4,c.ty*8+4,6)
     del(collapsers,c)
     if same_room then
      sfx(9)
     end
    end
   end
  end
 end
end

// convayers (invisible?)
function create_convayer(tx,ty,f)
 local s=create_thing(tx*8,ty*8,update_convayer,draw_convayer,current_room.things)
 s.f=f
 s.tx=tx
 s.ty=ty
 s.convayer=true
 local forw={36,37,38,39}
 local back={39,38,37,36}
 s.ff=s.f and back or forw
 s.ft=0
 s.sx=1
 s.sy=1

end

function update_convayer(c)
 c.ft+=dt*10
 local f=flr(c.ft)%#c.ff
 c.s=c.ff[f+1]
 mset(c.tx,c.ty,c.s)
end

function draw_convayer(c)
 //draw_sprite(c)
end

function create_powerup(x,y)
 local s=create_thing(x,y,update_powerup,draw_powerup,current_room.things)
 s.collide=collide_powerup
 s.s=26
 s.sx=1
 s.sy=1
 s.oy=y
 s.ox=x
end

function update_powerup(p)
 p.si=sin_time
 p.x=p.ox+sin(p.si*0.2)*4
 p.y=p.oy+sin(p.si*0.4+1.24)*4
end

function collide_powerup(p,po)
 // sparkles
 spawn_sparkles(p.x,p.y)
 po.can_slide=true
 p.active=false
 show_message("learned wall jump")
 sfx(7)
end

function draw_powerup(p)
 draw_spriteso(p)
end

// eyeballs!
function create_eyeball(x,y,a)
 local t=create_thing(x+4,y+4,update_eyeball,draw_eyeball,current_room.things)
 if a==nil then a=false end
 t.a=0
 t.wake=0
 t.outline=0
 t.sx=1
 t.sy=0
 t.s=86
 t.always=a
 if t.always == false then
 	mset(flr(x/8),flr(y/8),74)
 end
 return t
end

function update_eyeball(e)
 // check distance
 local p=player
 if e.always or (p.x>e.x-32 and
    p.x<e.x+32 and
    p.y>e.y-32 and
    p.y<e.y+32) then
   e.wake+=dt*5 
 else
   e.wake-=dt*5
 end
 
 e.wake=max(0,min(1,e.wake))
 e.sy=e.wake
 
 if e.wake>0 then
  e.a=atan2(p.y-e.y,p.x-e.x)
 end
end

function draw_eyeball(e)
 if e.wake>0 then
  draw_spriteso(e)
  
  local vx=sin(e.a)*3
  local vy=cos(e.a)*3-4
  spr(87,e.x+vx*e.wake-4,e.y+vy*e.wake)
 end
end
-->8
// whispers and checkpoints

whispers={
 "...who approaches...",
 "...my love...so near...",
 "...have they all forgotten...?",
 "...come to us...",
 "...you must save us...",
 "...do not look back, my love...",
 "...not long now...",
 "...we shall aid you...",
 "...we must sing...",
 "...my love...are you the last...?",
 "...then it is time...",
 "...thank you...",
 "..."
}

whisp_loc_i=1
// whisper locations
whisp_loc={
 1,
 2,
 5,//empty checkpoint
 7,//convayors
 9,//springs
 11,//top of pit
 13,// bottom of pit
 14,//  powerup room
 16,// descent start
 19,//final pit 
 22, // final room
 25,
 25,
}


// whispers

whisper_index=1
current_whisper=nil
current_whispert=0
room_whisper=0


function whisper()

 current_whisper=nil
 sfx(11)

 current_whispert=5
 current_whisper={}
 current_whisper.t=whispers[whisper_index]
 current_whisper.c={}
 
 local width=#current_whisper.t*5
 local x=64-width/2
 // create letters
 for i =0,#current_whisper.t do
  local c=sub(current_whisper.t,i,i)
  local ci={}
  ci.bx=x
  ci.by=32
  ci.x=ci.bx
  ci.y=ci.by  
  ci.c=c
  ci.vx=rrnd(1)
  ci.vy=rrnd(1)
  ci.t=1
  ci.o=rnd(1)
  add(current_whisper.c,ci)
  x+=5
 end
 
 whisper_index+=1
end

function update_whisper()
 if current_whisper!=nil then
  // animate time
  if current_whispert>0 then
   current_whispert-=dt*2
   
   local t=0
   if current_whispert>4 then
    local lt=(current_whispert-4)
    t=sin(lt*0.25)
   elseif current_whispert<1 then
    local lt=1-current_whispert
    t=sin(lt*0.25)
   end
   
   // update letters
   for c in all(current_whisper.c) do
    c.t=min(1,max(0,abs(t)))
    c.x=c.bx+c.vx*t*64+sin(sin_time*0.91+c.o)*0.5
    c.y=c.by+c.vy*t*64+sin(sin_time*1.07+c.o)*0.5
   end
  else
   current_whisper=nil
  end
  
 end
end

function draw_whisper()
 if current_whisper!=nil then
  local cols={7,6,5,1}
  for c in all(current_whisper.c) do
   local co=cols[flr((c.t)*#cols)+1]
   
   print(c.c,c.x,c.y,co)
  end
  
  //print(current_whisper.t,8,8,7)
 end
end
// text messages
c_mess=""
c_messtime=0

function show_message(t)
 c_mess=t
 c_messtime=5
 
end

function update_message()
 if c_messtime>0 then
  c_messtime-=dt*3
 end
end

function draw_message()
 local x=64-(#c_mess*4)*0.5
 local y=0
 if c_messtime>0 then
  // sliding in
  if c_messtime>=4 then
   y=128-cos((c_messtime-4)*0.25)*32
  elseif c_messtime<=1 then
   y=128-cos((1-c_messtime)*0.25)*32
  else
   y=96
  end
  local c=10
  if (flr(sin_time*10))%2==0 then
   c=7
  end
  for dx=-1,1 do
   for dy=-1,1 do
    print(c_mess,x+dx,y+dy,0)
   end
  end
  
  
  print(c_mess,x,y,c)
 end
 

end
-->8
// final cutscene

//stages={
// 0,//cut_to_position,
// 1,//cut_eyeballs,
// 2,//cut_big_eyeball,
// 3,//cut_teeth_fade_in,
// 4,//cut_teeth_chomp,
// 5,//cut_thanks

stage=nil
function begin_the_show()
 player.showtime=true
 stage=0
end

stage_time=0
eyeball_time=0

function update_the_show()
 if player.showtime then
  player.dc=5
  stage_time+=dt
  
  // part one, get into position
  if stage==0 then
   local tx=120*8
   if player.x<tx-2 then
    player.vx=1
   elseif player.x>tx+2 then
    player.vx=-1   
   else
    player.vx=0
    stage=1
    stage_time=0
    player.disabled=true
   end
   animate(player)
  
  //player rise + eyeballs
  elseif stage==1 then
   player.sx=1
   player.sy=1
   local p=stage_time/5
   player.y=60.5*8+sin(p*0.25)*32
   player.s=stage_time<2.5 and 5 or 13
   if stage_time<0.5 then
   	local ft=stage_time*2
   	player.flame.y=60.5*8-sin(ft*0.25)*4
   end
   if stage_time>=5 then
    stage_time=0
    stage=2
   end
   
   eyeball_time+=dt
   if eyeball_time>0.5 then
    eyeball_time=0
    local left=rnd(1)>=0.5
    local ex=player.x+(left and -48 or 48)
    local ey=54*8
    local e=create_eyeball(ex+rrnd(4),ey+rrnd(58),true)
   end
   
  elseif stage==2 then
   // eye open
   screen_shake=true
   if stage_time>=2 then
    stage_time=0
    stage=3
   end
   
   
   // just chillin'
  elseif stage==3 then
   screen_shake=false
   if stage_time>2 then
    stage=4
    stage_time=0
   end
  
  // teeth appear
  elseif stage==4 then
   if stage_time>5 then
    stage=5
    stage_time=0
   end
  // chomp
  elseif stage==5 then
   if stage_time>=0.4 then
    player.sx=0
    player.sy=0
   end
   if stage_time>=0.5 then
    stage=6
    stage_time=0
   end
  elseif stage==6 then
  
    player.x=108*8
    if stage_time>2 then
     whisper()
     current_screen.timing=false
     stage=7
     stage_time=0
    end
   // end
  elseif stage==7 then
   if stage_time>5 then
    run() // restart
   end
  end
 end
end

function draw_the_show()
 if stage>=2 then
  local sx=(stage==2 and stage_time/2 or 1)
  local ssx=(102*8)%128
  local ssy=flr(102/16)*8
  sspr(ssx,ssy,
     16,16,
     120*8-8*sx,50*8,
     16*sx,16)
     
  local esx=(104*8)%128
  sspr(esx,ssy,
       8,8,
       120*8-4*sx,51*8,
       8*sx,8)
 end
 
 if stage >=4 then
  
  if stage==4 then
   local pt=min(1,max(0,stage_time/3))
   if pt<0.5 then
    pal_vdark()
   elseif pt<1 then
    pal_dark()
   else
    pal()
   end
  else
   pal()
  end
  
  local tx=120*8
  local uty=56*8
  local lty=56*8
  if stage==4 then
   local off=min(1,max(0,stage_time/3))
   uty+=sin(off*0.25)*16
   lty-=sin(off*0.25)*16
  elseif stage==5 then
   local off=1-min(1,max(0,stage_time/0.5))
   uty+=sin(off*0.25)*16
   lty-=sin(off*0.25)*16
  end
  // upper teef
  spr(89,tx-16,uty,2,2,false,false)
  spr(89,tx,uty,2,2,true,false)
  // lower teef
  spr(89,tx-16,lty,2,2,false,true)
  spr(89,tx,lty,2,2,true,true)
  pal()
 end
 
 //if stage==7 then

 //end
end
-->8
// title screen


__gfx__
0000000002888880000000000228888000000000028888800288888000000000000000002aa12221aaaaaaa7244424440dddddd00288888099a919aa44444444
0000000022888e880228888022888e880228880002888e8822888e880288888000000000999a42aa499999aa12241224dddddddd02888e882444144922222224
007007002288888822888e882288888822888e802281ff18e288888e22888e8800000000a44219994999999a12241224dddddddd228888881222142922111224
00077000ef81ff1822888888ef81ff18288888882f8ffff8ef8888882288888800040000992124444999999a1112111277d1771dff8888ff1111211122111224
000770002e8effe82ef81ff82e8effe8ef81ff882e8eeee82e81ff18ef81ff1800ff0000422244122999999a24442444d7d7777d2e8888e8aa9aa99a22222224
007007000281502822e8eff8028152282e8eff88e2815028028440282e8effe800ee0000229aa9914999999a122412240dd770dd228888224244224421111124
0000000000215002022812280021502202815282222150220021500202815028000200001299a4422499999a1224122470d7700d022888201111111121111124
00000000001001000010012000011000002001200010100200010100002101020000000021144421221221121112111207770000002010200000000022222224
00000000000000000000000000090000004400000002000000000000000000000000000000000000001288000000000000000000888088881222222222222224
0422224000000000000a00000099900000044000000020000000000000000000000100000000100001887e8099a799aa0dddddd0808080081211111221121124
09a99a90000aa000009aa00000499900000024000000000000000000000220000010100000000000188877e842244224dddddddd888080081211111221121124
0094490000a77a00009aa90000044900000002000000000000044000002022000101010001000000288e277811111111dddddddd800088881211111222221124
0012410000977900000999000000040000000000000000000004400000222000001010100000000082278ee81221122177d1771d000000001211222221111124
001421000009900000009000000000000000000000000000000000000000200000010100000000108122ee8211111111d7d7777d888808881211211221111124
000110000000000000000000000000000000000000000000000000000000000000001000000100000812e820122112210dd770dd800800801222222222222224
0000000000000000000000000000000000000000000000000000000000000000000000000000000000888200111111117777700d888800801111111111111112
7cccc7777cccccc77c77ccc777cc7cc766556655566556655566556665566556770000707000070700770770077070007007700707700007cccccccc24444444
77cc7cc77cccc7777cccccc77c77ccc701100110001000100110011001000100cc7707c7c7777c7c77cc7cc77cc7c707c77cc77c7cc7707ccccccccc12222222
7c77ccc777cc7cc77cccc7777cccccc700000000000000000000000000000000cccc7ccccccccccccccccccccccccc7cccccccccccccc7cccccccccc12221112
7cccccc77c77ccc777cc7cc77cccc77711dd11dd1dd11dd1dd11dd11d11dd11dcccccccccccccccccccccccccccccccccccccccccccccccccccccccc12211112
7cccc7777cccccc77c77ccc777cc7cc7a7aa7a7aa7aa7a7aa7aa7a7aa7aa7a7acccccccccccccccccccccccccccccccccccccccccccccccccccccccc12111222
77cc7cc77cccc7777cccccc77c77ccc72f9f9f9a2f9f9f9a2f9f9f9a2f9f9f9acccccccccccccccccccccccccccccccccccccccccccccccccccccccc12112222
7c77ccc777cc7cc77cccc7777cccccc729f9f9fa29f9f9fa29f9f9fa29f9f9facccccccccccccccccccccccccccccccccccccccccccccccccccccccc12112212
7cccccc77c77ccc777cc7cc77cccc77712121211121212111212121112121211cccccccccccccccccccccccccccccccccccccccccccccccccccccccc12222222
00000000121221211111111111111111000000000497a4200000000007000700076d551100000000101010100000000000004990001165000994000024444444
0aaaaaa0121221211122221112222221aa9aa99a049aa940029912a006070607000000001155dd6710101010000000000000a77092249a79077a000012222224
049f9f9012211221121221211212212142442244024a7940014141a00d060d0676dd551100000000505050500000000000009aa592249a795aa9000012222224
04f9f99012122121122112211212212111111111044a7420021444900d0d0d0d000000001155d670505050500000000000004996411249a46994000012222224
049f9f90122112211221122112222221a7aa7a7a049aa9400419494005050505076d551100000000d0d0d0d0411249a400002441000000001442000012222224
04f9f9901212212111111111121111212f9f9f9a0497a9400144149005050505000000001155dd6760d060d092249a7900001221000000001221000012222224
0222222012222221122112211222222129f9f9fa024a7420011221200101010176dd5511000000007060706092249a7900001220000000000221000012222224
0000000012111121121221211111111112121211049aa9400000000001010101000000001155d670007000700011650000004990000000000994000011111112
22111122411111141111111111111111111111111111111100000000000000000000000000000000011010130000000033003303030300300b00300000000000
211221122422494211111111111100000000111111111111000000000000000000d000000010000013111001aa313aa30b33b0b00b0033300300000001133110
1124a21129449792111111111000000000000001111111110007700000c0000000100000000000001b0001003bb3b3b100bb003000300b00000000000133ba10
12947a2112947a211111111000000000000000000111111100c77c00000cc00000000000000000001b020011133b3333003000300003b030000000000313bb30
12947a2112947a211111110000000000000000000011111100cccc000c1cc10000011000000000000b00201bb3b3bb3b00b00000000000b00000000003113330
294497921124a21111111000000000000000000000011111000cc000000110c0d01dd1000001100001a000113113333100300000000000300000000001311310
24224942211221121111000000000000000000000000111100000000000c00000001100d10011000111bbb111001111000300000000000b00000000001133110
4111111422111122111000000000000000000000000001110000000000000000000d000000000001b101013b0000000000000000000000000000000000000000
00000000000000001110000000000000000000000000011100677600000000000000000000010001000000001001000010010000011110130111101313bbbb31
000a000000000000110000000000000000000000000000110677777000000000000000000011501050010150121011211000100113b3110113bb1101013bb310
00070000009090001100000000000000000000000000001167777776000110000000000001015101d01d15d10200000110002010133bab301131130013b33b31
0a777a00000a000011000000000000000000000000000011777777770011610000000000101510151151151001000001020201000133ba3101101111013bb310
0007000000909000100000000000000000000000000000016777777600111100000000000155001d11511d00010000200101020000113bbb001003bb13b33b31
000a000000000000100000000000000000000000000000013637736d00011000000000001151005d101501d01120001010100010010011b101311131013bb310
000000000000000010000000000000000000000000000001016663b000000000000000001550005d101d00000010111200020002113013111111011113b33b31
00000000000000001000000000000000000000000000000100133100000000000000000015d0101d5001d0100001000000010000b100013bb100013b013bb310
00000000000000001000000000000000000000000000000100000667766000000011110015d0150d601000000000aaaaaaaaa000000000000000000080000008
000000000000000010000000000000000000000000000001000667777776600001dddd1015d0050160000000000aaaaaaaaaa000000000aa0000aa0008000080
00040000000000001000000000000000000000000000000100677777777776001d6cc6d105d10000d000000000aaaaaaaaaaa00000aa00a7a0009a0000800800
00494000000200001000000000000000000000000000000106777777777777601dc17cd105d600000d00000000aaaaaaaaaaa0000aa7a00aa000000000088000
00040000000000001100000000000000000000000000001107777777777777701dc11cd101d610000000000000aaaa999999900009aaa00aaa00aa0000088000
00000000000000001100000000000000000000000000001177777777777777771d6cc6d1005d60000000000000aaaaaaa444400000aaaaaaaa00aa0000800800
000000000000000011000000000000000000000000000011677777777777777601dddd100005d1000000000000aaaaaaaaaa2000009aa009aa009a0008000080
00000000000000001110000000000000000000000000011137777777777777730011110000000d0000000000009aaaaaaaaaa000009990099000990080000008
33bbbb7777bbbb3311100000000000000000000000000111377777777777777300000000000000000000000000499999aaaaa000000000000000000000000000
02999999999999a01111000000000000000000000000111136377777777773630000000000000000000000000022222aaaaaa00000000a00a000000008888000
02444944499449a0111110000000000000000000000111113b777777777777b300000000000000000000000000aaaaaaaaaaa00000000a00a000000008000800
02444949499999a0111111000000000000000000001111110367377777737630000b0000003003000000100000aaaaaaaaaaa000000000000000000080000080
02499949494444a0111111100000000000000000011111110133b777777b331000b7b0000003b0000000100000aaaaaaaaaa90000000aaaaaa00000080000080
02444944494444a0111111111000000000000001111111110013677337763100000b0000000b3000001131100099999999994000000009999000000080000080
02999999999999a0111111111111000000001111111111110001133bb33110000000000000300300000010000044444444442000000000000000000008000800
02122112221221101111111111111111111111111111111100000111111000000000000000000000000010000022222222220000000000000000000000888000
03e0e0e0e0e0e0e0e0e0e0e053f3f35303e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e003a000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000e40000d400000000000000000000000000000000b60000000000000000000000000000b6
530000e4000000c50000e4d453b0b0535304533333232323131313133313b0f3f3b0333323233323231313232313539000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b60000000000000000000000000000b6
53c50000000000f3b0000000031333535302533313331323230123232333b0f3f3b0231323332313231333231323539000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b60000000000000000000000000000b6
53b5c50000000003030000c5f3231353530253230363636363636363636363030307170363636363636363630343039000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b60000000000000000000000000000b6
53b0b500000000839300c5f3f31323535302532353232313131313132323235390a0905393f3f3f3f3f3f383539090a000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b60000000000000000000000000000b6
53f3f342424242030372727272071753530203b103233333232333f3f3f323539090905393b0b0f3f3b0b08353a090a000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b60000000000000000000000000000b6
53b0f3b0c500c500000000000000e4535302232333233323232323f3b0f3335390a0905393f3b0b0f3f3b0835390a0a000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b60000000000000000000000000000b6
534242424242424242424242424200535302332323232372727223f3b0f3235390a0a05393336363b0b023835390a09000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b60000000000000000000000000000b6
53c5d400e402d4c4e40000c400000053530223b3332373e0e0e0232313132353a090a05393f3b0f32313b0835390a09000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b60000000000000000000000000000b6
530000000002000000010000007272535302830343430323d323232323132353a0a0a05393b0331313f3f38353a090a000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b60000000000000000000000000000b6
53000000000200000000000000d4c453530223a3a323232333233323b313235390a0905393f313332313138353a090a000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b60000000000000000000000000000b6
53636342424242420000004242c5b553530233f3b0f31323232313230323135390a0a0539313131323b523835390a0a000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b60000000000000000000000000000b6
53b0b003c4d400e4000000e40000c553530223b0b0f3230123b323232323135390a0905393c523c5636383030390a09000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b60000000000000000000000000000b6
5301f353c500000000727200c5737353530223f3b0f323030303233313131353a090a05393c513c5b5c583539090a0a000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b60000000000000000000000000000b6
53b0b053c5b5007373e400c5b54343535302b32333b323232333332323332353a0a0030393b5b500b500835390a0a0a000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b60000000000000000000000000000b6
53f3f30382828203038282828282825353144323234373737373737373737353a0905393b500630000008353a09090a000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b60000000000000000000000000000b6
53b0f353e2e2e2e2e2e2e2e2e2e2e25303e003131303e0e0e0e0e0e0e0e0e0e0a0a053930000000000b58353a090a0a000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b60000000000000000000000000000b6
53f3b003e0e0e0e0e0e0e0e0e0e0e0035393232313b0b0b02323131333232383909053930000000000830303a0a090a000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b60000000000000000000000000000b6
53b0f3e4d4c4d4e400c4d400e4d4c453539323b323f3f3f3132313131323238390a05393b500006300835390a090a09000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b60000000000000000000000000000b6
53f3f3000000000000000000000000535393230323b0b0b0232333232313238303030393c5b500b5008353a0d59090a000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b60000000000000000000000000000b6
5300000000c3e300000000000000005353932323233323b3237323b323132383535393b5c5b5c5b5c583030390e5d59000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b60000000000000000000000000000b6
5342424242030372727272030000005353937373737373032303230323332383530393c5c563c5b50000835390a0e59000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b60000000000000000000000000000b6
5300c4e40000b0f3f3b0e4c4000000535303a3a3a3a3a3d32323233333232383f593b5c5c5c5c5b5000083f4e5e5a0a400000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b60000000000000000000000000000b6
53000000008303f3f3039300000000535323b023232323232313f3b0f323b3835393c5c5b5c5c5c500000083f5a4d5e500000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b60000000000000000000000000000b6
5300004242420307170372727272725353b023b0b02313133323b0f3b0230383f5b5c5c5c5c5b5c56300008353e5a4e500000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b60000000000000000000000000000b6
5300000000e4c4e4c5b5b0b0331333535333b0f3b0f333131323f3b0f3132383f5c5b5c5c500000000000083f4f4e5d500000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b60000000000000000000000000000b6
5300000000000000c5b0b023130113535323b0f3b0232323132323b31313238393c5b5c5b5b500000000c5c583f4d5a400000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b60000000000000000000000000000b6
5342424242424242424242423313330303f3b001b0f323b323231303131333839300b5b5c5b5b50000c5c5c583f453e500000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b60000000000000000000000000000b6
538282828282828282828253828282828282820343b4b4430323332323131383930000b5c5c5b5c5c5c5c5b5c583f4f500000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b60000000000000000000000000000b6
53e2e2e2e2e2e2e2e2e2e253e2e2e2e2e2e2e253e5f4d59053231313331323839300c5c5c5c5b5c5c5b5c500c5c583f400000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b6f4b4b4b4b443434343b4b4b4b4f4b6
53e2e2e2e2e2e2e2e2e2e2034343434343434303a0e5d5e5032323132323138393b5c5c5b5c5c5b5c5c5000000c5c58300000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b6f5e565d5e5d590a0d5e5a465d5f5b6
53e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2539090e5a0537373737373737393c5c5c5c5b5c5c5c5c5c50000c5c58300000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b6f565d5e5d565a4e565d5e5d565f5b6
__label__
00000000101100011011000100000000000000000000000000000000000000000111111100000000000000000000000000000000101100011011000100000000
00000000100000011000000100000000000000000000000000000000000000000000000100000000000000000000000000000000100000011000000100000000
00000000100001111000011100000000000000000000000000000000000000000000000100000000000000000000000000000000100001111000011100000000
00000000110010011100100100000000000000000000000000000000000000000000000100000000000000000000000000000000110010011100100100000000
00000000101100011011000100000000000000000000000000000000000000000000000100000000000000000000000000000000101100011011000100000000
00000000100000011000000100000000000000000000000000000000000000000000000100000000000000000000000000000000100000011000000100000000
00000000100001111000011100000000000000000000000000000000000000000000000100000000000000000000000000000000100001111000011100000000
00000000110010011100100100000000000000000000000000000000000000000000000000000000000000000000000000000000110010011100100100000000
00000000101100011011000100000200000000000111111100000000000000000000000001111111011111110000000000000000101100011011000100000000
0000000010000001100000c712122121122200000000000100000000000000000000000000000001000000010000000000000100100000011000000100000000
00000000100001111000c777122112211212210000000001000000000000000000000000000000010000000100000021121221217ccc01111000011100000000
000000001100100111cc7cc71212212112122121000000010000000000000000000000000000000100000001000012211221122177cc7c011100100100000000
00000000101100011c77ccc7122112211222222110000001000000000000000000000000000000010000000100211221122112217c77ccc71011000100000000
00000000100000017cccccc7221221211211112112000001000000000000000000000000000000010000000101111111111111117cccccc77000000100000000
00000000100001177cccc777122222211222222112200001000000000000000000000000000000010000000112211221122112217cccc7777c00011100000000
00000000110010c777cc7cc71211112111111111111100000000000000000000000000000000000000000002121221212212212177cc7cc777c0100100000000
0000000010110cc77c77ccc7111144112444444424442111000000000000000000000000000000000111014411111112121224417c77ccc77c77000100000000
000000001000ccc77cccccc7112224411222222412241201000000000000000000000000000000000001022412222221122444227cccccc77cccc00100000000
000000001000c7777cccc777121221241222222412241201000000000000000000000000000000000001122412122121144422217cccc7777cccc71100000000
00000000110c7cc777cc7cc74421122212222224111211100000000000000000000000000000000000001112121221214412212177cc7cc777cc7c0100000000
000000001017ccc77c77ccc7144112221222222424442441000000000000000000000000000000000114244412222221122112217c77ccc77c77ccc100000000
0000000010ccccc77cccccc7192411112222222412241224000000000000000000000000000000000004122412111121121221217cccccc77cccccc100000000
0000000010ccc7777cccc777999944211222222412241224000000000000000000000000000000000024122412222221122242217cccc7777cccc77700000000
0000000011cc7cc777cc7cc74999a94111111112111211120000011001101000111011100110000000121112111111111244912177cc7cc777cc7cc700000000
000000001077ccc77c77ccc714499a91121221211001000000001aa11aa1a101aaa1aaa11aa100000001000011111111149aa4017c77ccc77c77ccc700000000
000000001cccccc77cccccc704aa799012122121100010010001a111a1a1a101a1a11a11a1100000000010011122221109aa7a407cccccc77cccccc700000000
000000001cccc7777cccc7770a77aa9012211221100020100001aaa1a1a1a101aaa11a11aaa1000000002010121221210a77a9907cccc7777cccc77700000000
0000000017cc7cc777cc7cc719779a911212212102020100000011a1a1a1a111a1a11a1011a10000000201001221122119779a9177cc7cc777cc7cc700000000
000000001c77ccc77c77ccc71099aa9112211221010102000001aa11aa11aaa1a1a1aaa1aa100000000102001221122110994a017c77ccc77c77ccc700000000
000000001cccccc77cccccc710142a011212212110100010000011001100111010101110110000000010001011111111101421017cccccc77cccccc700000000
0000000010ccc7777cccc777120110211222222100020002000000000000000000000000000000000002000212211221120110217cccc7777cccc77700000000
0000000011cc7cc777cc7cc71210012112111121000100000000000000000000000000000000000000010000121221211210012177cc7cc777cc7cc700000000
000000001077ccc77c77ccc7244424441111111100000000000000000000000000000000000000000000000012122121244444447c77ccc77c77ccc700000000
0000000010ccccc77cccccc7122412241222222100000000000000000000000000000000000000000000000012122121122222247cccccc77cccccc700000000
00000000100cc7777cccc777122412241212212100000000000000000000000000000000000000000000000012211221122222247cccc7777cccc77100000000
00000000110c7cc777cc7cc71112111212122121000000000000000000000000000000000000000000000000121221211222222477cc7cc777cc7cc100000000
000000001011ccc77c77ccc7244424441222222100000000000000000000000000000000000000000000000012211221122222247c77ccc77c77ccc100000000
000000001000ccc77cccccc7122412241211112100000000000000000000000000000000000000000000000012122121122222247cccccc77ccccc0100000000
00000000100007777cccc777122412241222222100000000000000000000000000000000000000000000000012222221122222247cccc7777cccc71100000000
00000000110010c777cc7cc71112111211111111000200000000000000000000000000000000000000000000121111211111111277cc7cc777cc700100000000
00000000101100c77c77ccc7100100000000000000200000000000000000000000000000000000000000000000000000100100007c77ccc77c77000100000000
00000000100000077cccccc7121011210000000000000000000000000000000000000000000000000000000000000000100010017cccccc77cc0000100000000
00000000100001117cccc777020000010000000000000000100000000000000000000000000000000000000000000000100020107cccc7777c00011100000000
000000001100100111cc7cc70100000100000000002000000202010000000000000000000000000000000000000000000202010077cc7cc77100100100000000
00000000101100011011ccc7010000200000000000020000010102000000000000000000000000000000000000000000010102007c77ccc71011000100000000
0000000010000001100000c7112000100000000000000000101000100000000000000000000000000000020000000000101000107ccccc011000000100000000
000000001000011110000111001011120000000000000000000200020000000000000000000000000000200000000000000200027cc001111000011100000000
00000000110010011100100100000000000000000000000000010000000000000000000000000000000000000000000000010000110010011100100100000000
00000000101100011011000100000000000000001001000011111111111100000000011111111111100100000000000000000000101100011011000100000000
00000000100000011000000100000000000000001000144111222211112220000000221111222211104410010000000000000000100000011000000100000000
00000000100001111000011100000000000000001000441012122121121221000000212112122121149020120000000000000000100001111000011100000000
00000000110010011100100100000000000000000204210012211221122112000001122112211221499901240000000000000000110010011100100100000000
00000000101100011011000100000000000000000102920012211221122112200001122112211221249994400000000000000000101100011011000100000000
00000000100000011000000100000000000000001019991011111111111111100011111111111111124a94100000000000000000100000011000000100000000
00000000100001111000011100000000000000000099999212211221122112200121122112211221009aa0020000000000000000100001111000011100000000
0000000011001001110010010000000000000000904a999212122121121221210112212112122121009aa9000000000000000000110010011100100100000000
0000000010110001101100010000000000000009999aa94424442444244424441244244424442444100999010000000000000000101100011011000100000000
0000000010000001100000010000000000000009aa99a9401224122412241224022412241224122404aaa2400000000000000000700000011000000100000000
0000000010000111100001110000000000000000a9779990122412241224122402241224122412240a77aa900000000000000000700001111000011100000000
00000000110010011100100100000000000000001a77a90111121112111211121112111211121112197799010000000000000000710010011100100100000000
000000001011000110110001000000000000000010aa410124442444244424442444244424442444109991010000000000000000701100011011000100000000
00000000100000011000000100000000000000001014210112241224122412241224122412241224101421010000000000000000700000011000000100000000
00000000100001111000011100000000000000001201102112241224122412241224122412241224120110210000000000000000700001111000011100000000
00000000110010011100100100000000000000000000000110021112000211120002100211120002000000010000000000000000110010011100100100000000
00000000101100011011000100000000aaa0aaa0aaa00aa00aa04440aaa04440aaa00aa02440aaa0aaa00aa0aaa0aa0000000000101100011011000100000000
00000000100000011000000100000000a0a0a0a0a000a000a002222400a022240a00a0a01220a0a0a000a0010a00a0a000000000100000011000000100000000
00000000100001111000011100000000aaa0aa00aa00aaa0aaa022240a0222240a00a0a01220aa00aa00a0010a00a0a000000000100001111000011100000000
00000000110010011100100100000000a000a0a0a00200a000a02220a00222240a00a0a01220a0a0a000a0a00a00a0a000000000110010011100100100000000
00000000101100011011000100000000a000a0a0aaa0aa00aa022220aaa022240a00aa041220aaa0aaa0aaa0aaa0a0a000000000101100011011000100000000
00000000100000011000000100000000000000000002002100222222000222241022002412220004000200010000000000000000100000011000000100000000
00000000100001111000011100000000000000001222222112222224122222241222222412222224122222210000000000000000100001111000011100000000
00000000110010011100100100000000000000001211112111111112111111121111111211111112121111210000000000000000110010011100100100000000
00000000101100011011000100000000100100002444244424444444244444444444444424444444244424441001000000000000101100011011000100000000
00000000100000011000000100000000100010011224122412222224122222222222222412222224122412241000100100000000100000011000000100000000
00000000100001111000011100000000100020101224122412222222122211122211122412222224122412241000201000000000100001111000011100000000
00000000110010011100100100000000020201001112111212222229122111122211122412222224111211120202010000000000110010011100100100000000
00000000101100011011000500000000010102002444244412422299921112222222222412222224244424440101020000000000101100011011000100000000
00000000100000011000000500000000101000101224122414944999421122222111112412222224122412241010000000000000100000011000000100000000
00000000100001111000011500000000000200021224122412999999000122122111112412222224122412240000000000000000100001111000011100000000
0000000011001001110010050000000000010000111211121119aaa9488022222222222411111112100100000000000000000000110010011100100100000000
000000001011000110110005000000001001000024442444244aaaa88e8802222222222424444444222212210000000000000000101100011011000100000000
000000001000000110000005000000001210112112241224129aa77a888e01122112112412222224111201110000000000000000100000011000000100000000
00000000100001111000011500000000020000011224122412999779888801122112112412222224111201110000000000000000100001111000011100000000
00000000110010011100100500000000010000011112111212299991ff1801122222112412222224100100000000000000000000110010011100100100000000
00000000101100011011000500000000010000202444244412220204402802222111112412222224222212210000000000000000101100011011000100000000
00000000100000011000000500000000112000101224122412222021500201122111112412222224111201110000000000000000100000011000000100000000
00000000100001111000011500000000001011121224122412222201010022222222222412222224111201110000000000000000100001111000011100000000
00000000110010011100100500000000000100001112111211111110101111111111111211111112100100000000000000000000110010011100100100000000
00000000101100011011000500000000000000000000000000000000000000000000000000000000000000000000000000000000101100011011000100000000
000000001000000110000005000000000aaaaaa0aa9aa99aaa9aa99aaa9aa99aaa9aa99aaa9aa99a442442220222222000000000100000011000000100000000
00000000100001111000011500000000049f9f904244224442442244424422444244224442442244212211210112121000000000100001111000011100000000
0000000011001001110010010000000004f9f9901111111111111111111111111111111111111111000000000121211000000000110010011100100100000000
00000000101100011011000100000000049f9f90a7aa7a7aa7aa7a7aa7aa7a7aa7aa7a7aa7aa7a74454454120112121000000000101100011011000100000000
0000000010000001100000010000000004f9f9902f9f9f9a2f9f9f9a2f9f9f9a2f9f9f9a2f9f9f94142424120121211000000000100000011000000100000000
000000001000011110000111000000000222222029f9f9fa29f9f9fa29f9f9fa29f9f9fa29f9f944124241220000000000000000100001111000011100000000
00000000110010011100100100000000000000001212121112121211121212111212121112121200010100000000000000000000110010011100100100000000
000000001011000110110001000000000497a42099a919aa99a919aa99a919aa99a919aa99a91244224201220111210000000000101100011011000100000000
00000000100000011000000100000000000a09002444000900040449200410090444000924440002000200010102001000000000100000011000000100000000
00000000100001111000011100000000999090901220999099909029099009909020999012209990999009909090990000000000100001111000011100000000
00000000110010011100100100000000909090901110999090909010900090909010999011109090909090909090909000000000110010011100100100000000
0000000010110001101100010000000099009990aa909090999090909090909090909090aa209900990090909090909000000000101100011011000100000000
00000000100000011000000100000000909000904240909090909000900090909000909041209090909090909990909000000000100000011000000100000000
00000000100001111000011100000000999099901110909090909990099099009990909000009990909099009990909000000000100001111000011100000000
00000000110010011100100100000000000400000000000000000000000000000000000000000000000000000002010000000000110010011100100100000000
00000000101100011011000100000000022542100b00300003030030000000003300310101010010000000000111210000000000101100011011000100000000
00000000100000011000000100000000022442200100000000003000000000000b33001001000110000000000112211000000000100000011000000100000000
00000000100001111000011100000000012452200000000055500550555000005010550050505000000000000012111000000000100001111000011100000000
00000000110010011100100100000000022452100000000050005050505000005010505050505000000000000112110000000000110010011100100100000000
00000000101100011011000100000000011442200000000055005050550000005010505055505550000000000112211000000000101100011011000100000000
00000000100000011000000100000000011142200000000050005050505000005000505000505050000000000111211000000000100000011000000100000000
00000000100001111000011100000000001211100000000050005500505000005550555000505550000000000012110000000000100001111000011100000000
00000000110010011100100100000000011221100000000000000000000000000000000000000000000000000112211000000000110010011100100100000000
00000000101100011011000100000000011121000000000000000000000000000000000000000000000000000111210000000000101100011011000100000000
00000000100000011000000100000000011221100000000000000000000000000000000000000000000000000112211000000000100000011000000100000000
00000000100001111000011100000000001211100000000000000000000000000000000000000000000000000012111000000000100001111000011100000000
00000000110010011100100100000000011211000000000000000000000000000000000000000000000000000112110000000000110010011100100100000000
00000000101100011011000100000000011221100000000000000000000000000000000000000000000000000112211000000000101100011011000100000000
00000000100000011000000100000000011121100000000000000000000000000000000000000000000000000111211000000000100000011000000100000000
00000000100001111000011100000000001211000000000000000000000000000000000000000000000000000012110000000000100001111000011100000000
00000000110010011100100100000000011221100000000000000000000000000000000000000000000000000112211000000000110010011100100100000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

__gff__
0000000000000000000101000000010000000000000000000000000900000000020202022121212102020202020202000100000001011105050505000000000001010000000000000000000100000001000000000000000000000000000000010000000000000000000000010000000001010000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
20350b0b0b350a0a0a0a0a0a09090a0a0a09090a0a090a0909090a0a090a0a0a0a35090b090a0a09090a0a0a09090a095f005c5c5c00005c5c000000005c5c5f5f5d4a5e5e5d5d5e4a5d5e5d5e5d5e5d5d5e5e4a5d4f4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4f4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b6b
20353f3f3f350a4009400a09090a0a090a3034343434343434343434343430090a3509090b0a0a0b090a09090a090a0a5f005b005c5c5c005c00005c5b5c5c5f5f5e5d4f4b4b4b4f5d5e4f4b4f4a5d4a5d5e5d5e565f4c4d4e4e004d4c4e4c4d5b5b4c4e4d4e4d005f4d20004d4e4e4c005b5c5c5b5b0000000000000000006b
20353f3132350a200a200a0a0a0a0a0a0a3532323232320b3f3232323132350a0a35090a090a090a0a0a090b0a0a0a095f5c5c5b5b5b5c005c005c5c5b5b005f4f4b4f4d4c4c4d4f4b4f5c4c5c4f4b4b4b4b4b4b4b4f5b5c4f4b4b4f005b5c5b5b5b0b3f005c00005f00200000005c5b5c5c5c5b5c000000000000000000006b
2035333f333509200a20090a090a090a0a35323f0b320b2f0f0b320b3f31350a09300e0e0e0e400e0e0e400e0e0e30095f5c5c5c005b5b005c5c5b5c5c5c5c5f5f4c4e5c5b5b5b4e4c4d5c5c004e4e204d5b4e4c38395b5c4d4e4d5f4b4f5b5c5b3f3f0b3f5c5b385f002000005b5c5c5b5b5c5c00000000000000000000006b
2035333232350a200a20090a0a0a0a0a0a35310b3131311e1f3131310b323509093533313232202f0b0f20313232350a5f5c00005c5c5b5c5c5c5c5c00005c5f5f5b5b5c00005b5b5c5c001000000020005b5c5c38393b5b5c5b5b5f4a4f4b4b4b4b70714f5c5c385f5b205c4f4b4b4b4b70714b4b4f0000000000000000006b
2035363636350a2009200a0a090a0a090a3532313232323f3f3232313232350a0a3532313331200b3f0b2033313335095f5c5b005c5c5c5c005b5c5c005b5b4f4f5b5b00000000005b5c4b4b4b00002000005b5c4f4b4b4f5c00005f5e5d5e4a5e4a565e5f5b5c385f5c205b5f565d5d5e5e5d565d4d0000000000000000006b
20350b0b0b3509200a200a09090a0a090a3531323232307071303233333835090a3531333132203f3f3f20313231350a5f5c5c5b5c5c5b00005c005c5c005c4c4d5c5c0000000000005b5f5d5f5c00200000005b5f5d565f5b00385f565d5e5e4f4b4b4b4f5c5c5c5f0b200b5f4a5d5e5d5e5e4f4c000000000000000000006b
20353f3f3f350a200a200a0a0a0a09090a3532323131354040353233333835090a3531333132203f103f2032323335095f5b5c5c5c5b5c5c5c5c5b5b5c5c5c5c00005c5b0000005b5c5b5f5e5f5c5c200000005b5f5d5e5f0000385f5d5e5d5e5f5c4e4e00005b5c5f1020335f5d5e5e5e5d4c4d00000000000000000000006b
20353f3332350a410a410a090a0a0a0a0a351b1b31313520203531313232350a093532313237201e0b1f2037313235095f5b5b5b5c5b5c5c5b5b5c5b005c5c0000005c5b5c5b5c5c5b5b5f565f282828282820005f5d4a5f0000385f5d5e5e5d5f5b4f4b4b00005b5f0b200b5f5e5e5e5d4f000000000000000000000000006b
2035323331300e0e0e0e0e0e0e0e0e0e0e30323232323520203531313232300e0e301b1b1b30413434344130363635095f28282828282828282828284f70714b4b4b4b5b5c5b5b3f3f005f5e4f4b4b4b4b4b20005f4a5e5f00005b5f5e5d5e5e5f5b4f4a563737375f5c205c5f5e5e4a6b4d000000000000000000000000006b
2035323132313132323331313132323f3f3232331b1b3520203531313232320b0b33323232350a0a09090a353232350a5f2e2e2e2e2e2e2e2e2e2e2e5f5d5d5d5e5d4f4b5b5c3f2f0f3f5f5d4a5e5e5d5e5f20005f565d5f005b5c5f4a5d565e5f5c4f4b4b4b4f4a5f0020005f5e5d5e6b00000000000000000000000000006b
2035323332313332323331103333320b0b31323232323520203533333231313f3f322f3f0f35090a0a0a0a353231350a4b4b4b4b4b4b4b4b4b4b4b4b4f5d4a5d4a5d5d4f4b5b3f1e1f3f5f5e565d5d5e5e5f20004f4b4b4f5b5c005f5e5d5e5d5f00004e4c4d5f5e5f2828285f5d5e5e6b00000000000000000000000000006b
2035323332313333323331303332320b0b3110331b1b3520203533333210313f3f321e3f1f350a09090a0935363635095e5e5e5d5e5e5d5d5e5d5d5e5e5d5e5d5d5e5d564f4b003f3f5b5f5e5e5e5d5e5e5f205b4e4d4c4d5c5c5b5f5e5e5d5d4f4b4b4b4f005f565f2e2e2e5f5d4a5e6b00000000000000000000000000006b
2035321033333030333233353333333f3f32323132323520203537373232320b0b33323b32350a090a0a0a35333335095e5d5d5e5e4a5d5d5e5e5e5e5d5e5d5e5d5e5d5e5d4f4b34344b4f5d5e5e4a5e5e5f20005b3210325c5b5c5f5d5e5e5e5d5e4a5d5f005f4b4b4b5f205f565d5e6b00000000000000000000000000006b
2030343434343434343434343434343434343434343430202030343434343434343434343430090a090a0a353132350a5d5e4a5d5e5d5d5e5e5e5d5e5e5d5d5d5e5e5e5d5d5d5d0a095d5d5e5e5d5e5d5e5f2000003f313f5c00005f5d565e5d5e5d565d5f5c5f5c104d5f205f4a5d5e6b00000000000000000000000000006b
2035090a0a09090a0a0a0909090a0a35350909090a0a3520203509090a0a0a350a090a0a090a0a0a0a0a0935323135095d5e5d5d5e5e5d5d5d5e5e4a5e5d5e5d5d5e5d4a5d5e5e090a5d5e5d5d5e5e5d5e4f3737373434343737375f5e5d5e5e5d5e5e5e5f5b5f5c4f005f205f5d5e5e6b00000000000000000000000000006b
20350e0e0e0e0e0e0e0e350e0e0e0e35350e0e0e0e0e302020300e0e0e0e0e3509090a090a0a0a0909090a353232350900202031323231313f32333131202000000000000000000000000000000000005e4f4b4b4b4b4b4b4b4b4f5e5e5d5d5e4a5e5d565f5c5f5b5f005f205f0000006b00000000000000000000000000006b
2035330b3333103333323532333238353500000000005b2020000000000000300e0e0e400e0e400e0e400e301010300a00202031333f3331333f3f3232202000000000000000000000000000000000004b4f4d4c4e4d004c4e4d4f4f5e5e5e4f4b4b4b4b4f5c5f5b5f004c205f0000006b00000000000000000000000000006b
203533333034343430333531313138353500000000005c41415b00000000003f3f3333323232323f3f0b3f3f32313509002020323f0b00005c5b0b3331202000000000000000000000000000000000005f4c00000000000000004e4f4b4b4b4f4c4d310b33005f5c5f2828285f0000006b00000000000000000000000000006b
20353232350a0909301b3032303231303000000000003f2f0f3f00000000003f3f3232320b32323232323f3f3f32350a00202010315c000000005c3210202000000000000000000000000000000000005f00000000375c0037005c5f5c5c4c5b0000311031005f005f4b4b4b4b0000006b00000000000000000000000000006b
2035323835090a0a35313331350b0b3f3f00000000003f1e1f3f00000000003f3f323332103f32320b0b3f3f313f35090020200b33000000000000313f20200000000000000000000000000000000000355c000000305b5c305c5c4f5c2727272424242727274f004f4b4f4d4e0000006b00000000000000000000000000006b
20353238300e0e0e3032313c353b0b3f3f000000005c3f3f3f3f5b000000003f3f3f3332323f310b37373f3f3132350a0020205b00005c00000000005c20200000000000000000000000000000000000355c5b5c5c353132355c5b5c5c3031325c00330b335b4d004c385f00000000006b00000000000000000000000000006b
20353231323f0b3f353b323130343434343434343434347071343434343434343436363636363132303434301b1b350900202000005c323232325c000020200000000000000000000000000000000000355b32313235323135323132273032315c5b3110315b5c0000385f00000000006b00000000000000000000000000006b
20353e3233323f0b3530330b3509090a4e35354c4e00354c4d35004d4c4e4d3f333f323f323231320b0b3f3f3231350a0020200000100b0b0b0b100000202000000000000000000000000000000000005f1031373730373730373730303331302424242424242424244b4f00000000006b00000000000000000000000000006b
20353233323132323037373730090a0a0035350000003500003500000000003f3332313f3232313132313f3f3f3f35090020200000313f3f3f3f31000020200000000000000000000000000000000000350b0b350e0e0e0e0e0e0e0e30313230090a095d5e5d5e4a5e5d4c00000000006b00000000000000000000000000006b
2035373736363636300e0e0e300e0e300035350000003500003500000000003f33333f3f3f31313f3f0b3f3f3f32350a002020005c0b3f2f0f3f0b5c0020200000000000000000000000000000000000350b0b353232313131313232313232380a0a5d5e4a565e5d4c4d0000000000006b00000000000000000000000000006b
20303430313232313f3f3132320b0b350035350000003500003500000000003f3333333f3232313231323f3f3232350a002020005b0b3f1e1f3f0b5c002020000000000000000000000000000000000035323135313232302424242424242424095d5e5d5e5d4c4d00000000000000006b00000000000000000000000000006b
2035323232323131323f313132320b35003535000000350000350000000000202828282828282828282828282828350a002020003034343434343430002020000000000000000000000000000000000035373235313132350a0909090a090a090a4a5d5e5e5e000000000000000000006b00000000000000000000000000006b
2035311032311b1b3131311b353131355c3535000000350000350000000000202e2e2e2e2e2e2e2e2e2e2e2e2e2e350900202000350e0e0e0e0e0e350020200000000000000000000000000000000000353a31303132313509090a0a090b0a5d5d5e5e4a4c00000000000000000000006b00000000000000000000000000006b
20351b1b3232313f32323131350b0b355c35355b0000350000355c00000000203434343434343434343434343434300a00202000354e4d004c4d4e35002020000000000000000000000000000000000035313132323132350a0a09095e5d0a5e5e5e5d000000000000000000000000006b00000000000000000000000000006b
203537373737373737373737350b0b355b35355c5b00355c00355b5c00000020350a090935090a0a0a0a09350a0a090900202000350000000000003500202000000000000000000000000000000000003532323132323b350a09565e4a5e564a5d4c4d000000000000000000000000006b00000000000000000000000000006b
203534343434343434343434353f3f353735353737373537373537373737373735090a0a350a0b0b0b0b0a35090a0a0900000000000000000000000000000000000000000000000000000000000000003034343470713430095e5e4a5e5e5d5e4c0000000000000000000000000000006b00000000000000000000000000006b
__sfx__
0001000016050180501a0501b0501e050220502405000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200000c13008130061300060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000800001d5402954022540000001d5202952022520000001d5102951022510000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00060000250401c040160400f040250201c020160200f020250101c010160100e0100100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0008000027550295502b55027520295202b52027510295102b5100050000400004000030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00050000166101b61023610296102c6102a61025610216101a610146100c610000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000800000c6300c6200b6101f6001c6000e7000870000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00020000260501f05019050100500b050080500b05010050170502005027050305503055000500005002955029550005002953029530000002952029520295002951029510000000000000000000000000000000
00020000110501105012050130501405016050180501202012020130201402016020190200470004700047000670006700085000c7000d7001050013700157001670031000000000000000000010000100000000
000700002b610036102761009610146100b6100f61009610046100161000610000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400000962004620176200562013620046200861002610136100361017610026101261005610026100261000000000000000000000000000000000000000000000000000000000000000000000000000000000
010800001e7501d7501c7501e7301d7301c7301e7201d7201c7201e7101d7101c7100010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000004000000000400000000010000000001000000000400000000040000000001000000000100000000040000000004000000000100000000010000000004000000000400000000010000000001000000
011000000015300000001430000018623000002461324613001530000000143000000000000000001430000000153000000014300000186230000000000186230015300000001430000000000000000014300143
01100000180421f0421d04222042180221f0221d02222022180121f0121d012220120000000000000000000026745267450000000000267152671500000000002274522745000000000022715227150000000000
01100000180421d0421b0421a042180221d0221b0221a022180121d0121b0121a0120000000000000000000024745247450000000000247152471500000000001f7451f74500000000001f7151f7150000000000
01100000187461b7461f74624746000000000000000000000000000000000000000000000000000000000000187461d74620746247460000000000000000000000000000000000000000167461a7461d74622746
01100000187461b7461f74624746000000000000000000000000000000000000000000000000000000000000187461d7462074624746000000000000000000001b7461f7462274627746167461a7461d74622746
01100000004250000000425004250c4250000000425000000a425000000c4250000000425034250542500000004250000000425004250c4250000000425000000a425094250c425000000f425000000e42500000
01100000004250000000425004250c4250000000425000000a425000000c425000000042503425054250000008425000000842508425000000e4250f425000000a425000000e42500000114250f4251142513425
__music__
00 10514344
00 10114344
01 10111244
00 10111344
00 10111244
00 10111344
00 11161444
00 11171544
00 11161444
02 11171544

