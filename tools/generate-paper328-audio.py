"""Original cartoon paper impacts: short paper snap, descending bass and folded-paper tail."""
from pathlib import Path
import math, random, struct, wave, json
root=Path(__file__).resolve().parents[1]/'assets'/'paper_stage328'
root.mkdir(parents=True,exist_ok=True)
rate=44100
report={}
for name,duration,low in [('mortar',.40,92.),('meteor',.62,68.)]:
 rng=random.Random(328+(name=='meteor'))
 smooth=0.
 data=[]
 for n in range(round(rate*duration)):
  t=n/rate
  noise=rng.uniform(-1,1)
  smooth=smooth*.92+noise*.08
  attack=min(1.,t/.003)
  tail=min(1.,(duration-t)/.07)
  bass=math.sin(math.tau*(low*t+low*.23*(1-math.exp(-t*22))/22))*math.exp(-t*8)
  snap=(noise-smooth)*math.exp(-t*65)
  crumple=(noise*.25+smooth*2)*math.exp(-t*10)*(0.65+0.35*math.sin(t*180)**2)
  data.append(attack*tail*(.58*bass+.18*snap+.22*crumple))
 peak=max(map(abs,data))
 data=[v*.78/max(.78,peak) for v in data]
 with wave.open(str(root/(name+'.wav')),'wb') as f:
  f.setparams((1,2,rate,0,'NONE','not compressed'))
  f.writeframes(b''.join(struct.pack('<h',round(v*32767)) for v in data))
 report[name]={'seconds':duration,'rate':rate,'peak':max(map(abs,data)),'rms':math.sqrt(sum(v*v for v in data)/len(data))}
(root/'manifest.json').write_text(json.dumps({'source':'original deterministic synthesis; no samples or speech','files':report},indent=2),encoding='utf-8')
print(report)
