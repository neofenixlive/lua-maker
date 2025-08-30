require("core")
update_frame = 0

function love.load()
    load_assets()
    scene_enter("example")
end

function love.update(dt)
    update_frame = update_frame + dt
    if update_frame > 1/GAME_DATA.scene.scene_speed then
        update_frame = update_frame - 1/GAME_DATA.scene.scene_speed
        
        GAME_DATA.scene:logic_code()
        for id, obj in pairs(GAME_DATA.instance) do
            if obj then
                obj:event_step()
            end
        end
    
        update_physics()
        countdown_alarms()
        follow_paths()
    end
end

function love.draw()
    if GAME_DATA.scene.view_follow then
        local follow = GAME_DATA.scene.view_follow
        view_x(get_variable(follow, "x") + get_variable(follow, "box_width")/2 - GAME_DATA.scene.view_width/2)
        view_y(get_variable(follow, "y") + get_variable(follow, "box_height")/2 - GAME_DATA.scene.view_height/2)
    end
    
    draw_screen()
end
