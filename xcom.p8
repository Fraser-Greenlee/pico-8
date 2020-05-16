pico-8 cartridge // http://www.pico-8.com
version 27
__lua__
-- shadows of dunwich
-- by paranoid cactus
function _init()
	poke(0x5f2d,1)
	memcpy(0x5b00,0x2d00,768)
	cartdata("shadowsofdunwich")
	camera_distance,camera_pos,camera_angle,mx,my,blink_time,mstate_c,bitmasks,special_funcs,mission,nsp=120,new_vector3d(),0,matrix_rotate_x(-0.05),matrix_rotate_y(0),0,get_mouse_state(),{0b0101101001011010.1,0b1010010110100101.1},{action_grenade,action_shock,action_heal},1,0
	read_sprites_and_anims()
	music(0)
end

function new_battle()
	cam_x,cam_y,wait,action_mode,grenade,floating_text = 0,0,0,0,{},{}
	gen_map()
	menuitem(3,"abort mission",function() nextmission() music(0) end)
	music(-1)
end

function get_mouse_state()
	return {x=stat(32),y=stat(33),b1=band(stat(34),0x01)==1,b2=band(stat(34),0x02)==2,b3=band(stat(34),0x04)==4}
end

function mouse_on_screen()
	return mstate_c.x>=0 and mstate_c.x<=127 and mstate_c.y>=0 and mstate_c.y<=127
end

function _update60()
	mstate_p,mstate_c,bp0,bp1,bp2,bp3,bp4,bp5=mstate_c,get_mouse_state(),btnp(0),btnp(1),btnp(2),btnp(3),btnp(4),btnp(5)
	if not mouse_on_screen() then
		mstate_c.b1=false
	end
	blink_time,action_cost=(blink_time-1)%40,0
	if game_mode==2 then
		if wait>0 then
			wait-=1
		else
			if gameover then
				nextmission(true)
				return
			end
			if player.p <= 0 then
				if not nextplayer() then
					for p in all(teams[team_i]) do
						p.n_action,p.p,p.shocked=2,2,nil
					end
					player_i,team_i=0,team_i%2+1
					if not nextplayer() then
						music(0)
						gameover,wait=true,60
						return
					end
				end
			end

			menu={}
			if not player.action then
				if team_i==1 then
					player_think()
				else
					ai_think()
				end
			end
		end
		local pm=new_line_table()
		for pr in all(particles) do
			for p in all(pr) do
				p.life-=1
				p.y+=p.vy
				p.x+=p.vx
				if p.life > 0 then
					add(pm[table_row(p.y)],p)
				end
			end
		end
		particles=pm
		
		for f in all(floating_text) do
			f.t-=1
			f.y-=0.25
			if f.t==0 then
				del(floating_text,f)
			end
		end
		
		for i,t in pairs(teams) do
			for p in all(t) do
				if p==player or (p.x>cam_x-10 and p.x<cam_x+130 and p.y>cam_y-10 and p.y<cam_y+130) then
					p:update()
				end
				if #teams[i%2+1]==0 then
					p.p=0
				end
				if p.hp<=0 then
					del(t,del(actors[table_row(p.y)],p))
				end
			end
		end
		cam_xd,cam_yd=flr(max(0,min(mid(cam_x,cam_follow.x-78,cam_follow.x-32),386))),flr(max(-15,min(mid(cam_y,cam_follow.y-74,cam_follow.y-32),145)))
		cam_x,cam_y=flr(cam_x+(cam_xd-cam_x)*0.1),flr(cam_y+(cam_yd-cam_y)*0.1)
		if scroll_wait and (abs(cam_xd-cam_x)>10 or abs(cam_yd-cam_y)>10) then
			mouse_enable=false
		else
			scroll_wait=nil
		end
	elseif game_mode==1 then
		if bp0 then
			cam_x=max(0,cam_x-1)
		elseif bp1 then
			cam_x=min(5,cam_x+1)
		end
		if bp2 then
			cam_y=max(0,cam_y-1)
		elseif bp3 then
			cam_y=min(5,cam_y+1)
		end
		column=flr(cam_x/2)+1
		player,selectedval=teams[1][column],cam_x%2+1
		if bp4 then
			if cam_y==0 then
				game_mode,message=2,nil
				new_battle()
			elseif cam_y<=player.st[6] and player.st[cam_y]==0 then
				player.st[cam_y]=selectedval
				spawn_players()
				--sfx(46)
			end
		end
	else
		if bp4 or bp5 then
			if bp5 then
				memset(0x5e00,0,0x00FF)
			end
			pskills={{},{},{}}
			for i,k in pairs(pskills) do
				for j=1,6 do
					k[j]=dget(j+i*6)
				end
			end
			nextmission()
		end
	end
end

function _draw()
	cls()
	if game_mode==2 then
		local xs,ys,node,gend=max(table_row(cam_x)-9,0),max(flr(cam_y/8),0),get_cursor_node(),grenade.pathend
		local xe,ye,can_move,can_action=min(xs+24,63),min(ys+19,31),node and getmovep(node)<=player.p,team_i==1 and not player.action and not player.pathnode and player.p>0
		camera(cam_x,cam_y)
		map(0,0,0,0,64,32)
		map(64,0,0,0,64,32)

		-- shadows
		for t in all(teams) do
			for a in all(t) do
				sspr(104,32,9,7,a.x-1,a.y+3)
			end
		end
		
		if wait<=0 and can_action then
			if action_mode==0 then
				if can_move then
					fillp(bitmasks[(cam_x+cam_y)%2+1])
					for ml in all(movelines) do
						rectfill(ml[1],ml[2],ml[3],ml[4],ml[5])
					end
					fillp()
					while node.parent ~= nil do
						line(node.x+3,node.y+3,node.parent.x+3,node.parent.y+3,10)
						node=node.parent
					end
				end
			elseif gend then
				circ(gend.x,gend.y,24,8)
			end
			circ(cursor.x+3,cursor.y+3,5,7)
		end
		for y=ys,ye do
			for x=xs,xe do
				local overlay=oget(x,y)
				if overlay>0 and overlay<=#mapspr then
					local sprite=mapspr[overlay]
					sspr(sprite.x,sprite.y,sprite.w,sprite.h,x*8,y*8-sprite.h+8)
				end
			end
			for a in all(actors[y+1]) do
				camera(cam_x+61-a.x,cam_y+57-a.y)
				a:draw()
			end
			camera(cam_x,cam_y)
			for p in all(particles[y+1]) do
				circfill(p.x,p.y,p.size,p.col)
			end
			if gend then
				for gp in all(grenade.path[y+1]) do
					pset(gp.x,gp.y+gp.z,7)
				end
			end
		end

		if wait<=0 then
			if player.action==action_attack_cont then
				draw_attack(player.n_action==3 and 12 or 6)
			elseif can_action and action_mode==0 and can_move then
				for y=cursor.y/8-1,cursor.y/8+1 do
					for x=cursor.x/8-1,cursor.x/8+1 do
						local m,sp=get_bval(x,y),215
						if m and m>=254 then
							if m==255 then
								sp=250
							end
							spr(sp,x*8,y*8)
						end
					end
				end
			end
		end
		if can_action then
			spr(107,player.x,player.y-15) --+sin(blink_time/40)*1.125
		end
		for f in all(floating_text) do
			local x=f.x-(#f.text*2)
			for x1=x-1,x+1 do
				for y1=f.y-1,f.y+1 do
					print(f.text,x1,y1,0)
				end
			end
			print(f.text,x,f.y,f.col)
		end
		
		camera()
		-- ui
		for k,a in pairs(teams[1]) do
			set_colors(a.cols)
			local x,col=k*28,a==player and 7 or 13
			rectfill(x-26,121,x,127,a==player and 12 or 0)
			draw_sprite_part(a.sprite_parts[1],x-21,126,1)
			draw_sprite_part(a.sprite_parts[7],x-21,126,1)
			print(a.hp,x-15,122,col)
			for i=1,a.p do
				rectfill(x-3,119+3*i,x-2,119+3*i+1,(a==player and blink_time<20 and action_cost>=a.p+1-i) and 8 or col)
			end
		end
		pal()
		
		if team_i==1 and player.hp>0 then	
			btns[3].i=player.si
			for i=1,3 do
				local col,bi=(max(0,i-2)==action_mode) and 1 or 0,btns[i]
				if player.n_action==i then
					pal(5,6)
					pal(13,7)
					col=12
				end
				rectfill(bi.x1,bi.y1,bi.x2,bi.y2,col)
				spr(bi.i,bi.x1+2,bi.y1)
				for j=0,player.sa-1 do
					pset(122+flr(j/3)*2,122+2*(j%3),13)
				end
				pal()
			end
			if player.n_action~=0 then
				spr(108,action_mode==0 and 95 or 115,114)
			end
			spr(124,action_mode==1 and 95 or 115,114)
		end

		if mouse_enable then
			spr(127,mstate_c.x,mstate_c.y)
		end
		if menu then
			local x,y,h=cam_follow.x-cam_x-1,cam_follow.y+13-cam_y,#menu*7
			if y+h>115 then
				y-=24+h
			end
			for m in all(menu) do
				local r=x+#m*4
				if r>127 then
					x,r=125-(r-x),125
				end
				rectfill(x,y,r,y+6,0)
				print(m,x+1,y+1,7)
				y+=7
			end
		end
	elseif game_mode==1 then
		print(message or "",34,3,9)
		memset(0x6300,0x55,0x0340)
		print("mission level "..mission,14,16,15)
		rectfill(84,14,112,22,cam_y==0 and 12 or 13)
		print("deploy",87,16,7)
		for i,a in pairs(teams[1]) do
			local x1=i*35
			rectfill(x1-21,40,x1+7,110,1)
			camera(71-x1,19)
			a:draw()
			camera()
			for j,b in pairs(skilltree[i]) do
				for k,s in pairs(b) do
					local v,st,x,y=1,a.st[j],x1-s.x,37+j*12
					if st==k then
						v=3
					elseif st~=0 or a.st[6]<j then
						v=5
					end
					if skilltree[column][cam_y]==b and selectedval==k then
						v+=1
						print(skilltree.text[s.t],14,114,15)
					end
					for i=1,13 do
						pal(i,pals[v][i])
					end
					rectfill(x,y,x+10,y+10,1)
					spr(s.s,x+2,y+1)
					pal()
				end
			end
		end
	else
		memcpy(0x63cc,0x370c,3060)
		if game_mode==3 then
			memcpy(0x7280,0x5b00,768)
		end
		spr(108,41,96)
		print("continue",53,98,15)
		spr(124,41,106)
		print("new game",53,108,8)
	end
end

function nextmission(isgo)
	gameover,game_mode,message,cam_x,cam_y,column,selectedval,prevmission,mission,nsp=nil,1,isgo and (team_i==1 and "mission failure" or "mission success") or nil,0,0,1,1,mission,1,max(nsp,flr(mission/4))
	if isgo and team_i==2 then
		for p in all(teams[1]) do
			p.st[6]=min(5,p.st[6]+1)
		end
	end
	spawn_players()
	for i,p in pairs(teams[1]) do
		mission+=p.st[6]
		menuitem(i)
	end
	--victory
	if prevmission==16 and mission==16 then
		game_mode,nsp,teams=3,0,nil
	end
	sfx(-1,0)
end

function nextplayer()
	found,list,scroll_wait=false,teams[team_i],true
	for i=1,#list do
		player_i=player_i%#list+1
		if list[player_i].p > 0 then
			player,found=list[player_i],true
			if not (team_i==2 and #player.tl == 0) then
				cursor.x,cursor.y,cam_follow=player.x,player.y,cursor
			end
			grenade,action_mode,player.n_action={},0,0
			gen_path_map(flr(player.x/8),flr(player.y/8))
			break
		end
	end
	menuitem(1)
	menuitem(2)
	if team_i==1 then
		menuitem(1,"next member",nextplayer)
		menuitem(2,"end turn",function() for p in all(teams[1]) do p.p=0 end end)
	end
	return found
end

function spawn_players(nosave)
	if teams then
		pskills={}
		for a in all(teams[1]) do
			pskills[a.i]=a.st
		end
	end
	actors,particles,teams=new_line_table(),new_line_table(),{{},{}}
	for i=1,3 do
		ut=unit_types[i]
		local a=new_actor(ut.sx,ut.sy,0.625,ut,teams[1],pskills[i])
		for j=1,6 do
			dset(j+i*6,a.st[j])
		end
	end
end

function add_floating_text(text,a,col,y)
	add(floating_text,{text=text,t=60,col=col,x=a.x+3,y=a.y-12+(y or 0)})
end

function new_actor(x,y,angle,ut,team,st)
	local sprite_parts,sprite_parts_sorted,anim,panims,angle,to_angle={},{},anims[ut.ai],{anims[ut.ai],anims[ut.am],anims[ut.aa]},angle,angle
	for l=1,#models[ut.m] do
		local p,a=models[ut.m][l][1],models[ut.m][l][2]
		add(sprite_parts,{sprites=sprites[models[ut.m][l][3]],pos=p,angle=a,pos_prev=new_vector3d(p.x,p.y,p.z),angle_prev=a})
	end
	local a=add(team,add(actors[table_row(y)],{
		x=x,
		y=y,
		i=#team+1,
		team=team,
		actions={action_move,action_attack,special_funcs[ut.sf]},
		sprite_parts=sprite_parts,
		tl={},
		update=function(p)
			del(actors[table_row(p.y)],p)
			if p.action then
				p.action()
			end
			angle+=(to_angle-angle)*0.2
			add(actors[table_row(p.y)],p)
			if p.shocked then
				add(particles[table_row(p.y)],{x=p.x+rnd(8),y=p.y-rnd_range(-4,11),vx=0,vy=0.25,size=1,col=7,life=2})
			end
			p.at+=1
			sprite_parts_sorted={}
			local m_rotation_x, m_rotation_y,prev_frame,prev_frame_time=matrix_rotate_x(0),matrix_rotate_y(-angle),nil,0
			if p.at>=anim[#anim].t then
				p.at-=anim[#anim].t
				prev_frame,prev_frame_time,anim=anim[#anim],0,anims[anim.on_finish]
			end
			for a in all(anim) do
				if p.at<a.t and p.at>=prev_frame_time then
						if prev_frame then
							for p in all(prev_frame) do
								local limb=sprite_parts[p.l]
								limb.pos_prev,limb.angle_prev=p.p,p.a
							end
						end
						for next_frame in all(a) do
							local limb,t=sprite_parts[next_frame.l],(p.at-prev_frame_time)/(a.t-prev_frame_time)
							v3d_lerp(limb.pos,limb.pos_prev,next_frame.p,t)
							limb.angle=lerp(limb.angle_prev,next_frame.a,t)
						end
					break
				end
				prev_frame,prev_frame_time=a,a.t
			end
			for v in all(sprite_parts) do
				local t=matrix_mul_add(mx,matrix_mul_add(my,v3d_add(camera_pos,matrix_mul_add(m_rotation_x,matrix_mul_add(m_rotation_y,v.pos)))))
				t.z+=192
				v.pos_scr,insert_i=new_vector3d(round(t.z/camera_distance*t.x+64),round(t.z/camera_distance*t.y+64),t.z),0
				for i=1,#sprite_parts_sorted do
					if v.pos_scr.z<=sprite_parts_sorted[i].pos_scr.z then
						insert_i=i
						break
					end
				end
				table_insert(sprite_parts_sorted,v,insert_i)
			end
		end,
		draw=function(p)
			set_colors(p.cols)
			for v in all(sprite_parts_sorted) do
				local sp_count = #v.sprites.sprs
				draw_sprite_part(v,v.pos_scr.x,v.pos_scr.y,flr((0.5+angle+v.angle)*sp_count+0.5)%sp_count+1)
			end
			pal()
		end,
		set_turn_angle=function(p,pos1,pos2)
			to_angle=atan2(-(pos2.y-pos1.y),pos2.x-pos1.x)
			local a,b,c=to_angle-angle,to_angle-1-angle,to_angle+1-angle
			angle=to_angle-(abs(a)<abs(b) and (abs(a)<abs(c) and a or c) or (abs(b)<abs(c) and b or c))
		end,
		set_anim=function(p,v)
			anim,p.at=panims[v],0
		end
	}))
	for k,v in pairs(ut) do
		a[k]=v
	end
	if team==teams[1] then
		if st then
			for i=1,5 do
				if st[i]~=0 then
					for k,m in pairs(skilltree[a.i][i][st[i]].m) do
						a[k]+=m
					end
				end
			end
			a.st=st
		else
			a.st={0,0,0,0,0,nsp}
		end
	end
	a:update()
	return a
end

function player_think()
	tg=false
	if mouse_enable and mouse_on_screen() then
		cursor.x,cursor.y,tg=min(max(flr((cam_x+mstate_c.x)/8)*8,0),504),min(max(flr((cam_y+mstate_c.y)/8)*8,0),248),true
	end
	if mstate_c.x~=mstate_p.x or mstate_c.y~=mstate_p.y then
		mouse_enable=true
	end

	if bp0 then
		cursor.x,tg,mouse_enable=max(cursor.x-8,0),true,false
	end
	if bp1 then
		cursor.x,tg,mouse_enable=min(cursor.x+8,504),true,false
	end
	if bp2 then
		cursor.y,tg,mouse_enable=max(cursor.y-8,0),true,false
	end
	if bp3 then
		cursor.y,tg,mouse_enable=min(cursor.y+8,248),true,false
	end
	
	player.n_action,target=0,get_cursor_actor(2)
	if action_mode==0 then
		movenode=get_cursor_node()
		local mp=getmovep(movenode)
		if movenode and mp<=player.p then
			player.n_action,action_cost=1,mp
		else
			target_message(2,player.p)
		end	
	else
		if player.stt==2 then
			target_message(3,2)
		elseif can_special() then
			player.n_action,action_cost=3,2
		else
			if player.stt==1 and target and v3d_distance2d(target,player)>player.sr then
				add(menu,"too far")
			end
			grenade,player.n_action={},0
		end
	end
	if bp4 or mstate_c.b1 and not mstate_p.b1 then
		if player.n_action>0 then
			grenade,mouse_enable,tg={},false,false
			player.actions[player.n_action]()
		end
	end
	if bp5 or mstate_c.b2 and not mstate_p.b2 then
		action_mode,grenade,tg=(action_mode+1)%2,{},true
	end
	if tg and action_mode==1 and player.stt==0 and can_special() then
		new_grenade(true)
	end
	if btnp(5,1) or mstate_c.b3 and not mstate_p.b3 then
		nextplayer()
	end
end

function target_message(n_action,points)
	if target then
		local hitchance=target.los
		if hitchance>=0 then
			hitchance=min(100,ceil(hitchance*(player.ac+(n_action-2)*player.sac)/100))
			add(menu,"hit "..hitchance.."%")
			player.n_action,action_cost=n_action,points
		elseif hitchance==-1 then
			add(menu,"blocked")
		else
			add(menu,"too far")
		end
		add(menu,"hp "..target.hp)
		player.hitchance=hitchance
	end
end

function get_cursor_actor(ti)
	if ti==0 then
		return cursor
	end
	for e in all(teams[ti]) do
		if e.x==cursor.x and e.y==cursor.y then
			return e
		end
	end
end

function can_special()
	target=get_cursor_actor(player.stt)
	return target and not (player.stt~=1 and player.x==cursor.x and player.y==cursor.y) and v3d_distance2d(cursor,player)<=player.sr and player.sa>0 and player.p>=2
end

function ai_think()
	if movenode then
		if target.los>30 or player.p==1 and target.los>0 then
			player.hitchance=target.los
			if player.actions[3] and rnd(4)<1 then
				player.n_action=3
				player.actions[3]()
			else
				action_attack()
			end
			return
		end
		while movenode.parent~=nil and movenode.f<24 do
			movenode=movenode.parent
		end
		local node=movenode
		while node.parent~=nil do
			if getmovep(node)<2 and find_los(node,target,128)>30 then
				movenode=node
				break
			end
			node=node.parent
		end
		if movenode.parent then
			action_move()
		else
			player.p-=1
		end
	else
		player.p=0
	end
end

function action_move()
	while movenode.parent~=nil do
		movenode.parent.next,movenode=movenode,movenode.parent
	end
	pathlerp,cam_follow,player.action=0,player,action_move_cont
	player:set_anim(2)
	sfx(player.fxm,0)
end

function action_move_cont()
	pathlerp+=0.1
	if movenode.x==movenode.next.x or movenode.y==movenode.next.y then
		pathlerp+=0.04
	end
	if pathlerp>=1 then
		pathlerp-=1
		movenode=movenode.next
	end
	if movenode.next then
		player:set_turn_angle(movenode,movenode.next)
		v3d_lerp(player,movenode,movenode.next,pathlerp)
		if player.team==teams[2] and player.at%3==0 then
			local y=player.y+rnd_range(0,7)
			add(particles[table_row(y)],{x=player.x+rnd_range(0,7),y=y,vx=0,vy=-0.15,size=0.5,col=0,life=14+rnd_range(0,6)})
		end
	else
		player.p-=getmovep(movenode)
		player.x,player.y,cursor.x,cursor.y,cam_follow,player.action=movenode.x,movenode.y,movenode.x,movenode.y,cursor,nil
		player:set_anim(1)
		gen_path_map(flr(player.x/8),flr(player.y/8))
		sfx(-1,0)
	end
end

function init_action(next_func,follow)
	cam_follow,player.action=follow,next_func
	player:set_anim(3)
	player:set_turn_angle(player,target)
	if player.n_action==3 then
		sfx(player.fxs)
	end
end

function action_attack()
	init_action(action_attack_cont,player)
	sfx(player.fxa)
end

function action_attack_cont()
	if player.at>=13 then
		cam_follow=target
		local dmg,threat=rnd_range(player.dmn,player.dmx),1
		if rnd_range(0,100)<=player.hitchance then
			if player.n_action==3 then
				target.p,target.shocked,dmg,threat=0,true,player.sdmg,10
				add_floating_text("shocked",target,12,-6)
			end
			if dmg>0 then
				damage(target,dmg)
			end
		else
			add_floating_text("miss",target,8)
		end
		target.tl[player.i]+=threat
		player.p,player.action,wait=0,nil,60
	end
end

function action_grenade()
	new_grenade()
	init_action(action_grenade_cont,grenade)
	player.sa-=1
end

function action_grenade_cont()
	if grenade:update() then
		for t in all(teams) do
			for a in all(t) do
				local d=v3d_distance2d(v3d_add(a,new_vector3d(3,3,0)),grenade)
				if d<32 then
					damage(a,ceil((32-d)/32*player.sdmg))
				end
			end
		end
		grenade,player.p,player.action,wait={},0,nil,60
	end
end

function action_shock()
	init_action(action_attack_cont,player)
	player.sa-=1
end

function action_heal()
	init_action(nil,player)
	add_floating_text("+"..player.sdmg,target,14)
	target.hp,player.p,player.action,wait=min(target.hp+player.sdmg,100),0,nil,60
	player.sa-=1
end

function damage(a,dmg)
	dmg=flr(max(1,dmg*(100-a.a)/100))
	a.hp-=dmg
	add_floating_text("-"..dmg,a,9)
	if a.team~=player.team then
		a.tl[player.i]=(a.tl[player.i] or 0)+dmg
	end
	if a.hp<=0 then
		die(a)
	end
end

function die(p)
	for t in all(teams) do
		for tm in all(t) do
			if tm.pht==p then
				tm.pht=nil
			end
		end
	end
	if p.si==255 then
		new_actor(p.x,p.y,0.625,unit_types[4],teams[2])
		if p.spwnx then
			new_actor(p.spwnx,p.spwny,-0.625,unit_types[4],teams[2])
		end
		sfx(55)
	else
		for i=1,32 do
			add(particles[table_row(p.y)],{x=p.x+rnd(8),y=p.y-rnd_range(-4,14),vx=0,vy=0.5,size=0.25,col=p.cols[rnd_range(1,2)],life=rnd_range(8,26)})
		end
		sfx(8)
	end
	--del(p.team,del(actors[table_row(p.y)],p))
end

function wall_blocked(bvalc,bvaln,gz)
	return bvaln==255 or (bvalc!=254 and bvaln==254 and gz>-4)
end

function new_grenade(tracer)
	local d=tracer~=true and v3d_distance2d(player,cursor)/8*((100-player.sac)/100) or 0
	local x,y,z,vx,vy,vz,t,sx,sy,sw,sh=player.x+3,player.y+3,-4,(cursor.x-player.x+rnd_range(-d,d))*0.0275,(cursor.y-player.y+rnd_range(-d,d))*0.0275,-1.325,180,104,40,4,4
	grenade={
		x=x,y=y,z=z,
		path=tracer and new_line_table() or nil,
		step=function()
			local mapxc,mapyc,mapxn,mapyn=flr(x/8),flr(y/8),flr((x+vx)/8),flr((y+vy)/8)
			local bvalc,xover,yover=get_bval_actors(mapxc,mapyc),255,255
			if wall_blocked(bvalc,get_bval_actors(mapxn,mapyn),z) and not wall_blocked(bvalc,get_bval_actors(mapxc,mapyn),z) then
				xover=(x+vx)%8
				if vx<0 then
					xover-=8
				end
			end
			if wall_blocked(bvalc,get_bval_actors(mapxn,mapyn),z) and not wall_blocked(bvalc,get_bval_actors(mapxn,mapyc),z) then
				yover=(y+vy)%8
				if vy<0 then
					yover-=8
				end
			end
			
			if abs(xover)<abs(yover) then
				x=x+vx-xover
				vx=-vx
				y+=vy
			elseif abs(yover)<abs(xover) then
				y=y+vy-yover
				vy=-vy
				x+=vx
			elseif xover<255 then
				x,y=x+vx-xover,y+vy-yover
				vx=-vx
				vy=-vy
			else
				y+=vy
				x+=vx
			end
			z+=vz
			local groundz=get_bval(flr(x/8),flr(y/8))==254 and -4 or 0
			if z+vz>groundz then
				if not grenade.path then
					sfx(7)
				end
				z=groundz-(z+vz-groundz)
				vx,vy,vz=vx*0.6,vy*0.6,-vz*0.6
			end
			if abs(vx)+abs(vy)<0.1 then
				vx,vy,vz,z=0,0,0,groundz
			else
				vz=vz+0.125
			end
			grenade.x,grenade.y,grenade.z=x,y,z
		end,
		update=function()
			if t>60 then
				del(actors[table_row(y)],grenade)
				grenade:step()
				if t==61 then
					sfx(6)
				else
					add(actors[table_row(y)],grenade)
				end
			else
				local psize,particle_row=max(1,(t-10)/50*5),particles[table_row(y)]
				if t==60 or t==58 then
					add(particle_row,{x=x,y=y,vx=0,vy=0,size=32,col=10,life=2})
					for i=0,32 do
						add(particle_row,{x=x,y=y,vx=sin(i/32)*(rnd(1)+1),vy=cos(i/32)*(rnd(1)+1),size=1,col=10,life=rnd_range(14,24)})
					end
				end
				if t>40 then
					for i=1,ceil(psize) do
						local a=rnd(1)
						add(particle_row,{x=x+sin(a)*rnd(20-psize),y=y+cos(a)*rnd(20-psize),vx=0,vy=0,size=rnd(psize)+psize,col=rnd_range(8,10),life=1})
					end
				end
				if t<50 then
					for i=1,2 do
						local a=rnd(1)
						add(particle_row,{x=x+sin(a)*rnd_range(28,32),y=y+cos(a)*rnd_range(28,32),vx=0,vy=0.25,size=0.5,col=rnd_range(8,10),life=rnd_range(4,14)})
					end
				end
			end
			t-=1
			return t<=0
		end,
		draw=function()
			camera(cam_x,cam_y)
			local px,py=x-sw/2,y-sh/2
			for i=2,15 do
				pal(i,1)
			end
			sspr(sx,sy,sw,sh,px,py+(get_bval(flr(x/8),flr(y/8))==254 and -3 or 1))
			pal()
			sspr(sx,sy,sw,sh,px,py+z)
		end
	}
	if tracer then
		for i=1,120 do
			grenade:step()
			grenade.pathend=add(grenade.path[table_row(y)],new_vector3d(x,y,z))
		end
	end
end

function draw_attack(col)
	local x1,y1,v=player.x+3,player.y-5,col/3-2
	if player.at>10-v*2 and player.at<14 then
		for i=1,12 do
			local x2,y2=lerp(player.x+3,target.x+3,i/12)+rnd_range(-v,v),lerp(player.y-5,target.y-5,i/12)+rnd_range(-v,v)
			line(x1,y1,x2,y2,col)
			x1,y1=x2,y2
		end
	end
end

function set_colors(cols)
	pal(3,cols[1])
	pal(11,cols[2])
end

function draw_sprite_part(sp,x,y,i)
	local sprites=sp.sprites
	local sprite=sprites.sprs[i]
	sspr(sprite.x,sprite.y,sprites.w,sprites.h,x+sprite.ox,y+sprite.oy,sprites.w,sprites.h,sprite.f~=0)
end

function find_los(origin,dest,maxdist)
	local dist_v=v3d_sub(dest,origin)
	local dist=v3d_length(dist_v)
	if dist>maxdist or abs(dist_v.x)>maxdist or abs(dist_v.y)>maxdist then
		return -2
	end
	
	local mapx,mapy,dir_vector=flr(origin.x/8),flr(origin.y/8),new_vector3d(dist_v.x/dist,dist_v.y/dist,dist_v.z/dist)
	local step,blockm,hitchance,dx,dy=get_intersection_step(3,3,dir_vector),1,min(100,106-dist*0.75),flr(dest.x/8),flr(dest.y/8)
	for i=0,32 do
		mapx+=step[2].x
		mapy+=step[2].y
		step=get_intersection_step(step[1].x+step[2].x*-8,step[1].y+step[2].y*-8,dir_vector)
		if mapx==dx and mapy==dy then
			return flr(hitchance*blockm)
		end
		local m=get_bval(mapx,mapy)
		if m==255 then
			return -1
		elseif m==254 then
			if abs(dx-mapx)<=1 and abs(dy-mapy)<=1 then
				blockm=0.5
			end
		else
			for a in all(actors[mapy+1]) do
				if a~=player and a.x==mapx*8 then
					return -1
				end
			end
		end
	end
	return -2
end

function get_bval(x,y)
	local m=oget(x,y)
	if m>=254 then
		return m
	elseif m>0 and m<=#mapspr then
		return mapspr[m].bval
	end
end

function get_bval_actors(x,y)
	for t in all(teams) do
		for a in all(t) do
			if a~=player and a.x==x*8 and a.y==y*8 then
				return 255
			end
		end
	end
	return (x<0 or y<0 or x>63 or y>31) and 255 or get_bval(x,y)
end

function get_intersection_step(ox,oy,d_vector)
	local tx,ix,stepx = get_time_intersect_step(ox,d_vector.x)
	local ty,iy,stepy = get_time_intersect_step(oy,d_vector.y)
	
	if (tx < ty) then
		iy,stepy=oy+d_vector.y*tx,0
	else
		ix,stepx=ox+d_vector.x*ty,0
	end
	
	return {new_vector3d(ix,iy),new_vector3d(stepx,stepy)}
end

function get_time_intersect_step(p,d)
	if d == 0 then
		return 32761,p,0
	end
	
	local ood = 1 / d
	local t1,t2 = -p * ood, (7-p) * ood
	local t = t1 > t2 and t1 or t2
	return t, round(p+d*t), ood < 0 and -1 or 1
end

-- path finding
function checkn(x,y,parent,mcost)
	if mapgrid[x] then
		local node,g,canadd=mapgrid[x][y],parent.g+mcost,true
		if node and not node.closed and not node.impassable and g<=104 then
			if g<=node.g then
				node.g,node.parent = g,parent
				if target then
					node.f=abs(target.x-node.x)+abs(target.y-node.y)
					if node.f<nodef then
						nodef,movenode=node.f,node
					end
				end
			end
			for o in all(olist) do
				if o==node then
					canadd=false
					break
				end
			end
			if canadd then
				add(olist,node)
			end
			return true
		end
	end
end

function findn(x,y)
	local node=mapgrid[x][y]
	node.closed=true
	local l,r=checkn(x-1,y,node,10),checkn(x+1,y,node,10)
	findnd(x,y-1,node,l,r)
	findnd(x,y+1,node,l,r)
end

function findnd(x,y,node,l,r)
	if checkn(x,y,node,10) then
		if (l) checkn(x-1,y,node,14)
		if (r) checkn(x+1,y,node,14)
	end
end

function gen_path_map(ox,oy)
	target,highest_threat=player.pht,player.pht and player.tl[player.pht.i] or 0
	for e in all(teams[team_i%2+1]) do
		e.los=find_los(player,e,128)
		if e.los>0 then
			player.tl[e.i],e.tl[player.i]=player.tl[e.i] or 1,e.tl[player.i] or 1
		end
		local et=player.tl[e.i]
		if et and et>highest_threat then
			highest_threat,target,player.pht=et,e,e
		end
	end
	mapgrid,mgx,mgy={},max(ox-13,0),max(oy-13,0)
	for x=1,min(ox+11,64)-mgx do
		mapgrid[x]={}
		for y=1,min(oy+11,32)-mgy do
			local mx,my=mgx+x-1,mgy+y-1
			mapgrid[x][y]={x=mx*8,y=my*8,z=0,gx=x,gy=y,g=32761,impassable=oget(mx,my)>7}
			for a in all(actors[my+1]) do
				if a~=player and a.x==mx*8 then
					mapgrid[x][y].impassable=true
					break
				end
			end
		end
	end
	local onode=mapgrid[ox-mgx+1][oy-mgy+1]
	onode.g,olist,movenode,nodef=0,{onode},nil,target and abs(target.x-onode.x)+abs(target.y-onode.y) or 32761
	onode.f=nodef
	while #olist>0 do
		local cur=olist[1]
		del(olist,cur)
		findn(cur.gx,cur.gy)
	end
	movelines={}
	if player.p==2 then
		getmovelines(104,14)
		getmovelines(64,12)
	else
		getmovelines(24,12)
	end
end

function getmovelines(maxval,c)
	local sgmin=16
	for x=1,#mapgrid do
		for y=1,#mapgrid[x] do
			local mg=mapgrid[x][y]
			if mg.g<=maxval then
				if x==1 or mapgrid[x-1][y].g>maxval then
					add(movelines,{mg.x,mg.y,mg.x,mg.y+7,c})
				end
				if y==1 or mapgrid[x][y-1].g>maxval then
					add(movelines,{mg.x,mg.y,mg.x+7,mg.y,c})
				end
				if x==#mapgrid or mapgrid[x+1][y].g>maxval then
					add(movelines,{mg.x+7,mg.y,mg.x+7,mg.y+7,c})
				end
				if y==#mapgrid[x] or mapgrid[x][y+1].g>maxval then
					add(movelines,{mg.x,mg.y+7,mg.x+7,mg.y+7,c})
				end
			end
			if mg.g>0 and mg.g<sgmin then
				sgmin,player.spwnx,player.spwny=mg.g,mg.x,mg.y
			end
		end
	end
end

function get_cursor_node()
	local cur_x,cur_y = flr(cursor.x/8),flr(cursor.y/8)
	if cur_x >= mgx and cur_x < mgx+#mapgrid and cur_y >= mgy and cur_y < mgy+#mapgrid[1] then
		return mapgrid[cur_x-mgx+1][cur_y-mgy+1]
	end
end

function getmovep(node)
	return (node and node.g > 0) and (node.g <= (player.p == 2 and 64 or 24) and 1 or node.g <= 104 and 2) or 3
end

function oset(x,y,val)
	poke(0x4300+y*64+x,val)
end

function oget(x,y)
	return peek(0x4300+y*64+x)
end

function gen_map()
	memset(0x4300,0,4096)
	memset(0x2000,0,4096)
	
	rooms,outside_blockers,cursor={},{},new_vector3d(16,16)
	cam_follow,player_i,team_i,enemy_room = cursor,0,1,0
	for i=0,31 do
		local r=try_place_object(rnd_range(3,4)*3,rnd_range(3,4)*3,2,2,60,27,3,rooms,room_types[max(1,rnd_range(0,#room_types))])
		if r then
			add(outside_blockers,{r[1]-1,r[2]-1,r[3]+2,r[4]+2})
		end
		for x=0,63 do
			mset(x,i,rnd_range(134,140))
		end
	end
	
	for r1 in all(rooms) do
		for y=r1[2],r1[4] do
			for x=r1[1],r1[3] do
				if (x==r1[1] or x==r1[3] or y==r1[2] or y==r1[4]) and oget(x,y)<r1.type.w then
					oset(x,y,r1.type.w)
				end
				if mget(x,y)~=192 then
					mset(x,y,r1.type.f[rnd_range(1,#r1.type.f)])
				end
			end
		end
	end
	for r1 in all(rooms) do 	
		for r2 in all(rooms) do
			if r1 ~= r2 then
				for i=1,2 do
					if r1[i] == r2[i+2] then
						local i1,i2=i%2+1,i%2+3
						local y1,y2 = max(r1[i1],r2[i1]),min(r1[i2],r2[i2])
						if y1 < y2 then
							add_door(r1[i],y1,y2,i==2,r1,r2)
							r1.doors[i],r2.doors[i+2] = true,true
						end
					end
				end
			end
		end
	end
	for r1 in all(rooms) do
		for i=1,4 do
			if not r1.doors[i] then
				add_door(r1[i],r1[i%2+1],r1[i%2+3],i%2==0,r1)
			end
		end
		local prop = props[r1.type.p[1]]
		local proprect = add(r1.blockers,new_rect(r1[1]+flr(r1.w/2-prop.tw/2)+1,r1[2]+flr(r1.h/2-prop.th/2)+1,prop.tw,prop.th))
		place_prop(proprect[1],proprect[2],prop.sprs)
		for i=2,#r1.type.p do
			prop = props[r1.type.p[i]]
			local room_pos = room_positions[prop.rp[rnd_range(1,#prop.rp)]]
			local px,py = room_pos[3],room_pos[4]
			-- mx = 0 or 1 (against left or right)
			-- px = 0 or 1 (edge or center)
			local blocker = try_place_object(prop.tw,prop.th,r1[1]+(r1.w-1-prop.tw)*room_pos[1],r1[2]+(r1.h-1-prop.th)*room_pos[2],r1.w*px-px-prop.tw*(px-1),r1.h*py-py-prop.th*(py-1),1,r1.blockers)
			if blocker then
				place_prop(blocker[1],blocker[2],prop.sprs)
			end
		end
	end
	
	for y=2,31 do
		for x=3,62 do
			local m,x1,y1 = oget(x,y),x+1,y+1
			if m==0 then
				mset(x+64,y,get_shadow_val(x,y)+112)
			else
				local wall_type = get_wall_type(m)
				if wall_type then
					local r,b = oget(x1,y),oget(x,y1)
					if is_wall(r,wall_type) then
						oset(x1,y,r+1)
						m+=4
					end
					if is_wall(b,wall_type) then
						oset(x,y1,b+2)
						m+=8
					end
					oset(x,y,m)
					mset(x,y,0)
				end
			end
			if rnd()<0.05 and try_place_object(1,1,x-1,y-1,1,1,1,outside_blockers) then
				place_prop(x,y,props[rnd_range(21,22)].sprs)
			end
		end
	end
	local el={}
	for i=1,12+mission do
		el[i]=flr(i/29*4)+4
	end
	while #el>0 do
		local r1=rooms[enemy_room+1]
		enemy_room=(enemy_room+1)%#rooms
		local a=try_place_object(1,1,r1[1]+1,r1[2]+1,r1.w-2,r1.h-2,1,r1.blockers)
		if a then
			local ei=del(el,el[rnd_range(1,#el)])
			new_actor(flr(a[1]*8),flr(a[2]*8),0.5,unit_types[ei],teams[2])
		end
	end
	for i=1,4 do
		nextplayer()
	end
end

function table_row(y)
	return round(y/8+1)
end

function new_line_table()
	local t={}
	for i=1,32 do
		t[i]={}
	end
	return t
end

function place_prop(px,py,prop_sprs)
	for j=1,#prop_sprs do
		local sprite = mapspr[prop_sprs[j]]
		for y=0,sprite.th-1 do
			for x=0,sprite.tw-1 do
				oset(px+sprite.gx+x,py+sprite.gy+y,sprite.bval)
			end
		end
		oset(px+sprite.gx,py+sprite.gy+sprite.th-1,prop_sprs[j])
	end
end

function get_shadow_val(x,y)
	local val = 0
	if (oget(x-1,y)>7) val += 1
	if (oget(x,y-1)>7) val += 2
	if (oget(x-1,y-1)>7) val += 4
	return val
end

function get_wall_type(m)
	return (m >= 8 and m <= 23) and 8 or ((m >= 24 and m <= 39) and 24 or nil)
end

function is_wall(m,val)
	return m >= val and m <= val+15
end

function add_door(x,y1,y2,flip,r1,r2)
	if y2-y1 > 3 then
		y1 += 1
		y2 -= 1
	end
	local y,xp,yp = rnd_range(y1+1,y2-2),0,1
	if flip then
		x,y,xp,yp = y,x,yp,xp
	end
	oset(x,y,0)
	oset(x+xp,y+yp,0)
	local r = add(r1.blockers,new_rect(x-yp,y-xp,2+yp,2+xp))
	if r2 then
		add(r2.blockers,r)
	end
end

function rnd_range(vmin,vmax)
	return vmin+flr(rnd(vmax-vmin+1))
end

function new_rect(x,y,w,h,rtype)
	return {x,y,x+w,y+h,w=w,h=h,blockers={},type=rtype,doors={}}
end

function try_place_object(w,h,bx,by,bw,bh,grid_size,list,rtype)
	for i=1,30 do
		local new_r,can_add = new_rect(bx+1+flr(rnd_range(0,bw-1-w)/grid_size)*grid_size,by+1+flr(rnd_range(0,bh-1-h)/grid_size)*grid_size,w,h,rtype),true
		for r in all(list) do
			if not (new_r[3] <= r[1] or new_r[4] <= r[2] or new_r[1] >= r[3] or new_r[2] >= r[4]) then
				can_add = false
				break
			end
		end
		if can_add then
			return add(list,new_r)
		end
	end
end

-- load & save
function read_sprites_and_anims()
	si,bo=0,0x2000
	sprites,anims,models,unit_types,mapspr,props,room_positions,room_types,btns,pals,skilltree=parse_table(),parse_table(),parse_table(),parse_table(),parse_table(),parse_table(),parse_table(),parse_table(),parse_table(),parse_table(),parse_table()
end

function parse_table()
	si+=1
	local key,ti,t=1,1,{}
	while si<=#mapdata do
		local c,w=sub(mapdata,si,si),false
		if c=="@" then
			t[ti],w,key=key,true,ti
		elseif c=="#" then
			t[key],w=peek(bo),true
			bo+=1
		elseif c=="$" then
			t[key],w=(peek(bo)-128)/16,true
			bo+=1
		elseif c=="{" then
			t[key],w=parse_table(),true
		elseif c=="}" then
			break
		else
			key=key==ti and c or key..c
		end
		if w then
			if key==ti then
				ti+=1
			end
			key=ti
		end
		si+=1
	end
	return t
end

-- vector & matrix
function new_vector3d(x,y,z)
	return {x=x and x or 0,y=y and y or 0,z=z and z or 0}
end

function v3d_add(a,b)
	return new_vector3d(a.x+b.x,a.y+b.y,a.z+b.z)
end

function v3d_sub(a,b)
	return new_vector3d(a.x-b.x,a.y-b.y,a.z-b.z)
end

function v3d_dot(a,b)
	local d=new_vector3d(a.x*b.x,a.y*b.y,a.z*b.z)
	return d.x+d.y+d.z
end

function v3d_length(a)
	if a.x+a.y+a.z<256 then
		local d = v3d_dot(a,a)
		if d >= 0 then
			return sqrt(d)
		end
	end
	return 32761
end

function v3d_distance2d(a,b)
	return v3d_length(new_vector3d(a.x-b.x,a.y-b.y,0))
end

function matrix_rotate_x(a)
	return {{1,0,0},{0,sin(a),cos(a)},{0,cos(a),-sin(a)}}
end

function matrix_rotate_y(a)
	return {{cos(a),0,sin(a)},{-sin(a),0,cos(a)},{0,1,0}}
end

function matrix_mul_add_row(m_row,v)
	return m_row[1]*v.x+m_row[2]*v.y+m_row[3]*v.z
end

function matrix_mul_add(m,v)
	return new_vector3d(matrix_mul_add_row(m[1],v),matrix_mul_add_row(m[2],v),matrix_mul_add_row(m[3],v))
end

function table_insert(t,item,index)
	if index<1 or index>#t then
		add(t,item)
	else
		for i=#t,index,-1 do
			t[i+1]=t[i]
		end
		t[index]=item
	end
end

function lerp(a,b,t)
	return a+(b-a)*t
end

function v3d_lerp(c,a,b,t)
	c.x,c.y,c.z=lerp(a.x,b.x,t),lerp(a.y,b.y,t),lerp(a.z,b.z,t)
end

function round(a)
	return a < 0 and ceil(a-0.5) or flr(a+0.5)
end

mapdata="{h#sprs{{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}}w#}{h#sprs{{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}}w#}{h#sprs{{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}}w#}{h#sprs{{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}}w#}{h#sprs{{x#y#ox$oy#f#}}w#}{h#sprs{{x#y#ox$oy$f#}}w#}{h#sprs{{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}}w#}{h#sprs{{x#y#ox$oy$f#}}w#}{h#sprs{{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}}w#}{h#sprs{{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}}w#}{h#sprs{{x#y#ox$oy$f#}}w#}{h#sprs{{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}}w#}{h#sprs{{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox#oy$f#}{x#y#ox#oy$f#}{x#y#ox#oy$f#}{x#y#ox#oy$f#}{x#y#ox#oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}}w#}{h#sprs{{x#y#ox$oy#f#}{x#y#ox$oy#f#}{x#y#ox$oy#f#}{x#y#ox$oy#f#}{x#y#ox$oy#f#}{x#y#ox#oy#f#}{x#y#ox#oy#f#}{x#y#ox#oy#f#}{x#y#ox#oy#f#}{x#y#ox#oy#f#}{x#y#ox#oy#f#}{x#y#ox$oy#f#}{x#y#ox$oy#f#}{x#y#ox$oy#f#}{x#y#ox$oy#f#}{x#y#ox$oy#f#}}w#}{h#sprs{{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}}w#}{h#sprs{{x#y#ox$oy$f#}}w#}{h#sprs{{x#y#ox$oy$f#}}w#}{h#sprs{{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}}w#}{h#sprs{{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox#oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}}w#}{h#sprs{{x#y#ox#oy$f#}{x#y#ox#oy$f#}{x#y#ox#oy$f#}{x#y#ox#oy$f#}{x#y#ox#oy$f#}{x#y#ox#oy$f#}}w#}{h#sprs{{x#y#ox$oy$f#}{x#y#ox#oy$f#}{x#y#ox#oy$f#}{x#y#ox#oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}{x#y#ox$oy$f#}}w#}{h#sprs{{x#y#ox$oy$f#}}w#}}{{{l#a#p{x#y$z#}}{l#a#p{x#y$z#}}{l#a#p{x$y$z$}}{l#a#p{x$y#z#}}{l#a#p{x$y#z#}}{l#a#p{x#y$z#}}{l#a#p{x#y$z#}}t#}on_finish#}{{{l#a#p{x$y#z$}}{l#a#p{x$y#z$}}{l#a#p{x#y$z$}}{l#a#p{x$y$z$}}{l#a#p{x#y$z$}}t#}{{l#a#p{x$y#z#}}{l#a#p{x$y$z#}}{l#a#p{x#y$z$}}{l#a#p{x$y$z$}}{l#a#p{x#y$z$}}t#}{{l#a#p{x$y#z$}}{l#a#p{x$y#z$}}{l#a#p{x#y$z$}}{l#a#p{x$y$z$}}{l#a#p{x#y$z$}}t#}{{l#a#p{x$y$z#}}{l#a#p{x$y#z#}}{l#a#p{x#y$z$}}{l#a#p{x$y$z$}}{l#a#p{x#y$z$}}t#}on_finish#}{{{l#a$p{x#y$z$}}{l#a#p{x#y$z$}}t#}{{l#a$p{x#y$z$}}{l#a#p{x#y$z$}}t#}{{l#a$p{x#y$z$}}{l#a#p{x#y$z$}}t#}on_finish#}{{{l#a#p{x#y$z#}}{l#a#p{x#y$z$}}{l#a#p{x#y$z#}}t#}{{l#a#p{x#y$z#}}{l#a#p{x#y$z$}}{l#a$p{x#y$z#}}t#}on_finish#}{{{l#a#p{x#y$z#}}{l#a$p{x$y$z$}}{l#a$p{x$y#z$}}{l#a$p{x$y#z$}}{l#a$p{x$y#z$}}{l#a#p{x#y$z$}}t#}{{l#a#p{x#y$z#}}{l#a$p{x$y#z$}}{l#a$p{x$y$z$}}{l#a$p{x$y#z$}}{l#a$p{x$y#z$}}{l#a#p{x#y$z$}}t#}{{l#a#p{x#y$z#}}{l#a$p{x$y#z$}}{l#a$p{x$y#z$}}{l#a$p{x$y$z$}}{l#a$p{x$y#z$}}{l#a#p{x#y$z$}}t#}{{l#a#p{x#y$z#}}{l#a$p{x$y#z$}}{l#a$p{x$y#z$}}{l#a$p{x$y#z$}}{l#a$p{x$y$z$}}{l#a#p{x#y$z$}}t#}on_finish#}{{{l#a$p{x$y$z$}}{l#a$p{x$y#z$}}{l#a$p{x$y$z$}}{l#a$p{x$y#z$}}{l#a#p{x#y$z#}}{l#a#p{x#y$z#}}t#}{{l#a$p{x$y#z$}}{l#a$p{x$y$z$}}{l#a$p{x$y$z#}}{l#a$p{x$y#z#}}{l#a#p{x#y$z#}}{l#a#p{x#y$z#}}t#}{{l#a$p{x$y#z$}}{l#a$p{x$y$z$}}{l#a$p{x$y#z$}}{l#a$p{x$y$z$}}{l#a#p{x#y$z#}}{l#a#p{x#y$z#}}t#}{{l#a$p{x$y$z$}}{l#a$p{x$y#z$}}{l#a$p{x$y#z#}}{l#a$p{x$y$z#}}{l#a#p{x#y$z#}}{l#a#p{x#y$z#}}t#}on_finish#}{{{l#a#p{x#y$z$}}{l#a#p{x#y$z$}}{l#a#p{x#y$z$}}{l#a#p{x#y$z#}}{l#a$p{x$y#z$}}{l#a$p{x$y#z$}}t#}{{l#a#p{x#y$z$}}{l#a#p{x#y$z$}}{l#a#p{x#y$z#}}t#}on_finish#}{{{l#a#p{x#y$z$}}{l#a#p{x#y$z$}}{l#a#p{x#y$z$}}{l#a#p{x#y$z#}}{l#a#p{x#y$z$}}{l#a$p{x$y#z$}}t#}{{l#a#p{x#y$z$}}{l#a#p{x#y$z$}}{l#a#p{x#y$z$}}{l#a#p{x#y$z#}}{l#a$p{x$y#z$}}{l#a$p{x$y$z$}}t#}{{l#a#p{x#y$z$}}{l#a#p{x#y$z$}}{l#a#p{x#y$z$}}{l#a#p{x#y$z#}}{l#a$p{x$y#z$}}{l#a#p{x$y$z$}}t#}{{l#a#p{x#y$z$}}{l#a#p{x#y$z$}}{l#a#p{x#y$z$}}{l#a#p{x#y$z#}}{l#a$p{x$y$z$}}{l#a$p{x$y#z$}}t#}on_finish#}{{{l#a#p{x#y$z#}}{l#a#p{x#y$z$}}{l#a$p{x$y$z#}}{l#a$p{x$y$z$}}{l#a$p{x#y$z$}}{l#a#p{x$y$z$}}{l#a$p{x$y#z$}}{l#a$p{x$y$z$}}{l#a$p{x$y#z$}}{l#a#p{x$y$z$}}{l#a$p{x$y$z$}}t#}{{l#a$p{x$y$z#}}{l#a$p{x$y$z$}}{l#a$p{x#y$z#}}{l#a$p{x$y$z$}}{l#a$p{x$y#z$}}{l#a$p{x$y$z$}}{l#a$p{x$y#z$}}{l#a#p{x$y$z$}}{l#a$p{x#y$z#}}t#}on_finish#}{{{l#a#p{x#y$z#}}{l#a#p{x#y$z$}}{l#a$p{x$y$z#}}{l#a$p{x$y$z$}}{l#a$p{x#y$z$}}{l#a#p{x$y$z$}}{l#a#p{x$y#z$}}{l#a#p{x$y$z$}}{l#a#p{x$y#z$}}{l#a#p{x$y$z$}}{l#a$p{x#y$z#}}t#}on_finish#}}{{{x#y$z#}##}{{x#y$z#}##}{{x$y$z$}##}{{x$y#z#}##}{{x$y#z#}##}{{x#y$z#}##}{{x#y$z#}##}}{{{x#y$z#}##}{{x#y$z$}##}{{x#y$z#}##}}{{{x#y$z#}##}{{x#y$z#}##}{{x$y$z$}##}{{x$y#z#}##}{{x$y#z#}##}{{x#y$z#}##}{{x#y$z#}##}}{{{x#y$z#}##}{{x#y#z$}$#}{{x$y#z$}$#}{{x$y#z$}$#}{{x$y#z$}$#}{{x#y$z$}##}}{{{x#y$z#}##}{{x#y$z#}##}{{x$y$z$}##}{{x$y#z#}##}{{x$y#z#}##}{{x#y$z#}##}{{x#y$z#}##}}{{{x#y$z$}##}{{x#y$z$}##}{{x#y$z$}##}{{x#y$z#}##}{{x$y#z$}$#}{{x$y#z$}$#}}{{{x#y$z#}##}{{x#y$z$}##}{{x$y$z#}$#}{{x$y$z$}$#}{{x#y$z$}$#}{{x$y$z$}##}{{x$y#z$}$#}{{x$y$z$}$#}{{x$y#z$}$#}{{x$y$z$}##}{{x#y$z#}$#}}}{p#stt#cols{##}sdmg#fxs#z#sac#sa#am#sy#a#si#sr#sf#ai#fxm#ac#dmx#dmn#sx#hp#fxa#m#at#aa#}{p#stt#cols{##}sdmg#fxs#z#sac#sa#am#sy#a#si#sr#sf#ai#fxm#ac#dmx#dmn#sx#hp#fxa#m#at#aa#}{p#stt#cols{##}sdmg#fxs#z#sac#sa#am#sy#a#si#sr#sf#ai#fxm#ac#dmx#dmn#sx#hp#fxa#m#at#aa#}{p#stt#cols{##}sdmg#fxs#z#sac#sa#am#a#si#sr#ai#fxm#sf#ac#dmx#dmn#hp#fxa#m#at#aa#}{p#stt#cols{##}sdmg#fxs#z#sac#sa#am#a#si#sr#ai#fxm#sf#ac#dmx#dmn#hp#fxa#m#at#aa#}{p#stt#cols{##}sdmg#fxs#z#sac#sa#am#a#si#sr#ai#fxm#sf#ac#dmx#dmn#hp#fxa#m#at#aa#}{p#stt#cols{##}sdmg#fxs#z#sac#sa#am#a#si#sr#ai#fxm#sf#ac#dmx#dmn#hp#fxa#m#at#aa#}}{tw#gx#gy#w#x#y#bval#th#h#}{tw#gx#gy#w#x#y#bval#th#h#}{tw#gx#gy#w#x#y#bval#th#h#}{tw#gx#gy#w#x#y#bval#th#h#}{tw#gx#gy#w#x#y#bval#th#h#}{tw#gx#gy#w#x#y#bval#th#h#}{tw#gx#gy#w#x#y#bval#th#h#}{tw#gx#gy#w#x#y#bval#th#h#}{tw#gx#gy#w#x#y#bval#th#h#}{tw#gx#gy#w#x#y#bval#th#h#}{tw#gx#gy#w#x#y#bval#th#h#}{tw#gx#gy#w#x#y#bval#th#h#}{tw#gx#gy#w#x#y#bval#th#h#}{tw#gx#gy#w#x#y#bval#th#h#}{tw#gx#gy#w#x#y#bval#th#h#}{tw#gx#gy#w#x#y#bval#th#h#}{tw#gx#gy#w#x#y#bval#th#h#}{tw#gx#gy#w#x#y#bval#th#h#}{tw#gx#gy#w#x#y#bval#th#h#}{tw#gx#gy#w#x#y#bval#th#h#}{tw#gx#gy#w#x#y#bval#th#h#}{tw#gx#gy#w#x#y#bval#th#h#}{tw#gx#gy#w#x#y#bval#th#h#}{tw#gx#gy#w#x#y#bval#th#h#}{tw#gx#gy#w#x#y#bval#th#h#}{tw#gx#gy#w#x#y#bval#th#h#}{tw#gx#gy#w#x#y#bval#th#h#}{tw#gx#gy#w#x#y#bval#th#h#}{tw#gx#gy#w#x#y#bval#th#h#}{tw#gx#gy#w#x#y#bval#th#h#}{tw#gx#gy#w#x#y#bval#th#h#}{tw#gx#gy#w#x#y#bval#th#h#}{tw#gx#gy#w#x#y#bval#th#h#}{tw#gx#gy#w#x#y#bval#th#h#}{tw#gx#gy#w#x#y#bval#th#h#}{tw#gx#gy#w#x#y#bval#th#h#}{tw#gx#gy#w#x#y#bval#th#h#}{tw#gx#gy#w#x#y#bval#th#h#}{tw#gx#gy#w#x#y#bval#th#h#}{tw#gx#gy#w#x#y#bval#th#h#}{tw#gx#gy#w#x#y#bval#th#h#}{tw#gx#gy#w#x#y#bval#th#h#}{tw#gx#gy#w#x#y#bval#th#h#}{tw#gx#gy#w#x#y#bval#th#h#}{tw#gx#gy#w#x#y#bval#th#h#}{tw#gx#gy#w#x#y#bval#th#h#}{tw#gx#gy#w#x#y#bval#th#h#}{tw#gx#gy#w#x#y#bval#th#h#}{tw#gx#gy#w#x#y#bval#th#h#}{tw#gx#gy#w#x#y#bval#th#h#}{tw#gx#gy#w#x#y#bval#th#h#}{tw#gx#gy#w#x#y#bval#th#h#}{tw#gx#gy#w#x#y#bval#th#h#}{tw#gx#gy#w#x#y#bval#th#h#}{tw#gx#gy#w#x#y#bval#th#h#}{tw#gx#gy#w#x#y#bval#th#h#}{tw#gx#gy#w#x#y#bval#th#h#}{tw#gx#gy#w#x#y#bval#th#h#}{tw#gx#gy#w#x#y#bval#th#h#}{tw#gx#gy#w#x#y#bval#th#h#}{tw#gx#gy#w#x#y#bval#th#h#}{tw#gx#gy#w#x#y#bval#th#h#}{tw#gx#gy#w#x#y#bval#th#h#}{tw#gx#gy#w#x#y#bval#th#h#}{tw#gx#gy#w#x#y#bval#th#h#}{tw#gx#gy#w#x#y#bval#th#h#}{tw#gx#gy#w#x#y#bval#th#h#}{tw#gx#gy#w#x#y#bval#th#h#}}{rp{#}tw#sprs{#}th#}{rp{#}tw#sprs{#}th#}{rp{###}tw#sprs{#}th#}{rp{###}tw#sprs{#}th#}{rp{##}tw#sprs{#}th#}{rp{##}tw#sprs{#}th#}{rp{#}tw#sprs{####}th#}{rp{#}tw#sprs{#}th#}{rp{##}tw#sprs{#}th#}{rp{##}tw#sprs{#}th#}{rp{#}tw#sprs{#}th#}{rp{####}tw#sprs{#}th#}{rp{#}tw#sprs{##}th#}{rp{#}tw#sprs{##}th#}{rp{#}tw#sprs{#}th#}{rp{#}tw#sprs{##}th#}{rp{#}tw#sprs{#}th#}{rp{#}tw#sprs{##}th#}{rp{#}tw#sprs{#}th#}{rp{###}tw#sprs{#}th#}{rp{}tw#sprs{#}th#}{rp{}tw#sprs{#}th#}}{####}{####}{####}{####}{####}}{p{######}f{##}w#}{p{########}f{##}w#}{p{#######}f{##}w#}{p{####}f{####}w#}{p{#########}f{####}w#}{p{#####}f{####}w#}{p{#####}f{####}w#}}{y2#x2#x1#y1#i#}{y2#x2#x1#y1#i#}{y2#x2#x1#y1#}}{#############}{#############}{#############}{#############}{#############}{#############}}{{{x#m{a#}t#s#}{x#m{sa#}t#s#}}{{x#m{dmn#dmx#}t#s#}{x#m{ac#}t#s#}}{{x#m{sac#sdmg#}t#s#}{x#m{sa#}t#s#}}{{x#m{dmn#dmx#}t#s#}{x#m{a#}t#s#}}{{x#m{sac#sdmg#}t#s#}{x#m{sa#}t#s#}}}{{{x#m{dmn#dmx#}t#s#}{x#m{sa#}t#s#}}{{x#m{ac#}t#s#}{x#m{a#}t#s#}}{{x#m{sac#sdmg#}t#s#}{x#m{sa#}t#s#}}{{x#m{ac#}t#s#}{x#m{dmn#dmx#}t#s#}}{{x#m{sac#sdmg#}t#s#}{x#m{sa#}t#s#}}}{{{x#m{ac#}t#s#}{x#m{sa#}t#s#}}{{x#m{a#}t#s#}{x#m{dmn#dmx#}t#s#}}{{x#m{sdmg#sr#}t#s#}{x#m{sa#}t#s#}}{{x#m{a#}t#s#}{x#m{ac#}t#s#}}{{x#m{sdmg#sr#}t#s#}{x#m{sa#}t#s#}}}text{armour +15%@accuracy +12%@gun damage +7@grenade damage +10\ngrenade accuracy +50%@shock deals +10 damage\nshock accuracy +15%@healing +25\nhealing range +1@1 additional grenade@1 additional shock charge@1 additional medkit@}}"

__gfx__
6666666d6666666d7666666d6666666d666666666666666676666666666666666666666d6666666d7666666d6666666d66666666666666667666666666666666
7666666d6666666d7666666d6666666d766666666666666676666666666666667666666d6666666d7666666d6666666d76666666666666667666666666666666
7666666d6666666d7666666d6666666d766666666666666676666666666666667666666d6666666d7666666d6666666d76666666666666667666666666666666
7666666d6666666d7666666d6666666d766666666666666676666666666666667666666d6666666d7666666d6666666d76666666666666667666666666666666
7666666d6666666d7666666d6666666d766666666666666676666666666666667666666d6666666d7666666d6666666d76666666666666667666666666666666
7666666d6666666d7666666d6666666d766666666666666676666666666666667666666d6666666d7666666d6666666d76666666666666667666666666666666
7666666d6666666d7666666d6666666d766666666666666676666666666666667666666d6666666d7666666d6666666d76666666666666667666666666666666
7777776d7777776d7777776d7777776d777777777777777777777777777777777666666d6666666d7666666d6666666d76666666666666667666666666666666
66dd66d566dd6d55666d66d5666d555566dd66dd66dd666d666d66dd666d666d00000000000000000000000000000000000333000bb0bb330005750000033330
6ddd6d556dd5d5556dd56dd56dd665dd6dd56dd5ddd56dd566d5ddd566d56dd50005000000000000000000000dddd50000333330bb3bb3330007870000333333
dd55d55555555555dd555d55d5555d6dd555d5555555d555d555d5555555d555000d00000ddd550000d55d00dddd505000333330b33b33330005750000333333
6d666dd5d566ddd56d66d5d5d5ddd5dd6d666d6ddd66dd666d66dd66d566dddd000000000ddd5500050dd0505dd5505000333330b33333330000000000333333
656dd5d5dd6dd5d56d6dd5d5ddddddd56d6dd5ddd56dd5dd6d6dd5dddd6dd5dd5d000d500ddd55000dd55dd0d55d505000333330033033330000000000033330
d55555555d555555d5d5555555d5d555d555555555d555d5d555555555d555d5000000000ddd550005d00d50dddd5500003333300b3330030000000000330030
666d6dd5666d66d566ddddd56ddd66d5666d66dd6ddd66dd666d66dd6dd56ddd000d000000dd5000005005005dd5500000333330b33333030001110003333333
6dd5dd556dd5d5556dd5d555ddddddd56dd5ddd5dd55dd5566d56dd5dd55ddd50005000000000000000dd0000000000000333330333333300001110003333333
d555555555555555d5555555d5d55555d555555555555555d5555555555555550000000000000000000000000000000000333330333333300001110000330333
6d66d5d5d56d55d56d6dd5d5dd66d5dd6d6dd5ddd56d55666d66d566d56dd5dd0000000000000000000000000000000000333330033330000000000000000333
65d555d555d5555565dd555555d555d565d555d5555555d565d555d555dd55d50000000000000000000000000000000003333333000000000000000000000333
d555555555555555d555555555555555d555555555555555d5555555555555550000000000000000000000000000000000333330000000000000000000000030
66667b6d6667b66d67bb37bd67bb37b3666b666666667b666b7b34666b7b346667b6666d67b6666d6b7b346d6b7b346d666b666666667b666b7b34666b7b3466
7b73bbdd3b3b3d7d73b33bddd3b37b3d7dd7b3dbb3dbb3db73b37b3db3b37b3b737bdd6dd37bdd6d73b37b3dd3b37b3d7dd7b3dbb3dbb3db73b37b3db3b37b3b
7db7b36db7b3b36d7d3bb36db73bb3dd6b7b3b737b3b3b737d437bb37b33b7b37d3b3bb3b733bbbd7d47b3ddb747b3dd6b7b3b737b3b3b737d437bb37b33b7b3
67b3b7b37b33b4dd6bb3b76d7bb33b6db7b373bb3373b3b367b337b3337b33b36db3b7dd73bb37b36bb3346d7b3b346db7b373bb3373b3b367b337b3337b33b3
bb3b3bddb37b3b3db73b3bb3b37b37bdd34bbb3b37b3bb337b3bb33337b3bb336b7b346db37b34dd7b3b736db3b37b6dd34bbb3b37b3bb337b3bb33337b3bb33
6d47b46d4b7343b3b347b4dd4b7343b36d734b344b347b34b3347b344b347b34b7b3b36d47b3b36db333b7b34b73b76d6d734b344b347b34b3347b344b347b34
766d7d6d66b3d6dd66673d6d66b3d6dd7bd663d663d6b3d66dd6b3d663d6b3d66d4bb7b36d4b73b36d7b34dd6dbb3bbd6d4bb7b36d4b73b36d7b34dd6dbb3bbd
7776d66d776d676d776dd66d776d676d76676d6776676d6777676d6776676d677db33bdd7db33bdd6b33b36d7b33b3dd7db33bdd7db33bdd6b33b36d7b33b3dd
6dddddd5ddddddd56dddddd5ddddddd56ddddddddddddddd6dddddddddddddddd1444415d1444415d1444415d1444415d1444415d1444415d1444415d1444415
65ddddd5dddddd556dddddd5dddddd5565dddddddddddddd65ddddddddddddddd1444415d1444415d1444415d1444415d1444415d1444415d1444415d1444415
655dd5555ddd5555655ddd5555ddd5556555dd5555dd55d56555ddd5555ddd55d1222215d1222215d1222215d1222215d1222215d1222215d1222215d1222215
d555555555555555d555555555555555d555555555555555d5555555555555555111111551111115511111155111111551111115511111155111111551111115
3bbbbb333bbbbb333bbbb3333bbb33333bb333333b33333333333333333333300000000000000000000000000000000000000000000111000bb00bb00bb00bb0
b67f76bbb67f76bbb67f7bbbb67fbbbbb67bbbbbb6bbbbbbbbbbbbbbbbbbbbb0000dd00000000000000000000000000000000000011111110bb00bb00bb00bb5
174f471f174f464f174f444f174f444f1744444f1744444f1444444f44444440000d500005dddddd005dd0000050500000500000111111111660056505660556
1efffe101efffe041efff0441eff04441ef044441e044444104444440444440000ddd0000dd555550505500005ddd500000d5000111111111550005500550000
01000100010010000101000001000000010000000100000000000000000000000d0dd5505d50d000505dd50005ddd5000005dd00111111111bb00bb60bb50bb0
c55555ccc55555ccc5555cccc555ccccc55cccccc5ccccccccccccccccccccc00005d000dd5d0000505dd500005d500000dd0000011111110bb60bb50bb50bb0
577577555775765557756555577555555765555556555555555555555555555000050d00d500000000055000000500000005d000000111000555055005500550
155f551f155f554f155f544f155f444f1554444f1544444f1444444f4444444000500d0000000000000000000000000000000500000000000000000000000000
1efffe101efffe041efff0441eff04441ef044441e04444410444444044444000000000000000000000000000000000000000000022000333333330000033000
010001000100100001010000010000000100000001000000000000000000000000000000000000000000000000000000000000002e8203303333033000333300
0bbbbbbb00bbbbbbb0bbbbbbb0000000000000000000000000000000000000000000000000000000000000000000001100000000288230000330000303333330
bbbbbbbbbbbbbbbbb0bbbbbbbb000110000f110000011000000111100000000000000000111100000110000111000011f0000000022000000300000003333330
bbbbbbbbbbbbbbbbb0bbbbbbbb000110000f110000ff111000ff111111011111111001111ff1000111ff00011ff00011f0000000000000000030000033333333
0bbbbbbb00bbbbbbb0bbbbbbb000f1100000111000ff111100ff001ff1ff1111ff10ff110ff0001111ff00111ff0001100000000000003333333330033333333
0bbbbbbb00bbbbbbb0bbbbbbb000f1100000f11000000ff10000000ff0ff0000ff00ff0000000ff1000000ff100000ff00000000000033003330330033333333
0bbbbbbb00bbbbbbb0bbbbbbb00001100000ff1000000ff000000000000000000000000000000ff0000000ff000000ff00000000000000003300033033333333
08882200000550000005550000005650000006500000050000000500000050000778660077726007776200001111111000000000000000003000003033333333
8ee88220056776500577665000576560000565500000650000005000000050007788866777882677778220001777661007777610033300000300000033333333
88822220560650655606006505755060000750500006500000006000000550007772666777626677766260000177610077ccc761030000333333330003333330
00ccc000600760066507506006006050006505000056000000055000000550000777660077766007776600000017100077c7c761030003333303330003333330
0c76cc00065005600650065006500650006000500065050000060500000550007777722777776277777660000001000067ccc661003000033000330003333330
c66cccc00056650000566500005665000005650000065000000550000005000077766627776666777666600000000000d6666651003000030000030033333333
0000000000000000000000000000000000000000000000000000000000000000077766007776600877660000000000000d555510003000003000000033333333
00000000000000000000000000000000000000000000000000000000000000008777766887776688877660000000000000000000003000333333333000000000
00000000000000000111111111111111111000001110000011111111111111117776666877666678766660000000000000000000000000333033330011000000
00000000100000000011111111111111111000001110000011111111111111110787660000000000000000000000000007777610000000330003300017100000
00000000110000000001111111111111111000001110000011111111111111117888766000000000000000000000000077878761000000300003300017610000
00000000111000000000000011100000000000001110000000000000111000007786666000000000000000000000000077787761000000000000300017761000
00000000111000000000000011100000000000001110000000000000111000000000000000000000000000000000000067878661000000333333333017766100
000000001110000000000000111000000000000011100000000000001110000000000000000000000000000000000000d6666651000003303333003317611000
0000000011100000000000001110000000000000111000000000000011100000000000000000000000000000000000000d555510000003000333000001100000
00000000111000000000000011100000000000001110000000000000111000000000000000000000000000000000000000000000000000000030000000000000
5555555555555554555555545555555444442444444444443333b333333333b333333333333333b333b3333333333333333333b3000000000003000000676500
5555555555555554555555545555554444442444444444443333b33333333333333b333333b33333333333333333b33333333333000000000000000000878500
55555555555555545555555455555544444424444444444433b335b3333b3333b33333b33333b3333b3333b33333333333b33333000000000000000000766500
555555545555554455555554555555542222222222222222333333b3b33b5b3333b333b53b33b3333b3333333b33333333333333000000000000000000565000
555555545555554455555555555555544444444444244444333b333335333b3333b3b3333b33333b33333b33333333333333333b000000000000000000333000
5555555455555544555555555555555444444444442444443b3b533333b3335b3335b33333533b33333b3b333333333333333333000000000000000003333300
5555554455555554555555455555554444444444442444443b33333b33b533333333333333333b53333b3333333333b33333b333000000000000000003333300
5445554444455444554444445445444422222222222222223333333333333333333333b333b33333333333333333333333333333000000000000000003333330
111111111110000000000000000000000000000000000000000000000000a90000066d00000000000000000000679a99999999999999a9200000000f03333330
1dddd177771000000000000000000000000000000000000000000000000a4490007766d000000000000000000657a9999999999999999a920000009e03333330
1dddd17777100000000000000000000000000000000000000000000000a724a00667765000000000000000006517a9999999999999999a92000000de00333330
177771777710000000000000000000000000000000000000000000000a7a24a006766d5500070000000000065117a9999999999999999a92000f99de00333330
1d77d1d77d10000000000000fffffffffffffff9fffffffffffffff9fa949a49d77dd555000769aa988889865117a9999999999999999a9200f000de00333330
0111101111000000000000007ffffffffffffff97ffff77f77fffff9794111f9d766d5d50656899aaa9998875117a9999999999999999a920deed2de00333330
00000000fffffffffffffff97ffffffffffffff97ff877767778f1f971911119766d6d5565689a99999998875116a9999999999999999a922eeed2de03333333
000000007ffffffffffffff97ffffffffffffff97ff877767778f1f97115611976ddd55575787aa9999998875116a9999999999999999a922eeed2de00333330
0006c0007ffffffffffffff97ffffffffffffff97ff876656678f1f9711111196d6d56d575796aaaa9a999875116a9999999999999999a922eeed2de00333300
0071dc007ffffffffffffff97ffffffffffffff97ff222222222fff97f1111f9d6dd5d5565797aa9999998865116a9999999999999999a922eeed2de03333330
00d7cd007ffffffffffffff97ffffffffffffff977777777777777f9777777f915d555516578aa99999998865116a9999999999999999a922eeed2de03333330
00dcd10077777777777777f97ffffffffffffff99444444444444444944444440000000065689aa9999998865117aa999999999999999a922eeed2de33333333
66c6c1dd94444444444444447ffffffffffffff90222222222222221942222440055b100656889aaaaa9998651179aaaaaaaa9aaaaaaa9822ddd22de33333333
7d76cd1d91c2856891c2d5647ffffffffffffff904424444444424419424444405b3330065588888999aa9865178888888888288888888822eeed2de33333333
7d66cd1d91c2856891c2d5647ffffffffffffff90941111111111941944999445bb7411065228888888899865781111111118288111118822eeed2de33333333
7dcccd1591c2856891c2d5647ffffffffffffff90941111111111941444444440574331065272222288888966811111111119288111119822eeed2de33333333
76dcd15592222222222222247ffffffffffffff90000000000000000000000000533b33065276222222288898817111111119288222229822eeed2df33333333
766d555592444444444444447ffffffffffffff90000000000000000000000005b7b4b3175276288882222888867122222229288999998822eeed29433333333
7666d5559228c2d2829561c477777777777777f9000000000000000000000000bb3b4311752627a9999822282886289999678288888888222eeed24433333333
77776dd59289c2d2829561c49444444444444444000000000000000000000000b733b4107622a7a9999982222888288888828229a99882252ddf994433333333
6dddddd59292c2d2829561c40222222222222221f00000000000000f00000000533b3b315769a2111129982222888888888822a21111282622f2224433333333
6d5555d592222222222222240442244444442441f00000000000000f0000000053b73b33055951511d1289982222222222222951511d1225f944444433333333
6d5dd5d592444444444444440941111111111941f00000000000000f6666666d6b33b3b30111d11d6115118888888888888882d11d6115112422224203333330
d555555542222222222222240941111111111941f00000000000000f7ddddd6d7b7bb41101111521122111111111111111111115211221114111111400333300
fffffff900000000fffffff9f00000000fffff907fffff0011fffff77d44446dbb734b3100000000000000000000000000000000000000000000000000000000
7ffffff9000000007f4447f9e9000000fffffff94fffff00117ffff47d44446db7433b3307777600000000000000000000000000000000000000000000000000
7ffffff9000000007f447ff9ed0000007ffffff94fffff00117ffff47d44446d6d3b43b377611760000000000000000000000000000000000000000000000000
7ffffff9000000007f47f4f9ed9ff0007ffffff94fffff10117ffff47d44446d7d7b422577155760000000000000000000000000000000000000000000000000
7ffffff9000000007f7f44f9ed0009007ffffff94f777f11117777f47666666d76d222d567655660066666600666666666666660006666666666666666666d00
7ffffff9000000007ffffff9ed2deed07ffffff944444411114444447777776d7776666dd66666506666666d666666666666666d06ddddddddddddddddddd6d0
7ffffff90000000077777779ed2deee247777f9441111411114111146dddddd56dddddd50d5555007666666d766666666666666d6ddddddddddddddddddddd6d
7ffffff9fffffff9f4444444ed2deee2044444414111141111411114d5555555d5555555000000007666666d766666666666666d7ddcdc6cdcd6ccdd6dccdd6d
7ffffff97ffffff9f4222244ed2deee20142221100000000000000001111110000666d10000000007666666d766666666666666d7dcd676d676d6dc67cd76d6d
7ffffff97ffffff9f4242294ed2deee20241142100000000000000001dddd10007766661077776007666666d677777777777776d7ddcc676ccccc67cc766cc6d
7ffffff97fccccf9f4224294ed2deee20421124100000000000000001dddd100677776d1771167607666666dd6ddddddddddddd57d6c66c66c6666ccc6ccc66d
7ffffff97fccccf9f4222494ed2deee200001111111111111111111017777100776dd555771557607666666d6d555111111555557d76ccc766776d6c6ccc676d
7ffffff97dccccf994444444ed22ddd20000d11111111111111111111d77d10076d55555671566607666666d66d551111115dd557d776676c6776d566677766d
7ffffff97d1111f900000000ed2deee20000d111111111111111111d0111100066d6d555d66666507666666d06d511111111dd517d66766c6d66dd5d6766cc6d
7ffffff97ddddff900000000ed2deee27765d111111111111111115d00000000d6dd55d50d5555007666666d00076d00000000007d6ccc667dddd55d66cccc6d
777777f972222ff900f7f900ed2deee26511d111111111111111156d000000000d555551000000007666666d007776d0000000007d66ccc676d5555d766cc66d
944444447ffffff90777f990fd2deee27761d11111111111d66776150000000000000000000000007666666d007665d0000000007d7766c7676d55d57766676d
944444447f8888f9f7f99494492deee26511d1111111111d511111d10000000000000000000000006777776d7d676d5d670000007d6cc66766776d5d766ccc6d
944444447f8888f9f9777f44442deee27761d111111111d515dddd5176676667676676666776666dd6ddddd5d5d66d565d0000007d6cccc6766dd5576cc6c66d
944444447f8888f9979449f4449ffdd26651d111111111d15115551177677767777677776777767d6d5555550d5dd5d5d00000007d76c6676766d676cc66776d
944444447f2222f979d66d94442229227761d111111115d51155551166667666776667766677666d66dddd55056766d5000000007d77676c666776dd66ccc66d
944444447ffffff9f4676744444444446511611111115615115551117666676766676667666666dd06ddd55106776d60000000007d76cccccc66dddc7ccc676d
94444444777777f9926667242422224277617777777665151511115177676777667777677676776d000000007d7665d6000000007d7776ccc66dddcc67766c6d
944444449444444492d77d2441111114651151d11111111d11111d5177766677767776677776676d000000000d666550000000007d7c666776c66c66c666cc6d
94444444022222214444444433333333776151611111115533333333666d5d66d5666d5666d5d6d5111111006d6d7d55000000007d6ccc676ccc776cccc66c6d
944444440442244114222221366d33336511d1d1111115d1333333336d5d6d66d5d6dd56dd5d5dd5177771007d7d66550000000076dcc6766cccc6776cccc66d
944444440941194119411441d6d51333776166666ddddd513336d533d5d66d5d51111115d5d6d55517777100767dd75d0000000067666666666666666666666d
44444444094119411f411941d55115336651d55555555511335d51336656dd5111111111156dd5d517777100766dd65d000000006677777777777777777776d5
00000000000000004f4229425111d6d57765d55555555511333515336dd555111111111111555d551d77d1006766ddd50000000066dddddddddddddddddddd55
00000000000000004944994233356d51d55555555555511133333333d566d111111111111116665501111000667766550000000066dddddddddddddddddddd55
00000000000000009444444433335113011111111111115133333333656d511111111111111d6d5d00000000d6dddd5500000000d6dddddddddddddddddddd55
000000000000000044111144333333330111d51111111d5133333333d5dd5111111111111115dd55000000000555555100000000055555555555555555555551
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
00000000000000000000000000000070000007000007000000007000000700070000000000700000070000070000070000000070000000000000000000000000
000000000000000000000000000007f700007700007700000007f7000077007f7000000007f700007700007700007700000007f7000000000000000000000000
00000000000000000000000000007fff7007f70007f70000007fff7007f707fff70000007fff7007f70007f70007f70000007fff700000000000000000000000
0000000000000000000000000007d7f75007f70007f7000007d7ff7007f77d7ff7000007d7ff7007f70007f70007f7000007d7f7500000000000000000000000
0010000000000010000010100075dd755007f70007f7000075dd7f7007f75dd7f7000075dd7f7007f70007f70007f7000075dd75500000000000000000000000
00000000000000000000000007750dd50007f70007f70007750d7f7007f750d7f70007750d7f7007f70007f70007f70007750dd5000000000000000000000000
0000100010001010100000007f7000d00007f70007f7007f70007f7007f70007f7007f70007f7007f70017f70007f7007f7000d0000010001000000000001000
0101000000000100000000007ff700000007f70007f7007f70007f7007f70007f7007f70007f7007f70007f70007f7007ff70000000000000000000000000000
101010100010101010100000d7ff70000007f70007f7007f70007f7007f70007f7007f70007f7007f70007f70017f700d7ff7000000000101010101000000000
010001010100000100000101dd7777000007770007770077700077700777000777007770007770077700077700077700dd777700000000000101000000000100
1010100000000010101010101dd7ff700007f70007f7007f70007f7007f70007f7007f70107f7007f70017f70007f7001dd7ff70100010101000101010101000
01010101000100000000010100dd7997000797000797007970007970079700079700797000797007970107970007970000dd7997000001010000000100000000
100020101010100010000000100ddf99f00f9f07f99f00f9f07f99f00f9f000f9f00f9f000f9f00f9f001f9f001f9f00100ddf99f01010100010101110100010
0000000100000000000001010000ddf9f00f9f0d799f00f9f0d799f00f9f000f9f00f9f000f9f00f9f000f9f010f9f010100ddf9f10101010100010111000000
00101010102021201000100010100dff500f9f0ddf9f00f9f0ddf9f00f9f000ff500f9f000ff501f9f002f9f001ff50020100dff500000102121211021101010
00000100000101000000000101f000f5500f9f00df9f00f9f00df9f00f9f000f5500f9f000f5500f9f010f9f010f550101f100f5500101010112010100010000
2010201010101000101011202f9f1f55001f9f000f9f00f9f000f9f01f99f1f55001f99f2f55002f99f1f999f2f550022f9f2f55002120212120222121101010
0101000000000000000102127999f550000f9f010f9f00f9f000f9f007999f5500017999f5500007999fd7999f5500027999f550001211010101010212010000
101010102121212110222222d79f5500022ff5001ff502ff5021ff501d79f5500021d79f5500001d79f5dd79f5500010d79f5500022222222222212120100010
010101010202121212122212dd7550001217550007550175500175501dd755000001dd755000000dd7550dd755000101dd755000122222122222220001000000
1010211022222221212122222dd50002222d50001d5001d50010d50020dd500010101dd500001010dd5000dd500020102dd50001222120112220211010101000
00010012122212221212122210d00012121d00010d0000d00001d000000d0001000000d0000000010d00000d0001010200d00002011212220101000000000000
00101010112222222122222222000222222200212000101000101000101000001077100000100010100010100020202222000122212121222110101000101010
00000101010112121222222222102212121202121101000000000000000007700755000001000100000102010101010212001212121212121100120102010100
10101010222122102010101010112121212121101010100010001000100075d71775000010002110101010101010211010112122222221112222222221102110
0000000100020122000000010001011101110100000000000099ff77000075d70750000077ff9901000000010001010000000101010102121212121201110000
10101010102120211010001110201010101010100000000000555ddd0000d77507500010ddd55521101010101010101010212021212121212010102010201010
120212010101121212021201010101000000000000000000000000000000dd550d00000000000000000000000101010012221201010001000101000001000000
1010201020102120211021202000101010101000100010000000000000112d500d00101010000000100010101011222222202000101010102010201010000000
00000001010100010000010007000701000107000007000101720272121210700101711101711101700101000071111222700000700000010000000000000000
10101010001010201010101077107f712121771000770021277227f72121277021077121277121277122212017f7222127700017701000101010001000000000
010100000000000001000007f707fff71217f70107f702027f707fff72017f70127f70117f70227f701222117fff72027f70007f700001000000000000000000
101010001010101020102017f77d7ff71017f70027f70017ff77d7ff71217f70217f70117f70227f70222227d7f751217f70217f702221212010100000001000
000000000101010100000007f75dd7f70007f70107f7007fff75dd7f70017f70017f70017f70127f70121275dd7550227f70127f701211120101000002010100
101010101021211010100017f750d7f70017f70017f700d7ff750d7f70107f70107f70117f70227f702227750dd500227f70227f702222222120101011200000
010112121212121212000007f70007f70007f70007f700dd7f70007f70007f70007f70017f70127f70127f7000d000227f70227f702222121212020100000000
212021212121222121202017f70017f70007f70017f7000d7f70007f70007f70107f70107f70217f70227f70020002227f70227f702222222120201010101000
010001020101020100010007f70007f70007f70007f700007f70007f70007f70007f70007f70017f70127f70122012227f70127f700101120101010100000101
00000010001010101010001777012777001777000777000077701077701077700077701077702177702277702222222277702177702121212121101000000000
000000000000000001000007f70117f70107f70007f700007f70017f70017960007f70007f70127f70127f70121212127f70017f700001010100000000000000
000010002010101010001017970127970127970027970010797020797010e8e21079700079702079702179702221222179702079701010101000100010001000
00000000011000000101010f9f010f9f010f9f010f9f0102f9f001f9f00222888869f000f9f000f9f001f9f001120201f9f07f99f01201010000010100000000
00000001002020101021212f9f012f9f002f9f012f9f0121f9f021f9e012288ee6e9f021f9f010f9f020f9f02121f121f9f0d799f02010101010101010100010
00000000000101010101010f9f010ff5021f9f021f9f0212f9f012f900222288e66ef012ff5001f9f001f9f0010f5201f9f0ddf9f00001000001011111100000
10001010101021212121212f9f012f55012f9f012f9f0121f9f022f401211122222e8021f55021f9f010f9f020f55021f9f02df9f01010101010101010001000
00000000010111010001000f99f0f550010f99f1f999f101f9f000f00101288ee668221f550001f9f000f99f0f550000f9f000f9f00100000000000100000000
100000000000000000000007999f55000017999fd7999f00f9f000e000288220022e8265500010f9f0107999f5500010f9f010f9f01010010000000010101010
02010001000000000000000d79f55000000d79f5dd79f500ff50002001820024e4202855000000ff5000d79f55000000ff5001ff500100000000010000010000
00000000000000000000000dd7550000000dd7550dd7550075500010120024efffe20250000000755000dd755000000075501075500000000000000000000000
000000000000000000000000dd5000000000dd5000dd5000d500000020024effffe40200000000d500000dd500000000d50000d5000000000000000000000000
0000000000000000000000000d00000000000d00000d0000d00000010005225efe520000000000d0000000d000000000d00000d0000000000000000000000000
0000000000000000000000000000000000000000000000000000000000222224f422100000000000000000111dccd10000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000001012efee47ffe20000000000000000111dcc666d000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000002010effe47f7f2000000000000000151ddcc6676d00000000000000000000000000000000
000000000000000000000000000000000000000000000000000000001104efe54fff2100000000000000d111ddccc66c10000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000102eee4effe110000000000000151111ddccccdd0000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000021024e454ef21100000000000001001dcc666776cd000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000121002eeeffe0120000000000000000dcd544444452000000000000000000000000000000
00000000000000000000000000000000000000000000000000000110210002effe20128000000000000012d5d677646765000000000000000000000000000000
00000000000000000000000000000000000000000000000000028210011000000002128220000000000125555677757765000000000000000000000000000000
00000000000000000000000000000000000000000000000002888211011021000121182288220000000001d15d66d5d6d2000000000000000000000000000000
0000000000000000000000000000000000000000000000000888882100101888ee2112288888ee20000011c02555efe551000000000000000000000000000000
00000000000000000000000000000000000000000000000102e8222200110288820112228e8ee62800001d0014fe47f7e0000000000000000000000000000000
00000000000000000000000000000000000000000000000201822002201102222101028212ee688e0000000012ee44ef40000000000000000000000000000000
0000000000000000000000000000000000000000000000012010012820012001102028888112e2e2100000000244eefe00000000000000000000000000000000
00000000000000000000000000000000000000000000000121001288801082008820288888211281200000100024eff400000000000000000000000000000000
00000000000000000000000000000000015dd5100000001022012220010288108e82222e888e2121220011021000120000000000000000000000000000000000
000000000000000000000000000000002d6677650000001012021101220288108e8188222e88ee112800151012124e1000000000000000000000000000000000
0000000000000000000000000000000188e777775000002001082111281182108e21288822888e21288005d10244ef0d00000000000000000000000000000000
000000000000000000000000000000088e6777776100002100018101280182102e12228882d6288112e2001dd124e21c1d000000000000000000000000000000
0000000000000000000000000000001d8e6677766d00012100008001111022002818228821d5d521128e1101dccd1ccd16cd0000000000000000000000000000
0000000000000000000000000000005d66777777d510012200001100122028002e18288821567d11228e81dd11c11cd1d1c7d000000000000000000000000000
00000000000000000000000000000056d500055d6d50012200000100028018001812282211d67611228ee00dcd111d1dcd1d1100000000000000000000000000
000000000000000000000000000001d00244220005d10112000001100120180018282222105d6612288ee8111dcd1cdc66dddc10000000000000000000000000
000000000000000000000000000005004efffe22000500121000001000200200082212d61015dd112888ee1dcdc11c1dc661dcc0000000000000000000000000
00000000000000000000000000000102eef422240240001110001000001002000821255d5001510122ee8e21dccd1c11ddd1dd6d000000000000000000000000
00000000000000000000000000000002024222ee22e00000100001000001020002121567610112011288eee11dcd1d1ccd111d6c000000000000000000000000
0000000000000000000000000000000000f4ef7fe40000000110000000010100021105d761128200122888e811d10cddc6c11dcc100000000000000000000000
0000000000000000000000000000000000ffe7ffe20000000155100000000100010101d6d22882001128ee8815cd0d1ccc6d11cdd00000000000000000000000
0000000000000000000000000000000020ee4efe2010000000015d51000001000100015d52288100002228e8811d0d1dcc6d1ddcc10000000000000000000000
00000000000000000000000000000000022004ee20d500001000015d5100000000110011128821000112888881510511dddd1dcc6d0000000000000000000000
0000000000000000000000000000000002022ef20065000010000001dd0000000100155112282110001112288015d10ddccd11ddcc1000000000000000000000
000000000000000000000000000000000022ef4007d101000100000000075000000000155d51211000100101280005d01dcc11dcd6d000000000000000000000
000000000000000000000000000000000002220076510200000000000005d01000000000155dd520000128882800001dd11d101c16c100000000000000000000
0000000000000000000000000000011101000006d51dd210022e450000005015015d000000155dd50000128882010005d6d1101d1dcd00000000000000000000
0000000000000000000000000015d11001d016dd5dddd0200124effe0000000101d7d500000015d610122128820151000566d0111d6c00000000000000000000
0000000000000000000000015d01150000500d11dd5d7d0000224e7ffe20000001d115dd100011651022881881011500015d6001116c10000000000000000000
0000000000000000000015dd51d111000000001d15ddd77000124efe4ff40000000101515d5111d110122888210010000015d1011ddcd0000000000000000000
0000000000000000015dd55111d010000100005511dddd7d101254ffe245000000010110115d55515d51228821d00001d001d510011d11000000000000000000
00000000000000000015651100101000005100511d5777d7d00254fef41001011000010000115d51115d518211cd1000150015d501dcd1000000000000000000
00000000000000005511510ee5000020001d005001dd777d71015e4e420150001551000015000151dd115d110ddccd000005115d5111c1000000000000000000
00000000000001d6d1011004ff1000e400050010001d777ddd0024e500000000001551100110120115dd115101ddc1000011d0115dd111000000000000000000
000000000000d5110000024effe102e20001000015ddd777dd100000000000000000155510002f200115dd50011d125ee00001101d5dd1000000000000000000
000000000000110000005eeeeefe0440000000005dd77dddd1100000001010110000000000002e4f00115d11001d025eff410005d1155d000000000000000000
0000000000000000000002144ee411100000100111d777ddd1d1001020122100000000000000125f2000051510010025eef01105510015d10000000000000000
0000000000000000000000212421d5dd51000000001d7775d1d105212d510000000000000100012e52100001dd100002520010000151015d5000000000000000
000000000000000000000001111ddd55dd5100001d7557dd1011025d5100000000011001122100024e55510015dd100000010000001d51115d00000000000000
00000000000000000000000000115dd1ddd77d5101d7d5dd100d1151000000000000000001220000024520000015dd10000005000001d5d51561000000000000
000000000000000000000000000011501dddd77ddd5dd7dd001d100000100000000001122222100000000000000015d60011511000001d515116d00000000000
0000000000000000000000000000001001d515ddd5d5ddd1005dd0001000000000001228888221000000000000000015000000010000151dcd15d60000000000
00000000000000000000000000000001001d1015dd115dd0011dd1010001000000012288888821000000000000000000000000000100051c7c051d6000000000
00000000000000000000000000000000000150005d511d100115d10001000000000128888ee821000000001100000000000000000011010dcd0d556000000000
000000000000000000000000000000000100010011d51500001ddd02110000010002288888e8210000000001101100001000010000001010005dd61000000000
0000000000000000000000000000000000100000001115000155dd0211000010001288888e882000000100011d100001111001000000010015155d0000000000
0000000000000000000000000000000000000000000150000015dd01200000110001288ee8821000000011000110001117777100000000110001510000007000
000000000000000000000000000000015551000001100000015ddd011000000000128888e8821000000011110000011d15655700000000001005100070007000
000000000000000000000000000001d77ddddd510000000001dd5d1101000010012888e88822000001111111100001dcd1716767606767606761676060677000
00000000000000000000000000001dd777d5ddddd500001100155d1010000100000288888821000000011dd11000111dc1777675707575707570757070757000
000000000000000000000000000115ddd775dd7dddd5000015015550100001000012882282200000000011dd10000111d1755167777067777070676070677700
000000000000000000000000000111155ddd5dd7ddddd510005115d0100010000128888222100010001101dc100011dcc1511155555055555050555050555500
0000000000000000000000000001011155ddd5d777dd77d51100515000000100122288821200000000001111100011ddcd11d177000000000700000000000000
00000000000000000000000000000011115ddd55dd7ddd77d51100100000100122228821110000100011dd110000011dddcd1755067606700770707067600000
000000000000000000000000000000011515dd515dddddd777d511500001100122888221200001100011dcd110000111dccd1700075707500750707075500000
0000000000000000000000000000000111d5ddd115d5dddd777dd5d10002000222888222100005100011ddcd100011dcc66c1700067776770670677056700000
00000000000000000000000000001000115ddd7d115155dd7777dd5500020012288888210000050001111ccd00000111ddcc1577755555550550555677600000
000000000000000000000000110001000155ddd7111115dddd777dd50011001228888821000001000011dcc10000111ddcc6d155500000000000000555500000
000000000000000000000011000001000115ddddd1d11555ddd77ddd0020001228888220000011000011dcd1000001111dc6c100000000000000000000000000
0000000000000000000000000000000000115dddd01d11155dddd7dd0120001122882220000015100111dd1000000011dc6cc100000000000000000000000000

__map__
05002050400007205040000e2050400015205040001c2050400023205040002a205040003120504000382050400031205040012a2050400123205040011c2050400115205040010e2050400107205040010706002a403000092a403001002a403000092a40300009063a2a406000432a4060004c2a406000542a4060005b2a40
7000542a3070014c2a307001442a3070013a2a406001312a406001282a406001212a4060011a2a406000212a406000282a406000312a40700009047020704000742068400078206840007c206840007024684000742468400078246840007c247040007824704001742468400170247840017c20784001782078400174207840
010403002b600000030f782850000008070830505000103050500018305050002030505000283050500030305050003830505000382f5050013830505001383050500038305050003830505001303050500128305050012130405001183050500110305050010803003050100007056c3c3030016c283030016c2d3030016c32
3030016c373030016c3c3030016c283030016c2d3030016c323030016c373030016c3c3030016c283030016c2d3030016c323030016c373030010c05002550400007255040000e2550400015255040001c2550400023255040002a255040003125504000382550400031255040012a2550400123255040011c25504001152550
40010e25504001072550400107030033501000070c6108500000794450000179445000017944500001610850000079445000007944500000794450000007046934704000693470400068310040016831004001693100400168310040016831004001693470400069347040006934704000683160400068316040006931604000
683160400068316040006934704000030479407000017a407000017a407000017b407800017c4070000177400200017640000000764000000076400000007640000000764000000077406000017c406000007b406800007a406800007a406800000403403050100047305010004e30501000403350100047335010004e335010
004e335010004e335010004e335010004e335010004e335010004e33501000403650100047365010004e3650100040395010000704790d60600004057a0850400006077d0d6860007d0d6860007d0d6060007d0d6060007d0d7060007d0d7060007d0d7860007d0d706000030672087060017308686001730870600174087860
0175087060017008706000720e006001730e686001730e606001730e506001730e506001730e4060017008206000750850600074085860007308506000730860600004076e080010016e0a0010006e090010006e080010006e0a0010016e090010010205680d7020006b0d0020006b0d0020006b0d0020006b0d7020016b0d70
20016b0870200068087020006b08702000030f785050000008010000240002000058000300782850040099000005006700000600004000070000240014010400990068050067009801000030740300743458070000307406040099000005006778000100002474030078345807000024740e0400990098050067006801000030
7403007c3458070000307416040099780005006700000100002474030078345807000024741e02037d0214500600001c540c037d0214680600001c6810037d0214500600001c541e010100001800020000006803000098000e0100001800020000006803820098001e040100004400027e9c746403826400640486680098057a
9800980600002078060100004400027e9c006403826474640486680098057a98009806000020780e0100004400027e9c006403826400640486687498057a9800980600002078160100004400027e9c006403826400640486680098057a98749806000020781e05027e98745c038264006c0486687498057a9800980100004400
060000200002027e9c006403826474640486687401057a9400020100003800060000140006027e9c006c038268745c0486680098057a987498010000380006000014000a027e9c7464038264006404866c0002057a987401010000440006000020000e0601000020740200002070030000288c0400005800057e94007806826c
00780e0100003064020000306003000030001e0701000020740200002070030000288c0400005800050001747006836c00840601000020740200002070030000288c0400005800057e94007c06826c747c0e01000020740200002070030000288c0400005800057d94008406007074701601000020740200002070030000288c
0400005800057e94747c06826c007c1e080100000000020000006803835c3800047da418740578001cac060064786c078394006808889c7c94097d7000980a006804680b7b9c488c0e0383543800047d9c18740578001c02068564786c078894006808839c7c9409787000980a007004700b7b0248021e090100000000020000
00680383543800047da418740578001cac0600647874070094007008009c7c98090070009c0a006804680b7b0248010c0a0024000001005800000278285000039900000004670000000400400000050024000008001800000600007000070098000009002400000a005800000278285000039900000004670000000400400000
05002400000b004000000c0200687e0d600068820d680098860d9800987a0d002078000e002400000100580000027828500003990000000467000000040040000005002400000f0020740011002070001300288c001200580000109400787e0d6c0078820d0000000016000068000e5438008315a418747d15001cac78156474
6c001494006883149c7c9488146c00987d1468046800150248017b15020002081e050000030208004a6001010164230f3064000100030202060c000b000f030230004c6002010164230f0864000300030201060723040000030210004b1803010164230f10640005000302000000000b00640008000000070900640f06320a06
000702020000000b00640306004c6005090264140a4b0a04000502000000000b0064000400000004030064190a640202000402000001000b0064000a00ff000903006423143202070009010000080838000108010000081038000108010000081838000108010000082038000108010000082838000108010000083038000108
010000083838000108010000080014fe010c010000080814fe010c010000081014fe010c010000081814fe010c010000082014fe010c010000082814fe010c010000083014fe010c010000083814fe010c010000084014fe010c010000084814fe010c010000085014fe010c010000085814fe010c010000086014fe010c0100
00086814fe010c010000087014fe010c010000087814fe010c010000080000ff0114010000080800ff0114010000081000ff0114010000081800ff0114010000082000ff0114010000082800ff0114010000083000ff0114010000083800ff0114010000084000ff0114010000084800ff0114010000085000ff011401000008
5800ff0114010000086000ff0114010000086800ff0114010000087000ff0114010000087800ff011402000010284cfe010c010000083848fe011002010010184cfe010801000108285cfe010c01030108305cfe010c02000010084eff0112010000080050fe0110010000080060ff021c010000080867fe0215030000186864
fe031c010000085064fe0212020000105864fe010a0100000a586eff0112010000084054ff0114020101101850fe0210020003105864fe010a020000105864fe010a02000010206bfe021501020008306bfe010d01000008106fff011102000010484bfe0215030200185848ff0218010000081060fe010d010000081860fe02
18010300087048fe0218010000082060fe010b030000183872fe010e010000084048fe010b010000084068fe01080202280102022d01020304012901020304012e010304012f02030401300201042a362b2c030103310303040132020205023301010134010203040501350101023738040103393a0202013b0101053c3d0201
013e0101043f400202034201020304014101014301014401000001010000010000000001010000010001010007010204050685841812131403020506048584180e0f020506140385841810111111808182830008090a090a0c0c0c0c80818283080b0c0c0c0c80818283080d0c0c0c0c80818283087f625778487f6e6378497f
7d70780d02030406060708090a0b0c070c080b0f060707090a0707070708080b0f090707090a0707070a09080b0f0f0707090a070707070001010105010101010101010d02080b0f000707090a07070700120f01190601071b120a070349060c021812320a044a0601071b120a070349060f011912320a044a0601071b120a07
03490601081b120c0218060f0119120f0a054c0601081b120c0218060a070349120f0a054c0601081b120c02180601091b120f0119060a070349121908064b0601091b120f0119060c0218121908064b0601091b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000007000700070000706077776706000700700007007000000007007000700000700000000000000000000000000000000000000000000000000000000000000070067006700600006756666666057066006770660067000070660067006700006706000000000000000000000000000000
0000000000000000000000e2888888721672167216827865155d67552157672167576721672188576721672167217865258888881e00000000000000000000000000000000000000000000789a99497216781678168857d12111671172156781671567816781781567816781678167d1419999998a0000000000000000000000
00000000000000e0888828ea888888721778177817781712882277217711778177217781778177117781778177817717828888889e2188880e000000000000000000000000000000a79949e8888888721678167816781682822867816721678167815781678167216781678167217d76828888888e42a97a0000000000000000
0000000000000000e08828e8888888721c781c781c781c222628c781c781c781c7611582c781c781c781c781c721d1c7868888888821880e00000000000000000000000000000000008828e8888888d216681c681c681c621528c681c6815681c6d11688c681c6815681c681c681126d2c8888888e2188000000000000000000
0000000000000000008e28789a9999146d621c681c681c562128c681c6611582c611c682c681c6611582c661c62c6861159499998a21e80000000000000000000000000000000000e08828ea88888828d1761c781c786c158228c781c7562188c721c781c781c7562188c756c715c756218888889821880e0000000000000000
0000000000000000a79a491800000000006d056005d05600000056006d0500005600560056006d0500006d0556006d05000000008141997a000000000000000000000000000000e0888828010000000000d000d000000d0000000d00d00000000d000d000d00d0000000d0000d00d00000000000108288880e00000000000000
__sfx__
010200000000000000000000000000000000000000000000266730507516773166541062111621086210661604616036160261601616016150161701617016170161701617016170161701617016170161701615
01040015046141871305614046010460501600106000461415713036140260104605136000960006614167130461403601046050e600146000220401601026010260101605000000000000000000000000000000
010b0000322113c2113022332233332333f2233f21333213001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010601070071502711047210672104731027210071100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010300000c05410031130541803113054180311c0541f0311c0211f02124011240112401500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010400000c6142462124631186210c611006150000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010600001a673050750a053167730a6541062115631116210c6210862107621066110561204612036120361502612026150161201615016150161500000006150000000000000000000000000000000000000000
010300003071530714307163071500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010300000c2240c241170330b0732e2110a0102d221090202c231080302b241070402a24106230292310523028231042302723103220262210222025221012202421100215242110021524211002152421100215
01030018186130061400615000001d6130561405615000001b6130361403615000001f6130761407615000001a613026140261500000196130161401615000001e6130661406615000001a613026140261500000
010400000041400411004213c4213c4313c4323c4323c422004310042100411004110061200612006120061200615000000000000000000000000000000000000000000000000000000000000000000000000000
010200003b6403b6203b6203b62000000000003b6403b62000000000003b620000000000000000000003b62000000000000000000000000000000000000000000000000000000000000000000000000000000000
011b00000007500055000350007500055000350007500055000350007500055000350107501055010350103500075000550003500075000550003500075000550003500075000550003503075030550303503035
011b00000017300133000000012300113000000011300000076230762307615076150000000000000000c02300173001330000000123001130000000113000000762307623006130061503113031230313307113
011b0000081250512500125081250512500125081250512508125051250012508125051250112508125051250a12507125021250a12507125021250a125071250a12507125031250c12507125031250c12507125
011b000022314223122231222312223122231222312223152031420312203122031220312203151d3141d3121f3141f3121f3121f3121f3121f3121f3121f3121f3121f3121f3121f31500000000000000000000
011b000024314243122431224312243122431224312243152231422312223122231222312223151d3141d3121f3141f3121f3121f3121f3121f3121f3121f3121f3121f3121f3121f315000000c0332461524615
011b0000293142931229312293122931229312293122931527314273122731227312273122731529314293122b3142b3122b3122b3122b3122b3122b3122b3152431424312243122431224312243151f3141f312
011b00000c2250c2150c21511225112151121514225142251421500000000001861518615000730c013186131122511215112150c2250c2150c2150d2250d2250d215000000c0230c04318615000000000000000
0000707f0000000430000003010000007000000000007000000070000700000000000043000000301000000700000301000000000430000000000000000000000000000000000000000000000000000000000000
07707f0000000371000043700000000073f1000043700c37070000000030577000003710000437000003710000000305770000000000000000000000000000000040000000000000040000000014000000037f77
707f0000305770000000c373f7303057730d773f1000000037f77070073f10030577000073f1000000037f77070000000000000000000000000000000000000000000000000000000000000073d577050073f100
57ddf707305673f7303057717f373f100000073dd77070073f10030577000073f100000073d577050000000000000000000000000000000000100001000014000100000000014351d735050073f1003057700000
707f057d30577157673f100004351df37070073f10031577000073f100004351d7350500001000010000000000000010001000100000000001000000000000003053510765000073f10030577000071790537730
7f00f7073f1003053510f37070073f10030577000073f10030535107650000000000000000000000000000000140001400004000140001400000003777700460000073f1003057700c3707000377303057700007
00f7077000c37070073f10030577004073f10037777004600000000400014000140000000000001000010001100000000100000100013dd7707000000073f1003057700c37070003773030577000073f10037730
770071773f10030577000073f1003dd77070000000000000100010000000000100000140001000000000040001400014001d73737100000073710030537004370700037530305370000737100375300143707007
00707f0000007371001d73737100010000140001000014000140001000100011000100001000000000010001107673f730000073f1003057700c37070003773030577000073f1003773000c37070073f10130577
01dd9779107673f73000000100010000000001000000000001000024000140001000010000000001c651764700007391003054700c3107000176303054700007391001763000c310700739100315470040739100
1f101010004000140000400014010140000400000000000100000000000000010001008053df410f807393071fe4700c710fc371967030f4700807393001f67000c710f8073930030f471080739301108053df41
1212120110000100011100000000004000140001010120100100001000014001df710f80739b0517e4700c710f4671967030f4700807393001f67000c710fc073930032f4700c0739300024001df710f00000400
0010000012400014000000010000000011000000000000011000010f770580739b053df4700c710fc651f67030f47008071f1001f67000c77058073930130f47108071f1011000110f7705001100011040210001
10100000024000240001400010000140011010124700147505c07393003df4700c710f8051f67031f4710817151011f67002475058173930132f4720817151021247102475050110201112010220111240001400
121212120000000000000012040231f4730725008073930130f4700c710f0001f67030f411f475050011fe473072500807196701fe412f4750500231f47307250040211001100011000221001000000140001400
21212221010122201217e411f520008173930031f4720c710f0111f67031d41397250000117e411f5200040719e473dd41397250000017e411f52000012220122201212011024000040010001100012000221402
dd5705003dd471510020c071f1003077510c77050013f72011f311f520000013dd471510000805176751df311f520000013dd4715100200122240222012220001000000000014001240022012220111201122012
21d105102201715100315251043505400175201276715100004001d7350500001c053d5251076715100004001d735050002201102401220101240001400010000000100402210122101221402210121176500002
d200000d1072000465000011d10000c6505000000001076500000000011d72000c650500010002107650000210402210121000100000000000000000400014001101222012120122201202460000122281500001
00000000004000d000018050000001437014600040000400103000080500000020120246000012120111201212400014000040001400000001000110001214022101222012220002040221402004021100000000
0100577d0000030530305250000010000100000000020000000011000221000204022140221402110002100120001100000140001400220112240002400014000140012011120111040001000010000100001000
700500003153500000010001240001000014000040012400014001201222012124012201222012124001240000000000010000210012000000000100001104011040110000000000000000c413f7370000017567
dd5d551237d77192010000000001000011000000000100011000120402214022140210401000000140001400010110201101400004010101001400014000140000000000000042515f65000003d5353052000400
000000000140001400014000140001011020111201112011024000101001010014002100221001100012140221002210011000110000000000000000000000000000000000000001d72510300000000000000000
011122221000110000210122100110000100001000100000100000000001400024000240012010124001201002000014000140001000010000100000000000000040112720103000140001000000000100001400
220700002201002000014000140002400024000100000000000000000110001000010000010000301003010100001301000000700001104322043221402014301000117401104311100107001100000043111402
070100010700000001000000000000000000000140001400004000101001400014003750037731120113750000437000113253232577120113253012007170113253112017170121201031577220113253000407
00000000014000040000000000001000100000000000000010000000073f1073f777214073f10130577200023773037f77270013773021c37074013773022c37074022240137f77270023773000c370700010000
0000010000000000000140001000014000140002400024073fd3537777014073f10032577004073f7373dd77170113773012c37074013773022c3707012220173d577150113773012c3707012120110240001000
010101010000000000100011000100000000073fd253d577000073f1013057700c373f7351df37070013773010c37070013773021c3707402214351d735050123773021c37074021140210001000002000110000
21212121010111240001400004073f5203d577004073f10031577004673f73510f37074003773001c37074013773022c37070123253510765000123773022c370701222012120100140011010000001000121402
1202027121000000073f10030577000073f1003057700c653773000c37070003773000c37070013773021c37074023773000460000123773022c3707012224022140220001000000000012010120111201122011
770070773f10031577000073f10031577008053773000c37070003773001c37074003773012c37070123773020000200123773022c37070122201212010024000140001000100001000210001200010000100007
00717f000000737100305370000037530004370700037530004370700037530104370740237530210102101237530214370700110402100011000100000100010000000400004000140001400004073f10132577
7079000030577000003773001c37074003773000c37074003773012c37070123773022012220123773012c3707011120111201101400000000000000000000000000000000100000000739101315471000739100
9f0f029f1763010c31070011763000c31070001763021c31074021763021402214021763010c31070001000110000000000000000000000000100002400014000100001c073930132f47108173930032f4700400
0f009f0f0f4001f67001c710f0001f67002c710f0111f67022011220111f67037f410f40001400010000100001000010000000000000104000000010001108073930130f47108073930130f47100021f67010c71
129f0f1210c710f0001f67000c710f0011f670104022f0011f6703dd410f40210001000001000100000000000000000001000100240001011128173930132775008173930132f47100111f67012c710f0111f670
5f05109f3f72001c710f0101f67012817150111f6701df710f0100140001400014000140000400000000000000001100011000110807393013072520c073930231f47204021f67021c710f4021f67021c710f402
0f019ff90f0011f67010475250011f67010f710f0001000000001104011140000000010000140001400120111201112817196711f52010817196711fe411f0111f67022c710f0111fe4732f4139b171510012c71
5f05000032725020111f67002c710f400014000140001400010000100000000000001000111001000010000719e47151001000719e473dd41393011f67000c710f00117e411ff31196750500010c710f00017e41
ff0501ff1f67000c710f0010000000000000010000000000010000000000000000000000000805176750500000c05176751df311f1003f72000c77054003dd4715767397250000001c77054003dd471550000400
051000000540001001000000000001400014002000100001000000000000000008053d52500000008053d52510767151001752000435050001d73505c65175200000000435050001d73505000000001752010435
00000000000001000000001000000000000000000000000000000000001d72000000000001d72000c65050001d100004650000011765008051d1000000000465000001176500000000001d100014650000000000
0000000000000000000000000000000000000000000000001030000000000001030000805000000d000004600000000460000000d0000000000460000000046000000000000d0000046000000000000000000000
__music__
00 0c0d4344
00 0c0d0e44
00 0c0d0e4f
00 0c0d0e0f
00 0c0d0e10
00 0c0d0e11
00 0c0d0e0f
00 0c0d1244
00 0c0d1244
00 0c0d0e0f
00 0c0d0e10
00 0c0d0e11
02 0c0d0e0f

