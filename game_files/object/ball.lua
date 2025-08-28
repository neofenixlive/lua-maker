return function()
    local object = {}
    
    object.x = 0
    object.y = 0
    
    object.hspeed = 0
    object.vspeed = 0
    object.box_width = 75
    object.box_height = 75
    
    object.image = get_asset("image", "sphere.png")
    object.image_xscale = 1.5
    object.image_yscale = 1.5
    object.image_angle = 0
    
    
    function object:event_create()
        self.sfx = get_asset("sound", "spring.mp3")
        self.hspeed = 8
    end
    function object:event_remove()
    end
    
    function object:event_step()
        self.vspeed = self.vspeed + 0.2
        if self.x+self.box_width>scene_width() then
            self.hspeed = -8
        end
        if self.x<0 then
            self.hspeed = 8
        end
        
        if self.y+self.box_height>scene_height() then
            self.vspeed = -12
            sound_play(self.sfx)
            bounce = bounce + 1
        end
    end
    function object:event_draw()
    end
    
    return object
end
