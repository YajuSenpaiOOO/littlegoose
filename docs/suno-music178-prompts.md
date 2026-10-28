# 小白鹅大冒险 · Suno 音乐提示词包

2026-10-26。设计提案，尚未生成或接入BGM。现项目可见鸟鸣/秋千等程序音效，未找到已导入ogg/wav/mp3成品背景曲。本文件包含10首优先曲、6首备用曲和4条短提示音，均为可单独复制的完整提示词。备用车站/小游戏/姐姐级战斗是声音预案，不代表相关玩法本轮已实施或音乐必须全部制作。

## 分配建议

按氛围区域与玩法状态分配，避免每个地图小块都强行做“探索＋战斗”各一首。小院/普通散步可共用01；湖边02、山顶03、森林04有足够差异，值得各自一首。姐姐小屋05作为森林的安全感变奏。普通战斗分团团06、纸怪07、蜘蛛08；09可全局用作普通区域夜曲，森林夜间先继续04，不另开每张地图夜曲。10是叙事通用曲。标题、车站、Boss与小游戏先备用。

先抽01、04、08、05，每首选同一模型/设置的2–4个候选；确定整体音色后再扩剩余曲。分批并行生成可以，但不要一开始给20条都抽很多遍。只改一个变量（速度、主奏或密度），保留曲目ID和提示词版本。

## 统一声音风格

建议用“小编制木质童话室内乐”，不是看到像素画就固定用8-bit。共同底色为柔和毛毡钢琴、尼龙弦吉他、拨弦弦乐、少量木管和清亮小钟；每首只突出其中2–3种，木马林巴/轻手打击乐提供弹性。温暖、好奇、带一点笨拙，战斗更有脉冲而非突然变成史诗交响/摇滚。森林是躲猫猫式神秘，小布偶努力扮鬼却像求抱抱，不是恐怖片。

下面每条已重复放入统一风格句，直接复制整条即可。统一提示词只提高音色与编配的一致性，不能保证不同生成曲共享同一条旋律；同BPM/调性也不保证拍点、段落或相位对齐。要真正发展同一主题，先选定满意的原创主旋律，再用平台当时可用且账户允许的音频参考/延展工作流；提示词中的“四音短句”只是目标，不是模型一定遵守的记谱。

## 使用方法

在Suno选择自定义创作，开启Instrumental，把下面英文整段放进Styles/风格输入。标题填ID与中文名，歌词留空；不把场景说明作为歌词。若当前界面提供Exclude Styles，可填：vocals, singing, humming, choir, spoken word, EDM drops, distorted guitars, epic trailer, horror stingers。没有该字段也可以直接用正文里的限制句。

长曲先争取90–150秒可用的稳定段落；模型不保证精确时长。要求loop-friendly只是创作倾向，成品仍需找循环点、裁切并试听接缝。游戏内探索/战斗先采用短交叉淡入淡出，不把独立抽出的两首当作天然同步分轨。森林入口让04沿小径渐入即可，短小径不单独耗一首BGM。鸟声、脚步、丝线与“呜喵”以后走独立音效，避免烙在背景曲里反复播放。

## 曲目清单

| ID | 曲名 | 用途 | 优先级 |
|---|---|---|---|
| 01 | 小白鹅的出门日 | 小院／普通林间散步共用 | 优先 |
| 02 | 水边慢慢走 | 湖边／岸边／休息点 | 优先 |
| 03 | 风把纸页翻过去 | 纸怪山顶的探索／眺望 | 优先 |
| 04 | 很吓人的森林！ | 森林探索／弯折小径逐渐淡入 | 优先 |
| 05 | 灯亮着，线还没收好 | 蜘蛛姐姐小屋／安全对话与手工 | 优先 |
| 06 | 团团们又滚过来了 | 团团怪普通遭遇 | 优先 |
| 07 | 纸页追逐赛 | 纸怪山顶战斗 | 优先 |
| 08 | 毛线球滚到哪里啦 | 森林小蜘蛛战斗 | 优先 |
| 09 | 晚安，小院 | 夜间小院／普通区域共享夜曲 | 优先 |
| 10 | 口袋里的一小段童年 | 较长记忆片段／温柔叙事 | 优先 |
| 11 | 小小的出发站 | 车站／离开当前区域时备用 | 备用 |
| 12 | 小白鹅大冒险 | 标题画面主题，核心场地曲满意后再抽 | 备用 |
| 13 | 大家一起假装很厉害 | 未来团团／纸怪姐姐级战斗候选，Boss玩法未定 | 备用 |
| 14 | 姐姐的毛线小考验 | 未来蜘蛛姐姐战斗候选，玩法未定 | 备用 |
| 15 | 先别急，想一想 | 小游戏／轻量解谜可共用 | 备用 |
| 16 | 回家的时候 | 结尾／阶段结束的较长段落候选 | 备用 |

## 01 · 小白鹅的出门日

用途：小院／普通林间散步共用。

```text
Instrumental cozy storybook adventure game soundtrack. Small acoustic chamber-folk ensemble with a handmade toy-box touch, warm clean timbres, gentle human phrasing, a compact memorable melody, soft dynamics, uncluttered mix. 88 BPM, D major. A sunny little courtyard and a child setting off with a line of tiny black geese. Felt piano carries a short lilting melody, nylon-string guitar answers, light pizzicato bass and a few glockenspiel notes. Affectionate, curious, lightly clumsy, warm morning light, never sugary or sleepy. Gentle walking pulse, low energy. Background game underscore, instrumental only, no singing, humming, choir or spoken voice. Loop-friendly repeating A-B-A phrases, steady texture, no long intro, fade-out or hard final chord. No EDM drop, distorted guitars, cinematic impacts or literal sound effects.
```

## 02 · 水边慢慢走

用途：湖边／岸边／休息点。

```text
Instrumental cozy storybook adventure game soundtrack. Small acoustic chamber-folk ensemble with a handmade toy-box touch, warm clean timbres, gentle human phrasing, a compact memorable melody, soft dynamics, uncluttered mix. 76 BPM, G major. A quiet lakeside path, soft afternoon air and a safe place to pause. Nylon-string guitar and felt piano in a spacious call-and-response, a few breathy woodwind notes and soft pizzicato bass. Calm, clear and gently curious, little ripples suggested musically, no literal water recording. Very light percussion, wide gaps between phrases. Background game underscore, instrumental only, no singing, humming, choir or spoken voice. Loop-friendly repeating A-B-A phrases, steady texture, no long intro, fade-out or hard final chord. No EDM drop, distorted guitars, cinematic impacts or literal sound effects.
```

## 03 · 风把纸页翻过去

用途：纸怪山顶的探索／眺望。

```text
Instrumental cozy storybook adventure game soundtrack. Small acoustic chamber-folk ensemble with a handmade toy-box touch, warm clean timbres, gentle human phrasing, a compact memorable melody, soft dynamics, uncluttered mix. 94 BPM, D major. An airy hilltop above the coast, drifting paper scraps and a wide open view. Light flute over nylon-string guitar arpeggios, felt piano and restrained pizzicato strings. Buoyant, breezy, playful discovery with a hint of wonder. A gently swaying rhythm with plenty of space, no sweeping orchestral climax. Background game underscore, instrumental only, no singing, humming, choir or spoken voice. Loop-friendly repeating A-B-A phrases, steady texture, no long intro, fade-out or hard final chord. No EDM drop, distorted guitars, cinematic impacts or literal sound effects.
```

## 04 · 很吓人的森林！

用途：森林探索／弯折小径逐渐淡入。

```text
Instrumental cozy storybook adventure game soundtrack. Small acoustic chamber-folk ensemble with a handmade toy-box touch, warm clean timbres, gentle human phrasing, a compact memorable melody, soft dynamics, uncluttered mix. 82 BPM, B minor with warm D major glimpses. A sunken woodland clearing below mossy rock banks, dark blue trees, pale lavender cloth ribbons, tiny warm amber night lanterns. Round plush kitten ghosts raise tiny paws and try to say boo, but sound like they want a cuddle. Felt piano, delicate pizzicato strings, rounded wooden marimba and sparse celesta notes. Tiptoeing curiosity, shy mischief, slightly mysterious but safe, cozy and affectionate, low intensity. Tiny playful pauses, no sinister build-up. Background game underscore, instrumental only, no singing, humming, choir or spoken voice. Loop-friendly repeating A-B-A phrases, steady texture, no long intro, fade-out or hard final chord. No EDM drop, distorted guitars, cinematic impacts or literal sound effects.
```

## 05 · 灯亮着，线还没收好

用途：蜘蛛姐姐小屋／安全对话与手工。

```text
Instrumental cozy storybook adventure game soundtrack. Small acoustic chamber-folk ensemble with a handmade toy-box touch, warm clean timbres, gentle human phrasing, a compact memorable melody, soft dynamics, uncluttered mix. 70 BPM, D major. Inside a tiny warm timber cottage at the foot of the forest bank, books, lavender yarn and a gentle older sister quietly making little toys. Intimate felt piano, soft nylon-string guitar and only occasional music-box-like celesta. Tender, handmade, slightly shy humor, comforting amber light. Sparse arrangement and breathing room for dialogue, no beat-heavy groove, no melancholy drama. Background game underscore, instrumental only, no singing, humming, choir or spoken voice. Loop-friendly repeating A-B-A phrases, steady texture, no long intro, fade-out or hard final chord. No EDM drop, distorted guitars, cinematic impacts or literal sound effects.
```

## 06 · 团团们又滚过来了

用途：团团怪普通遭遇。

```text
Instrumental cozy storybook adventure game soundtrack. Small acoustic chamber-folk ensemble with a handmade toy-box touch, warm clean timbres, gentle human phrasing, a compact memorable melody, soft dynamics, uncluttered mix. 120 BPM, D major. A friendly but active skirmish with round soft creatures that charge, miss, tumble and bump each other. Bouncy pizzicato strings, wooden marimba, short felt-piano replies, warm light bass and soft hand percussion. Comically determined, energetic, elastic and mischievous, medium-low intensity. Clear steady rhythmic movement, playful little stumbles in the melody without stopping the beat. No threatening villain music. Background game underscore, instrumental only, no singing, humming, choir or spoken voice. Loop-friendly repeating A-B-A phrases, steady texture, no long intro, fade-out or hard final chord. No EDM drop, distorted guitars, cinematic impacts or literal sound effects.
```

## 07 · 纸页追逐赛

用途：纸怪山顶战斗。

```text
Instrumental cozy storybook adventure game soundtrack. Small acoustic chamber-folk ensemble with a handmade toy-box touch, warm clean timbres, gentle human phrasing, a compact memorable melody, soft dynamics, uncluttered mix. 128 BPM, D major with brief B minor turns. A nimble hilltop chase with drifting paper creatures and little paper airplanes. Quick light flute phrases, nimble pizzicato strings, nylon-string guitar ostinato, warm bass and restrained brushed percussion. Airy, agile, alert and playful, medium intensity. Clear forward pulse and space for game sound effects, no brass fanfares, no epic battle climax. Background game underscore, instrumental only, no singing, humming, choir or spoken voice. Loop-friendly repeating A-B-A phrases, steady texture, no long intro, fade-out or hard final chord. No EDM drop, distorted guitars, cinematic impacts or literal sound effects.
```

## 08 · 毛线球滚到哪里啦

用途：森林小蜘蛛战斗。

```text
Instrumental cozy storybook adventure game soundtrack. Small acoustic chamber-folk ensemble with a handmade toy-box touch, warm clean timbres, gentle human phrasing, a compact memorable melody, soft dynamics, uncluttered mix. 116 BPM, B minor with warm D major answers. A challenging playful skirmish: tiny round spiders wind yarn balls, push them along the ground, make little web rugs and proudly bounce twice. Staccato pizzicato strings, rounded wooden marimba, felt-piano fragments, warm soft bass and dry tiny hand-percussion ticks. Threadlike interlocking rhythms, tiptoe syncopation, cute determination and harmless pretend-spooky charm. Medium intensity, alert and readable, never predatory or genuinely frightening. No rushing horror strings. Background game underscore, instrumental only, no singing, humming, choir or spoken voice. Loop-friendly repeating A-B-A phrases, steady texture, no long intro, fade-out or hard final chord. No EDM drop, distorted guitars, cinematic impacts or literal sound effects.
```

## 09 · 晚安，小院

用途：夜间小院／普通区域共享夜曲。

```text
Instrumental cozy storybook adventure game soundtrack. Small acoustic chamber-folk ensemble with a handmade toy-box touch, warm clean timbres, gentle human phrasing, a compact memorable melody, soft dynamics, uncluttered mix. 66 BPM, D major. The same childlike countryside world at bedtime, a safe courtyard with a few warm windows, quiet paths and tiny geese settling down. Felt piano and very sparse celesta with a gentle nylon-string guitar response. Hushed, intimate, content and a little dreamy, almost no percussion, no sadness or cinematic sentimentality. Keep long rests and a small warm melody. Background game underscore, instrumental only, no singing, humming, choir or spoken voice. Loop-friendly repeating A-B-A phrases, steady texture, no long intro, fade-out or hard final chord. No EDM drop, distorted guitars, cinematic impacts or literal sound effects.
```

## 10 · 口袋里的一小段童年

用途：较长记忆片段／温柔叙事。

```text
Instrumental cozy storybook adventure game soundtrack. Small acoustic chamber-folk ensemble with a handmade toy-box touch, warm clean timbres, gentle human phrasing, a compact memorable melody, soft dynamics, uncluttered mix. 74 BPM, D major with soft B minor color. A small childhood memory found in an ordinary object, warm and slightly bittersweet but reassuring. Intimate felt piano, nylon-string guitar and a very soft sustained woodwind line. Honest, restrained, fragile wonder, room for spoken dialogue. A simple memorable phrase returns gently, no emotional swell, no grand finale, no sad trailer music. Background game underscore, instrumental only, no singing, humming, choir or spoken voice. Loop-friendly repeating A-B-A phrases, steady texture, no long intro, fade-out or hard final chord. No EDM drop, distorted guitars, cinematic impacts or literal sound effects.
```

## 11 · 小小的出发站

用途：车站／离开当前区域时备用。备用，先不必消耗额度。

```text
Instrumental cozy storybook adventure game soundtrack. Small acoustic chamber-folk ensemble with a handmade toy-box touch, warm clean timbres, gentle human phrasing, a compact memorable melody, soft dynamics, uncluttered mix. 92 BPM, G major. A tiny countryside station and the happy anticipation of going somewhere new with a friend. Nylon-string guitar, felt piano, light pizzicato strings and small rounded marimba. Patient forward motion, gentle curiosity and soft excitement, low intensity, no literal train noises, no dramatic farewell. Background game underscore, instrumental only, no singing, humming, choir or spoken voice. Loop-friendly repeating A-B-A phrases, steady texture, no long intro, fade-out or hard final chord. No EDM drop, distorted guitars, cinematic impacts or literal sound effects.
```

## 12 · 小白鹅大冒险

用途：标题画面主题，核心场地曲满意后再抽。备用，先不必消耗额度。

```text
Instrumental cozy storybook adventure game soundtrack. Small acoustic chamber-folk ensemble with a handmade toy-box touch, warm clean timbres, gentle human phrasing, a compact memorable melody, soft dynamics, uncluttered mix. 86 BPM, D major. The opening page of a handmade childhood storybook: a white-haired child, tiny black geese, a warm courtyard and an adventure just beyond the path. Felt piano leads a clear short four-note phrase, answered by nylon-string guitar, delicate woodwinds, pizzicato strings and sparse glockenspiel. Warm, curious, quietly memorable, optimistic and slightly clumsy. Restrained chamber ensemble, low-to-medium energy, no cinematic crescendo. Background game underscore, instrumental only, no singing, humming, choir or spoken voice. Loop-friendly repeating A-B-A phrases, steady texture, no long intro, fade-out or hard final chord. No EDM drop, distorted guitars, cinematic impacts or literal sound effects.
```

## 13 · 大家一起假装很厉害

用途：未来团团／纸怪姐姐级战斗候选，Boss玩法未定。备用，先不必消耗额度。

```text
Instrumental cozy storybook adventure game soundtrack. Small acoustic chamber-folk ensemble with a handmade toy-box touch, warm clean timbres, gentle human phrasing, a compact memorable melody, soft dynamics, uncluttered mix. 136 BPM, D major with brief B minor tension. A bigger friendly storybook challenge, round creatures trying very hard to look impressive. Nimble pizzicato ensemble, wooden marimba, warm felt-piano accents, soft bass and tidy hand percussion. Confident playful determination, clear phrases and rhythmic breathing room. Medium-high energy within a small chamber ensemble, no menace, no bombast, no pounding war drums. Background game underscore, instrumental only, no singing, humming, choir or spoken voice. Loop-friendly repeating A-B-A phrases, steady texture, no long intro, fade-out or hard final chord. No EDM drop, distorted guitars, cinematic impacts or literal sound effects.
```

## 14 · 姐姐的毛线小考验

用途：未来蜘蛛姐姐战斗候选，玩法未定。备用，先不必消耗额度。

```text
Instrumental cozy storybook adventure game soundtrack. Small acoustic chamber-folk ensemble with a handmade toy-box touch, warm clean timbres, gentle human phrasing, a compact memorable melody, soft dynamics, uncluttered mix. 126 BPM, B minor with comforting D major responses. A clever older sister turns a cozy pretend-haunted woodland into a playful yarn obstacle course. Interwoven pizzicato patterns, rounded marimba, celesta sparkles, felt piano and soft dry percussion. Clever, cheeky, affectionate and a little more intricate than a small skirmish, medium-high energy. Clear rhythmic landmarks for dodging, no genuine threat, no horror chase, no aggressive orchestra. Background game underscore, instrumental only, no singing, humming, choir or spoken voice. Loop-friendly repeating A-B-A phrases, steady texture, no long intro, fade-out or hard final chord. No EDM drop, distorted guitars, cinematic impacts or literal sound effects.
```

## 15 · 先别急，想一想

用途：小游戏／轻量解谜可共用。备用，先不必消耗额度。

```text
Instrumental cozy storybook adventure game soundtrack. Small acoustic chamber-folk ensemble with a handmade toy-box touch, warm clean timbres, gentle human phrasing, a compact memorable melody, soft dynamics, uncluttered mix. 102 BPM, G major. A small friendly cooperative puzzle played by children, taking turns, trying an idea and giggling when it almost works. Repeating wooden marimba figures, light pizzicato strings, felt piano and soft dry taps. Curious, patient, gently clever, low-to-medium energy. Steady looping rhythm, no ticking countdown, no suspense spike. Background game underscore, instrumental only, no singing, humming, choir or spoken voice. Loop-friendly repeating A-B-A phrases, steady texture, no long intro, fade-out or hard final chord. No EDM drop, distorted guitars, cinematic impacts or literal sound effects.
```

## 16 · 回家的时候

用途：结尾／阶段结束的较长段落候选。备用，先不必消耗额度。

```text
Instrumental cozy storybook adventure game soundtrack. Small acoustic chamber-folk ensemble with a handmade toy-box touch, warm clean timbres, gentle human phrasing, a compact memorable melody, soft dynamics, uncluttered mix. 72 BPM, D major. Returning to the little courtyard after a childhood adventure, slightly tired, quietly happy, with friends close by. Warm felt piano and nylon-string guitar, soft woodwind replies and very sparse celesta. Gratitude, closeness and gentle nostalgia, simple and intimate. Small chamber arrangement, no crying strings or triumphal fanfare. Background game underscore, instrumental only, no singing, humming, choir or spoken voice. Loop-friendly repeating A-B-A phrases, steady texture, no long intro, fade-out or hard final chord. No EDM drop, distorted guitars, cinematic impacts or literal sound effects.
```

## 短提示音（后期备用）

普通歌曲生成不一定遵守3–7秒；如果你的账户当前有Sounds/One Shot入口，可按短音频生成，仍需试听长度。胜利/失败提示很短，也可后续用乐器音源手工做，现阶段优先抽长曲。

### S01 · 发现记忆碎片

```text
Instrumental short game cue, 5-7 seconds, D major. Cozy handmade storybook chamber-folk palette, warm clean timbres. A tiny discovery cue, warm felt piano and three delicate celesta notes, a curious upward question resolving into a soft hopeful answer. No vocals, humming, choir, speech, big brass, cinematic impacts or noise. Brief musical gesture with a clean gentle ending, not a full song.
```

### S02 · 普通遭遇结束

```text
Instrumental short game cue, 3-5 seconds, D major. Cozy handmade storybook chamber-folk palette, warm clean timbres. A small friendly success cue, bouncy pizzicato and rounded marimba answered by one warm piano chord, a relieved little smile, not a victory parade. No vocals, humming, choir, speech, big brass, cinematic impacts or noise. Brief musical gesture with a clean gentle ending, not a full song.
```

### S03 · 扑通，休息一下

```text
Instrumental short game cue, 3-5 seconds, D major. Cozy handmade storybook chamber-folk palette, warm clean timbres. A gentle unsuccessful-attempt cue, two softly descending felt-piano notes and a playful wooden marimba reply, reassuring and a little sheepish, no tragedy or mocking failure sound. No vocals, humming, choir, speech, big brass, cinematic impacts or noise. Brief musical gesture with a clean gentle ending, not a full song.
```

### S04 · 新的路可以走了

```text
Instrumental short game cue, 5-7 seconds, D major. Cozy handmade storybook chamber-folk palette, warm clean timbres. A tiny path-unlocked cue, a lilting nylon-string guitar phrase and celesta answering upwards, warm curious anticipation and understated delight. No vocals, humming, choir, speech, big brass, cinematic impacts or noise. Brief musical gesture with a clean gentle ending, not a full song.
```

## 挑选和交付

先听是否太吵/太恐怖/太像流行歌曲，再听20–40秒后是否仍适合走路、战斗和读对话，最后才挑最抓耳的旋律。保留干净、能长期听的版本。候选命名如04_forest_explore_v01，记录链接、生成模型、日期、设置、是否可下载及所用授权。先分享Suno播放链接比较，不急于下载每个候选。选定后再导入音频、做循环点和音量匹配，目前没有自动监控或替用户在Suno生成。

## 官方使用信息（查阅于2026-10-26）

- [Instrumental生成说明](https://suno.com/tools/instrumental-generator)：描述风格、情绪、乐器、速度或场景，并开启Instrumental。
- [Custom创作说明](https://help.suno.com/en/articles/3726721)：Custom模式可输入Styles和标题并切换Instrumental。
- [Sounds短音频与循环](https://help.suno.com/en/articles/10625537)：One Shot/Loop是样本工作流，不应当等同于整首BGM自动无缝。
- [最新下载说明](https://help.suno.com/en/articles/13876865)与[套餐权益](https://help.suno.com/en/articles/9601665)：免费试用下载不带商用许可，付费订阅期间下载的音乐按该页说明获得商用权益。免费试用下载次数与账户注册时间有关；不要把每日创作额度等同于每日无限下载。
- [免费计划权益](https://help.suno.com/en/articles/9601601)：免费生成用于个人非商业用途。用免费额度抽风格、保留链接比较很合适；正式商用发行时应核对当时账户生成/下载条款。旧FAQ与2026下载政策表述有差异，不在此承诺之后付费自动覆盖既往免费曲目。

