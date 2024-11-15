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

# Function to create necessary directories
setup_environment() {
  mkdir -p "$DOWNLOAD_DIR"
}

# Function to display menu and get user choice
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
  read -p "Your choice: " choice
  echo
  return "$choice"
}

# Function to handle single downloads
download() {
  local mode=$1
  read -p "Enter the link: " link
  clear
  echo "Starting download..."
  echo "----------------"
  yt-dlp ${CONFIG_OPTIONS[$mode]} "$link"
}

# Function to handle playlist downloads
youtube_playlist_download() {
  local mode=$1
  read -p "Enter the playlist link: " playlist_link
  echo "Getting video list..."

    # Get playlist information
    local video_ids=($(yt-dlp --flat-playlist --get-id "$playlist_link"))
    local total_videos=${#video_ids[@]}

    if [ "$total_videos" -eq 0 ]; then
      echo "No videos found in playlist"
      return 1
    fi

    echo "Found $total_videos videos. Starting downloads..."
    local running_downloads=0
    local completed_downloads=0

    # Create named pipe for status updates
    local pipe="/tmp/yt_status_$$"
    mkfifo "$pipe"
    exec 3<> "$pipe"
    rm "$pipe"

    # Background process to update display
    {
      while read -r line; do
        clear
        echo "Total videos: $total_videos"
        echo "----------------------------------------"
        echo -e "$line"
      done <&3
    } &
    local display_pid=$!

    # Process videos in parallel
    for video_id in "${video_ids[@]}"; do
      # Wait if max parallel downloads reached
      while [ $running_downloads -ge $MAX_PARALLEL_DOWNLOADS ]; do
        wait -n
        ((running_downloads--))
        ((completed_downloads++))
      done

        # Start download in background
        {
          local video_url="https://youtube.com/watch?v=$video_id"
          local title=$(yt-dlp --get-title "$video_url" 2>/dev/null || echo "Unknown Title")
          echo "Currently downloading ($completed_downloads/$total_videos):\n$title" >&3
          yt-dlp ${CONFIG_OPTIONS[$mode]} "$video_url" >/dev/null 2>&1
        } &

        ((running_downloads++))
      done

    # Wait for remaining downloads
    while [ $running_downloads -gt 0 ]; do
      wait -n
      ((running_downloads--))
      ((completed_downloads++))
    done

    # Clean up
    kill $display_pid
    exec 3>&-

    clear
    echo "All downloads complete!"
  }

# Function to handle parallel batch downloads
parallel_batch_download() {
  local mode=$1
  [[ ! -f "$BATCH_FILE" ]] && touch "$BATCH_FILE"
  echo "Edit the batch links file. Each line should contain a link. Close the editor to continue."
  $EDITOR "$BATCH_FILE"
  mapfile -t links < "$BATCH_FILE"
  youtube_playlist_download "$mode" "${links[@]}"
}

# Function to display about information
show_about() {
  clear
cat << EOF
Created by Emanuel Peixoto
github.com/EmanuelPeixoto
This software requires FFmpeg and YT-DLP to be installed
EOF
}

# Main function
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
    read -p "Press ENTER to continue or 'q' to quit: " continue
    [[ "$continue" == "q" ]] && break
  done
}

main
