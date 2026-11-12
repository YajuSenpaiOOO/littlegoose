# 291 · 手电变身偶发缩小

用户认可Boss新受击轮廓和打击感，本轮保留该表现，只修手电变身期间主角偶发缩小、结束后恢复的问题。

## 原因与复现

woodland_world288.start288先设置hero.facing=down，再调用hero.render_pose，最后才关闭controls_enabled。hero36.render_pose会按仍按住的W/A/D重新决定朝向；同时start未清moving，保留当前行走帧。不同朝向/步态使用独立分辨率，pixel_size按各帧body_height归一化。正常行走显示没有问题，但旧变身将这个比例套在固定正面画稿和正面待机Atlas上。

原生输入复现四方向×四行走时刻：W/A/D的12种组合pixel比例为前向标准的约0.61–0.86，S的4种为1.0。具体值见transform-scale291-baseline.json；因此缩小程度取决于触发瞬间方向与步态，并非随机生成或变身原画变小。

## 修复范围

仅修改288系主动手电入口：先保存控制状态并锁住输入，清moving/phase/velocity/locomotion，再渲染正面静止姿态、重置该visual的物理插值历史。演出直接引用hero.directions.down的idle纹理、idle_anchor和idle_height，比例固定1.6/674，避免再次从临时方向画稿读取。站稳/举灯仍沿已校准0.595比例，回正面待机时沿同一脚点。

原主角169/192的行走显示、朝向、几何与材质没有修改；没有重画图、改镜头角度、增减战斗数值或修改团团动画。288、290、291继承链获得修复；285–287独立历史演出入口不回改。最新入口继续291。

## 验证

validate_transform_scale291.gd通过原生Input.parse_input_event按住W/A/S/D，在真实291场景分别取四个行走时刻启动F2预览，检查比例、正面冻结、站稳/举灯/待机三个演出时点、取消后控制恢复；另检查真实Q走路触发、显形恢复、光线激活和取消消耗30秒CD。最终117项全部通过，16种起步比例均1.0，缩小组合从12降为0，无新script/shader错误。结果见transform-scale291-validation.json。本验证针对尺寸与生命周期，不重复做伤害或Boss平衡测试；连续实玩观感待用户确认。
