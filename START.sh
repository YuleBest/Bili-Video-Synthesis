#!/bin/bash
# By Yule
# https://github.com/YuleBest/Bili-Video-Synthesis
SCTIPT_DIR="$(dirname $(readlink -f $0))"    # 不要改这个

# 基本配置
INPUT_DIR="/storage/emulated/0/Android/data/tv.danmaku.bili/download"    # 哔哩哔哩下载目录
OUTPUT_DIR="$SCTIPT_DIR/output"    # 输出目录

# 变量定义
VAR_DEF() {
    gr='\033[0;32m'
    ye='\033[1;33m'
    re='\033[0;31m'
    bre='\033[41m'
    bye='\033[43m'
    bgr='\033[42m'
    res='\033[0m'
    paths_record_file="./record"
    path_json_file="$SCTIPT_DIR/Bili-Info.json"
}

# 环境配置
CHECK_TOOL() {
    mkdir -p "/data/bilivideotool"
    export PATH="/data/bilivideotool:$PATH"
    chmod -R 777 "/data/bilivideotool"

    if ! command -v ffmpeg &> /dev/null; then
        echo -e "[INFO] res/ffmpeg -> /data/bilivideotool"
        cp "$SCTIPT_DIR/res/ffmpeg" "/data/bilivideotool/"
        CHECK_TOOL
        return 0
    fi

    if ! command -v jq &> /dev/null; then
        echo -e "[INFO] res/ffmpeg -> /data/bilivideotool"
        cp "$SCTIPT_DIR/res/jq" "/data/bilivideotool/"
        CHECK_TOOL
        return 0
    fi
    return 0
}

# 寻找 video.m4s 并构建 JSON
BUILD_JSON() {
    local id=1
    local video_path audio_path bili_info_path bili_title bili_qua bili_author
    echo -e "[INFO] 开始构建 Bili-Info.json"
    echo "{}" > "$path_json_file"

    find "$INPUT_DIR" -type f -name 'video.m4s' -print0 | while IFS= read -r -d '' file; do
        video_path="${file}"
        audio_path="$(dirname ${file})/audio.m4s"
        bili_info_path="$(dirname $(dirname ${file}))/entry.json"
        bili_title="$(jq -r '.title' $bili_info_path)"
        bili_qua="$(jq -r '.quality_pithy_description' $bili_info_path)"
        bili_author="$(jq -r '.owner_name' $bili_info_path)"

        jq \
        --arg id "$id" \
        --arg bili_title "$bili_title" \
        --arg video_path "$video_path" \
        --arg audio_path "$audio_path" \
        --arg bili_info_path "$bili_info_path" \
        --arg bili_author "$bili_author" \
        --arg bili_qua $bili_qua \
           '. += { $id: { "title": $bili_title, "author": $bili_author, "quality": $bili_qua, "video": $video_path, "audio": $audio_path, "info": $bili_info_path } }' \
           "$path_json_file" > $SCTIPT_DIR/tmp.json && mv $SCTIPT_DIR/tmp.json "$path_json_file"

        echo -e "[INFO] 查找到视频 $id「$bili_title」- $bili_author"
        ((id++))
    done
    echo -e "[INFO] JSON 文件构建完成"
}

# 单次合成
OPERATION() {
    local video=$1
    local audio=$2
    local filename=$3

    if ! ffmpeg -y -loglevel error -i "$video" -i "$audio" -c copy -map 0:v -map 1:a -f mp4 "${OUTPUT_DIR}/${filename}.mp4" 2>&1; then    # 使用 ffmpeg 合成并设定日志级别 error
        echo -e "${re}[ERROR]${res}「${filename}」ffmpeg出现错误，此视频未完成合并"
        return 1
    else
        echo -e "${gr}[SUCCESS]${res}「${filename}」合成成功"
        return 0
    fi
}

# 合成视频
SYNTHESIS() {
    local video audio title author qua doubt
    local bili_number=$(jq 'keys | length' "$path_json_file")    # 获取键的数量
    local succ_count=0
    local fail_count=0
    mkdir "$OUTPUT_DIR" 2>/dev/null
    echo ''

    for bili in $(jq -r 'keys[]' "$path_json_file"); do    # 获取所有键并遍历
        video=$(jq -r ".\"$bili\".video" "$path_json_file")    # 访问字符串键
        audio=$(jq -r ".\"$bili\".audio" "$path_json_file")
        author=$(jq -r ".\"$bili\".author" "$path_json_file")
        title=$(jq -r ".\"$bili\".title" "$path_json_file")
        qua=$(jq -r ".\"$bili\".quality" "$path_json_file")

        OPERATION "$video" "$audio" "[$qua][$author]${title}"    # 执行合成任务
        doubt=$?
        [ $doubt -eq 0 ] && ((succ_count++)) 
        [ $doubt -eq 1 ] && ((fail_count++))
    done
    echo ''; echo -e "- ${gr}成功: $succ_count${res}"; echo -e "- ${re}失败: $fail_count${res}"
}

MAIN() {
    VAR_DEF
    CHECK_TOOL
    BUILD_JSON
    SYNTHESIS
}

MAIN