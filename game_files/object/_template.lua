return function()
    local object = {}
    
    object.x = 0 --x position
    object.y = 0 --y position
    
    object.hspeed = 0 --horizontal speed
    object.vspeed = 0 --vertical speed
    object.box_width = 50 --hitbox width
    object.box_height = 50 --hitbox height
    
    object.image = get_asset("image", "") --sprite image
    object.image_xscale = 1 --sprite x scale
    object.image_yscale = 1 --sprite x scale
    object.image_angle = 0 --sprite rotation angles
    
    
    function object:event_create() --called when created
    end
    function object:event_remove() --called when removed
    end
    
    function object:event_step() --called every frame (update)
    end
    function object:event_draw() --called every frame (render)
    end
    
    return object
end
