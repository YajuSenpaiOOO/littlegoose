"""Original additive/noise synthesis. No recordings, samples or borrowed melodies."""
from pathlib import Path
import math, random, struct, wave, json
ROOT = Path(__file__).resolve().parents[1] / 'assets' / 'transform_audio287'
SR = 44100
ROOT.mkdir(parents=True, exist_ok=True)
rng = random.Random(287031)
def envelope(t, length, attack=.008, release=.10):
    return min(1., t/attack) * min(1., (length-t)/release)
def render(name, length, voice):
    samples = [voice(i/SR) for i in range(round(length*SR))]
    peak = max(map(abs, samples))
    gain = min(1., .65/max(peak, 1e-9))
    samples = [x*gain for x in samples]
    with wave.open(str(ROOT/(name+'.wav')), 'wb') as f:
        f.setparams((1, 2, SR, 0, 'NONE', 'not compressed'))
        f.writeframes(b''.join(struct.pack('<h', round(x*32767)) for x in samples))
    return {'seconds':length,'rate':SR,'peak':max(map(abs,samples)),
            'rms':math.sqrt(sum(x*x for x in samples)/len(samples)),
            'first':samples[0],'last':samples[-1],'clipped':False}
tau = math.tau
stats = {}
stats['switch'] = render('switch', .10, lambda t:
    envelope(t,.10,.001,.06)*math.exp(-t*55)*(.22*math.sin(tau*780*t)+.12*rng.uniform(-1,1)))
stats['burst'] = render('burst', .55, lambda t:
    envelope(t,.55,.005,.20)*(.18*math.sin(tau*(360*t+1050*t*t))*math.exp(-t*4)
    +.21*math.sin(tau*(76*t-18*t*t))*math.exp(-t*8)+.065*rng.uniform(-1,1)*math.exp(-t*5)))
def bloom(t):
    total=0.
    for freq, onset, amplitude in [(523.251,0.,.12),(659.255,.075,.09),(783.991,.16,.085),(1174.659,.245,.035)]:
        u=t-onset
        if u<0:continue
        total += amplitude*(1-math.exp(-u*65))*math.exp(-u*2.6)*(
            math.sin(tau*freq*u)+.28*math.sin(tau*freq*2.003*u)+.08*math.sin(tau*freq*3.99*u))
    return total*min(1.,(1.85-t)/.25)
stats['bloom']=render('bloom',1.85,bloom)
stats['hum']=render('hum',1.5,lambda t:
    envelope(t,1.5,.025,.025)*(.035*math.sin(tau*110*t)+.014*math.sin(tau*220*t)+.009*math.sin(tau*440*t))*(.9+.1*math.cos(tau*t/1.5)))
stats['pulse']=render('pulse',.18,lambda t:
    envelope(t,.18,.008,.10)*math.exp(-t*11)*(.17*math.sin(tau*(690*t-185*t*t))+.045*math.sin(tau*1035*t)))
stats['outro']=render('outro',.65,lambda t:
    envelope(t,.65,.012,.30)*math.exp(-t*4)*(.13*math.sin(tau*(880*t-510*t*t))+.055*math.sin(tau*1320*t)+.018*rng.uniform(-1,1)))
(ROOT/'manifest.json').write_text(json.dumps({'synthesis':'original deterministic additive/chirp/noise; seed287031','files':stats},indent=2),encoding='utf-8')
print(json.dumps(stats))
