#!/usr/bin/env bash

# Configuration
DOWNLOAD_DIR="./Downloads"
BATCH_FILE="./batch_links.txt"
EDITOR="${EDITOR:-nvim}"
MAX_PARALLEL_DOWNLOADS=5

download_mp4() {
  yt-dlp --recode-video mp4 -P "$DOWNLOAD_DIR" -f "bv*[ext=mp4]+ba[ext=m4a]/b[ext=mp4]" "$1"
}

download_mp3() {
  yt-dlp -x --audio-format mp3 -P "$DOWNLOAD_DIR" "$1"
}

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
  if [ "$mode" = "MP4" ]; then
    download_mp4 "$link"
  else
    download_mp3 "$link"
  fi
}

download_video() {
  local video_id=$1
  local mode=$2
  local video_url="https://youtube.com/watch?v=$video_id"
  local title=$(yt-dlp --get-title "$video_url" 2>/dev/null || echo "Unknown Title")
  echo "Downloading: $title"
  if [ "$mode" = "MP4" ]; then
    download_mp4 "$video_url"
  else
    download_mp3 "$video_url"
  fi
  echo "Completed: $title"
}

youtube_playlist_download() {
  local mode=$1
  echo -n "Enter the playlist link: "
  read playlist_link
  echo "Getting video list..."

  local video_ids=()
  while IFS= read -r id; do
    [[ -n "$id" ]] && video_ids+=("$id")
  done < <(yt-dlp --flat-playlist --get-id "$playlist_link")

  local total_videos=${#video_ids[@]}

  if [ "$total_videos" -eq 0 ]; then
    echo "No videos found in playlist"
    return 1
  fi

  echo "Found $total_videos videos. Starting downloads..."
  local current=0
  local running=0
  local pids=()

  for video_id in "${video_ids[@]}"; do
    while [ $running -ge $MAX_PARALLEL_DOWNLOADS ]; do
      for pid in "${pids[@]}"; do
        if ! kill -0 $pid 2>/dev/null; then
          running=$((running - 1))
        fi
      done
      sleep 1
    done

    ((current++))
    echo "Starting download $current of $total_videos"
    download_video "$video_id" "$mode" &
    pids+=($!)
    ((running++))
  done

  for pid in "${pids[@]}"; do
    wait $pid
  done

  echo "All downloads complete!"
}

parallel_batch_download() {
  local mode=$1
  [[ ! -f "$BATCH_FILE" ]] && touch "$BATCH_FILE"
  echo "Edit the batch links file. Each line should contain a link. Close the editor to continue."
  $EDITOR "$BATCH_FILE"

  local links=()
  while IFS= read -r link; do
    [[ -n "$link" ]] && links+=("$link")
  done < "$BATCH_FILE"

  if [ "${#links[@]}" -eq 0 ]; then
    echo "No links found in batch file"
    return 1
  fi

  for link in "${links[@]}"; do
    [[ -z "$link" ]] && continue
    if [ "$mode" = "MP4" ]; then
      download_mp4 "$link"
    else
      download_mp3 "$link"
    fi
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
