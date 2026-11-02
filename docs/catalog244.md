## 2026-10-30 · 244撤下双弹道 / 流动红旗待设计

用户明确撤掉双弹道（实际id distract、卡名开小差），红旗只要求灵感，未选定重做方案。world244继承243，当前C装配列表通过hidden_cards226虚拟钩子隐藏distract（226默认空数组、旧预览不变），profile244拒绝其正等级，buff_book244沿229保留25%/50%眼速，仅eligible过滤该卡，阻止当前随机候选。旧cards/战斗实现保留供169及历史预览对照，不全局删除素材/存档。此变更针对当前第一地区开发装配/候选，不是正式169背包重构。

独立music244_preview.cfg/boss_balance244.cfg。首次无244测试配置时读取243，复制levels并仅erase distract，再按新profile验证，保留其它装配及测试HP；不改写旧cfg。流动红旗仍原连击40%实现，未顺带改数值/费用，不把待讨论方案直接写进玩法。当前想法为可独立使用的接力/鼓劲机制，避免强绑多鹅；用户尚未选定，后续先讨论。

7项Compatibility检查通过（docs/catalog244-validation.json、catalog244-validation.log）：新profile拒绝/旧profile仍接受、随机eligible排除、眼速仍1.25、真实初始化控制台无该行、红旗及乐器课行保留、装配不含distract。无脚本错误；不为目录取舍重复全套战斗测试。最新244，旧243菜单35/music243；启动器UTF-8 BOM保留并实际PowerShell list通过。未改判定框/声音/战斗机制/地图/角色，未提交/push。
