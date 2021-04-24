#!/usr/bin/env bash
set -e
TEMPDIR="/mnt/pool0/p0ds0smb/temp/ffmpeg"
WORKDIR="$TEMPDIR/working"
SCRIPT_NAME=$(basename "$0")
declare -a LOG
shopt -s globstar
shopt -u nullglob

usage()
{
cat <<EOF
Usage: "$SCRIPT_NAME" [options]

-h| --help         Help shows this message.
-d| --directory    Specify the directory to process.
-w| --workdir      Writable working directory for FFmpeg.
                   If you don't specify this option, the
                   subdirectory named "working" will be used
                   within the --directory path or \$TEMPDIR.
EOF
}

while [ "$1" != "" ]; do
    case $1 in
        -d | --directory )	shift
                                TEMPDIR="${1:-$TEMPDIR}"
                                WORKDIR="$WORKDIR"
                                ;;
        -w | --workdir )	shift
                                WORKDIR="${1:-$WORKDIR}"
                                ;;
        -h | --help )           usage
                                exit 0
                                ;;
        * )                     usage
                                exit 1
    esac
    shift
done

cd $TEMPDIR
echo -e "DEBUG:\n\$TEMPDIR = $TEMPDIR\n\$WORKDIR = $WORKDIR"
[ -d "$WORKDIR" ] || mkdir "$WORKDIR" || exit $?
find . ! -path "*$(basename "$WORKDIR")/*" -regextype posix-extended -regex '.*(mkv|mp4)$' -print0 | while IFS= read -r -d $'\0' f;
  if [ -n "$f" ]; then
    do
    LOG+=("$f")
    AUDIOFORMAT=($(ffprobe -loglevel error -select_streams a:0 -show_entries stream=codec_name,channels -of default=nw=1:nk=1 "${f/DDP/AAC}"))
  	if ! [ "${AUDIOFORMAT[0]}" = "aac" ]; then
      # Build ffmpeg array within the loop to populate variables
      args=(
      -nostdin
      -i "$f"
      -y
      -map 0:v:0
      -map 0:a:0
      -map 0:s?
      -c:v copy
      -ac "${AUDIOFORMAT[1]}"
      -ar 48000
      -metadata:s:a:0
      language=eng
      -c:a aac
      -c:s copy
      "$WORKDIR/$(basename "${f}")"
      )
# args=("-i ${f}" "${args[@]}")
#	args+=("$WORKDIR/$(basename "${f}")")
	echo -e '\nffprobe detected '${AUDIOFORMAT[0]}' in the default audio stream with '${AUDIOFORMAT[1]}' channels\nPreparing to convert audio codec to AAC...\n' ; sleep 1
	echo -e "DEBUG: ffmpeg ${args[@]}\n"
	ffmpeg "${args[@]}" || break
	echo -e 'Moving '$WORKDIR/$(basename "${f}")' back to source directory name '$(dirname "${f}")''; sleep 1
	mv -ufv "$WORKDIR/$(basename "${f}")" "$(dirname "${f}")" || break
    fi
    done
  printf '\nPROCESSED:%s\n'
  for i in "${LOG[@]}"; do echo "$i"; done
  fi

