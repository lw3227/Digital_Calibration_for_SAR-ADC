# GitHub 上传步骤

## 1) 初始化仓库

```bash
git init
git branch -M main
```

## 2) 提交本地代码

```bash
git add .
git commit -m "Initial commit: 16bit SAR ADC digital calibration"
```

## 3) 关联远程仓库

```bash
git remote add origin <your-github-repo-url>
```

示例：

```bash
git remote add origin https://github.com/<username>/<repo>.git
```

## 4) 推送

```bash
git push -u origin main
```

## 5) 后续更新

```bash
git add .
git commit -m "update"
git push
```

## 备注

- 本项目 `.gitignore` 已过滤常见 Vivado 生成文件和日志。
- 如已有历史仓库，请先确认远程分支状态，避免覆盖。
