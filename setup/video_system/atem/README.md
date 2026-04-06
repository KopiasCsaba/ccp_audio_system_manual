# ATEM Setup

# Startup config
Saved into atem's "startup config" via the software control:
 * Inputs, outputs mapped as per the [schematic.png](../assets/schematic.png)
 * Multiview set up conveniently for the crew
 * A/B mode
 * 1080p50 (we still have a suboptimal HDMI calbe to the projector that can't take 60)
 * Transition speeds
 * Preset gallery files for the mediaplayers

# Init
The event manager n8n workflow periodically looks for the ATEM to come online:
   * if the ATEM is not streaming then we know it is uninitialised
     * We load up our current preset (background images, set auxes automatically)
     * Enable streaming (to restreamer, then restreamer needs to be turned on when we really go live)
     * Set recording file name to current preset prefix+date
     * Etc.
