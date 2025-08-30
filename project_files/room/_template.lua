return function()
    local room = {}
    
    room.view_x = 0 --camera x position
    room.view_y = 0 --camera y position
    room.view_follow = nil --camera instance follow
    room.view_width = 500 --screen width
    room.view_height = 500 --screen height
    
    room.scene_speed = 30 --scene frames per second
    room.scene_width = 500 --scene width
    room.scene_height = 500 --scene height
    room.scene_background = get_asset("image", "") --image background
    room.scene_build = {
        {x=0, y=0, object=""},
    } --instance list

    function room:enter_code() --called after entering
    end
    function room:logic_code() --called every frame
    end

    return room
end
