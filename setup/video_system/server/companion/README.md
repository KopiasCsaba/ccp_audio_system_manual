# Companion

We use n8n as our main automation system. But, n8n have no plugin for controlling an ATEM console directly.

Therefore the bitfocus companion is setup as a thin proxy to accept commands from n8n, or to relay information back.

I wish to simplify this, therefore I'll not go into details, but here is the general idea with one example:


# Setting mute status of Mic1

Enabling the mix1 microphone happens like this:

 * There is a custom variable called "command" in companion
 * n8n sends a POST request to set this variable:
   * PATH: companion_host/api/custom-variable/command/value
   * BODY: set_mix1_on,1775468024977,1
     * `<command_name>,<timestamp>,<value1>[,<value2>...]`
 * Companion have a trigger to watch for this "MIC 1 MIX ON":
   * Event: on variable change `custom:command`
   * Condition: `split($(custom:command), ',')[0] == 'set_mix1_on' && split($(custom:command), ',')[2]=='1'`
     * (if the 0th element is set_mix1_on and the 2nd value is 1)
   * Actions:
     * atem: Fairlight Audio Set input mix option

Sadly some actions have no variable input, so in this case we need a "MIC 1 MIX OFF" trigger as well that does the inverse of this.

Some ATEM actions can have expression as parameter, it's simpler in those cases.

Most triggers use this command variable, by having the timestamp dumped into it is guaranteeing a trigger execution on change.

