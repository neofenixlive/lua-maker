GAME_DATA = {
    file={},
    instance={},
    scene={},
    mouse={},
    keyboard={},
    playback={}
}



--ASSETS--

function load_images()
    local image_list = love.filesystem.getDirectoryItems("game_files/image")
    GAME_DATA.file.image = {}
    
    for _, img in ipairs(image_list) do
        local name = img
        for format in {".png", ".jpg", ".bmp", ".tga"} do
            string.gsub(name, format, "")
        end

        GAME_DATA.file.image[name] = love.graphics.newImage("game_files/image/"..img)
    end
end

function load_sounds()
    local sound_list = love.filesystem.getDirectoryItems("game_files/sound")
    GAME_DATA.file.sound = {}
    
    for _, snd in ipairs(sound_list) do
        local name = snd
        for format in {".mp3", ".wav", ".ogg"} do
            string.gsub(name, format, "")
        end

        GAME_DATA.file.sound[name] = love.audio.newSource("game_files/sound/"..snd, "static")
    end
end

function load_fonts()
    local font_list = love.filesystem.getDirectoryItems("game_files/font")
    GAME_DATA.file.font = {}
    
    for _, fnt in ipairs(font_list) do
        local name = string.gsub(fnt, ".ttf", "")
        GAME_DATA.file.font[name] = love.graphics.newFont("game_files/font/"..fnt)
    end
end

function load_scripts()
    local script_list = love.filesystem.getDirectoryItems("game_files/script")
    for _, scr in ipairs(script_list) do
        local name = string.gsub(scr, ".lua", "")
        require("game_files.script."..name)
    end
end

function load_assets()
    load_images()
    load_sounds()
    load_fonts()
    load_scripts()
end

function get_asset(t, n)
    return GAME_DATA.file[t][n]
end



--SHARED--

function file_make(file)
    love.filesystem.write(file, "")
end

function file_delete(file)
    love.filesystem.remove(file)
end

function file_write(file, var, value)
    local write = "<var>"..var.."="..tostring(value).."</var>"

    if not love.filesystem.read(file) then
        love.filesystem.write(file, write)
        return
    end

    local content = love.filesystem.read(file)
    local pattern = "<var>"..var.."=(.-)</var>"

    if string.match(content, pattern) then
        love.filesystem.write(file, string.gsub(content, pattern, write))
    else
        love.filesystem.append(file, write)
    end
end

function file_read(file, var)
    if not love.filesystem.read(file) then
        return nil
    end

    local content = love.filesystem.read(file)
    local pattern = "<var>"..var.."=(.-)</var>"
    local read = string.match(content, pattern)

    if read == "true" then
        return true
    end
    if read == "false" then
        return false
    end
    if read == "nil" then
        return nil
    end
    if tonumber(read) then
        return tonumber(read)
    end
    return read
end



--MAIN--

function update_game()
    update_physics()
    for _, i in pairs(GAME_DATA.instance) do
        i:event_step()
    end
end

function render_game()
    render_animation()
    for _, i in pairs(GAME_DATA.instance) do
        i:event_draw()
    end
end



--INSTANCE--

function create_instance(obj, x, y)
    local id = #GAME_DATA.instance+1
    local instance = require("game_files.object."..obj)()
    
    GAME_DATA.instance[id] = instance
    instance.id = id
    instance.object = obj
    instance.x = x
    instance.y = y
        
    instance:event_create()
    return id
end

function remove_instance(id)
    GAME_DATA.instance[id]:event_remove()
    GAME_DATA.instance[id] = nil
end

function get_variable(id, var)
    return GAME_DATA.instance[id][var]
end

function set_variable(id, var, value)
    GAME_DATA.instance[id].var = value
end



--SCENE--

function scene_enter(room)
    GAME_DATA.instance = {}
    
    local scene = require("game_files.room."..room)()
    GAME_DATA.scene = scene
    GAME_DATA.scene.room = room

    for _, i in ipairs(GAME_DATA.scene.scene_build) do
        create_instance(i.object, i.x, i.y)
    end
    
    GAME_DATA.scene:creation_code()
    love.window.setMode(scene.view_width, scene.view_height, {resizable = false})
end

function scene_width()
    return GAME_DATA.scene.scene_width
end
function scene_height()
    return GAME_DATA.scene.scene_height
end
function view_x()
    return GAME_DATA.scene.view_x
end
function view_y()
    return GAME_DATA.scene.view_y
end
function view_follow(id)
    GAME_DATA.scene.view_follow = id
end



--INPUT--

function love.keypressed(key)
    GAME_DATA.keyboard[key] = true
end
function love.keyreleased(key)
    GAME_DATA.keyboard[key] = false
end
function love.mousepressed(x, y, button)
    GAME_DATA.mouse.button = button
end
function love.mousereleased(x, y, button)
    GAME_DATA.mouse.button = nil
end
function keyboard_check(key)
    return GAME_DATA.keyboard[key]
end
function mouse_x()
    return love.mouse.getX()
end
function mouse_y()
    return love.mouse.getY()
end
function mouse_button()
    return GAME_DATA.mouse.button
end



--PHYSICS--

function update_physics()
    for _, i in pairs(GAME_DATA.instance) do
        i.x = i.x + i.hspeed
        i.y = i.y + i.vspeed
    end
end

function position_meeting(x, y, obj)
    for _, box in ipairs(GAME_DATA.instance) do
        if box.object == obj then
            if box.x<x and box.x+box.box_width>x and box.y<y and box.y+box.height>y then
                return box.id
            end
        end
    end
end

function position_free(x, y)
    for _, box in ipairs(GAME_DATA.instance) do
        if box.x<x and box.x+box.box_width>x and box.y<y and box.y+box.height>y then
            return false
        end
    end
    return true
end

function place_meeting(id, x, y, obj)
    local width = GAME_DATA.instance[id].box_width
    local height = GAME_DATA.instance[id].box_height

    for _, box in ipairs(GAME_DATA.instance) do
        if box.id ~= id and box.object == obj then
            if (box.x<x+width and
                box.x+box.box_width>x and
                box.y<y+height and
                box.y+box.box_height>y) then
                return box.id
            end
        end
    end
end

function place_free(id, x, y)
    local width = GAME_DATA.instance[id].box_width
    local height = GAME_DATA.instance[id].box_height

    for _, box in ipairs(GAME_DATA.instance) do
        if box.id ~= id then
            if (box.x<x+width and
                box.x+box.box_width>x and
                box.y<y+height and
                box.y+box.box_height>y) then
                return false
            end
        end
    end
    return true
end

function move_towards(id, x, y, speed)
    local id_x = GAME_DATA.instance[id].x
    local id_y = GAME_DATA.instance[id].y

    local dir_x = x - id_x
    local dir_y = y - id_y
    local magnitude = math.sqrt(dir_x^2+dir_y^2)
    local unitdir_x = dir_x/magnitude
    local unitdir_y = dir_y/magnitude

    local new_x = id_x + (unitdir_x * speed)
    local new_y = id_y + (unitdir_y * speed)

    if (id_x <= new_x and new_x <= x) or (id_x >= new_x and new_x >= x) then
        if (id_y <= new_y and new_y <= y) or (id_y >= new_y and new_y >= y) then
            GAME_DATA.instance[id].x = new_x
            GAME_DATA.instance[id].y = new_y
        end
    end
end

function move_boundaries(id1, id2)
    local x1 = GAME_DATA.instance[id1].x
    local y1 = GAME_DATA.instance[id1].y
    local w1 = GAME_DATA.instance[id1].box_width
    local h1 = GAME_DATA.instance[id1].box_height
    local x2 = GAME_DATA.instance[id2].x
    local y2 = GAME_DATA.instance[id2].y
    local w2 = GAME_DATA.instance[id2].box_width
    local h2 = GAME_DATA.instance[id2].box_height
    
    local overlap_x = max(0, min(x1 + w1, x2 + w2) - max(x1, x2))
    local overlap_y = max(0, min(y1 + h1, y2 + h2) - max(y1, y2))
    
    if overlap_x > overlap_y then
        if x1 > x2 then
            GAME_DATA.instance[id1].x = x2 + w2
        else
            GAME_DATA.instance[id1].x = x2 - w1
        end
    else
        if y1 > y2 then
            GAME_DATA.instance[id1].y = y2 + h2
        else
            GAME_DATA.instance[id1].y = y2 - h1
        end
    end
end

function point_direction(x1, y1, x2, y2)
    local dir_x = x2 - x1
    local dir_y = y2 - y1
    local magnitude = math.sqrt(dir_x^2+dir_y^2)
    local unitdir_x = dir_x/magnitude
    local unitdir_y = dir_y/magnitude

    return (math.atan2(unitdir_y, unitdir_x) * (180/math.pi))
end

function out_of_bounds(x, y)
    return (x<0 and y<0 and x>GAME_DATA.scene.scene_width and y>GAME_DAYA.scene.scene_height)
end



--ANIMATION--

function render_animation()
    if GAME_DATA.scene.view_follow then
        local follow = GAME_DATA.instance[GAME_DATA.scene.view_follow]
        GAME_DATA.scene.view_x = follow.x
        GAME_DATA.scene.view_y = follow.y
    end
    
    local view_x = GAME_DATA.scene.view_x
    local view_y = GAME_DATA.scene.view_y
    love.graphics.draw(GAME_DATA.scene.scene_background, -view_x, -view_y)

    for _, i in pairs(GAME_DATA.instance) do
        local x = i.x + i.box_width/2 - view_x
        local y = i.y + i.box_height/2 - view_y
        local angle = (i.image_angle * (math.pi/180)) 
        local ox = i.image:getWidth()/2
        local oy = i.image:getHeight()/2

        love.graphics.draw(i.image, x, y, angle, i.image_xscale, i.image_yscale, ox, oy)
    end
end

function draw_set_color(r, g, b, a)
    love.graphics.setColor(r, g, b, a)
end
function draw_set_font(font)
    love.graphics.setFont(font)
end
function draw_rectangle(x1, y1, x2, y2, mode)
    love.graphics.rectangle(mode, x1, y1, x2-x1, y2-y1)
end
function draw_circle(x, y, r, mode)
    love.graphics.circle(mode, x, y, r)
end
function draw_point(x, y, size)
    love.graphics.setPointSize(size)
    love.graphics.point(x, y)
end
function draw_line(x1, y1, x2, y2, width)
    love.graphics.setLineWidth(width)
    love.graphics.line(x1, x2, y1, y2)
end
function draw_text(label, x, y)
    love.graphics.print(label, x, y)
end
function draw_image(image, x, y, r, sx, sy)
    love.graphics.draw(image, x, y, r, sx, sy)
end



--PLAYBACK--

function sound_play(src)
    local id = #GAME_DATA.playback+1
    local sound = src:clone()

    GAME_DATA.playback[id] = sound
    love.audio.play(GAME_DATA.playback[id])

    return id
end

function sound_pause(id)
    love.audio.pause(GAME_DATA.playback[id])
end
function sound_resume(id)
    love.audio.resume(GAME_DATA.playback[id])
end
function sound_stop(id)
    love.audio.stop(GAME_DATA.playback[id])
    GAME_DATA.playback[id] = nil
end
function sound_stop_all()
    for _, i in ipairs(GAME_DATA.playback) do
        love.audio.stop(i)
    end
    GAME_DATA.playback = {}
end
function sound_volume(value)
    love.audio.setVolume(value/100)
end
