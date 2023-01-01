function onEndSong()
    if isStoryMode and not seenCutscene then
        startVideo('henryend')
        seenCutscene = true
        return Function_Stop
    end
    return Function_Continue
end
