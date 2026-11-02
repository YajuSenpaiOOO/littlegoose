# 接力旗245运行原型

来源：父工作区art_workbench/red_banner245/parts-v1的三张已拆分透明图原样复制；goose-fire.png用内置imagegen基于goose-idle生成，提示词见generation.json，非CLI。均保留原图，不脚本改画；Image加载+mipmap后以alpha .5丢弃极淡生成杂点。

相机朝向/共享笔尖与挂点/各层缩放位置沿assembly.json。三Sprite3D使用card_depth199派生shader，保持实际世界深度测试；各层脚深面仅.003间隔保证旗盖笔、鹅盖旗，不设置无条件最前显示。独立接触影，不加角色/路障碰撞、不用整张图矩形作体积、不新建投射阴影实体，不改hero192、镜头或树。原生接触地形floor_height，当前只接森林草土；stone/wood_indoor需物体ground_material元数据，未做全地图标签迁移。

程序动画落下/共用笔尖轻晃/共用挂点展开/旗布收拢像素淡出，两张鹅图换姿；不是完整手绘逐帧动画。初始高度1.25m已与主角同镜头日夜看过。F11标debug预览，真正触发为装备red_banner后闪避落旗，下一次攻击主鹅的一份载荷从旗补射，仅一旗，约5秒后收回；落地前开火缓存一轮等待站稳，补射不递归。relay_gain245=.35仅测试参数，不代表数值定稿。旧连击40%被替换；C仅开放一份旗。

组合测试：普通、多鹅仅取源0、乐器课Perfect最终预算、剑标记、纸飞机投递身份与一次接棒。手电暂只补第一束样本的短光段（独立ribbon generation），尚未设计完整持续接力，不宣称所有武器平衡就绪。地面碎屑是6个短命无碰撞mesh，按材质标签选草土/石/纸屑配色，独立影子及浅埋量；木地轻弹。无固定泥土贴片、无地面破洞。

验证：godot_world/docs/relay245-validation.json和relay245-verified.log；地图drop/fire/ready/day/night截图。尚待用户确认插地力度、旗尺寸与鹅发射感；未完成长时间性能和全场地遮挡/桥面支撑验收。
