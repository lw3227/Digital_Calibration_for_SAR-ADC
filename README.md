# 16bit SAR ADC Digital Calibration

本仓库包含一个 16bit SAR ADC 数字校准项目，覆盖 MATLAB 行为级模型与 FPGA(Vivado)实现。

## 项目内容

- MATLAB 行为模型与算法验证（含 dither 校准、动态性能计算）
- Verilog LMS 数字校准模块
- Vivado 工程与仿真/综合实现文件
- 两份项目文档 PDF

## 目录结构

- `16bit_dither校准/`：MATLAB 主模型与算法脚本
- `VDAO_test/`：Vivado 工程目录
- `说明文档.pdf`：项目说明文档
- `21312379 吴林晓 高精度SAR ADC设计与数字校准（幸新鹏）.pdf`：课程/课题报告
- `docs/`：仓库补充文档（索引、上传说明）

## 关键文件

- `16bit_dither校准/test.m`：主仿真入口，调用 ADC 行为模型、校准与频谱评估
- `16bit_dither校准/cal_dither.m`：dither 校准流程
- `16bit_dither校准/calculate_dynamic_spec.m`：SNR/SNDR/ENOB/SFDR 计算
- `VDAO_test/VDAO_test.srcs/sources_1/new/LMS_cali.v`：LMS 权重迭代校准核心
- `VDAO_test/VDAO_test.srcs/sources_1/new/cali_top.v`：顶层集成（时钟、ROM、校准与输出）

## 运行说明

### MATLAB

1. 打开 MATLAB，工作目录切到 `16bit_dither校准/`
2. 运行 `test.m`
3. 查看校准前后频谱与 ENOB/SNDR 指标

### Vivado

1. 打开 `VDAO_test/VDAO_test.xpr`
2. 根据需要执行综合/实现/仿真
3. 顶层模块为 `cali_top`

## 上传 GitHub 前建议

本仓库包含大量 Vivado 自动生成文件（`*.runs`、`*.sim`、`*.cache`、日志文件等），不建议纳入版本管理。

已提供 `.gitignore`，按下面流程上传：

```bash
git init
git add .
git commit -m "Initial commit: 16bit SAR ADC digital calibration"
git branch -M main
git remote add origin <your-github-repo-url>
git push -u origin main
```

详细步骤见 `docs/UPLOAD_GUIDE.md`。
