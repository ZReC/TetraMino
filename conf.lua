function love.conf(t)
    t.identity				= nil
    t.version				= "0.10.0"
    t.console				= false
    t.accelerometerjoystick	= true
    t.gammacorrect			= false
 
    t.window.title			= "TetraMino"
    t.window.icon			= "gfx/icon.png"
    t.window.width			= 1280
    t.window.height			= 720
    t.window.borderless		= false
    t.window.resizable		= false
    t.window.minwidth		= 640
    t.window.minheight		= 480
    t.window.fullscreen		= true
    t.window.fullscreentype = "desktop"
    t.window.vsync			= true
    t.window.msaa			= 0
    t.window.display		= 1
    t.window.highdpi		= false
    t.window.x				= nil
    t.window.y				= nil
 
    t.modules.audio			= true
    t.modules.event			= true
    t.modules.graphics		= true
    t.modules.image			= true
    t.modules.joystick		= true
    t.modules.keyboard		= true
    t.modules.math 			= true
    t.modules.mouse 		= true
    t.modules.physics		= true
    t.modules.sound 		= true
    t.modules.system		= true
    t.modules.timer 		= true
    t.modules.touch 		= false
    t.modules.video			= false
    t.modules.window		= true
    t.modules.thread		= true
	
	t.identity				= "TetraMino"
	t.release				= true
end