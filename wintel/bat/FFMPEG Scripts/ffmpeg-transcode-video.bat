for %%A IN ("*.mkv") Do ffmpeg -y -i "%%A" -map 0:v -c:v copy -map 0:a:0? -c:a:0 copy -map 0:a:0? -c:a:1 aac -b:a:1 192k -ac 2 -metadata:s:a:1 title="Eng 2.0 Stereo" -metadata:s:a:1 language=eng -map 0:a:1? -c:a:2 copy -map 0:a:2? -c:a:3 copy -map 0:a:3? -c:a:4 copy -map 0:a:4? -c:a:5 copy -map 0:a:5? -c:a:6 copy -map 0:a:6? -c:a:7 copy -map 0:s? -c:s copy "ffmpegOut/%%~nA_Stereo.mkv"

for /r %A IN ("*.mkv") Do ffmpeg -y -i "%A" -map 0:v:0 -map 0:a:0 -map 0:s? -movflags +faststart -c:v libx264 -c:a copy -metadata:s:a:0 language=eng -metadata:s:s:0 language=eng -disposition:s:0 default -c:s copy "working\%~nA.mkv"