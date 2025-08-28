return function()
    local room = {}
    
    room.view_x = 0
    room.view_y = 0
    room.view_width = 500
    room.view_height = 500
    room.view_follow = nil
    
    room.scene_width = 500
    room.scene_height = 500
    room.scene_background = get_asset("image", "sky.png")
    room.scene_build = {
        {x=50, y=300, object="ball"},
        {x=250, y=200, object="ball"},
        {x=450, y=100, object="ball"}
    }

    function room:creation_code()
        bounce = 0
        sound_volume(30)
    end
    return room
end
