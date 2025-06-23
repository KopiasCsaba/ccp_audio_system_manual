# ffmpeg -i "Website Beach Video.mp4" -filter_complex "[0:v]split[vf][vr];[vr]reverse[vrv];[vf][vrv]concat=n=2:v=1:a=0[out]"  -map "[out]" -c:v libx264 -crf 18 -preset veryfast output.mp4

# ffmpeg -stream_loop 1 -i "Website Beach Video.mp4" -filter_complex "[0:v]format=yuva420p,split[vf][vt]; [0:a]asplit[af][at];  [vf][vt]xfade=transition=fade:duration=1:offset=4[vout]; [af][at]acrossfade=d=1[outa]" -map "[vout]" -map "[outa]" -c:v libx264 -crf 18 -preset medium  -c:a aac -b:a 192k  output_looped.mp4



ffmpeg -i "Website Beach Video.mp4" -filter_complex "[0:v]format=yuva420p,split=2[v0][v1];[v0]trim=0:8,setpts=PTS-STARTPTS,fps=fps=30000/1001,settb=AVTB[A];[v1]trim=7,setpts=PTS-STARTPTS,fps=fps=30000/1001,settb=AVTB[B];[B][A]xfade=transition=fade:duration=1:offset=7,format=yuv420p[v]" -map "[v]" -c:v libx264 -crf 18 -preset medium -an output_loop.mp4
