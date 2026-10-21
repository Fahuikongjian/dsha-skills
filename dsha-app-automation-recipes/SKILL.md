---
name: dsha-app-automation-recipes
description: 把常用 Android App 的重复操作流程固化成可复用配方（包名 → 入口 → 按文字点按序列 → 验证点），用 DSHA 桥执行；每跑通一条新流程就把步骤沉淀回本文件，配方库随使用自动增肥。
whenToUse: 用户要求自动化某个 App 的日常/重复操作（签到、打卡、喂鸡、发消息、查余额、开关某功能等），或说「每天帮我点开 XX」「帮我自动做 XX」类需求时；执行前先查本文件有没有现成配方。
---

# App 自动化配方库（DSHA 桥版）

把「UI 探索成本」固化成「配方」。已有 computer-use 是手，本库是肌肉记忆。

## 铁律（每条配方执行时都必须遵守）

1. **每步 dump 再动**：每次点按/输入后先重新读屏（`/app/ui/dump`），确认界面状态再决定下一步。绝不凭记忆连点——界面可能已经变了。
2. **按文字点，不按坐标**：用 `/app/ui/tap?text=...`，分辨率/布局无关。坐标只作 fallback（文字重复或不可见时），且必须在当次 dump 里现取。
3. **验证点不过就停**：任何一步的验证条件不满足，立即停止并如实报告卡在哪一步、屏幕上实际是什么。不要瞎试超过 2 次。
4. **成功后沉淀**：跑通一条新流程后，把配方写回本文件「配方区」（见下方格式）。失败时把失败点记进配方的 `notes`，下次少踩坑。

## DSHA 桥端点速查（本机 127.0.0.1:3090，凭据走 header 文件）

所有请求形如 `curl -s -H @/root/.dsh/.bridge_headers "http://127.0.0.1:3090/<端点>"`。

| 用途 | 端点 |
|---|---|
| 读屏（点按/输入前后的观察） | `/app/ui/dump` |
| 按文字点按 | `/app/ui/tap?text=<文字>` |
| 输入框写入 | `/app/ui/input?text=<文字>` |
| 滑动 | `/app/ui/swipe` |
| 导航键（back/home/recents/notifications） | `/app/ui/key?name=<键>` |
| 截屏存证 | `/app/ui/screenshot` |
| 启动应用 | `/app/launch?pkg=<包名>` |
| 应用列表 | `/app/apps?q=<关键词>` |
| 设备状态 | `/app/device` |
| 手电筒 | `/app/torch?on=1` / `?on=0` |
| Toast 反馈 | `/app/toast?text=<文字>` |
| 通知 | `/app/notify?title=<标题>&text=<内容>` |
| 导出文件到 Download | `/app/export?path=<绝对路径>` |

## 配方格式

新配方按此格式追加到「配方区」，一条一个 YAML 块：

```yaml
- name: 配方名（中文，动词开头）
  package: com.example.app        # 目标 App 包名
  entry: /app/launch?pkg=com.example.app   # 入口动作
  steps:
    - action: tap                 # tap / input / swipe / key / endpoint
      target: "文字或端点"         # tap 用界面文字；endpoint 写完整 URL
      verify: "点后 dump 应看到的内容"   # 验证条件，不满足即停
  success: "最终验证点（dump 里应出现的关键内容）"
  notes: 版本差异、坑、失败记录（可空）
  verified: "2026-10-21"          # 最后一次跑通日期
```

## 配方区

<!-- 新配方追加在这里。执行前先扫一遍：有现成配方就直接按配方跑，没有才从零探索。 -->

### 配方 1：查看「关于手机」页面（系统设置）

```yaml
- name: 查看关于手机页面
  package: com.android.settings
  entry: /app/launch?pkg=com.android.settings
  steps:
    - action: tap
      target: "关于手机"
      verify: "dump 出现 Android 版本 / 版本号 等字样"
  success: "dump 含设备名称与 Android 版本信息"
  notes: 部分 ROM 该项在「系统」二级菜单下；找不到时先 tap「系统」再找。UI 类配方依赖读屏能力：dump 报 [ERR] SCREEN_TARGET_UNAVAILABLE 时，是设备无障碍/读屏授权未开——提示用户在 DSHA App 的设备能力授权里开启屏幕读取，不要反复重试。读屏可能逐次弹确认框：用户点拒绝（返回「你拒绝了这次屏幕读取」）时立即停下询问意图，绝不连续重试。
  verified: "2026-10-21"
```

### 配方 2：开关手电筒（端点直控型，无需 UI）

```yaml
- name: 开/关手电筒
  package: N/A（系统硬件能力）
  entry: /app/torch?on=1
  steps:
    - action: endpoint
      target: "/app/torch?on=1"      # 关闭用 ?on=0
      verify: "返回 result=ok（或等价成功标志）"
  success: "端点返回成功；可用 /app/device 确认状态"
  notes: 端点直控型配方的价值：跳过 UI 探索，一步到位。
  verified: "2026-10-21"
```

## 从零探索新流程的方法（还没有配方时）

1. `/app/apps?q=<关键词>` 找包名；没有就 `/app/launch?pkg=` 直接试。
2. `/app/ui/dump` 读屏 → 找目标文字 → `/app/ui/tap?text=` → 再 dump。
3. 每步记下：点的前置条件、点的文字、点后应看到什么。
4. 到达终点后，按「配方格式」把整条链写回本文件，标 `verified` 日期。
5. 如果流程涉及敏感操作（支付、发送、删除），配方里必须加 `confirm: true` 步骤——执行到该步先向用户确认。
