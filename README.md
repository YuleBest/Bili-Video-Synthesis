# Bili-Video-Synthesis

📺 一个用于自动合成哔哩哔哩下载视频与音频的 Bash 脚本工具，生成带元数据的 MP4 文件。

---

## 项目简介

本脚本可自动扫描哔哩哔哩客户端的下载目录，将分散的 `video.m4s` 和 `audio.m4s` 文件合并为完整视频，并自动添加画质标签、作者名与视频标题。

---

## 功能特性

- 自动遍历哔哩哔哩下载目录
- 构建视频信息 JSON 记录文件
- 使用 FFmpeg 无损合成音视频
- 支持批量处理多个下载视频
- 输出文件名包含质量/作者/标题信息

---

## 依赖环境

- **Termux** 或其他 Bash 终端环境
- `ffmpeg` - 音视频处理工具（已内置）
- `jq` - JSON 解析工具（已内置）

> 💡 脚本会自动配置依赖到 `/data/bilivideotool`，若失败请手动安装

---

## 使用说明

### 配置修改
编辑脚本前两行的关键路径：
```bash
INPUT_DIR="/storage/emulated/0/Android/data/tv.danmaku.bili/download"  # 哔哩哔哩下载目录
OUTPUT_DIR="$SCTIPT_DIR/output"  # 合成视频输出目录
```

### 使用方法
1. 前往 [Release](https://github.com/YuleBest/Bili-Video-Synthesis/release/latest) 下载最新发行版

2. 赋予执行权限
```bash
chmod +x START.sh
```

3. 运行脚本
```bash
bash START.sh
```

### 输出示例
```
[INFO] 查找到视频 1「【4K修复】故宫雪景-哔哩官方」- 哔哩纪录片
[SUCCESS] 「[1080P][哔哩纪录片]【4K修复】故宫雪景」合成成功
```

---

## 注意事项

1. 📱 **路径适配**  
   路径可能因应用版本不同而变化，请通过文件管理器确认真实路径

2. 📂 **输出目录**  
   默认输出到脚本所在目录的 `output/` 文件夹，首次运行会自动创建

3. ⚠️ **依赖问题**  
   若出现 `ffmpeg/jq not found` 错误，请手动将 `res/` 下的二进制文件复制到系统 PATH

---

## 关于项目

- **许可证**: MIT License
- **额外条例**: 禁止商用
- **声明**: 本项目仅供学习交流，请勿用于非法用途

> 觉得好用？给个 ⭐ 鼓励作者吧！  
> 问题反馈：[创建 Issue](https://github.com/YuleBest/Bili-Video-Synthesis/issues)