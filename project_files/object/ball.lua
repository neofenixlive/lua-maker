return function()
    local object = {}
    
    object.hspeed = 12
    object.vspeed = 0
    object.friction = 0
    object.gravity = 0.4

    object.box_width = 75
    object.box_height = 75
    object.box_collide = true
    object.box_locked = false
    
    object.image = get_asset("image", "ball")
    object.image_xscale = 1.5
    object.image_yscale = 1.5
    object.image_angle = 0
    object.image_visible = true
    object.image_depth = 1
    
    
    function object:event_create()
        self.sound = get_asset("sound", "boing")
        self.font = get_asset("font", "comic_sans")
    end
    function object:event_remove()
    end
    
    function object:event_step()
        if self.x+self.box_width>scene_width() then
            self.hspeed = -12
        end
        if self.x<0 then
            self.hspeed = 12
        end
        
        if self.hspeed<0 then self.image_angle = self.image_angle-10 end
        if self.hspeed>0 then self.image_angle = self.image_angle+10 end
        if self.image_angle<0 then self.image_angle = 360 end
        if self.image_angle>360 then self.image_angle = 0 end
            
        if self.y+self.box_height>scene_height() then
            self.vspeed = -16
            sound_play(self.sound)
            
            bounce = bounce + 1
        end
    end
    function object:event_draw()
        draw_set_font(self.font, 10)
        draw_set_color(0,0,0)
        
        local string = "This is a BALL!\nId: "..tostring(self.id)..", X: "..tostring(math.floor(self.x))..", Y: "..tostring(math.floor(self.y))
        draw_text(string, self.x-30, self.y-60)
        
        draw_set_font(self.font, 20)
        draw_text("Bounces: "..tostring(bounce), 10, 10)
    end
    
    return object
end
