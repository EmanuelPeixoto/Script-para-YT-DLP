#!/usr/bin/env bash

# Configuration
DOWNLOAD_DIR="./Downloads"
BATCH_FILE="./batch_links.txt"
EDITOR="${EDITOR:-nvim}"
MAX_PARALLEL_DOWNLOADS=5

# YT-DLP configuration options
declare -A CONFIG_OPTIONS=(
  ["MP4"]="--recode-video mp4 -P $DOWNLOAD_DIR -f 'bv*[ext=mp4]+ba[ext=m4a]/b[ext=mp4]' -q"
  ["MP3"]="-x --audio-format mp3 -P $DOWNLOAD_DIR -q"
)

setup_environment() {
  mkdir -p "$DOWNLOAD_DIR"
}

show_menu() {
  clear
  cat << EOF
File Download Menu
------------------------------
Choose an option by entering the number:
1 - MP4 with link
2 - MP3 with link
3 - MP4 with file
4 - MP3 with file
5 - MP4 youtube playlist
6 - MP3 youtube playlist

9 - About the software
0 - Exit
EOF
  echo -n "Your choice: "
  read choice
  echo
  return "$choice"
}

download() {
  local mode=$1
  echo -n "Enter the link: "
  read link
  clear
  echo "Starting download..."
  echo "----------------"
  yt-dlp ${CONFIG_OPTIONS[$mode]} "$link"
}

youtube_playlist_download() {
  local mode=$1
  echo -n "Enter the playlist link: "
  read playlist_link
  echo "Getting video list..."

  readarray -t video_ids < <(yt-dlp --flat-playlist --get-id "$playlist_link")
  local total_videos=${#video_ids[@]}

  if [ "$total_videos" -eq 0 ]; then
    echo "No videos found in playlist"
    return 1
  fi

  echo "Found $total_videos videos. Starting downloads..."
  local running_downloads=0
  local completed_downloads=0

  local pipe="/tmp/yt_status_$$"
  mkfifo "$pipe"
  exec 3<> "$pipe"
  rm "$pipe"

  {
    while read -r line; do
      clear
      echo "Total videos: $total_videos"
      echo "----------------------------------------"
      echo -e "$line"
    done <&3
  } &
  local display_pid=$!

  for video_id in "${video_ids[@]}"; do
    while [ $running_downloads -ge $MAX_PARALLEL_DOWNLOADS ]; do
      wait -n 2>/dev/null || true
      ((running_downloads--))
      ((completed_downloads++))
    done

    {
      local video_url="https://youtube.com/watch?v=$video_id"
      local title=$(yt-dlp --get-title "$video_url" 2>/dev/null || echo "Unknown Title")
      echo "Currently downloading ($completed_downloads/$total_videos):\n$title" >&3
      yt-dlp ${CONFIG_OPTIONS[$mode]} "$video_url" >/dev/null 2>&1
    } &

    ((running_downloads++))
  done

  while [ $running_downloads -gt 0 ]; do
    wait -n 2>/dev/null || true
    ((running_downloads--))
    ((completed_downloads++))
  done

  kill $display_pid 2>/dev/null || true
  exec 3>&-

  clear
  echo "All downloads complete!"
}

parallel_batch_download() {
  local mode=$1
  [[ ! -f "$BATCH_FILE" ]] && touch "$BATCH_FILE"
  echo "Edit the batch links file. Each line should contain a link. Close the editor to continue."
  $EDITOR "$BATCH_FILE"
  readarray -t links < "$BATCH_FILE"

  if [ "${#links[@]}" -eq 0 ]; then
    echo "No links found in batch file"
    return 1
  fi

  for link in "${links[@]}"; do
    [[ -z "$link" ]] && continue
    yt-dlp ${CONFIG_OPTIONS[$mode]} "$link"
  done
}

show_about() {
  clear
  cat << EOF
Created by Emanuel Peixoto
github.com/EmanuelPeixoto
This software requires FFmpeg and YT-DLP to be installed
EOF
}

main() {
  setup_environment
  while true; do
    show_menu
    case $? in
      1) download "MP4" ;;
      2) download "MP3" ;;
      3) parallel_batch_download "MP4" ;;
      4) parallel_batch_download "MP3" ;;
      5) youtube_playlist_download "MP4" ;;
      6) youtube_playlist_download "MP3" ;;
      9) show_about ;;
      0) echo "Exiting..."; exit 0 ;;
      *) echo "Unknown option."; sleep 2 ;;
    esac
    echo
    echo -n "Press ENTER to continue or 'q' to quit: "
    read continue
    [[ "$continue" == "q" ]] && break
  done
}

main
