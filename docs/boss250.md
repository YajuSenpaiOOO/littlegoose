# 250 Boss接入共用角色轮廓投影

2026-10-31。用户明确要求Boss使用正确的世界影子，落点读不清以后再说。本轮只修影子接入，不调招式/碰撞/主角/镜头/树避让。

## 接入

world250继承249，每次begin247创建Boss后调用既有_add_actor_shadow(boss247,boss247.visual)，实际工厂为actor_shadow113（CPU回退actor_shadow105/25）。注册到actor_shadows，由现有日夜time55.apply_look立即同步太阳/月光方向和夜间透明度。投影直接采样当前Sprite3D贴图、像素尺寸、脚锚点、镜像与实际变换，落到既有地形高度场；压扁/急眼/起跳/落地均共享身体来源。不重新生成美术，不加新的投影算法。

停用249加强的柔边椭圆影。旧shadow节点仅因历史pose代码引用而保留，250每次render后隐藏，轮廓投影是此Boss唯一可见影子来源。其cast_shadow关闭，不叠加原生卡片投影。淡出沿既有visual.modulate.a；演员删除时子投影一起释放，重开按既有actor_shadows清理路径移除旧注册。

落地圈继续默认关闭，F10对照保留。不增加假落点影；轮廓投影随光照方向偏移，不能保证它能精确预告未来落点。是否需要额外落点提示待用户实玩。

## 入口和验证

统一tools/launch-game.ps1 latest→world250，菜单41/boss249保留249椭圆影对照，248/247/246仍保留。所有战斗参数和单次反向跳逻辑沿249。

18项Compatibility真实渲染检查全部通过。validate_boss250.gd检查共用工厂/注册/唯一可见影源/默认撤圈/中午与夜间方向透明度/实际空中变换/姿态来源/开关/弹反/重开注册/淡出/清场。报告boss250-validation.json，最终日志boss250-release.log；本机截图plush220-boss250-ground-noon/air-noon/night/parry.png。

同镜头检查代表性日夜截图，不等于全地图/全部邻灯/复杂遮挡已验收。当前共用系统是轮廓投影，非宣称所有局部光源自动产生独立实时影子。用户实玩观感、落点读招与长期性能仍待反馈。独立试演存档tuantuan_boss250_preview.cfg，不发正式奖励。未提交/push。

首轮三项断言读取发生在渲染更新前，fixture改为等待process帧并显式采样投影更新后复验通过；生产投影算法未修改。
