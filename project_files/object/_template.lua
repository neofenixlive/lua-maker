return function()
    local object = {}
    
    object.hspeed = 0 --horizontal speed
    object.vspeed = 0 --vertical speed
    object.friction = 0 --force agaisnt hspeed
    object.gravity = 0 --force agaisnt vspeed

    object.box_width = 50 --hitbox width
    object.box_height = 50 --hitbox height
    object.box_collide = true --hitbox collision detection
    object.box_locked = false --hitbox movement locking
    
    object.image = get_asset("image", "") --image
    object.image_xscale = 1 --image x scale
    object.image_yscale = 1 --image y scale
    object.image_angle = 0 --image rotation angle
    object.image_visible = true --image visibility
    object.image_depth = 1 --image render order
    
    
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
