return function()
    local room = {}
    
    room.view_x = 0
    room.view_y = 0
    room.view_follow = nil
    room.view_width = 500
    room.view_height = 500
    
    room.scene_speed = 30
    room.scene_width = 500
    room.scene_height = 500
    room.scene_background = get_asset("image", "sky")
    room.scene_build = {
        {x=25, y=225, object="ball"},
        {x=225, y=400, object="ball"},
        {x=400, y=25, object="ball"}
    }

    function room:enter_code()
        bounce = 0
        sound_volume(75)
    end
    function room:logic_code()
    end

    return room
end
