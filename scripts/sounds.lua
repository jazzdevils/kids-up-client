local userSetting = require( "scripts.userSetting" )
local sound = {} 

sound.buttonPress = audio.loadSound( "audio/buttonPress.wav" )
--sound.bigBoomSound = audio.loadSound( "audio/explosion.wav" )
--sound.killMeSound = audio.loadSound( "audio/idied.wav" )
--sound.missileSound = audio.loadSound( "audio/missile.wav" )
--sound.blasterSound = audio.loadSound( "audio/scifi048.wav" )
--sound.bossSound = audio.loadSound( "audio/scifi026.wav" )
--sound.shieldsSound = audio.loadSound( "audio/shields.wav" )

local audioPlay = function( handle, options )
    if (userSetting.soundOn == false ) then
        print("not play sound")
        
        
        return false
    end
    
    
    audio.play(handle, options)
    print("play sound")
    
end

sound.audioPlay = audioPlay

return sound

