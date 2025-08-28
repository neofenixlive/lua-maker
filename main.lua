require("core")

function love.load()
    load_assets()
    scene_enter("example")
end

function love.update(dt)
    update_game()
end

function love.draw()
    render_game()
end
