-- Initialize logger (optional, but good practice for debugging)
local log = hs.logger.new("audio_watcher", "info")

-- Function to handle the audio device change event
local function handleAudioChange(event)
    log.i("Audio change event: " .. event) -- Log the event

    if event == "dOut" or event == "sOut" then
        -- Delay slightly to allow the system to fully update
        hs.timer.doAfter(0.5, function()
            local currentOutput = hs.audiodevice.defaultOutputDevice()

            if currentOutput then
                -- Here you would implement your logic.
                -- For example, to mute the *new* default output device:
                currentOutput:setOutputMuted(true)
                log.i("Attempted to mute the new default output: " .. currentOutput:name())

                -- Alternatively, to unmute a *previously* selected device (requires storing the previous device):
                -- if previousOutput and previousOutput:name() ~= currentOutput:name() then
                --     previousOutput:setOutputMuted(false) -- Unmute the old device
                -- end
                -- previousOutput = currentOutput -- Update previousOutput for the next event
            else
                log.i("No default output device found.")
            end
        end)
    end
end

-- Create and start the watcher
hs.audiodevice.watcher.setCallback(handleAudioChange)
hs.audiodevice.watcher.start()

