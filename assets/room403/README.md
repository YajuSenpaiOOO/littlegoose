# 固定床几何的原生资源

来源是现有程序化模型，未生成/重画图片，未减面。`bake_home403.gd`在原构建路径生成后用ResourceSaver.FLAG_COMPRESS保存，再逐surface比较原始数组与重新读取的数组，三个网格完全一致。

- skirt.res：linen_mesh365.mesh365，153600顶点。
- quilt-0.res：quilt_mesh366.mesh366(0)，76800顶点。
- quilt-1.res：quilt_mesh366.mesh366(1)，61440顶点。

共约2.45MB，Godot原生ArrayMesh，遵循仓库现有*.res Git LFS规则。材质仍使用各原模型的材质；床空间坐标、UV、法线、颜色与原数组一致，碰撞/睡眠变形仍由原接入脚本管理。

`meshes.json`记录生成器及bed_mesh364依赖的SHA256；403启动选择此资源，签名不一致则明确告警并回退原算法。旧试演默认不开启此选择。改变生成器后运行：

```powershell
& 'D:\work\Agent\Godot_v4.7.2-stable_win64\Godot_v4.7.2-stable_win64_console.exe' --headless --path . --script res://scripts/world/bake_home403.gd
```

不要手改manifest绕过失效检查。
