# dsha-skills 🐟

适配 [DSH（DeepSeek Harness）安卓端（DSHA）](https://github.com/)的 skill 合集——给运行在 Android 手机容器里的 DSH agent 用的「肌肉记忆包」。

每个 skill 都基于 DSHA 桥（`127.0.0.1:3090` 的 `/app/*` 端点）编写，端点与字段全部实测过。

## Skills 一览

| Skill | 干什么 |
|---|---|
| `dsha-app-automation-recipes` | App 自动化配方库：把重复操作流程固化成配方（包名→入口→按文字点按→验证点），跑通新流程自动沉淀回库，越用越肥 |
| `dsha-phone-health-report` | 手机体检报告：一次采集设备/电量/存储/传感器/应用数据，产出 Markdown 报告并导出到 Download |
| `dsha-app-qa-walkthrough` | App 走查方法论：像 QA 一样系统过一遍 App（冷启动→首页→逐 Tab→深页→返回栈），输出带截图存证的问题清单 |

## 安装

### 方式一：整仓 clone（推荐，方便 git pull 更新）

```bash
git clone https://github.com/Fahuikongjian/dsha-skills ~/.dsh/skills/dsha-skills
```

DSH 的 skill 扫描器会自动发现 `~/.dsh/skills/` 下的 `<name>/SKILL.md`，**无需重启**，下一轮对话即可用。

### 方式二：只装单个 skill

```bash
git clone https://github.com/Fahuikongjian/dsha-skills /tmp/dsha-skills
cp -r /tmp/dsha-skills/dsha-app-automation-recipes ~/.dsh/skills/
```

### 方式三：一键脚本

```bash
curl -fsSL https://raw.githubusercontent.com/Fahuikongjian/dsha-skills/main/install.sh | bash
```

## 使用

不用手动调用。skill 的 `whenToUse` frontmatter 会让 agent 在合适的场景自动想起它们：

- 「帮我每天自动签到 XX」→ 配方库
- 「看看我手机状态」→ 体检报告
- 「测测这个 App 好不好用」→ 走查

## Skill 格式速查

```
<name>/SKILL.md          # 目录形式（本仓库全部用这种）
```

```yaml
---
name: <必填>
description: <必填>
whenToUse: <可选，触发场景>
---
正文 = 给 agent 看的操作手册
```

扫描根：`~/.dsh/skills/`、`<project>/.dsh/skills/` 等；目录有 watch，增删改即时生效。

## License

MIT
