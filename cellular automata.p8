pico-8 cartridge // http://www.pico-8.com
version 27
__lua__
-- Cellular Automata Game
-- copy of cellular automata by apretrue

-- Idea is to write your own cellular automata rules to get a desired effect after N turns.

function draw_menu()
 print("p12=",28,80,7)
end

function empty_grid(size)
    holder = {}
    for i=0,size do
        cells_line = {}
        for j=0,size do
            cells_line[j] = 0
        end
        holder[i] = cells_line
    end
    return holder
end

update_time=0
grid_is_running = false
grid_is_paused = false
frames_per_grid_update=1
state_grid_size=10
state_grid=empty_grid(state_grid_size)
-- make starting level state
state_grid[5][5]=1
--
new_state_grid={}
rule_grid_config = {
    size=3,
    x=0,y=10
}
rule_grid=empty_grid(rule_grid_config.size)
cell_size=8
cursor={i=0,j=0}

function draw_grid(grid, x_offset, y_offset)
    for i=1,#grid do
        for j=1,#grid[0] do
            if grid[i][j]==0 then --none
                spr(4,i*cell_size+x_offset,j*cell_size+y_offset)
            elseif state_grid[i][j]%2==0 then --recent state
                state_grid[i][j]=0
                spr(2,i*cell_size+x_offset,j*cell_size+y_offset)
            elseif state_grid[i][j]%2==1 then --active state
                state_grid[i][j]=1
                spr(3,i*cell_size+x_offset,j*cell_size+y_offset)
            end
        end
    end
end

function inc_state_cell(i, j)
    if i>=1 and j>=1 and i<=grid_size and j<=grid_size then
        if state_grid[i][j]==1 then
            new_state_grid[i][j]=1
        else
            new_state_grid[i][j]=0
        end
    end
end

function apply_rule_to_cell(i, j)
    for im=-1,1 do
        for jm=-1,1 do
            if rule_grid[im][jm] then
                inc_state_cell(i+im, j+jm)
            end
        end
    end
end

function apply_rule()
    new_state_grid = empty_grid(state_grid_size)
    for i=1,#new_state_grid do
        for j=1,#new_state_grid[0] do
            if state_grid[i][j] == 1 then
                apply_rule_to_cell(i, j)
            end
        end
    end
    state_grid = new_state_grid
end

function show_title()
    sspr(0,16,80,8,20,40,100,10)
end

function _init()
    in_game = false
end

function _draw()
    cls()
    if in_game then
        draw_grid(state_grid, 0, 0)
        draw_grid(rule_grid, 0, cell_size*#state_grid)
        -- draw cursor
        print(cursor.i, 0, 10, 3)
        print(cursor.j, 0, 20, 3)
        sspr(8,0,8,8,cursor.i*cell_size,cursor.j*cell_size)
    else
        show_title()
        print('❎ -', 40, 70, 6)
        print('play/pause',60,70,8)
        print('🅾️ -', 40, 80, 6)
        print('toggle rule cell',60,80,12)
        if update_time%40<20 then
            print('press ❎ to start', 32, 100, 6)
        end
    end
end

function limit_rule_cursor_index(i, max_val)
    if i < 1 then
        return i+max_val
    elseif i > max_val then
        return i-max_val
    end
end

function cursor_controls()
    if btnp(0,0) then
        cursor.i -= 1
    elseif btnp(1,0) then
        cursor.i += 1
    elseif btnp(2,0) then
        cursor.j -= 1
    elseif btnp(3,0) then
        cursor.j += 1
    end
    cursor.i = limit_rule_cursor_index(cursor.i, #rule_grid)
    cursor.j = limit_rule_cursor_index(cursor.j, #rule_grid[0])
    if btnp(4,0) then
        rule_grid[cursor.i][cursor.j]=(rule_grid[cursor.i][cursor.j]+1)%2
        sfx(0)
    elseif btnp(5,0) then
        if grid_is_running==false then
            grid_is_running = true
        elseif grid_is_paused then
            grid_is_paused = false
        else
            grid_is_paused = true
        end
    end
end

function game_update()
    if grid_is_running and grid_is_paused==false and update_time % frames_per_grid_update == 0 then
        apply_rule()
    end
    cursor_controls()
end

function menu_update()
    if btnp(4,0) or btnp(5,0) then
        in_game = true
        update_time = 0
    end
end

function _update()
    update_time += 1
    if in_game then
        game_update()
    else
        menu_update()
    end
end
__gfx__
00000000aaa00aaa7666666776666667766666675333333333335000555555555555500000000000000000000000000000000000000000000000000000000000
00000000a000000a6777777667777776600000063337733333333000555775555555500000000000000000000000000000000000000000000000000000000000
00700700a000000a67dddd7667cccc76600000063373373377733000557557557775500000000000000000000000000000000000000000000000000000000000
000770000000000067dddd7667cccc76600000063733333733373000575555575557500000000000000000000000000000000000000000000000000000000000
000770000000000067dddd7667cccc76600000063733773733373000575577575557500000000000000000000000000000000000000000000000000000000000
00700700a000000a67dddd7667cccc76600000063373373733373000557557575557500000000000000000000000000000000000000000000000000000000000
00000000a000000a6777777667777776600000063337733377733000555775557775500000000000000000000000000000000000000000000000000000000000
00000000aaa00aaa7666666776666667766666675333333333335000555555555555500000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00999990000009099000000900000000000009000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
99000090000009099000000900000000000009900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
99000000099009099000000900000000000009900000000090000000000000000000900000000000000000000000000000000000000000000000000000000000
90000000900909099099090909900990900009900099090999009900999999099009990990000000000000000000000000000000000000000000000000000000
90000000999009099099090900090090900090990099090090090990990909000900900009000000000000000000000000000000000000000000000000000000
99000000900009099099090909990090000099990099090090090990990909099900900999000000000000000000000000000000000000000000000000000000
99000090900909099099090909990090000900999099090090090990990909099900900999000000000000000000000000000000000000000000000000000000
09999900099009999909999990099090009900099009990099009900990909090990990909900000000000000000000000000000000000000000000000000000
__label__
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111999999111111199199111111119111111111111111199111111111111111111111111111111111111111111111111111111111111
11111111111111111111999111119111111199199111111119111111111111111199911111111111111111111111111111111111111111111111111111111111
11111111111111111111999111119111111199199111111119111111111111111199911111111111111111111111111111111111111111111111111111111111
11111111111111111111999111111119991199199111111119111111111111111199911111111111911111111111111111111111191111111111111111111111
11111111111111111111911111111191119199199119919919199911999191111199911119919919999119991199999999199111999919911111111111111111
11111111111111111111911111111199991199199119919919111191119191111911991119919911911191999199919199111991191111199111111111111111
11111111111111111111999111111191111199199119919919199991119111111999991119919911911191999199919199199991191119999111111111111111
11111111111111111111999111111191111199199119919919199991119111111999991119919911911191999199919199199991191119999111111111111111
11111111111111111111999111119191119199199119919919199991119111119111999119919911911191999199919199199991191119999111111111111111
11111111111111111111199999991119991199999991999999911199119111199111199111999911999119991199919199191999199919199911111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111666661111111111111188818181888188111111888188818811111111111111111111111111111111111111
11111111111111111111111111111111111111116616166111111111111118118181818181811111818181118181111111111111111111111111111111111111
11111111111111111111111111111111111111116661666111116661111118118181881181811111881188118181111111111111111111111111111111111111
11111111111111111111111111111111111111116616166111111111111118118181818181811111818181118181111111111111111111111111111111111111
11111111111111111111111111111111111111111666661111111111111118111881818181811111818188818881111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111111111111111111111111111111111116666611111111111111ccc1c1c1ccc1cc111111ccc1c111c1c1ccc111111111111111111111111111111111
1111111111111111111111111111111111111111661116611111111111111c11c1c1c1c1c1c11111c1c1c111c1c1c11111111111111111111111111111111111
1111111111111111111111111111111111111111661616611111666111111c11c1c1cc11c1c11111cc11c111c1c1cc1111111111111111111111111111111111
1111111111111111111111111111111111111111661116611111111111111c11c1c1c1c1c1c11111c1c1c111c1c1c11111111111111111111111111111111111
1111111111111111111111111111111111111111166666111111111111111c111cc1c1c1c1c11111ccc1ccc11cc1ccc111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111666166616661166116611111166666111111666116611111166166616661666166611111111111111111111111111111
11111111111111111111111111111111616161616111611161111111661616611111161161611111611116116161616116111111111111111111111111111111
11111111111111111111111111111111666166116611666166611111666166611111161161611111666116116661661116111111111111111111111111111111
11111111111111111111111111111111611161616111116111611111661616611111161161611111116116116161616116111111111111111111111111111111
11111111111111111111111111111111611161616661661166111111166666111111161166111111661116116161616116111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111

__map__
0017171700001717001700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000001700000000170000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0017000017000000000017001700171700000000171700171700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0017170000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0017000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0500171700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000170000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100002d7002c7002b7002b7002a70029700267002870011700090000a0000c000100000f0000f0100f010100101201014010170101901012000207000d0000e0000f000100001200015000157000f70014700
0001000026700077000d7000d7000c7000c7000c7000c7000b7000b7000b7000b7000b7000b7000b7000a7000c7000c7000c7000c7000d7000d7000d7000d7000c70010700107000f7000f7000e7000f7000e700
