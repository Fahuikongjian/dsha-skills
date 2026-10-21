#!/usr/bin/env bash
# dsha-skills 一键安装：clone 到临时目录，把各 skill 目录拷进 ~/.dsh/skills/
set -euo pipefail

REPO_URL="https://github.com/Fahuikongjian/dsha-skills"
SKILLS_DIR="${HOME}/.dsh/skills"
TMP="$(mktemp -d)"

trap 'rm -rf "$TMP"' EXIT

echo "==> 克隆 $REPO_URL"
git clone --depth 1 "$REPO_URL" "$TMP/dsha-skills"

mkdir -p "$SKILLS_DIR"

for d in "$TMP/dsha-skills"/dsha-*/; do
  name="$(basename "$d")"
  echo "==> 安装 skill: $name"
  rm -rf "$SKILLS_DIR/$name"
  cp -r "$d" "$SKILLS_DIR/$name"
done

echo "==> 完成！skill 已装入 $SKILLS_DIR（无需重启，下一轮对话生效）"
echo "    已安装："
ls -d "$SKILLS_DIR"/dsha-*/ 2>/dev/null | sed 's/^/      /'
