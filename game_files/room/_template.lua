return function()
    local room = {}
    
    room.view_x = 0 --camera x position
    room.view_y = 0 --camera y position
    room.view_width = 500 --screen width
    room.view_height = 500 --screen height
    room.view_follow = nil --camera instance follow
    
    room.scene_width = 500 --scene width
    room.scene_height = 500 --scene height
    room.scene_background = get_asset("image", "") --image background
    room.scene_build = {
        {x=0, y=0, object=""}
    } --instance list

    function room:creation_code() --called after loaded
    end
    return room
end
