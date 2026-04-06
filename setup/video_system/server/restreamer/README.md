# Restreamer setup

## Choppy youtube audio bug

We had a bug where a racecondition caused choppy audio on youtube, for now the solution for that is
enabling audio re-encoding on the restreamer side.

Learn more: https://github.com/datarhei/restreamer/issues/728#issuecomment-3853307225


# Automation

The deciding factor for us being live or not is if the restreamer outputs are enabled or not. 

N8N is watching for the ATEM to come online, and immediately turns on it's streaming output, which is directed to restreamer.
And then when the session starts (either by the "PRE STREAM" or the auto starter workflow (on time on sundays)) then n8n will enable/disable the right restreamer outputs as needed.
