---
name: dsha-phone-health-report
description: 用 DSHA 桥给 Android 手机做一次体检（型号系统、电量充电、存储内存、传感器、应用统计），汇总成 Markdown 报告并用 /app/export 交付到 Download 目录。
whenToUse: 用户说「看看手机状态」「手机体检」「电池/存储还剩多少」「手机卡不卡」等想了解设备整体状况时。
---

# 手机体检报告（DSHA 桥版）

一次采集、一份报告、一个交付文件。全程只读，不改任何设置。

## 采集步骤（按序执行，全部走 DSHA 桥）

请求统一形如 `curl -s -H @/root/.dsh/.bridge_headers "http://127.0.0.1:3090/<端点>"`。

1. **基本信息**：`/app/device` —— 返回多行文本，含 `model`、`android`、`battery`、`network`、`screen`、`storage_free/total`、`memory_free/total` 字段。
2. **传感器抽检**：`/app/sensors` —— 传感器清单（accel/gyro/light/gravity 等，`max=` 为量程）。
3. **应用统计**：`/app/apps`（不带 q，取全量）—— 分「用户应用/系统应用」两组列出，末行有可见应用总数。
4. **当前前台界面**（可选）：`/app/ui/dump` 粗看当前页面，判断是否有异常弹窗。

## 报告模板

把采集结果填进下面的模板（数据用真实值，不要编）：

```markdown
# 📱 手机体检报告

- 生成时间：<日期时间>
- 设备：<model> · Android <版本>

## 电量与充电
- 电量 <N>%，<是否充电中>
- 建议：<低于 20% 且未充电 → 提醒充电；长期插电 → 提示电池压力>

## 存储与内存
- 存储：可用 <X> GB / 共 <Y> GB（<可用/总量的百分比>）
- 内存：可用 <X> GB / 共 <Y> GB
- 建议：<存储可用 < 10% → 列出可清理方向；内存吃紧 → 提示后台过多>

## 传感器抽检
- 共识别 <N> 个传感器：<accel/gyro/light 等关键项各一行>
- 建议：<关键传感器缺失时提示>

## 应用
- 可见应用共 <N> 个（用户应用 <n>，系统应用 <m>）

## 总体结论
<一两句话：整体健康 / 需要注意的点>
```

## 交付

1. 报告写入 `/root/Documents/phone-health-report-<日期>.md`（或用户指定路径）。
2. `curl -s -H @/root/.dsh/.bridge_headers "http://127.0.0.1:3090/app/export?path=<报告绝对路径>"` 导出到手机 Download。
3. 回复里贴报告全文（用户在 GUI 里直接看），并告知导出位置。

## 注意

- 所有数据当次实时采集，不缓存旧值。
- `/app/device` 的字段是行式文本（`key=value` 空格分隔），解析时按行 split。
- 若某端点返回 DISABLED / NO_PERMISSION，照原话告诉用户去哪里开，跳过该项继续其余体检，不要反复重试。
