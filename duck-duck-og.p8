pico-8 cartridge // http://www.pico-8.com
version 27
__lua__
--duck duck on the loose
--sean s leblanc

function range(v)
 return rnd(max(0,v[2]-v[1]))+v[1]
end

function lerp(from,to,t)
 return from+t*(to-from)
end

function ease(t)
 if t >= 0.5 then
  return (t-1)*(2*t-2)*(2*t-2)+1
 else
  return 4*t*t*t
 end
end

function v_add(a,b)
 return {a[1]+b[1],a[2]+b[2]}
end
function v_sub(a,b)
 return {a[1]-b[1],a[2]-b[2]}
end
function v_mul(v,s)
 return {v[1]*s,v[2]*s}
end
function v_div(v,s)
 if s != 0 then
  return {v[1]/s,v[2]/s}
 else
  return {0,0}
 end
end
function v_len2(v)
 return v[1]*v[1]+v[2]*v[2]
end
function v_len(v)
 return sqrt(v_len2(v))
end
function v_lenm(v)
 return abs(v[1])+abs(v[2])
end
function v_normalize(v)
 return v_div(v,v_len(v))
end
function v_lerp(a,b,t)
 return{lerp(a[1],b[1],t),lerp(a[2],b[2],t)}
end
function v_dist(a,b)
 return v_len(v_sub(a,b))
end
function v_distm(a,b)
 return v_lenm(v_sub(a,b))
end
function hex(num)
 if num>9 then
  num-=9
  num=sub("abcdef",num,num)
 end
 return num
end

function add_biome(
 colour,tree_range,bush_props,transition,footprints)
 
 biomes[colour]={
 tree_range=tree_range,
 transition=transition,
 bush_props = bush_props,
 footprints=footprints[1],
 foot_sfx=footprints[2],
 building_freq=0
 }
end

function _init()
 music(0,1000,3+4)
 srand"4"
 seed=rnd()
 palt(0,false)
 palt(14,true)
 
 shadow_offset=v_normalize({2,3})
 
 shadow_offset=v_mul(shadow_offset,0.2)
 
 perspective_offset={64,80}
 height_mult=0.015
 
 cell_size=32
 cells={}
 cell_bounds=128
 cell_bound_str=2
 cell_fill=flr(128/cell_size+0.5)
 
 
 biomes={}
 for i=0,15 do
  add_biome(i,{0,0},{0,0,{}},false,{true,3})
 end
 add_biome(14,{0,0},{0,0,{}},true,{true,0})
 add_biome(1,{0,0},{0,0,{}},true,{false,1})
 add_biome(12,{0,0},{0,0,{}},false,{false,1})
 add_biome(3,{0.25,0.3},{0.5,05,{8,12,13,10}},true,{true,0})
 add_biome(4,{0,0},{0,0,{}},true,{true,3})
 add_biome(5,{0,0},{0,0,{}},false,{false,2})
 add_biome(6,{0,0},{0,0,{}},false,{false,2})
 add_biome(7,{0,0.1},{0.1,0,{}},true,{true,3})
 add_biome(11,{0.1,0.3},{0.5,0.8,{8,12,13,10}},true,{true,0})
 add_biome(15,{0,0.2},{0.2,0.2,{11,13}},true,{true,3})
 add_biome(10,{0,0},{0,0,{}},true,{true,3})

 biomes[10].building_freq=0.8
 biomes[15].building_freq=0.01
 
 trees={
 height_range={10,25},
 girth_range={4,10},
 gap=16
 }
 
 clouds={}
 c_height_range={45,50}
 c_count_range={20,40}
 c_radius_range={5,15}
 c_cluster_range={5,7}
 c_size=256
 
 bushes={}
 bushes_height_range={0.5,1.5}
 bushes_count_range={10,30}
 bushes_radius_range={1,2.5}
 bushes_cluster_range={2,4}
 
 buildings={}
 buildings_height_range={10,35}
 buildings_w_range={8,min(cell_size,cell_size)-16}
 buildings_h_range={8,min(cell_size,cell_size)-16}
 buildings_colours={8,9,6}
 
 p={
 p=v_mul({82,16},32),
 v={0,0},
 speed={0.7,0.7},
 max_speed=3,
 cur_speed=0,
 damping=0.8,
 a=0.75,
 a_o=0,
 stride_w=4,
 stride_l=12,
 stride_alt=false,
 height=4,
 quack_timer=0,
 c={0,0,0},
 duck=-1,
 ducklings={}
 }
 
 ducklings={
 height=3,
 r=2,
 found=0,
 found_timer=0
 }
 
 add(ducklings,{
  p=v_add(v_mul({23,60},32),{rnd(cell_size),rnd(cell_size)})
 })
 add(ducklings,{
  p=v_add(v_mul({118,8},32),{rnd(cell_size),rnd(cell_size)})
 })
 add(ducklings,{
  p=v_add(v_mul({26,105},32),{rnd(cell_size),rnd(cell_size)})
 })
 add(ducklings,{
  p=v_add(v_mul({69,82},32),{rnd(cell_size),rnd(cell_size)})
 })
 add(ducklings,{
  p=v_add(v_mul({118,105},32),{rnd(cell_size),rnd(cell_size)})
 })
 add(ducklings,{
  p=v_add(v_mul({32,19},32),{rnd(cell_size),rnd(cell_size)})
 })
 add(ducklings,{
  p=v_add(v_mul({107,84},32),{rnd(cell_size),rnd(cell_size)})
 })
 
 p.r=4 
 p.r2=p.r*p.r
 cam={
 p=v_sub(p.p,{64,64+128}),
 c={0,0},
 offset={64,64},
 sway={0.25,0.25,8,9}
 }
 cam.p_o=cam.p
 
 cells.current={
  flr(cam.p[1]/cell_size),
  flr(cam.p[2]/cell_size)
 }
 
 mapdata_string=""
 for i=0x2000,0x2fff do
  local a=shr(band(peek(i),0xf0),4)
  local b=hex(band(peek(i),0x0f))
  for j=1,a do
   mapdata_string=mapdata_string..b
  end
 end
 
 mapdata={}
 local x=cell_bounds-1
 local y=-1
 while #mapdata_string > 0 do
  x+=1
  if x==cell_bounds then
   x=0
   y+=1
   if y==cell_bounds then
    break
   end
   mapdata[y]={}
  end
  
  local s=sub(mapdata_string,1,1)
  mapdata[y][x]=("0x"..s)+0
  mapdata_string=sub(mapdata_string,2,#mapdata_string)
 end
 init_cells()
 
 footprints={
  {0,0},
  {0,0},
  max=64,
  remove_delay=0.25,
  remove_last=time()
 }
 for i=3,footprints.max-1,2 do
  footprints[i]=footprints[1]
  footprints[i+1]=footprints[2]
 end
 
 for i=1,range(c_count_range) do
  local x=rnd(c_size*2)
  local y=rnd(c_size*2)
  local r=0
  for j=1,range(c_cluster_range) do
   local c={
    r=range(c_radius_range),
   }
   c.p={
    x+range({1,(c.r+r)/2})-range({1,(c.r+r)/2}),
    y+range({1,(c.r+r)/2})-range({1,(c.r+r)/2})
   }
   
   if rnd() > 0.5 then
    x=c.p[1]
    y=c.p[2]
    r=c.r
   end
   c.height=range(c_height_range)
   c.s=c.p
   
   add(clouds,c)
  end
 end
 
 npcs={
 	{who="drake",spr=1,
 	mouth=-1,mouth_offset=0,
 	c1=4,c2=3,r=3,height=2,
  cell={81,15},
 	lines="duck duck! we need your help!|we lost our babies!!!!!|we had eight before, but now we only have one!|i don't know what happened to the rest!|i'm staying here to keep track of the last one.|please find the other seven!|we're counting on you\nduck duck!|...|if you don't know where to look...|try the city west of us.|"},

 	{who="hen",spr=0,
 	mouth=-1,mouth_offset=0,
 	c1=6,c2=4,r=3,height=2,
  cell={83,15},
 	lines="duck duck! you need to find our babies!|we lost them!!!!!|one's here, but seven are out there all alone!|you've got to find them!|don't let us down duck duck!|...|i wonder if they went to the town east of our lake?|"},

 	{who="duckling",spr=2,
 	mouth=-1,mouth_offset=0,
 	c1=9,c2=10,r=2,height=2,
  cell={81,16},
 	lines="hi duck duck!|are you going to find my brothers and sisters?|they're hiding somewhere around here...|i'll let you know if i see them!|good luck duck duck!|"},

 	{who="chevy",spr=15,
 	mouth=0,mouth_offset=0,
 	c1=3,c2=8,r=5,height=4,
  cell={53,52},
  lines="oi, duck duck.|you seen tom?|i caught the rascal sneaking through winter supplies.|i chased him out of town...|but lost him when he cut through the river.|make sure to let me know if you see him, you hear?|...|he'll have to come back at some point...|"},

 	{who="spooky ghost",spr=14,
 	mouth=7,mouth_offset=0,
 	c1=7,c2=6,r=3,height=4,
  cell={17,77},
  lines="hi duck duck!|how's it going?|keeping busy?|you always were a go-getter.|never could sit still...|that's not really my style, you know?|i tend to stay put.|course, i always appreciate visitors.|drop by anytime!|"},

 	{who="giddy girl",spr=13,
 	mouth=0,mouth_offset=2,
 	c1=10,c2=8,r=3,height=2,
  cell={101,8},
  lines="hey duck duck!|whatcha up to?|are you playing a game?|can i play too?!|i'm really good at games!!|my parents said i can't leave the city though.|does that mean i can't play with you?|...|what's it like outside?|are there lots of kids like me?|or are they all ducks like you?|that'd be weird!|i'm glad i'm not a duck.|...|...|could i go out on my own like you if i was a duck?|"},

 	{who="helenista",spr=12,
 	mouth=0,mouth_offset=0,
 	c1=13,c2=15,r=3,height=4,
  cell={50,39},
  lines="hmph.\nduck duck.|i see you're doing well.|...|...|don't think i've forgotten what happened last time.|things don't just fix themselves overnight.|i certainly haven't forgiven you either.|...|look, i appreciate you're making an effort...|but i can't do this right now.|-you- can't do this right now.|i've heard the rumours.|i see the way you walk through town.|more importantly:\ni know you duck duck.|do you even know how long it's been?|do you care?|of course you don't.|you never did.|maybe someday you'll realize why that matters.|i hope, for your sake, that you do.|until then, i'd really rather not talk to you.|...|...|just... just drop it, duck duck.|"},

 	{who="tommy tim-tom",spr=11,
 	mouth=0,mouth_offset=0,
 	c1=1,c2=15,r=4,height=4,
  cell={58,58},
  lines="duck duck, buddy!|how's it going?|on a noble adventure, i see!|i know how that goes...|but that life's not for your ol' pal tommy!|leave the adventurin' to the birds, i always say!|speaking of birds...|what's up with those ducklings?|i saw one headed out west earlier...|course i didn't follow!|birds know best, as i always say!|or is it \"birds know west\"?|...|well, i'll let you get back to it...|best o' luck duck duck!|"},

 	{who="swimmer",spr=10,
 	mouth=0,mouth_offset=-4,
 	c1=10,c2=13,r=4,height=3,
  cell={28,84},
 	lines="oh! duck duck!|what a great day for a swim.|wouldn't you agree?|i've been doing calisthenics here every day.|i feel so much better for it!|so full of energy!|swimming is such great exercise.|though i'm sure you already knew that!\nha ha!|...|my friends think i'm crazy for doing this.|they say it's dangerous to be out here alone.|they keep telling me but i just ignore them.|it's like water off a duck's back!|ha ha!|...|thanks for the visit...|but i should get back to exercising.|see you around duck duck!|"},

 	{who="chuck",spr=9,
 	mouth=0,mouth_offset=-4,
 	c1=9,c2=15,r=4,height=4,
  cell={42,15},
  lines="duck duck!|what did i tell you last time!?|i don't care what the others say.|no freeloaders allowed!|uh uh, no exceptions!|like 'em or not, those're the rules.|...|don't pretend you don't know what i'm talking about!|think i'm gonna let ducklings lounge in our park?|if they're not gone today, it's your head!|and you bet your butt that's a threat.|look at you, acting all high and mighty...|you ain't mighty duck duck!|you're on thin ice.|thin.\n\nice.|"},

  {who="pupperino",spr=8,
  mouth=0,mouth_offset=0,
  c1=4,c2=4,r=3,height=2,
  cell={23,61},
  lines="greetings duck duck.|your kind is very disruptful.|the peaceful clearing should not be disrupted.|please leave, and take your kin with you.|"},

  {who="pupperoni",spr=8,
  mouth=0,mouth_offset=0,
  c1=4,c2=4,r=3,height=2,
  cell={23,61},
  lines="hello duck duck.|please take your young and leave.|this clearing is a place of peace.|a peace which your kind now disturbs.|begone.|"},

  {who="doggo",spr=8,
  mouth=0,mouth_offset=0,
  c1=4,c2=4,r=3,height=2,
  cell={24,62},
  lines="hey duck duck.|sorry about the others.|they take the \"peaceful clearing\" very seriously.|you don't really need to worry.|they're too lazy to kick you out themselves.|but you should probably head out anyway.|talk to you later duck duck.|"},

 	{who="pen",spr=7,
 	mouth=0,mouth_offset=0,
 	c1=2,c2=4,r=4,height=4,
  cell={91,46},
  lines="duck duck.|sometimes i worry about the future.|things can change so fast...|what will the world be like when i'm gone?|it used to stress me out.|but then i remembered:|i won't even be around to reflect on it!|so why worry?|...|...now that i say that out loud...|i'm realizing that's actually even more worrying.|hmm.|...|i, uh...|i might need a minute to let that one digest.|hmm...|"},

 	{who="barbara",spr=6,
 	mouth=2,mouth_offset=0,
 	c1=8,c2=10,r=4,height=3,
  cell={107,8},
  lines="hi there! you must be duck duck.|are you looking for those ducklings from earlier?|i think most of them left already.|they were super cute!|...|...|do you ever wonder if you waited too late to have kids?|...|ha ha! me neither!|...|...|life here is pretty nice, don't you think?|"},

 	{who="buddy boy",spr=5,
 	mouth=0,mouth_offset=2,
 	c1=12,c2=15,r=3,height=2,
  cell={26,26},
  lines="duck duck!|ha ha!|hey, guess what?|can you guess?|i bet you can't!\nha ha!|you're a duck!|ha ha!|"},

 	{who="ranger",spr=4,
 	mouth=0,mouth_offset=0,
 	c1=3,c2=15,r=4,height=4,
  cell={106,69},
  lines="hoi duck duck!|what's the news from the lake?|anything to report?|it's been pretty quiet in these parts.|couple ruffians came through earlier...|nothing i couldn't handle though!|i sent them packing down south, yes i did!|youngsters like that have no business in these woods!|all running about as if they own the place...|no respect for nature!|not at all like you duck duck.|i can always count on you to get things done right!|...|best let you get back to it duck duck!|"},

 	{who="scarves mcgee",spr=3,
  mouth=0,mouth_offset=0,
  c1=5,c2=4,r=4,height=4,
  cell={37,26},
  lines="hello duck duck!|how are you today?|i'm taking a personal day...|get me some me time, you know?|oh, speaking of which...|i saw a couple ducklings strolling through town.|looked like they were making a day of it!|i doubt they both stuck around though.|not much space around here...|anyway, nice catching up with you.|make sure to hit me up next time you're in town!|...|...|...i wonder if i should get a new scarf...|"},

 {who="mountain climber",spr=16,
  mouth=0,mouth_offset=0,
  c1=1,c2=8,r=4,height=4,
  cell={107,83},
  lines="wow duck duck!|you climbed this mountain too?|impressive!|isn't it great here? we're so far up!|so far away from everything...|it was quite a hike!|one slip and that would've been it for me!|...|i hope we'll have a safe trip back to base camp.|wouldn't want them to send a rescue team after us!|...|*sigh*|i know, duck duck.|i know it's all flat.|but... let me have this moment, okay?|...|thanks duck duck.|...|...|i think i can see my house from here!|"},

 {who="chateau",spr=18,
  mouth=7,mouth_offset=2,
  c1=0,c2=0,r=3,height=2,
  cell={37,32},
  lines="bonjour duck duck!|comment ca va?|bien? bien!|"},

 {who="chatelain",spr=17,
  mouth=0,mouth_offset=2,
  c1=10,c2=9,r=3,height=2,
  cell={115,42},
  lines="salut duck duck!|voulez-vous l'aide?|non?|d'accord, je reste ici!|me parler encore si tu besoin d'aide.|...|voux parlez francais, oui?|"},

 {who="maximillian",spr=19,
  mouth=0,mouth_offset=0,
  c1=0,c2=15,r=4,height=4,
  cell={54,32},
  lines="welcome back duck duck!|i hope things are going well for you.|things here are better than ever!|don't you worry about us.|surely you've got other things to do anyway.|oh!|ducklings!!|we had some duckling guests earlier!|i think one of them is still here...|a couple left to the south a little while ago.|you should probably go check that out.|...|yep, definitely don't need help here right now.|"},

 {who="poctling",spr=20,
  mouth=0,mouth_offset=2,
  c1=0,c2=13,r=4,height=3,
  cell={83,110},
  lines="duck duck.|you were not expected, duck duck.|"},

 {who="poctling",spr=21,
  mouth=0,mouth_offset=0,
  c1=0,c2=13,r=4,height=3,
  cell={96,107},
  lines="duck duck.|you were not invited, duck duck.|"},

 {who="poctling",spr=22,
  mouth=0,mouth_offset=0,
  c1=0,c2=13,r=4,height=4,
  cell={95,113},
  lines="duck duck.|you were not allowed, duck duck.|"},

 {who="poctling",spr=23,
  mouth=0,mouth_offset=0,
  c1=0,c2=13,r=4,height=4,
  cell={102,109},
  lines="duck duck.|you are trespassing, duck duck.|"},

 {who="poctling",spr=22,
  mouth=0,mouth_offset=0,
  c1=0,c2=13,r=4,height=4,
  cell={108,107},
  lines="duck duck.|you are intruding, duck duck.|"},

 {who="poctling",spr=21,
  mouth=0,mouth_offset=0,
  c1=0,c2=13,r=4,height=3,
  cell={112,114},
  lines="duck duck.|you are violating, duck duck.|"},

 {who="poctling",spr=20,
  mouth=0,mouth_offset=2,
  c1=0,c2=13,r=4,height=3,
  cell={118,110},
  lines="duck duck.|this place is not for you, duck duck.|this place is not for your younglings, duck duck.|collect them, duck duck.|collect them and leave, duck duck.|"},

 {who="worker",spr=31,
  mouth=-1,mouth_offset=0,
  c1=10,c2=12,r=4,height=4,
  cell={18,84},
  lines="what's up duck duck?|oh...|oh hey! check it out!|duck duck's on the dock!|heh.|hehe!|ha ha ha ha!|haaa...|man, i crack myself up.|"},

 {who="worker",spr=31,
  mouth=-1,mouth_offset=0,
  c1=10,c2=12,r=4,height=4,
  cell={32,100},
  lines="duck duck?! you shouldn't be out here!|it's really dangerous!|you aren't wearing protective gear or anything!|ohhh - if my supervisor sees you they're gonna flip.|we already had one duck come through here...|that didn't go over well at all!|look, you need to get a move on.|this is no place for ducks!|not even you duck duck!|oh man i'm going to be in sooo much trouble...|"},

 {who="debbie",spr=28,
  mouth=0,mouth_offset=0,
  c1=2,c2=4,r=4,height=4,
  cell={64,88},
  lines="have you seen this garden maze duck duck?|i thought it'd be fun to explore...|but you can just walk between the trees!|it's kind of lame, honestly.|major let-down. a 6/10 at best.|you can quote me on that.|looks like that feathery kid had fun at least.|so not a total waste of space.|...|i wonder who organized this thing...|"},

 {who="curious child",spr=27,
  mouth=0,mouth_offset=2,
  c1=3,c2=4,r=3,height=2,
  cell={106,6},
  lines="um, you're duck duck, right?|my dad said i'm not supposed to talk to strangers...|especially ones from out of town...|but can i ask you something?|um...|do i reaaalllly need to go to bed when the sun goes down?|cause sometimes, i'm just not tired!|...|i think my dad's a liar.|"},

 {who="signpost",spr=24,
  mouth=-1,mouth_offset=0,
  c1=4,c2=4,r=4,height=4,
  cell={71,108},
  lines="the sign says:|new poctridge|"},

 {who="signpost",spr=24,
  mouth=-1,mouth_offset=0,
  c1=4,c2=4,r=4,height=4,
  cell={103,12},
  lines="the sign says:|obblesville|"},

 {who="signpost",spr=24,
  mouth=-1,mouth_offset=0,
  c1=4,c2=4,r=4,height=4,
  cell={31,19},
  lines="the sign says:|ackelsby park|"},

 {who="faded signpost",spr=24,
  mouth=-1,mouth_offset=0,
  c1=4,c2=4,r=4,height=4,
  cell={36,78},
  lines="the sign says:|pol r1 gf|"}
 }
 
 for npc in all(npcs) do
  npc.p={rnd(cell_size),rnd(cell_size)}
  npc.r2=npc.r*npc.r
  
  if npc.cell==nil then
   npc.cell={flr(rnd(cell_bounds)),flr(rnd(cell_bounds))}
  
   -- put unset npcs in top-left
   npc.cell={flr(rnd"6"),flr(rnd"6")}
  end
  
  npc.sfx=flr(rnd"2")+10
  
  npc.lines=npc.lines or "oh hey duck duck!|this is just some test dialog.|it's the same for every character!|i'm just gonna say this now.|"
  
  -- add breaks into lines
  -- (no word breaks)
  local l=npc.lines
  local lw=0
  local ww=0
  local word=""
  npc.lines=""
  while #l > 0 do
   --get next letter
   local c=sub(l,1,1)
   l=sub(l,2,#l)
   word=word..c
   
   -- word ends
   if c==" " or c=="\n" or c=="|" or #l==0 then
    if #word+lw>16 then
     npc.lines=npc.lines.."\n"
     lw=0
    end
    
    npc.lines=npc.lines..word
    lw+=#word
    word=""
    -- newline characters
    if c=="\n" or c=="|" then
     lw=0
    end
   end
  end
  
  -- save the last line for repeating
  local l=#npc.lines
  repeat
   l-=1
  until sub(npc.lines,l,l) == "|"
  npc.lastline = sub(npc.lines,l,#npc.lines)
 end
 
 talk={
  npc=nil,
  bounce=0,
  say="",
  said="",
  offset_target=40
 }
 talk.offset=-talk.offset_target
 
 menu=0
end

function init_cells()
 
 
 cells.a={}
 for a=0,cell_fill do
 cells.a[a]={}
 for b=0,cell_fill do
 local c={}
 cells.a[a][b]=c
 
 local x=a+cells.current[1]
 local y=b+cells.current[2]
 
 -- seed the rng based on cell position
 c.seed=seed+x*(cell_bounds*2)+y
 srand(c.seed)
 
 if x<0 or x>cell_bounds-1 or y<0 or y>cell_bounds-1 then
  c.c=1
 else
  c.c=mapdata[y][x]
 end
 c.c=c.c or 1
 c.biome=biomes[c.c]
 
 -- get colours for edge transition
 c.edges={}
 for u=-1,1 do
  c.edges[u]={}
 for v=-1,1 do
  if x+u<0 or x+u>cell_bounds-1 or y+v<0 or y+v>cell_bounds-1 then
   c.edges[u][v]=1
  else
   c.edges[u][v]=mapdata[y+v][x+u]
  end
  if c.edges[u][v]==14 then
   c.edges[u][v]=3
  end
  c.edges[u][v]=c.edges[u][v] or 1
  
 end
 end
 
 
 c.trees={}
 local tree_freq=ease(range(c.biome.tree_range))
 
 c.bushes={}
 
 if c.c==14 then
  -- boundaries
  c.c=3
  local t={
   height=range(trees.height_range),
   girth=min(cell_size,cell_size)*2/5,
   p={
    cell_size/2,
    cell_size/2
   },
   leaves={{0,0},{0,0},{0,0}}
  }
  t.s=t.p
   
  add(c.trees,t)
 else
  -- normal cell
  
  --trees
  for x=0,cell_size-trees.gap,trees.gap do
  for y=0,cell_size-trees.gap,trees.gap do
   if rnd() < tree_freq then
    local t={
     height=range(trees.height_range),
     girth=range(trees.girth_range),
     p={
      x+rnd(trees.gap),
      y+rnd(trees.gap)
     },
     leaves={{0,0},{0,0},{0,0}}
    }
    t.p={
    mid(t.girth,t.p[1],cell_size-t.girth),
    mid(t.girth,t.p[2],cell_size-t.girth)
    }
    t.s=t.p
    add(c.trees,t)
   end
  end
  end
  
  --bushes
  if rnd() < c.biome.bush_props[1] then
   local x=rnd(cell_size)
   local y=rnd(cell_size)
   local r=0
   local bloom_colours=c.biome.bush_props[3]
   local colour=bloom_colours[flr(rnd(#bloom_colours))%#bloom_colours+1]
   for j=1,range(bushes_cluster_range) do
    local b={
     r=range(bushes_radius_range)
    }
    b.p={
     x+range({1,(b.r+r)})-range({1,(b.r+r)/2}),
     y+range({1,(b.r+r)})-range({1,(b.r+r)/2})
    }
    if rnd() > 0.5 then
     x=b.p[1]
     y=b.p[2]
     r=b.r
    end
    b.height=range(bushes_height_range)
    b.c=colour
    
    if rnd() < c.biome.bush_props[2] then
     local a=rnd()
     local r=rnd(b.r/2)+b.r/4
     local bloom={
      p={
       r*cos(a),
       r*sin(a)
      }
     }
     b.bloom = bloom
    else
     b.bloom=nil
    end
    b.s=b.p
   
    add(c.bushes,b)
   end
  end
 
  -- buildings
  if
   #c.bushes + #c.trees == 0 and
   rnd() < c.biome.building_freq
  then
   c.building={
    size={
     range(buildings_w_range),
     range(buildings_h_range)
    },
    p={cell_size/2,cell_size/2},
    height=range(buildings_height_range),
    c=buildings_colours[flr(rnd(16))%#buildings_colours+1]
   }
   c.building.s=v_sub(c.building.p,p.p)
  end
 
 end
 
 end
 end
end

function add_blob(p,r)
 add(blobs,{
 hit=false,
 p=p,
 r=r,
 r2=r*r
 })
end

function _update()
 
 local v_dif={0,0}
 
 if menu != nil then
  -- menu transition
  if menu==0 then
   if btnp"4" or btnp"5" then
    menu-=1
    sfx(7,1)
    if btnp"4" then
     p.c={4,10,3}
     p.duck=4
    else
     p.c={6,10,4}
     p.duck=5
    end
   end
  else
   menu+=menu/4
   
   if menu < -128 then
    menu=nil
   end
  end
 else
  
  -- movement
  if btn"0" then v_dif[1] -= p.speed[1] end
  if btn"1" then v_dif[1] += p.speed[1] end
  if btn"2" then v_dif[2] -= p.speed[2] end
  if btn"3" then v_dif[2] += p.speed[2] end
  
  -- footstep sfx
  if
   btn"0" != btn"1" or
   btn"2" != btn"3"
  then
   if p.cell!= nil and stat"16" != p.cell.biome.foot_sfx then
    sfx(p.cell.biome.foot_sfx,0)
   end
  else
   sfx(-1,0)
  end
 
 end
 
 
 
 -- quack
 if btnp"4" then
  sfx(5,2)
  p.quack_timer=10
  cam.p=v_add(cam.p,{cos(p.a)*-2,sin(p.a)*-2})
 elseif btnp"5" then
  sfx(6,2)
  p.quack_timer=10
  cam.p=v_add(cam.p,{cos(p.a)*-2,sin(p.a)*-2})
 end
 
 p.quack_timer=max(0,p.quack_timer-1)
 
 perspective_offset={64+sin(time()/9)*4,80+sin(time()/11)*4}
 
 
 if abs(v_dif[1])+abs(v_dif[2]) > 0.01 then
  p.v=v_add(p.v,v_dif)
  p.a_o=p.a
  p.a=atan2(p.v[1],p.v[2])
 end
 
 p.v=v_mul(p.v,p.damping)
 
 if abs(p.v[1]) < 0.01 then
  p.v[1]=0
 end
 if abs(p.v[2]) < 0.01 then
  p.v[2]=0
 end
 
 p.cur_speed=v_len(p.v)
 if p.cur_speed > p.max_speed then
  p.v=v_mul(p.v,p.max_speed/p.cur_speed)
  p.cur_speed=p.max_speed
 end
 
 p.p=v_add(p.p,p.v)
 
 -- camera
 cam.offset=v_add(v_mul(p.v,-15),{64,64})
 if menu!=nil then
  cam.offset[2]+=128+menu*1.5
 end
 
 cam.p_o=cam.p
 local sway={
  cam.sway[1]*cos(time()/cam.sway[3]),
  cam.sway[2]*sin(time()/cam.sway[4])
 } 
 cam.p=v_add(
 v_lerp(cam.p,v_sub(p.p,cam.offset),0.1),
 sway
 )
 cam.v=v_sub(cam.p,cam.p_o)

 cam.c={
 cam.p[1]%cell_size,
 cam.p[2]%cell_size
 }

 local cell={
 flr(cam.p[1]/cell_size),
 flr(cam.p[2]/cell_size)
 }
 if cell[1]!=cells.current[1] or cell[2]!=cells.current[2] then
  cells.current=cell
  init_cells()
 end
 
 
 blobs={}
 
 u_trees()
 u_clouds()
 u_bushes()
 u_buildings()
 u_npcs()
 u_ducklings()
 u_collision()
 
 
 local pcell={
 flr(p.p[1]/cell_size),
 flr(p.p[2]/cell_size)
 }
 
 pcell=v_sub(pcell,cell)
 
 p.cell=cells.a[pcell[1]][pcell[2]]

 u_footprints()
 u_dialog()
end

function u_footprints()
 if p.cell then
 if p.cell.biome.footprints then
  -- footprints
  local fa=p.a
  if p.stride_alt then
   fa+=0.5
  end
  local fw=p.stride_w*(1-p.cur_speed/p.max_speed*0.8)*(1-abs(p.a-p.a_o))
  local fl=p.stride_l*(0.5+p.cur_speed/p.max_speed*0.5)
  local fp={
   p.p[1]+fw*cos(fa+0.25),
   p.p[2]+fw*sin(fa+0.25)
  }
  fp[3]=fp[1]-p.v[1]
  fp[4]=fp[2]-p.v[2]
  
  if v_distm(fp,footprints[footprints.max-1]) > fl then
   -- add footprints
   -- (actually just recycle existing ones)
   for i=1,footprints.max-1 do
    footprints[i]=footprints[i+1]
   end
   footprints[footprints.max]=fp
   p.stride_alt = not p.stride_alt
  end
 end
 end
end


function u_collision()
 -- blobs
 for b in all(blobs) do
  local d=v_sub(p.p,b.p)
  local l2=v_len2(d)
  if l2 < b.r2+p.r2 then
   b.hit=true
   p.v=v_add(p.v,v_div(d,sqrt(l2)))
  else
   b.hit=false
  end
 end
 
 -- boundaries
 local x=p.p[1]/cell_size
 local y=p.p[2]/cell_size
 if x > cell_bounds then
  p.v[1] -= (x-cell_bounds)*cell_bound_str
 elseif x < 0 then
  p.v[1] -= x*cell_bound_str
 end
 
 if y > cell_bounds then
  p.v[2] -= (y-cell_bounds)*cell_bound_str
 elseif y < 0 then
  p.v[2] -= y*cell_bound_str
 end
end

function u_trees()
 
 for x=0,cell_fill do
 for y=0,cell_fill do
 
 local ts=cells.a[x][y].trees
 
 local cellp = {
  cam.p[1]%cell_size-x*cell_size,
  cam.p[2]%cell_size-y*cell_size
 }
 
 for t in all(ts) do
  t.s=v_sub(t.p,v_add(cellp,perspective_offset))
  t.s=v_mul(t.s,t.height*height_mult)
  
  t.s=v_add(t.p,t.s)
  
  t.leaves={
  v_lerp(t.p,t.s,0.5),
  v_lerp(t.p,t.s,0.75),
  t.s
  }
  
  add_blob(v_add({(cells.current[1]+x)*cell_size,(cells.current[2]+y)*cell_size},t.p), t.girth)
  
 end
 
 end
 end
end

function u_clouds()
 for c in all(clouds) do
  c.p[1]+=0.1-cam.v[1]
  c.p[2]+=0.1-cam.v[2]
  
  if c.p[1] > c_size+c_radius_range[2] then
   c.p[1] -= c_size*2+c_radius_range[2]
  elseif c.p[1] < -c_size-c_radius_range[2] then
   c.p[1] += c_size*2+c_radius_range[2]
  end
  if c.p[2] > c_size+c_radius_range[2] then
   c.p[2] -= c_size*2+c_radius_range[2]
  elseif c.p[2] < -c_size-c_radius_range[2] then
   c.p[2] += c_size*2+c_radius_range[2]
  end
  
   
  
  c.s=v_sub(c.p,perspective_offset)
  c.s=v_mul(c.s,c.height*height_mult)
  c.s=v_add(c.p,c.s)
  
  c.ps=v_add(c.p,v_mul(shadow_offset,c.height))
 end
end

function u_bushes()
 for x=0,cell_fill do
 for y=0,cell_fill do
 
 local bs=cells.a[x][y].bushes
 
 local cellp = {
  cam.p[1]%cell_size-x*cell_size,
  cam.p[2]%cell_size-y*cell_size
 }
 
 for b in all(bs) do
  b.s=v_sub(b.p,v_add(cellp,perspective_offset))
  b.s=v_mul(b.s,b.height*height_mult)
  
  b.s=v_add(b.p,b.s)
 end
 
 end
 end
end


function u_buildings()
 for x=0,cell_fill do
 for y=0,cell_fill do
 
 local b=cells.a[x][y].building
 
 if b then
  local cellp = {
   cam.p[1]%cell_size-x*cell_size,
   cam.p[2]%cell_size-y*cell_size
  }
  b.s=v_sub(b.p,v_add(cellp,perspective_offset))
  
  local s1=max(b.size[1],b.size[2])
  local s2=min(b.size[1],b.size[2])
  for i=-s1+s2/2,s1-s2/2,s2 do
   local blob={
    hit = false,
    p = v_add({(cells.current[1]+x)*cell_size,(cells.current[2]+y)*cell_size},b.p),
    r = s2,
    r2=s2*s2
   }
   if s1==b.size[1] then
    blob.p[1]+=i
   else
    blob.p[2]+=i
   end
   add(blobs,blob)
  end
  local blob={
   hit = false,
   p = v_add({(cells.current[1]+x)*cell_size,(cells.current[2]+y)*cell_size},b.p),
   r = s2,
   r2=s2*s2
  }
  if s1==b.size[1] then
   blob.p[1]+=s1-s2/2
  else
   blob.p[2]+=s1-s2/2
  end
  if v_dist(blob.p,blobs[#blobs].p)>2 then
   add(blobs,blob)
  end
 end
 
 end
 end
end

function u_npcs()
 for npc in all(npcs) do
  npc.p2={npc.cell[1],npc.cell[2]}
  
  if v_distm(npc.p2,v_add(cells.current,{2,2})) <= 4 then
  npc.active=true
  npc.p2[1]*=cell_size
  npc.p2[2]*=cell_size
  npc.p2=v_add(npc.p, npc.p2)
  
  npc.s=v_sub(npc.p2,v_add(cam.p,perspective_offset))
  npc.s=v_mul(npc.s,npc.height*height_mult)
  npc.s=v_add(npc.p2,npc.s)
  
  add_blob(npc.p2,npc.r)
  else
  npc.active=false
  end
 end
end

function u_ducklings()
 -- pick em up
 for d in all(ducklings) do
  if v_distm(d.p,p.p) < p.r then
   d.target=p.ducklings[#p.ducklings] or p
   add(p.ducklings,d)
   del(ducklings,d)
   ducklings.found+=1
   ducklings.found_timer=80
   
   if ducklings.found==7 then
    npcs[1].lines="duck duck!|you found\nthem all!|ha ha, it looks\nlike they're not\ndone exploring\nthough!|feel free to\nbabysit them\nfor now.|just be sure you\ndon't lose them!|thanks again\nduck duck!|"
    npcs[2].lines="duck duck!|you found\nthem all!|um...|would you mind\nlooking after\nthem for a bit?|it's just...\nthey're having\nso much fun!|you could take\nthem exploring!|you're great with\nkids, duck duck!|thank you\nso much!|"
    npcs[1].lastline="|thanks again\nduck duck!|"
    npcs[2].lastline="|thank you\nso much!|"
    npcs[3].lines="oh, you found\nthem all\nduck duck!|next time we\nplay hide and\nseek i'll try\nharder...|"
    npcs[3].lastline="|next time we\nplay hide and\nseek i'll try\nharder...|"
   elseif ducklings.found==1 then
    npcs[1].lines="you found one!|but where are\nthe others?|you've got to\nfind them\nduck duck!!|please find\nour babies!|"
    npcs[2].lines="you found one!|but where are\nthe others?|you've got to\nfind them\nduck duck!!|please find\nour babies!|"
    npcs[1].lastline="|please find\nour babies!|"
    npcs[2].lastline="|please find\nour babies!|"
   else
    npcs[1].lines="duck duck!|you found "..#p.ducklings.."\nducklings, but\nthere's still "..(7-#p.ducklings).."\nleft out there!|please find them!|"
    npcs[2].lines="duck duck!|you found "..#p.ducklings.."\nducklings, but\nthere's still "..(7-#p.ducklings).."\nleft out there!|please find them!|"
    npcs[1].lastline="|please find them!|"
    npcs[2].lastline="|please find them!|"
   end
   
   sfx(8,2)
  end
 end
 
 ducklings.found_timer=max(0,ducklings.found_timer-1)
 
 
 
 -- follow the leader
 for d in all(p.ducklings) do
  local v=min(1,v_distm(d.p,d.target.p)/(p.r*2))*0.4
  d.p=v_lerp(d.p,d.target.p,v*v)
  d.a=-atan2(d.target.p[2]-d.p[2],d.target.p[1]-d.p[1])-0.25
 end
end

function u_dialog()
 local prev=talk.npc
 -- find closest npc in range
 talk.r=10000
 for npc in all(npcs) do
  if npc.active then
   local r=v_dist(npc.p2,p.p)
   if r<talk.r and r < (npc.r+p.r)*2.5 then
    talk.npc=npc
    talk.r=r
   end
  end
 end
 
 -- if it's a new npc
 -- get their lines
 if prev!=talk.npc then
  if #talk.npc.lines > 0 then
   talk.say="|"..talk.npc.lines
  else
   talk.say=talk.npc.lastline
  end
  talk.said=""
 end
 
 -- transition view
 if talk.r==10000 then
  talk.offset=lerp(talk.offset,-talk.offset_target,0.25)
  if abs(talk.offset-(-talk.offset_target)) < 1 then
   talk.offset=-talk.offset_target
   talk.npc=nil
   talk.say=""
   talk.said=""
  end
 else
  if abs(talk.offset) < 1 then
   talk.offset=0
  else
   talk.offset=lerp(talk.offset,0,0.25) 
  end
 end
 
 
 local s=sub(talk.say,1,1)
 local skip=btnp"4" or btnp"5"
 
 --skip only applied mid-line
 if s=="|" then
  skip = false
 else
 end
 -- handle text
 if talk.npc!=nil then
  if #talk.say <= 1 then
   talk.say=talk.npc.lastline
  end
  repeat
   s=sub(talk.say,1,1)
   if s!="|" and s!="" then
    
    if stat"17" != talk.npc.sfx then
     sfx(talk.npc.sfx,1)
     talk.bounce=10
    end
    
    -- add letter
    talk.said=talk.said..s
    talk.say=sub(talk.say,2,#talk.say)
   elseif talk.offset==0 and not skip and (btnp"4" or btnp"5") then
    -- go to next line
    talk.said=""
    
    -- remove npc's old line
    while #talk.npc.lines > 0 and sub(talk.npc.lines,1,1) != "|" do
     talk.npc.lines=sub(talk.npc.lines,2,#talk.npc.lines)
    end
    talk.npc.lines=sub(talk.npc.lines,2,#talk.npc.lines)
    
    talk.say=sub(talk.say,2,#talk.say)
   else
    -- reached end of line
    skip=false
   end
  until not skip
 end
 talk.bounce=max(0,talk.bounce-1)
end

function _draw()
 d_bg()
 
 camera(cam.p[1],cam.p[2])
 
 d_footprints()
 
 d_bushes"1"
 d_ducklings"1"
 d_npcs"1"
 d_player"1"
 d_trees"1"
 d_buildings"1"
 d_clouds"1" 
 
 d_bushes()
 d_ducklings()
 d_npcs()
 d_player()
 d_trees()
 d_buildings()
 d_clouds()
 
 if ducklings.found_timer > 0 then
  d_found()
 end
 
 if menu!=nil then
  d_menu()
 elseif talk.offset > -talk.offset_target then
  camera(0,talk.offset)
  d_duckface()
  d_npcface()
  d_dialog()
 end
end

function d_bg()
 camera(cam.p[1],cam.p[2])
 
 for a=0,cell_fill do
 for b=0,cell_fill do
 
 x=(cells.current[1]+a)*cell_size
 y=(cells.current[2]+b)*cell_size
 
 local cell=cells.a[a][b]
 
 rectfill(x,y,x+cell_size,y+cell_size,cell.c)
 
 if cell.biome.transition then
 srand(cell.seed)
 
 local c=cell.edges[1][0]
 if c!=cell.c then
  pal(0,c)
  for v=0,cell_size/8 do
   spr(4+flr(rnd"4")*16,x+cell_size-8, y+v*8)
  end
 end
 c=cell.edges[-1][0]
 if c!=cell.c then
  pal(0,c)
  for v=0,cell_size/8 do
   spr(3+flr(rnd"4")*16,x, y+v*8)
  end
 end
 c=cell.edges[0][-1]
 if c!=cell.c then
  pal(0,c)
  for u=0,cell_size/8 do
   spr(2+flr(rnd"4")*16,x+u*8, y)
  end
 end
 c=cell.edges[0][1]
 if c!=cell.c then
  pal(0,c)
  for u=0,cell_size/8 do
   spr(1+flr(rnd"4")*16,x+u*8, y+cell_size-8)
  end
 end
 
 end
 end
 
 pal(0,0)
 end
 
end

function d_footprints()
 color"5"
 for f=2,#footprints,2 do
  local f1=footprints[f-1]
  local f2=footprints[f]
  
  line(f1[1],f1[2],f1[3],f1[4])
  line(f2[1],f2[2],f2[3],f2[4])
  
  circfill(f1[1],f1[2],1)
  circfill(f2[1],f2[2],1)
 end
end

function d_ducklings(shadow)
 camera(cam.p[1],cam.p[2])
 
 if shadow then
  color"5"
  for d in all(ducklings) do
   circfill(d.p[1]+shadow_offset[1]*ducklings.height,d.p[2]+shadow_offset[1]*ducklings.height,ducklings.r+1)
  end
  for d in all(p.ducklings) do
   circfill(d.p[1]+shadow_offset[1]*ducklings.height,d.p[2]+shadow_offset[1]*ducklings.height,ducklings.r+1)
  end
 else
  for d in all(ducklings) do
   circfill(d.p[1],d.p[2],ducklings.r,9)
   circfill(d.p[1]+1,d.p[2]+1,1,10)
  end
  for d in all(p.ducklings) do
   circfill(d.p[1],d.p[2],ducklings.r,9)
   circfill(d.p[1]+cos(d.a),d.p[2]+sin(d.a),1,10)
  end
 end
end

function d_player(shadow)
 camera(cam.p[1],cam.p[2])
 
 if shadow then
  local c
  if p.cell and p.cell.biome.foot_sfx==1 then
   if time()*2%1 > 0.5 then
   spr(46,
   p.p[1]+shadow_offset[1]*p.height-8,
   p.p[2]+shadow_offset[2]*p.height-8,
   2,2)
   end
  end
  circfill(
  p.p[1]+shadow_offset[1]*p.height,
  p.p[2]+shadow_offset[2]*p.height,
  p.r,5)
 else
  local s=p.cur_speed/p.max_speed*p.r/5+0.5
  local p1={p.p[1],p.p[2]}
  local p2={
   p1[1]+p.height*cos(p.a)*s,
   p1[2]+p.height*sin(p.a)*s
  }
  
  circfill(p1[1],p1[2],p.r*3/4,p.c[1])
  circfill(p2[1],p2[2],p.r/2,p.c[2])
  p2=v_lerp(p1,p2,0.75)
  circfill(p2[1],p2[2],p.r/2,p.c[3])
  p2=v_lerp(p1,p2,0.5)
  pset(p2[1],p2[2],0)
  end
end

function d_trees(shadows)
 for a=0,cell_fill do
 for b=0,cell_fill do
 
 local trees=cells.a[a][b].trees
 camera(
  cam.c[1]-a*cell_size,
  cam.c[2]-b*cell_size
 )
 
 if shadows then
 -- shadows
 color"5"
 for t in all(trees) do
  circfill(
  t.p[1]+shadow_offset[1]*t.height/2,
  t.p[2]+shadow_offset[2]*t.height/2,
  t.girth)
 end
 else
 -- trunks
 color"4"
 for t in all(trees) do
  for x=-1,1 do
  for y=-1,1 do
  if abs(x)+abs(y)!=2 then
   line(t.p[1]+x,t.p[2]+y,t.s[1],t.s[2])
  end
  end
  end
 end
 -- leaves
 c={{3,1},{11,0.7},{7,0.4}}
 for i=1,3 do
 color(c[i][1])
 for t in all(trees) do
  circfill(t.leaves[i][1],t.leaves[i][2],t.girth*c[i][2])
 end
 end
 
 end
 
 end
 end
end

function d_buildings(shadows) 
 for x=0,cell_fill do
 for y=0,cell_fill do
 
 local b=cells.a[x][y].building
 
 if b then
 
 camera(
  cam.c[1]-x*cell_size,
  cam.c[2]-y*cell_size
 )
 
 if shadows then
 color"5"
 for i=0,b.height/2,4 do
  local t={b.s[1],b.s[2]}
  t=v_mul(t,i*height_mult)
  t=v_add(b.p,t)
  rectfill(t[1]-b.size[1],t[2]-b.size[2],t[1]+b.size[1],t[2]+b.size[2])
 end
 else
  color"5"
  for i=b.height/2,b.height-1,4 do
   local t={b.s[1],b.s[2]}
   t=v_mul(t,i*height_mult)
   t=v_add(b.p,t)
   rectfill(t[1]-b.size[1],t[2]-b.size[2],t[1]+b.size[1],t[2]+b.size[2])
  end
 
  local s=v_mul(b.s,b.height*height_mult)
  s=v_add(b.p,s)
  rectfill(s[1]-b.size[1],s[2]-b.size[2],s[1]+b.size[1],s[2]+b.size[2],b.c)
 end
 end
 
 end
 end
end

function d_clouds(shadows)
 camera""
 if shadows then
  color"5"
  for c in all(clouds) do
   circfill(c.ps[1],c.ps[2],c.r)
  end
 else
  color"7"
  for c in all(clouds) do
   circfill(c.s[1],c.s[2],c.r)
  end
 end
end
 
function d_bushes(shadows)
 for a=0,cell_fill do
 for b=0,cell_fill do
 
 local bushes=cells.a[a][b].bushes
 camera(
  cam.c[1]-a*cell_size,
  cam.c[2]-b*cell_size
 )
 
 if shadows then
  color"5"
  for b in all(bushes) do
   circfill(
   b.p[1]+shadow_offset[1]*b.height,
   b.p[2]+shadow_offset[2]*b.height,
   b.r)
  end
 else
  color"3"
  for b in all(bushes) do
   circfill(b.s[1],b.s[2],b.r)
  end
  for b in all(bushes) do
   if b.bloom!=nil then
    local p=v_add(b.s,b.bloom.p)
    pset(p[1],p[2],b.c)
   end
  end
 end
 
 end
 end
end

function d_npcs(shadows)
 camera(cam.p[1],cam.p[2])
 
 if shadows then
  for npc in all(npcs) do
   if npc.active then
    circfill(
     npc.p2[1]+shadow_offset[1]*npc.height,
     npc.p2[2]+shadow_offset[2]*npc.height,
     npc.r,5)
   end
  end
 else
  for npc in all(npcs) do
   if npc.active then
    local s=v_lerp(npc.s,npc.p2,0.75)
    circfill(s[1],s[2],npc.r,npc.c1)
    circfill(npc.s[1],npc.s[2],npc.r-1,npc.c2)
   end
  end
 end
end

function d_title()
 local t=time()
 local t2=t
 local c=2
 if menu != 0 then
  c=8
  t2*=16
 end
 for i=0,3 do
  pal(0,(i+t2)%c+c)
  sspr(40+8*i,16,8,11,12+12*i,10+sin(t+i/3)*1.2,16,22)
 end
 for i=0,3 do
  pal(0,(i+t2+4)%c+c)
  sspr(40+8*i,16,8,11,9+12*(i+4)+8,10+sin(t+(i+1)/3)*1.2,16,22)
 end
 local s=" on the"
 for i=1,#s do
  pal(0,(i+t2)%c+c)
  print_ol(sub(s,i,i),64+(i-1)*4-#s*2+2,35+sin(t/2+i/#s)+2.1,5,5)
  print_ol(sub(s,i,i),64+(i-1)*4-#s*2,35+sin(t/2+i/#s)+0.1,7,0)
 end
 
 for i=0,4 do
  pal(0,(i+t2)%c+c)
  sspr(72+8*i,16,8,11,9+12*(i+2),44+sin(t+(i+2)/3)*1.2,16,22)
 end
 pal(0,0)
end

function d_menu()
 camera(0,menu)
 d_title()
 
 local a=-abs(sin(time()/2))*3
 a=flr(a)
 
 sx=64
 if p.duck==4 then
  sx+=16
 end
 sspr(sx,0,16,16,0,128-32-a,32,32+a)
 sx=96
 
 if p.duck==5 then
  sx+=16
 end
 sspr(sx,0,16,16,128-32,128-32-a,32,32+a,true)

 if p.duck==4 then
  print_ol("🅾️",33,127-16,7,0)
 else
  print_ol("🅾️",33,127-16,0,7)
 end
 if p.duck==5 then
  print_ol("❎",97-8,127-16,7,0)
 else
  print_ol("❎",97-8,127-16,0,7)
 end
 print_ol("ˇ quack ˇ",43,127-16,0,7)
end

function d_duckface()
 local t=p.quack_timer
 local a=abs(sin(t/40))*5-abs(sin(time()/2))*3
 a=flr(a)
 sx=64
 if p.duck==5 then
  sx+=32
 end
 if t > 0 then
  sx+=16
 end
 sspr(sx,0,16,16,0,128-32-a,32,32+a)
end

function d_npcface()
 local a=abs(sin(talk.bounce/40))*5-abs(sin(time()/2))*3
 a=flr(a)sx=0
 sy=32
 local npc=talk.npc
 sx+=npc.spr*16
 while(sx >= 128) do
  sx-=128
  sy+=16
 end
 sspr(sx,sy,16,16,128-32,128-32-a,32,32+a)
 if npc.mouth >= 0 then
  local c=sub(talk.say,1,1)
  if c!="|" and c!="" and time()%0.2 > 0.1 then
   pal(0,npc.mouth)
   sspr(56,0,8,16,128-20,128-32-a+npc.mouth_offset,16,32+a)
   pal(0,0)
  end
 end
end

function d_dialog()
 local a=abs(sin(talk.bounce/40))*5-abs(sin(time()/2))*3
 a=flr(a)
 print_ol(talk.npc.who,127-#talk.npc.who*4-2,127-39-a,0,7)
 print_ol(talk.said,32,127-24,0,7)
end

function d_found()
 local c=ducklings.found_timer/160
 c=c*c*2
 c=-(-sin(c))*128+64
 camera(0,c)
 for i=0,3 do
  pal(0,(i+time()*16)%8+8)
  sspr(40+i*8,16,8,11, 20+i*16,10+sin(time()+i/3)*1.2, 16,22)
 end
 for i=0,5 do
  pal(0,(i+time()*16)%8+8)
  sspr(80+i*8,112,8,11, 20+i*16,30+sin(time()+i/3)*1.2, 16,22)
 end
 pal(0,0)
end

function print_ol(s,x,y,c1,c2)
 for u=x-1,x+1 do
 for v=y-1,y+1 do
  print(s,u,v,c1)
 end
 end
 print(s,x,y,c2)
end
__gfx__
eeeeeeeeeeeeeeee00e000ee0e0eeeeeeee0eee0eeeeeeeeeeeeeeeeeeeeeeeeeeeeee777777eeeeeeeeee777777eeeeeeeeee777777eeeeeeeeee777777eeee
eeeeeeeeee0eee0eeeeeeeee0e0e0eeee0eee0e0eeeeeeeeeeeeeeeeeeeeeeeeeeeee77333377eeeeeeee77333377eeeeeeee77444477eeeeeeee77444477eee
ee7ee7eeeeeeeeeee00e0e000eeeee0eeee0e0eeeeeeeeeeeeeeeeeeeeeeeeeeeeeee73333337eeeeeeee73333337eeeeeeee74444447eeeeeeee74444447eee
eee77eeee0e0e0e0eeeeeeee0e0e0eeeeeeeeee0eeeeee999999eeeeeeeeeeeeeeeee73333337eeeeeeee73333337eeeeeeee74444447eeeeeeee74444447eee
eee77eeeeeeeeeee0e0e0e0e0eeeeeeeeee0e0e0eeeee99888899eeeeeeeeeeeeeeee73303307eeeeeeee73303307eeeeeeee74404407eeeeeeee74404407eee
ee7ee7ee00e0e00eeeeeeeeeee0e0eeee0eeeee0eeeee98080889eeeeeeeeeeeeeeee73303307eeeeeeee73303307eeeeeeee74404407eeeeeeee74404407eee
eeeeeeeeeeeeeeeee0eee0eeee0eee0eeee0e0e0eeeee88080888eeeeeeeeeeeeeeee73303307eeeeeeee7330330777eeeeee74404407eeeeeeee7440440777e
eeeeeeee00000e00eeeeeeee0eee0eeeeeeee0e0eeeee88080888eeeeeeeeeeeeeeee73333aa777eeeeee73333aaaa7eeeeee74444aa777eeeeee74444aaaa7e
eeeeeeeeeeeeeeee00e000000eeeeeeeeeeeeee0eeeee888888888eeeeeeeeeeeeeee7333aaaaa7eeeeee7333aaa777eeeeee7444aaaaa7eeeeee7444aaa777e
eeeeeeeeeee0eeeeeeeeeeee0eee0eeeeeeee0e0eeeee888888888eee000eeeeeeeee7333333777eeeeee73330037eeeeeeee7444444777eeeeee74440047eee
eeeeeeeeeeeeeeeee0eee0ee0e0eeeeeeee0eeeeeeeee88000888eeee000eeee7777773333337eee777777333aa377ee7777774444447eee777777444aa477ee
eeeeeeeee0eee0eeeeeeeeee0eeeee0eeeeeeee0eeeee88888888eeeeeeeeeee7444773333337eee7444773333aaa7ee7666774444447eee7666774444aaa7ee
eeeeeeeeeeeeeeeeee0eee0e0eeeeeeee0eeeee0eeeeeee8888eeeeeeeeeeeee4444443333337eee44444433333377ee6666664444447eee66666644444477ee
eeeeeeeeee0eee0eeeeeeeeeeeee0eeeeeeee0e0eeeeeeaa88aaeeeeeeeeeeee44444443333477ee44444443333477ee66666664444677ee66666664444677ee
eeeeeeeeeeeeeeeeeeee0eee0e0eeeeeeee0eee0eeeeeeaaaaaaeeeeeeeeeeee44444444444447ee44444444444447ee66666666666667ee66666666666667ee
eeeeeeee00000e00eeeeeeee0eeeeeeeeeeeeee0eeeeeeaaaaaaeeeeeeeeeeee444444444444447e444444444444447e666666666666667e666666666666667e
eeeeeeeeeeeeeeee0ee0ee000eeeeeeeeeeee0e0777777ee7777777e7777777e7777777e7777eeeee77777eee77777eee777777e7777777eeeeeeeeeeeeeeeee
eeeeeeeeeeeeee0eeeeeeeeeee0eee0eeee0eee07000077e70077075770000757007707570075eee7700077e7700077e7700007570000075eeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeee0ee0ee0eeeeeeeeeeeeeeee7007707570077075700777757007707570075eee70077075700770757007777570077775eeeeeeeeeeeeeeee
eeeeeeeee0e0eeeeeeeeeeee0eeeeeeeeee0e0ee7007707570077075700755557007077570075eee70077075700770757007555570075555eeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeee0e0eee0e0eeeeeeeeee0700770757007707570075eee7000775570075eee7007707570077075700777ee700777eeeeeeeeeeeeeeeeee
eeeeeeee0ee0ee0eeeeeeeeeeeeeeeeeeeeeeeee700770757007707570075eee7007077e70075eee70077075700770757700077e7000075eeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeee0eeeeee0eee0eeee0eee0ee700770757007707570075eee7007707570075eee7007707570077075e77700757007775eeeeeeeeeeeeeeeee
eeeeeeee00ee0ee0eeeeeeee0e0eeeeeeeeeeee070077075700770757007777e700770757007777e7007707570077075777700757007777eeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeee00e00eeeeeee0eeee0eeee700007757700077577000075700770757000007577000775770007757000077570000075eeeeeeeeeeeeeeee
eeeeeeeeeeeeeee0eeeeeeeeeeeeeeeeeeeee0e077777755e7777755e77777757777777577777775e7777755e77777557777775577777775eeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeee0e0eeeeeeeeeeeeee0e555555eee55555eee555555e5555555e5555555ee55555eee55555ee555555ee5555555eeeeeeeeeeeeeeee
eeeeeeee0eee0eeeeeeeeeee0eee0eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeee0eee0eeeeeeeeeee0eee0eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeee0eeeeeeeeeeeeee0eeeeeeeeeeeeee0eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeee0eeeeeee0e0eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeee00e00eeeeeeeeeeeeee0eeee0eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeee777777eeeeeeeeee777777eeeeeeeeeeeeeeeeeeeeeeeeeeee777777eeeeeeeee77777777eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee777777777eee
eee77444477eeeeeeee77333377eeeeeeeeeeeeeeeeeeeeeeeeeee755557eeeeeeee7773333777eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee770000000777e
eee74444447eeeeeeee73333337eeeeeeeeeeeeeeeeeeeeeeeee7776666777eeeeee7333333337eeeeeeeeeeeeeeeeeeeeeee77777777eeeee77000000000077
eee74444447eeeeeeee73333337eeeeeeeeeeeee77777eeeeeee7555555557eee777755555555777eeeee77777777eeeeeee77aaaaaa777eee70000400000007
eee70440447eeeeeeee70330337eeeeeeeeeeee7799977eeeeee7724444227eee7333f66f66ff333eeee7744444477eeeeee7aafaaaaaa7eee70004444400007
eee70440447eeeeeeee70330337eeeeeeeeeeee7999997eeeeeee740404427eee7777ff0f0fff777eeee744ffff447eeeeee7af0faaaaa7eee70004040400007
eee70440447eeeeeeee70330337eeeeeeeeeeee7999997eeeeeee740404427eeeeee7ff0f0fff77eeeee74f0f0ff47eeeeee7af0f0fffa7eee70004040400007
e777aa44447eeeeee777aa33337eeeeeeeeeeee7090997eeeeeee740404427eeeeee7ff0f0ffff7eeeee7ff0f0fff7eeeeee7af0f0fffa77ee70004040440077
e7aaaaa4447eeeeee7aaaaa3337eeeeeeeeeeee7090997eeeeeee744444447eeeeee7fffffffff7eeeee7ff0f0fff77eeeee7ffffffffaa7ee7000444444047e
e7774444447eeeeee7773333337eeeeeeeeeee77aa9997eeeeeee744444447eeeeee7f66666ff77eeeee7fffffffff7eeeee7fffffffffa7ee7704444444047e
eee7444444777777eee7333333777777eeeeee7aaaa99777eeeee740004427eeeeee7760006f77eeeeee78ffff0f8f7eeeee7ff222ffffa7eee774400044407e
eee7444444776667eee7333333774447eeeeee7799999779eeeee744444477eeeeeee77ffff77eeeeeee7ff000fff77eeeee7ffffffffaa7eeee74444444407e
eee7444444666666eee7333333444444eeeeee7999999999eeeee77666677eeeeeee7739553377eeeeee77ffffff77eeeeee7aaffffaaaa7eeee77044440077e
ee77644446666666ee77433334444444eeeee77996699999eeeee75665557eeeeeee73339aa337eeeeee7777ff7777eeeeee7788ff88aa77eeeee766446677ee
ee76666666666666ee74444444444444eeeee79966669999eeeee75655557eeeeeee7f335933f7eeeeeee7ccffcc7eeeeee77f888888fa7eeeeee76666667eee
ee76666666666666ee74444444444444eeeee79666666999eeeee75555557eeeeeee7f335593f7eeeeeee7cccccc7eeeeee7ff888888ff7eeeeee72222227eee
eeee777eeeee777eeeeeeeeeeeeeeeeeeeeee77777777eeeeee777eeeeeeeeeeeeeee777777777eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeee7077eee7707eeeeeee777777eeeeeeee77dddddd77eeeee74777777777eeeeee77555555577eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeee74477777447eeeeee77ffff77eeeeeee7ddffffdd7eeeee744444444477eeeee75555555557eeee7777eee77777eeeeee77777777eeeeeeee77777777eee
eeee74444444467eeeee7744f44f77eeeeee7d11f11fd7eeeee774444444447eeeee7555ff55557eee77887777788877eeee77eeeeee77eeeeee778a8a8877ee
eeee77404044667eeeee7ff040fff7eeeee771cc1cc1177eeeee77ffffff447eeeee75ffffff557ee778228888828887eeee7eeeeeeee7eeeeee78a8a8a887ee
eeeee7404044677eeee77ff0f0fff77eeee71fccfccff17eeeeee744f44f447eeeee77f5f5ff557ee788288ffff82888eeee7ee7e7eee7eeeee88888888887ee
eeeee740404447eeeee7ffffffffff7eeee7dfffffffff7eeeeee744f44f447eeeeee7f0f0ff557ee78878f0f0ff8788eeee7ee7e7eee7eeeeee7ff0f0fff7ee
ee777744444447eeeee7affffffffa7eeee7dfffffffff7eeeeee7f0f0ff447eeeeee7f0f0fff57ee7877ff0f0fff778eeee7ee7e7eee77eeee77ff0f0fff77e
ee700666664447eeeee77ff000fff77eeee7dff000fffd7eeeeee7ffffff4f7eeeeee7fffffff77ee7777ff0f0fff777eeee7eeeeeeeee7eeee7ffffffffff7e
ee700666666447eeeeee77ff4fff77eeeee77ffffffff77eeeeee7ffff0fff7eeeeee7ffffff57eeeeee7fffffffff7eeeee7eeeeeeeee7eeee7ffffffffff7e
ee7766600064477eeeeee77ffff77eeeeeee777ffff777eeeeeee7f000fff47eeeeee7f000ff77eeeeee79ffff0f9f7eeeee7ee777eee77eeee7fff000fff77e
eee7776666644477eeee7749ff9477eeeeee77a8ff8a77eeeeeee7fffffff77eeeeee7ffffff7eeeeeee7ff000fff77eeeee7eeeeeeee7eeeee7fffffffff7ee
eeeee77466644447eeee7f499994f7eeeeee7f888888f7eeeeeee777ffff7777eeeee777ff777eeeeeee77ffffff77eeeeee777eeee777eeeee77ffffffff77e
eee7774466644447eeee7ffaf9fff7eeeee77faaaaaaf77eeeee7711fff11117eeeee77555577eeeeeee7777ff7777eeeeeee7eeeeee7eeeee77333ffff3337e
e777474666664444eeee7ffaf9fff7eeee77998888889977eeee71111f111f11eeeee7dddddd7eeeeeeee7aaffaa7eeeeeeee7eeeeee7eeeee7ff3333333ff7e
e744474666664444eeee7749999477eeee7cccccccccccc7eeee71111111ff11eeeee7dddddd7eeeeeeee7aaaaaa7eeeeeeee7eeeeee7eeeee7ff3333333ff7e
eeeee77777777eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee7777777777eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee7777777777ee
eeeee711111877eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee7000000007eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee7777ee77777eeeee70000000077e
eeee771c1c18877eeeeee777eee777eeeeeee777eee777eeeeee7000000007eeeeeeeeeeeeeeeeeeeeeee77777777eeeeee7700777700077eeee70000000007e
eeee71818181887eeeeee797777797eeeeeee707777707eeee77788888888777eeeee77777777eeeeeee7700000077eeeee7000000000007eeee70000000007e
eeee78888888187eeeeee799777997eeeeeee700777007eeee700afffffaa007eeee7700000077eeeeee700dddd007eeeee7000dddd00007eeee70ddddd0007e
eeee7ff0f0ff817eeeeee7999999a7eeeeeee700000067eeee777ff0f0ffa777eeee700dddd0077eeeee70dadadd07eeeee770dadadd0077eeee7ddadadd007e
eeee7ff0f0fff87eeeeee7999999a7eeeeeee700000067eeeeee7ff0f0fff7eeeeee70dadadd007eeeee7dddddddd7eeeeee7dddddddd77eeeee7ddddddd007e
ee777ff0f0ffff7eeeeee790909997eeeeeee709090007eeeeee7ff0f0fff77eeeee7dddddddd07eeeee7ddadaddd77eeeee7ddadadddd7eeeee7ddadadd0d7e
ee717ffffffff17eeeee7790909997eeeeee7709090007eeeeee7fffffffff7eeeee7ddadaddd07eeeee7ddddddddd7eeeee7ddddddddd7eeeee7ddddddddd7e
ee717fffff0ff17eeeee7009999997eeeeee7000000007eee7777fffff0fff7eeeee7ddddddddd7eeeee7ddddddddd7eeeee7dd000ddd07eeeee7dd000ddd07e
ee717ff000fff17eeeee7999999997eeeeee7000000007eee7ff7ff000fff77eeeee7ddddddddd7eeeee7dd000ddd77eeeee7dddddddd77eeeee7dddddddd77e
ee7174ffffff417eeeee79900099977eeeee70077700077ee7ff7ffffffff7eeeeee7dd000ddd07eeeee77dddddd77eeeeee777dddd777eeeeee777dddd777ee
e77174444444717ee777779999999977e777770000000077e700777ffff777eeeeee70dddddd007eeeeee77dddd77eeeeeeee700dd007eeeeeee7700dd0077ee
e788774444478877e799777999999997e700777000000007e7000000ff007eeeeeee777dddd7777eeeeee700dd007eeeeeee7700000077eeeeee7000000007ee
e788771441178817e7799799aaaa9999e770070000000000e700000088007eeeeeeee700dd007eeeeeeee70000007eeeeee770000000077eeeee7000000007ee
e771111111177117ee77979aaaaaa999ee77070000000000e777770066007eeeeeeee70000007eeeeeeee70000007eeeeee700000000007eeeee7000000007ee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee777777777eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
ee777777777777eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee77444444477eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee77777777eee
e77444444444477eeeeeee999999eeeeeeeeee999999eeeeeeeee77777777eeeeeee74444444447eeeeeee999999eeeeeeeeee999999eeeeeeee7755555577ee
e74444444444447eeeeee99888899eeeeeeee99888899eeeeeee7700000077eeeee7744ffff44477eeeee99888899eeeeeeee99888899eeeeeee7aaaaaaaa7ee
e74000040040047eeeeee98080889eeeeeeee98080889eeeeeee7044444007eeeee74444f44f4447eeeee98080889eeeeeeee98080889eeeeeee7accccc6a7ee
e74444444444447eeeeee88080888eeeeeeee88080888eeeeeee7440404407eeeee744f0f0ff4447eeeee88080888eeeeeeee88080888eeeeeee7ac7c7c6a7ee
e74000004000047eeeeee88080888eeeeeeee88080888eeeeeee7440404407eeeee744f0f0ff4447eeeee88080888eeeeeeee88080888eeeeeee7ac7c7c6a7ee
e74444444444447eeeeee888888888eeeeeee888888888eeeeee74404044077eeee744ffffff4f47eeeee888888888eeeeeee888888888eeeeee7accccc6a7ee
e74004000400047eeeeee888888888eeeeeee888888888eeeeee74444444447eeee744ffffff5f47eeeee888888888eeeeeee888888888eeeeee7a66666aa7ee
e74444444444447eeeeee88000888eeeeeeee88000888eeeeeee74444444447eeee744f000ff4447eeeee88000888eeeeeeee88000888eeeeeee7a65656aa7ee
e77777744777777eeeeee88888888eeeeeeee88888888eeeeeee74400044477eeee774ffffff9447eeeee88888888eeeeeeee88888888eeeeeee7766666a777e
eeeeee7447eeeeeeeeeeeee8888eeeeeeeeeeee8888eeeeeeeee7744444477eeeeee744ffff44447eeeeeee8888eeeeeeeeeeee8888eeeeeeeeee7755556667e
eeeeee7447eeeeeeeeeeeeaa88aaeeeeeeeeeeaa88aaeeeeeeeee77444477eeeeeee7422ff224477eeeeeeaa88aaeeeeeeeeeeaa88aaeeeeeeee776aaa6a667e
eeeeee7447eeeeeeeeeeeeaaaaaaeeeeeeeeeeaaaaaaeeeeeeeee73344337eeeeeee77222222477eeeeeeeaaaaaaeeeeeeeeeeaaaaaaeeeeeeee7a6aaa6aa67e
eeeeee7447eeeeeeeeeeeeaaaaaaeeeeeeeeeeaaaaaaeeeeeeeee73333337eeeeeeee7ff22ff77eeeeeeeeaaaaaaeeeeeeeeeeaaaaaaeeeeeeee7a6aaa6aa67e
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee77ddddd077eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee70dadad007eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeee77777777eeeeeeee77777777eeeeeeee77777777eeeeeeee77777777eeeeeee70ddddd007eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeee7744444477eeeeee7799999977eeeeee7744444477eeeeee7700000077eeeeee70dadad007eeeeeeee999999eeeeeeeeee999999eeeeeeeeee999999eeee
eeee7444444447eeeeee799ffff997eeeeee744ffff447eeeeee7004444007eeeeee70ddddd007eeeeeee99888899eeeeeeee99888899eeeeeeee99888899eee
eeee7400400447eeeeee79f0f0ff97eeeeee740fff0f47eeeeee7077477407eeeeee70dadadd07eeeeeee98080889eeeeeeee98080889eeeeeeee98080889eee
eeee7400400447eeeeee7ff0f0fff7eeeeee7ff0f0fff7eeeeee7477477447eeeeee7dddddddd7eeeeeee88080888eeeeeeee88080888eeeeeeee88080888eee
eeee74404044477eeeee7ff0f0fff77eeeee7f0fff0ff77eeeee74c74c74477eeeee7ddadaddd77eeeeee88080888eeeeeeee88080888eeeeeeee88080888eee
eeee74444444447eeeee7fffffffff7eeeee7fffffffff7eeeee74444444447eeeee7ddddddddd7eeeeee888888888eeeeeee888888888eeeeeee888888888ee
eeee74444444447eeeee7fffffffff7eeeee7fffffffff7eeeee74400444447eeeee7ddddddddd7eeeeee888888888eeeeeee888888888eeeeeee888888888ee
eeee74400044477eeeee7ff000fff77eeeee7ff000fff77eeeee74400444477eeeee7dd000ddd77eeeeee88000888eeeeeeee88000888eeeeeeee88000888eee
eeee7444444447eeeeee7ffffffff7eeeeee7fffeefff7eeeeee7444444447eeeeee7dddddddd7eeeeeee88888888eeeeeeee88888888eeeeeeee88888888eee
eeee7774444777eeeeee777ffff777eeeeee777ffff777eeeeee7774444777eeeeee777dddd777eeeeeeeee8888eeeeeeeeeeee8888eeeeeeeeeeee8888eeeee
eeeee79944997eeeeeeee7bbffbb7eeeeeeee7aaffaa7eeeeeeee70044007eeeeeeee700dd007eeeeeeeeeaa88aaeeeeeeeeeeaa88aaeeeeeeeeeeaa88aaeeee
eeeee79999997eeeeeeee7bbbbbb7eeeeeeee7aaaaaa7eeeeeeee70000007eeeeeeee70000007eeeeeeeeeaaaaaaeeeeeeeeeeaaaaaaeeeeeeeeeeaaaaaaeeee
eeeee79999997eeeeeeee7bbbbbb7eeeeeeee7aaaaaa7eeeeeeee70000007eeeeeeee70000007eeeeeeeeeaaaaaaeeeeeeeeeeaaaaaaeeeeeeeeeeaaaaaaeeee
eeeeeeeeeeeeeeeeeeeeee77777eeeeeeeeeeeeeeeeeeeeeeeeeeeeeee777eeeeeeeeeeeeeeeeeee7777777ee77777ee7777777e7777777e777777ee77777eee
eeeeeeeeeeeeeeeeeeeee77979777eeeeeeee77777777eeeeeeeeeeeee767eeeeeeeeeeeeeeeeeee700000757700077e70077075700770757000077e700075ee
eeeee77777777eeeeeee77a9a9a977eeeeee77f0ffff77eeeeeee77777757eeeeeeeeeeeeeeeeeee7007777570077075700770757007707570077075700075ee
eeee77ffffff77eeeeee79a444a9a7eeeeee7fff0ffff7eeeeee7766666677eeeeeeeeeeeeeeeeee7007555570077075700770757000707570077075700075ee
eeee7ffffffff7eeeeee7444444447eeeeee7ffff000f7eeeeee7666666667eeeeeeeeee7777eeee700777ee70077075700770757000707570077075770775ee
eeee7888888887eeeeee7440404447eeeeee7ff0f000f77eeeee7663636667eeeeeeeee77ff77eee7000075e70077075700770757000007570077075777775ee
eeee7ff0f0fff7eeeeee7440404447eeeeee7ffff000ff7eeeee766a6a6667eeeeeeeee7ffff7eee7007775e70077075700770757007007570077075700075ee
eeee7ff0f0fff77eeeee74404044477eeeee7fffffff0f7eeeee7663636667eeeeeeee77fefe77ee7007555e70077075700770757007707570077075700075ee
eeee7fffffffff7eeeee74444444447eeeee7ff000fff77eeeee7666666667eeeeeeee7ffffff7ee70075eee77000775770007757007707570000775700075ee
eeee7fffffffff7eeeee74444404447eeeee7fffff0ff7eeeeee7666666667eeeeeee77ffffff77e77775eeee7777755e77777557777777577777755777775ee
eeee7ff000fff77eeeee74400044477eeeee77ffffff77eeeeee7777777777eeeeeee7afffafff7ee5555eeeee55555eee55555ee5555555e555555ee55555ee
eeee7ffffffff7eeeeee7444444447eeeeeee777ff777eeeeeeee76666667eeeeeeee7aafaaafa7eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeee777ffff777eeeeee7774444777eeeeeee78888887eeeeeeee76666667eeeeeeee7afffafff7eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeee788ff887eeeeeee778f44f877eeeeee7766666677eeeeeee77555577eeeeeeee7ffffffff7eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeee78888887eeeeeee748ffff847eeeeee7ff8888ff7eeeeeeee755557eeeeeeeee77cfcfcf77eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeee78866887eeeeeee748f88f847eeeeee7fff66fff7eeeeeeee755557eeeeeeeeee7ffffff7eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
__label__
ccccccccccccccccccccccccccccccccccc444c44444444444444444444444444444444444444444444444444444444c4ccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccc4c444c4444444c44c444c44444444c44cc4c4cc4c44c44c4c444c444cccc4cccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccc44444c44444444444444444444444444444444444444444444444444444444ccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccc44c444c444c444c44c444c4444c444cc4c4c4c44444c4c444c444c4ccc4c4cccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccc4444c44444444444444444444444444444444444444444444444444444444c4ccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccc4c44444c44444444444c444c44444444c444c444c4444444444c4444c4c4c4ccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccc44444444444444444444444444444444444444444444444444444444444444ccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccc444444c4444444444444444444444444444444444444444444444444444c4444cccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccc4444444444444444444444444444444444444444444444444444444444444c4ccccccccccccccccccccccccccccccc
cccccccccccc7777777777777777777777777744444444447777777777777744477777777777744444444444477777777777777777777777777ccccccccccccc
cccccccccccc77777777777777777777777777c4444444447777777777777744477777777777744444444444477777777777777777777777777ccccccccccccc
cccccccccccc773333333377772222777722777777777777772222777722775547733333333777777777777777777333333337722227777227755ccccccccccc
cccccccccccc773333333377772222777722777777777777772222777722775547733333333777777777777777777333333337722227777227755ccccccccccc
cccccccccccc773333777733772222777722777733333333772222777722775547733337777337722227777227733337777777722227777227755ccccccccccc
cccccccccccc773333777733772222777722777733333333772222777722775547733337777337722227777227733337777777722227777227755ccccccccccc
cccccccccccc773333777733772222777722773333777777772222772277775547733337777337722227777227733337755557722227722777755ccccccccccc
cccccccccccc773333777733772222777722773333777777772222772277775547733337777337722227777227733337755557722227722777755ccccccccccc
cccccccccccc773333777733772222777722773333775555772222227777555547733337777337722227777227733337755cc7722222277775555ccccccccccc
cccccccccccc773333777733772222777722773333775555772222227777555547733337777337722227777227733337755cc7722222277775555ccccccccccc
cccccccccccc773333777733772222777722773333775544772222772277774447733337777337722227777227733337755cc77222277227777ccccccccccccc
cccccccccccc773333777733772222777722773333775544772222772277774447733337777337722227777227733337755cc77222277227777ccccccccccccc
cccccccccccc773333777733772222777722773333775544772222777722775547733337777337722227777227733337755cc7722227777227755ccccccccccc
cccccccccccc773333777733772222777722773333775544772222777722775547733337777337722227777227733337755cc7722227777227755ccccccccccc
cccccccccccc773333777733772222777722773333775544772222777722775547733337777337722227777227733337777777722227777227755ccccccccccc
cccccccccccc773333777733772222777722773333775544772222777722775547733337777337722227777227733337777777722227777227755ccccccccccc
cccccccccccc773333333377777722222277773333777777772222777722775547733333333777722227777227777333333337722227777227755ccccccccccc
cccccccccccc773333333377777722222277773333777777772222777722775547733333333777722227777227777333333337722227777227755ccccccccccc
cccccccccccc777777777777557777777777777733333333777777777777775547777777777777777222222777777777777777777777777777755ccccccccccc
cccccccccccc777777777777557777777777777733333333777777777777775547777777777777777222222777777777777777777777777777755ccccccccccc
cccccccccccccc555555555555cc55555555557777777777775555555555555544455555555555577777777775555555555555555555555555555ccccccccccc
cccccccccccccc555555555555cc55555555557777777777775555555555555544b55555555555577777777775555555555555555555555555555ccccccccccc
cc44cc4cc4cc4cccccc44c44ccc44c44cc4444445555555555554444444444444b4b44b44b44b444b5555555555b44b44bccbcccccccbcccbbccbcccccccbccc
cc4444444444444444444444444444444444444455555555555544444444444b4b4bbb4bbbbbbbbbb5555555555bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbcbbbc
ccc44444c44c444c444c44c44c4c44c44c444444444444444444444444444b444777777777b44b4b44b44b4b44bbbbbb4bbcbbbcbbbccbcbccbcbbbcbbbccccc
ccc444c44444444444444444444444444444444444444444444444444777744447222737377777bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
cc444c444c44c444c44444c4c44444c4c4444444444444444444447777227744477277373722274b4b4b4b4b4bbbb4bbb4bbcbbbcbcbcbcbcbbbcbbbcbcbcccc
ccc444444444444444444444444444444444444444444444444447733727275b4b72773337277755bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbcbbbb
ccc4c444444444c4444c4444444c4444444444444444444444444737372727554b72773737227555bbb4bbb4bb4bbbbbbbbbbbcbbbbcbbbcbbbbbbcbbbbcbcbc
cc4444c4444444444444444444444444444444444444444444444737372727554b72773737277755bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbc
cc444444c4444444444444444444444444444444444444444444473737272755447777777722275bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
cc444444444444444444444444444444444444444444444444444733777777554b4b555557777755bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbc
ccc44444444444444444444444444444444444444444444444444777755555554b4b555555555555bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbcbb
ccc444c444444444444444444444444444444444444444444444444555555555444bbbbb4bb55555bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
cc4444444444444444444444444444444444444444444447777777777557777777777bbbbbbbbbbbb77777777777777bbbbbbbbbbbbbbbbbbbbbbbbbbbbcbbbb
ccc444444444444444444444444444444444444444444447777777777447777777777b4bbbbbbbbbb77777777777777bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbc
ccc4c44444444444444444444444444447777777744447777222222777777333333777777777777777733333333337755bbbbbbbbbbbbbbbbbbbbbbbbbbbbcbb
cc4444c444444444444444444444444447777777744447777222222777777333333777777777777777733333333337755bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
ccc4444444444444444444444444444447733337755447722227777227733337777337777222222227733337777777755bbbbbbbbbbbbbbbbbbbbbbbbbbbbcbb
cc44c444c4444444444444444444444447733337755447722227777227733337777337777222222227733337777777755bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbc
cc44444444444444444444444444444447733337755447722227777227733337777337722227777777733337755555555bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
ccc4444444444444444444444444444447733337755447722227777227733337777337722227777777733337755555555bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
cc44c4c44444444444444444444444444773333775544772222777722773333777733772222775555773333777777bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbcbb
cc4444444444444444444444444444444773333775544772222777722773333777733772222775555773333777777bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
ccc444c4444444444444444444444444477333377554477222277772277333377773377222277777777333333337755bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
ccc4c444444444444444444444444444477333377554477222277772277333377773377222277777777333333337755bbbbbbbbbbbbbbbbbbbbbbbbbbbbcbbbb
ccc4c444444444444444444444444444477333377554477222277772277333377773377772222227777333377777755bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
ccc434c4344443444444344434443444377333377554377222277772277333377773377772222227777333377777755bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbc
ccc44444c44444444444444444444444477333377554477222277772277333377773377777777222277333377777777bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbcbb
ccc3c3c3434344434443434343434343477333377553477222277772277333377773377777777222277333377777777bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
ccc4444444444444444444444444444447733337777777777222222777777333333777777777722227733333333337755bbbbbbbbbbbbbbbbbbbbbbbbbbcbbbb
cc33c3c334443444343343433433434337733337777777777222222777777333333777777777722227733333333337755bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbc
cc44c444c4444444444444444444444447733333333337777777777775577777777777722222222777777777777777755bbbbbbbbbbbbbbbbbbbbbbbbbbbbcbb
cc33333433333334333333343333333437733333333337777777777775577777777777722222222777777777777777755bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
cc44344444443444334334334444344437777777777777755555555555534555555557777777777775555555555555555bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
3333333333333333333333333333333337777777777777755555555555533555555557777777777775555555555555555bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
3c343334333443434434334334344343443555555555555553343334333333334b3bbbb555555555555bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
3333333333333333333333333333333333355555555555555333333333333333333bbb3555555555555bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
c33333333343434343333343434343434333433343333333333343334333343334bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
33333aa3333333333333333333333333333333333333333333333333333333333b3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
3333333333343334333433333334333433333343333333333333335333433333333b3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb53bbbbbb
33333333333333333333333333333333333333333333333333333335533b333333bbbb3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb5383bbbbb
3333333333333333333333333333333333333333333bbbbb333333335553333b3bbbbbbb3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb5358bbbb
33333333333333333333333333333333333333333bbbbbbbbb33333335553b333bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb5333bbb
3333333333333333333333333333333333333333bbbbbbbbbbb3333335555333333bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb53bbbb
333333333333333333333333333333333333333bb77777bbbbbb33333355553b333bbb3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
33333333333333333333333333333333333333bb7777777bbbbbb333335555333bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
33333333333333333333333333333333333333b777777777bbbbb33333355553333bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
3333333333333333333333333333333333333b77777777777bbbbb333335555b333b3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
3333333333333333333333333333333333333b77777777777bbbbb33333555553bbbbb3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
3333333333333333333333333333333333333b77777777777bbbbb33333555553b3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
3333333333333333333333333333333333333b77777777777bbbbb33333555553bbb3bbb3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
3333333333333333333333333333333333333b77777777777bbbbb333335555533bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
33333333333333333333333333333333333333b777777777bbbbb333333555553b3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
33333333333333333333333333333333333333bb7777777bbbbbb333335555553bbb3b3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
333333333333333333333333333333333333333bb77777bbbbbb3333335555553bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
3333333333333333333333333333333333333333bbbbbbbbbbb333333555555b3b3bbb3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
33333333333333333333333333333333333333333bbbbbbbbb3333333555555b3b3b3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
3333333333333333333333333333333333333333333bbbbb33333333555555333b3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
33333333b333b333b333b333b33333333b33333333333333333333355555553b3bbb3bbb3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
3333333333333333333333333333333333333333333333333333335555555b3b33bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
333b3b33333b3b3b3b3b3b3b3bb333b3333b3b3333333333333355555555333b3b3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
3333333333333333333333333333333333333333333333333355555555533b3b3bbb3b3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
33b33b33b3bb3b3bb3bb3b3bb33b333333b33b33b33b335555555555533bb333bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
3333333333333333333333333333333333333333333333335555555333333b3b3b3bbb3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
33bb33b33bbbbbb3bbbbbbb3bb3bb3bb33bb33b33b3bb3bb33bbbbb3bbbbbbbbbb3b3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
333bb3bb333bb3bb3333b3333333b333bbbb33b33bbb33b33b33b333bbbb33b33bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
3b3bbb3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbc
3b333b3bb3b3777777777777bbb33b3b33bbbbbb3bbbbbbb3bb33b3b33bbbbb3335bbbbbbbb3bbbbbbbbbbbbbbbbbbbbbbbbbbbb777777777777bbbbbbbbbcbb
333bbbbb3bbb777777777777bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb333a35bbbbbbc33bbbbbbbbbbbbbbbbbbbbbbbbbbb777777777777bbbbbbbbbbbb
3b3bbb3b3b77773333333377773b3b3b3bbbb3bbb3bbb3bbb33b3b3b3bbbb3333333bbbbbbbc33bbbbbbbbbbbbbbbbbbbbbbbb7777444444447777bbbbbcbbbb
3bbbbb3bbb7777333333337777bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb333333bbbbbbb33cbbbbbbbbbbbbbbbbbbbbbbbb7777444444447777bbbbbbbbbc
33333bbbbb7733333333333377b3bbb3bb3bbbbbbb3bbbbbbbb3bbb3bb3bbbb33a33bbbbbbbb3bbbbbbbbbbbbbbbbbbbbbbbbb7744444444444477bbbbbbbcbb
333bbbbbbb7733333333333377bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb333bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb7744444444444477bbbbbbbbbb
3b3b3bbbbb7733333333333377bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb7744444444444477bbbbbbbcbb
3b3b3b3bbb7733333333333377bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb7744444444444477bbbbbcbbbc
333bbbbb3b7733330033330077bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb7700444400444477bbbbbbbcbc
333b3b3bbb7733330033330077bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb7700444400444477bbbbbbbbbb
3b3bbbbbbb7733330033330077bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb7700444400444477bbbbbbbcbc
33bb3b3bbb7733330033330077bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb7700444400444477bbbbbcbbbb
33bb3bbb3b7733330033330077bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb7700444400444477bbbbbbbcbc
3b3bbb3bbb7733330033330077bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb7700444400444477bbbbbbbbbc
3b3bbbbbbb7733333333aaaa777777bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb777777aaaa4444444477bbbbbbbbbc
3b3bbb3bbb7733333333aaaa777777bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb777777aaaa4444444477bbbbbbbcbb
333b3bbbbb77333333aaaaaaaaaa77bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb77aaaaaaaaaa44444477bbbbbbbbbb
333bbbbb3b77333333333333777777bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb77777744444444444477bbbbbbbcbc
3b3bbbbbbb77333333333333777777bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb77777744444444444477bbbbbbbbbb
77777777777733333333333377bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb77444444444444777777777777
77777777777733333333333377bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb77444444444444777777777777
77444444777733333333333377bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb77444444444444777766666677
77444444777733333333333377bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb77444444444444777766666677
44444444444433333333333377bbbbbb3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbc77444444444444666666666666
44444444444433333333333377bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb77444444444444666666666666
4444444444444433333333447777b3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbc7777664444444466666666666666
4444444444444433333333447777bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb7777664444444466666666666666
4444444444444444444444444477b3bb3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb7766666666666666666666666666
4444444444444444444444444477bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb7766666666666666666666666666
4444444444444444444444444444773bb3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb776666666666666666666666666666
444444444444444444444444444477bbbb3b3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbc776666666666666666666666666666

__map__
f1f1f1f1f1f1f1f1f1e1fc3ca1fcfc8c51fcfc4cd14c31fcfcfc4c24fcfc8f4b4c3b435ca1dc212c415c2ffc2c44234c23344c1e231e6334ac3b3f3a3f2b1f2b1c3b232b333c91bc512c513c14ff3f647344931e23545f6b1f9a1f4b1c434b332c819c912c412c14ff6f547354331e43645f6b1f5a165a1f2b2c434b431c719c
b13c113cff8f6443746354532f5b2f2a769aa31c619cc16cffaff4547c1334236b2f2a162a16ba242c731c518cb14c11ecff1ff434bc24135b3f2af616143c631c516c71fcfc8c5fe4ec14135b3f4a163a168a243c1e531c415c81fcfcec2f84bc245c14135b3f2a769a133c14531c413c81bc1f7bfcfcfc2c242b4c236b2f6a
164a1f1c2314431c731c313c81ac1f3b9f3a4f141f44fc7c142f5c231e3b4c137b234a3f2a1b2ce32c312c818c5bfafa1a2f1b9f244f4c14134b5c2f5b131f239f1cb31e231f2c312c715c8bda16fa2a2f2bff3c24232b5c4f6b239f1ce31f2c213c614c2f8b2af6e62f1b33df4c14237c1b4f4b132b138f1c4314431e431f2c
213c614c3f1b1f5b2a16aa164a165a166a2f537f53144c138c2b434b1f2b7f2c1fc32f2c214c613c3f7b2a16aa164a165a167a735f6324bc1b331b237b7f1c2f2b832b1f3c217c314c3f5b3a164a1e1b4a164a162a1f2a162a2f3b431e532f331e33248c2b233b237b7f1c3f1b733b1f3c317c214c4f4b2a462a1b1c2a364a16
2a1f2a162a2f2b431b83246344134f1b234b336b6f2c3f2b534b1f2c418c213c8f3a164a1e1b4a164a162a1f1a3f1a1f2b432b73441b934f235b334b1f1b6f1c5f3b233b3f2c41ec4f1b3f2a16fa162a6f2b334b53447b9f135b1e336b6f1c6f8b2f2c415c1b3c114c2b6f2a16fa162a5f9b73247b9f1b233b1e436b5f2c6f6b
4f2c315c3b7c4b4f2a166a564a162a3fab431e532b1f3b8f4b837b5f1cff2f3c212c3b232b3c112c5b5a163a162a163a164a162a2f3b434ba32b2f1b9f5b738b3f2cff3f2c211c3b431b6c3b142f4a163a162a163a164a162a1f5b334b933b1f1bcf2b1ffb3f1cff4f2c211c1b632b5c4b2f962a163a164a162a8b235b635bcf
eb332b2f2cdf2b3f132c211c1b231e332b5c4b2f4a163a162aa62a8b231e6b138bcf1b1fbb432b2f1cdf4b332c211c1b632b1f5c4b5a163a16ba162a13fb7bef5b1f7b532b1f2cdf3b531c211c2b432b2f5c6b1f2a163a16ba162a33fb6bdf3b4f5b632b1f1cef2b631c211c137b3f4c3b1f2b1f2a16faea8b2f1bff7f4b732b
2cff731c211c5b1e3b3f3c3b1f2b1f2a16fada2f8bef3b3f2b1f5b732b1cff831c211c2b136b4f3c4b2f2ad65ab63f5bff1f3b2fab231e331b2c23cf931c211c9b4f4c3b2f6a166a16ca164a2f4bff3f2b6f7b433b1c43bf831e1c211c2b332b6f4c2b4f5a166a164a167a165a4bffffab2c43af332b531c211c1b439f4c1b7f
1a3f1a2f2a164a162a3f2a162a1f5bffff4f7b1c539f1b232b431e131c211c1b131e338f5cef1a3f3a162a1b2f2a162a1f5bffff5f5b2c538f1b332b631c211c1b131e338f1b6c14ff132a162a3b2a16caff7f535f431c331e139f1b332b531e1c211c1f437f232b6c14af1b432a162a3b2a16baff7fe32c538fa31e231c211c
2f238f232b7caf2b231b2a162a3b2ac6ff5ff32c331e336f1bc31e1c212caf432b8c5f8b2a162a3b2a16baff4ff32c1f636f431b831e131c212caf532b9c249b2a162a1f1b1f2a16caff1f932f53141c142f436f532b931c213c7f733bec143b1f1a3f1a1f1b1f5affaf836f342c143f234f833b531e231c213c6f331e431f4b
fc3c3f5c3a2cdf3b4f3b935f144c247fa31b1e1b731e1c213c5f931f5bfcfcdc4b3f1b631e434f144c148fb33b831c213c3fa32f3b1f3b1ffcfcecf33f4c148fe31b931c213c2fa32f8b4ffcfcfca31f5cbff3832c212c2fa34f4b1f4b1f5b141b742b7ffccc53fc6cf3532c212c2f431e435f9b2f7b543beffcfcfc8cc33c21
2c3f231e435ffbbbffbffcac3f83fc2c132c311c4f635ffb1fabffff4f2bff3ff3a34c311c5f436f3b73fbffff5f1bff3ff3d32c311c23cf3ba3cbffffff9f532b631ef3131c311c23bf3b731e33bbffff3f83cf634bf3732c211c339f3bd39b246f2bff6f532b933f838bf3532c211c437f4be37b544f3bff4f534bf3335bf3
a31c211c535f4bf37b545b1f2b4f6b6f833bf3432bf3b31e1c211c231e333f4bd31e33fbfb4f631ef3e31ef3431e331c211c735b834b73fb1b1f3b2f3b133b2ff3631ef3f3131e131e631c211c231e834b436b431e233b13fb1b2f6b531ed31ef3831e831e831e131e1c211cf3436b83fb137bf3f3331ec31e231e431e531e13
1e531c211c732e231e736b833b133b13ebf3f3931ee31e431e131e331e231e1c211cf3436b83fb7bf3f3f3f3931c211cf3534b93fb6b1ff3f3731ed31e531eb31c211ca33bf3231e33ab1f1b2f3b4ff3f3f3331e531e531e231e531c211c231e533bf3931b1fcb7f831eb31ef3f3f3231c211c638bf3232b231bff6fe31ef3f3
431eb31e131e331c211c131e335b3f3b4f839bbf1b3f141b6ff3f3f3931e832c211c534bffaf4baf134f131b7fc33b531e835ff3a31e132c211c433bffdf2b9f1bff8b435bb39f433bf3232c211c234b8f2a2f2aef2baf24ef3b136bf313df433bf32c211c5b8f7adf4b1f3a8f1b135f142b2f3b237bb3ff5f933b732c211c4b
8f3a362a9f1aa61aff2b2fbb131bffff8f7b532c212c1b1f1b8f2a261a164a1f1a4f2a168a161aef131b2f9b135bffff8f7b132b132c212c3b8f2af6261a661a168f13142f1b5f4b137b136b9f13afdb4f5b231b132c212c2b9f2a162a164a2f231a2b1a161a164b161a16ff2ffb1b134b5f143f1b7f4b943b4f5b131b231c21
2c3b8f2a462a4f333b161a161b2e1b161a161bff1f2b1ffb3b1f1b5f1b8f4bc42b4f6b231c212c3b7f4426343f433b161a161b2e1b161a161b9f145f5bce5b1f1b4f149f3b3463442b4f6b231c214c7f342c261c341f531b131b161a164b161a162b8f1b132f141f3b1f1b1eab1e5b1f2bcf3b2433a42b4f3b131b231c216c2f
8c264c1f533ba62b13df5b1e1b8e1b1e5b1f2bbf4b2413c43b4f2b132b131c31fc266c535b1426145b238f1b3f5b1e1b1e6b1e1b1e5b2f1b3f131f135f4b2413d42b6f132b131c31fc269c231b231b2426244c23cf5b1e1b1e1b4e1b1e1b1e3b132b3f1b148f4b241364172423342b5f231b131c41ec26fc2c267c13cf5b1e1b
1e1b1e2b1e1b1e1b1e7bcf4b84372413342b5f231b131c41ec26fc2c169cbf6b1e1b1e1b1e1b2e1b1e1b1e4b133bbf4b74571413343b4f231b131c51dc268c614c217cbf1b1f4b1e1b1e1b1e4b1e1b1e1b1f6bcf3b44133437241324133b4f431c51dc267ce16caf7b1e1b1e1b6e1b1e5bff4b34134417241334133b4f431c51
dc26acb15cbf7b1e1b1e8b1e3b3f1bef3b4413a4133b5f331c41ec26ec417ccf7b1e1bae2b2f2bff1f3b344364233b5f232c41bc3426443ffc2cdf3b13fb1b2f2b2f13ef4b94434b6f3c318c2f44461a147fdceffb1b1f3b1f2bff3f5b54635b5f4c317c4f341624162a9f5c162cef1b1ffb6b1f1b6f1bdf5b836b4f6c217c6f
141a462a4f1a8f1426ff1b1ffb5b7f1bff2ffb1b4f6c315c8f2a16141a161aef241614df2b1f3b138b1f1b1f2baf142f13ff1fbb5f8c314c9f2a461f1aaf142f44df2b1f5b234bcf141b3f14ffff3f8c414cbf267f147f141f441f14bf6b433bff4f1bffff2f8c413caf144f1adf141f1416142f141f149f4b131b333bff131f
14ff7fa33f8c413cff2f543f146f341f14cfdbff1bff4ff39c412caf1a8f942f141f24162f24bf3b1f2b131b1f3bffff2ff3538c412cff6f643f241f24ff1fabfffff3138a8c312cbf1a1f143f14df442f141f14bf4b2f3bffeff3134a462a8c312cbf1a2f143fb44f24ff2f2b2f3bffef738a135a162a165a5c312cdf242f24
1f143c243f243f143f14ffff9fb37a565a462a166a5c213cbf243f141f241c113c242f143f24ff5f1bff6f238a132a461a161a161b165a162a162a661a5c211c1f1cbf242f141f247c543f14ff3f1bff7f233a465a162a161a161a161b161a562a162a164c162a4c211c1f2caf143f141f144c111c111c341f141f141f14ffff
af231b1a362a165a162a361a161b161a1633162a461c2b1c162a4c214caf242f341c111c214c441f141f14ef1b1f2b3f2bff332b1a161a162a361a362a161a161a361a16131e13162a162a164c162a4c215c7f141f243f243c311c112c1f241f141f14ff5f5b2f1b9f234b1a161a461a361a162a161a163a161a1633462a662a
4c215caf144f242c116c341f141f145f146f1b1fab8f131e131e131e2b4a164a361a161a461a161a968a164a4c216cef346c341f141f14ef1b1f1b134b132b9f166b5a161a235a166a161a16aa531a162a274c217caf143f541c441f44ff1f3b134b2f1b7ff6f6f6361a473c218cefa42f14ff3f5bcff6f6f6361a473c219c8f
143f143f242f143f245f149f1b3f1b5f1b9f166b5a165a231a166a161a131e131e131a162a161a131e131e131a161a473c213c3f4cff1f544f24ffff3f131e131e131e2b4a161a364a162a361a161a531a162a161a531a162a373c213c4f4cff7f34ffff9f234b1a361a461a162a1613161a167a162a167a163a273c213c5f4c
ef94ffffbf332b3a362a362a161e464a461a661a362a273c214c5f4caf145f34ff5f87ff3f231b4a163a161a4613162a662a161a161a162b161a161a162a273c215c5f4cff8f145f145ff7976f234a564a362a161a162a162a161a161a162b562a174c216c5f4cffff1ff7f74f33fa1a362a661a465a274c218c4f5cffcfc7fc
774f236a433a13fa6a275c219c4ffc1ccf977cd77c471ff3f353376c21ac5ffc1c6f876c477c674c473c77f3b3675c172c21bc7ffc1c775cf78c977c47f353674c374c31ac17bf47fcf7675cf7173cb78387bc41ac376fc76cf7e73cf7176c9743476c773c51ac374f4ca7ccf7776c17ac774c171c976c874c71fc8c476c174c
374c572c477c278c275c373c57fc875cc1fcfcfcfcfcfcfc8cf1f1f1f1f1f1f1f1f100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
010300060561407611096110961508605046050160000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
0003000603514085110f5111951109515045050150000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
000300062a615136001b6000960008600046050160000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
00030006016140561507604076050560401605016000060000600006000060000600006000060000600006000d000006000060000600006000060000600006000060000600006000060000600006000060000600
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100001117505171071710a1710e175122741827111271102711124114231232511d26124271292750000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000517505171071710a1710e175122741827111271102711124114231172511d26118271112750000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400002b000360003b00036000120000d000090000700006010040100501007010090200b0300e03011030150401d050210502805030060370603d060000000000000000000000000000000000000000000000
000900001b5151d5251b5251f0251b535220351b5352b04533550330613356133061335613355133551335413354133531335313352133521335113351533505335052650528505265052a505315053550537505
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0002000000000000000d0500a05009050080500000000000000000d0500d0500c0500905010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00020000000000000005050060500b050110500000000000000000405005050070501005010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
012000001d7151d5251d7151d525187151871518715187151f7151f5251f7151f5251a7151a7151a7151a71523715235252371523525217152152521715215251f7151f5251f7151f52524715247152471524715
012000001c7151f5251c7151f525187151c715187151c7151d715215251d715215251771518715177151871524715215252471521525237151f525237151f525187151c525187151c5251f715217152371524715
0120000018715245251871524525187151a7151c7151871518715245251871524525187151a7151c71518715187152452518715245251871524525187152452518715245251871524525187151a7151c71518715
01200000247152452524715245252471524525247152452521715215252171521525217152151521715215151d7151d5251d7151d5252471524525267152652524715245252471524525187151a7151c71518715
01200000247142471024710247102471024710247102471521714217102171021710217102171021710217151d7141d7101d7101d715237142371023710237152471424710247102471024710247102471024715
01200000187141871524714247102471024710247102471515714157151c7141c7101c7101c7101c7101c71511714117101171011715177141771017710177151871418710187101871018710187101871018715
__music__
00 41425514
01 41421514
00 41421614
00 41421514
00 41421714
00 41425413
00 41421613
00 41421513
00 41421713
02 41425213
00 41425252
00 41425652

