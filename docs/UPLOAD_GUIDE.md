# GitHub Upload Guide

## 1) Initialize repository

```bash
git init
git branch -M main
```

## 2) Commit files

```bash
git add .
git commit -m "Initial commit"
```

## 3) Add remote

```bash
git remote add origin https://github.com/<username>/<repo>.git
```

## 4) Push

```bash
git push -u origin main
```

## 5) Future updates

```bash
git add .
git commit -m "update"
git push
```
