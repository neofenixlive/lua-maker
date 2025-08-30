GAME_DATA = {
    file={},

    instance={},
    scene={},

    mouse={},
    keyboard={},

    render={},
    playback={},
    
    timer={}
}



--ASSETS--

function load_assets()
    load_images()
    load_sounds()
    load_fonts()
    load_scripts()
end

function load_images()
    love.graphics.setDefaultFilter("nearest", "nearest")
    
    local image_list = love.filesystem.getDirectoryItems("project_files/image")
    GAME_DATA.file.image = {}
    
    local extensions = {".png", ".jpg", ".bmp"}
    for _, img in ipairs(image_list) do
        local name = img
        for _, format in ipairs(extensions) do
            name = string.gsub(name, format, "")
        end

        GAME_DATA.file.image[name] = love.graphics.newImage("project_files/image/"..img)
    end
end

function load_sounds()
    local sound_list = love.filesystem.getDirectoryItems("project_files/sound")
    GAME_DATA.file.sound = {}
    
    local extensions = {".mp3", ".wav", ".ogg"}
    for _, snd in ipairs(sound_list) do
        local name = snd
        for _, format in ipairs(extensions) do
            name = string.gsub(name, format, "")
        end

        GAME_DATA.file.sound[name] = love.audio.newSource("project_files/sound/"..snd, "static")
    end
end

function load_fonts()
    local font_list = love.filesystem.getDirectoryItems("project_files/font")
    GAME_DATA.file.font = {}
    
    for _, fnt in ipairs(font_list) do
        local name = string.gsub(fnt, ".ttf", "")
        GAME_DATA.file.font[name] = {}
        for size=1, 100 do
            GAME_DATA.file.font[name][size] = love.graphics.newFont("project_files/font/"..fnt, size*2)
        end
    end
end

function load_scripts()
    local script_list = love.filesystem.getDirectoryItems("project_files/script")
    for _, scr in ipairs(script_list) do
        local name = string.gsub(scr, ".lua", "")
        require("project_files.script."..name)
    end
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
    local write = "<var>"..var.."="..tostring(value).."</var>\n"

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
    local value = string.match(content, pattern)
    
    if tonumber(value) then
        value = tonumber(value)
    end
    if value == "true" then
        value = true
    end
    if value == "false" then
        value = false
    end
    if value == "nil" then
        value = nil
    end
    
    return value
end



--MAIN--

function load_game()
    load_assets()
    GAME_DATA.game = require("load")
    GAME_DATA.game.update = 0
    GAME_DATA.game.frame = 0
    
    love.window.setTitle(GAME_DATA.game.window_title.." - "..GAME_DATA.game.window_version)
    scene_enter(GAME_DATA.game.room_start)
end

function update_game(dt)
    GAME_DATA.game.update = GAME_DATA.game.update + dt
    if GAME_DATA.game.update > 1/GAME_DATA.scene.scene_speed then
        GAME_DATA.game.update = GAME_DATA.game.update - 1/GAME_DATA.scene.scene_speed
        GAME_DATA.game.frame = GAME_DATA.game.frame + 1
        
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

function draw_game()
    if GAME_DATA.scene.view_follow then
        local follow = GAME_DATA.scene.view_follow
        view_x(get_variable(follow, "x") + get_variable(follow, "box_width")/2 - GAME_DATA.scene.view_width/2)
        view_y(get_variable(follow, "y") + get_variable(follow, "box_height")/2 - GAME_DATA.scene.view_height/2)
    end
    
    draw_screen()
end



--INSTANCE--

function create_instance(obj, x, y)
    local id = #GAME_DATA.instance+1
    local instance = require("project_files.object."..obj)()
    
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
    GAME_DATA.instance[id][var] = value
end



--SCENE--

function scene_enter(room)
    GAME_DATA.instance = {}
    GAME_DATA.alarm = {}
    
    local scene = require("project_files.room."..room)()
    GAME_DATA.scene = scene
    GAME_DATA.scene.room = room

    GAME_DATA.scene:enter_code()
    love.window.setMode(scene.view_width, scene.view_height, {resizable = false})
    
    for _, i in ipairs(GAME_DATA.scene.scene_build) do
        create_instance(i.object, i.x, i.y)
    end
end

function scene_width()
    return GAME_DATA.scene.scene_width
end
function scene_height()
    return GAME_DATA.scene.scene_height
end
function view_x(x)
    if not x then
        return GAME_DATA.scene.view_x
    end
    GAME_DATA.scene.view_x = x
end
function view_y(y)
    if not y then
        return GAME_DATA.scene.view_y
    end
    GAME_DATA.scene.view_y = y
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



--TIME--

function countdown_alarms()
    for id, alarm in pairs(GAME_DATA.timer) do
        if alarm then
            alarm.time = alarm.time - 1
            if alarm.time == 0 then
                alarm.code()
                GAME_DATA.timer[id] = nil
            end
        end
    end
end

function date_time(t)
    local times = {second="S", minute="M", hour="H"}
    return os.date("%"..times[t], os.time())
end

function date_calendar(t)
    local calendars = {day="d", month="m", year="Y"}
    return os.date("%"..calendars[t], os.time())
end

function alarm_create(time, code)
    local id = #GAME_DATA.timer+1
    GAME_DATA.timer[id] = {time=time, code=code}
    return id
end

function alarm_remove(id)
    GAME_DATA.timer[id] = nil
end



--PHYSICS--

function update_physics()
    for id, box in pairs(GAME_DATA.instance) do
        if box and not box.box_locked then
            box.x = box.x + box.hspeed
            box.y = box.y + box.vspeed
    
            if box.hspeed > 0 then
                box.hspeed = box.hspeed - box.friction
                if box.hspeed < 0 then
                    box.hspeed = 0
                end
            end
            if box.hspeed < 0 then
                box.hspeed = box.hspeed + box.friction
                if box.hspeed > 0 then
                    box.hspeed = 0
                end
            end
            box.vspeed = box.vspeed + box.gravity
        end
    end
end

function position_meeting(x, y, obj)
    for id, box in pairs(GAME_DATA.instance) do
        if box and box.object == obj and box.box_collide then
            if box.x<x and box.x+box.box_width>x and box.y<y and box.y+box.height>y then
                return box.id
            end
        end
    end
end

function position_free(x, y)
    for id, box in pairs(GAME_DATA.instance) do
        if box and box.box_collide then
            if box.x<x and box.x+box.box_width>x and box.y<y and box.y+box.height>y then
                return false
            end
        end
    end
    return true
end

function place_meeting(id, x, y, obj)
    local width = GAME_DATA.instance[id].box_width
    local height = GAME_DATA.instance[id].box_height

    for id, box in pairs(GAME_DATA.instance) do
        if box and box.id ~= id and box.object == obj and box.box_collide then
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

    for id, box in pairs(GAME_DATA.instance) do
        if box and box.id ~= id and box.box_collide then
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
    return (x<0 and y<0 and x>scene_width() and y>scene_height())
end



--PATH--

function follow_paths()
    for id, obj in pairs(GAME_DATA.instance) do
        if obj and obj.path then
            local point_x = obj.path[obj.path_point].x + obj.path_xbegin
            local point_y = obj.path[obj.path_point].y + obj.path_ybegin
            local point_speed = obj.path[obj.path_point].speed
            
            local old_x = obj.x
            local old_y = obj.y
            
            move_towards(id, point_x, point_y, point_speed)
            
            if old_x == obj.x and old_y == obj.y then
                obj.path_point = obj.path_point + 1
                if obj.path_point > #obj.path then
                    path_stop(id)
                end
                
                obj.x = point_x
                obj.y = point_y
            end
        end
    end
end

function path_start(id, path, speed, scale, flip_x, flip_y)
    local new_path = require("project_files.path."..path)()

    
    if speed then
        for idx, point in ipairs(new_path) do
            new_path[idx].speed = point.speed * speed
        end
    end

    if scale then
        for idx, point in ipairs(new_path) do
            new_path[idx].x = point.x * scale
            new_path[idx].y = point.y * scale
            new_path[idx].speed = point.speed * scale
        end
    end

    if flip_x then
        for idx, point in ipairs(new_path) do
            new_path[idx].x = -point.x
        end
    end

    if flip_y then
        for idx, point in ipairs(new_path) do
            new_path[idx].y = -point.y
        end
    end

    set_variable(id, "path", new_path)
    set_variable(id, "path_point", 1)
    set_variable(id, "path_xbegin", get_variable(id, "x"))
    set_variable(id, "path_ybegin", get_variable(id, "y"))
end

function path_stop(id)
    set_variable(id, "path", nil)
    set_variable(id, "path_point", 0)
    set_variable(id, "path_xbegin", 0)
    set_variable(id, "path_ybegin", 0)
end



--RENDER--

function draw_screen()
    GAME_DATA.render = {}
    
    for id, obj in pairs(GAME_DATA.instance) do
        if obj and obj.image_visible then
            if not GAME_DATA.render[obj.image_depth] then
                GAME_DATA.render[obj.image_depth] = {}
            end
            
            local img = {}
            if obj.image then 
                img.image = obj.image
                img.x = obj.x + obj.box_width/2 - view_x()
                img.y = obj.y + obj.box_height/2 - view_y()
                img.r = (obj.image_angle * (math.pi/180)) 
                img.sx = obj.image_xscale
                img.sy = obj.image_yscale
                img.ox = obj.image:getWidth()/2
                img.oy = obj.image:getHeight()/2
            end
            img.id = id
            table.insert(GAME_DATA.render[obj.image_depth], img)
        end
    end

    if GAME_DATA.scene.scene_background then
        love.graphics.setColor(255, 255, 255)
        love.graphics.draw(GAME_DATA.scene.scene_background, -view_x(), -view_y())
    end

    for id1, depth in pairs(GAME_DATA.render) do
        for id2, img in ipairs(depth) do
            love.graphics.setColor(255, 255, 255)
            if img.image then
                love.graphics.draw(img.image, img.x, img.y, img.r, img.sx, img.sy, img.ox, img.oy)
            end
            GAME_DATA.instance[img.id]:event_draw()
        end
    end
end

function draw_set_color(r, g, b, a)
    love.graphics.setColor(r, g, b, a)
end
function draw_set_font(font, size)
    local set_font = font[math.ceil(size/2)*2]
    love.graphics.setFont(set_font)
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

function sound_play(source)
    local id = #GAME_DATA.playback+1
    local sound = source:clone()

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
    for id, snd in ipairs(GAME_DATA.playback) do
        love.audio.stop(snd)
    end
    GAME_DATA.playback = {}
end
function sound_volume(value)
    love.audio.setVolume(value/100)
end
