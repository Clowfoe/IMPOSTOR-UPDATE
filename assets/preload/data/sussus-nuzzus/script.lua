
function onCreate()
    setProperty('healthBar.alpha', tonumber(0))
    setProperty('iconP1.alpha', tonumber(0))
    setProperty('iconP2.alpha', tonumber(0))
end

function onUpdate()
    setProperty('health', 1) -- prevents any kind of health gain or loss
end

function onEndSong()
    if isStoryMode and not seenCutscene then
        startVideo('oversight')
        seenCutscene = true
        return Function_Stop
    end
    return Function_Continue
end
