"""Summarize native paper-castle benchmarks; no gameplay or user files are changed."""
import csv,json,shutil
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
p=ROOT/'docs/dps339-results.json'
d=json.loads(p.read_text(encoding='utf-8-sig'))
assert d['complete'] and not d['failures'] and len(d['samples'])==26
# The first run exported the existing cumulative activation counter. Keep its
# raw evidence and convert to per-sample deltas, matching subsequent harness runs.
if not d['conditions'].get('q_counts_per_sample',False):
    shutil.copyfile(p,p.with_name('dps339-results.raw.json'))
    previous=0
    for r in d['samples']:
        cumulative=r['q_activations']
        r['q_activations_total_counter']=cumulative
        r['q_activations']=cumulative-previous
        assert r['q_activations']>=0
        previous=cumulative
    d['conditions']['q_counts_per_sample']=True
    d['normalization']='First-run cumulative Q counters converted to successive per-sample deltas; raw JSON preserved.'
    p.write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
for r in d['samples']:
    assert r['damage']>=0 and abs(r['dps']*r['seconds']-r['damage'])<1e-5
    assert abs(sum(r['sources'].values())-r['damage'])<1e-5
    assert (r['q_activations']>0)==r['q_enabled']
keys=['build','slots','distance','seed','seconds','damage','dps','post4_dps','time_to_144','charged_releases','charge_policy','q_enabled','q_activations','planes_launched','hits','wall_seconds']
with p.with_suffix('.csv').open('w',encoding='utf-8-sig',newline='') as f:
    w=csv.DictWriter(f,fieldnames=keys);w.writeheader()
    for r in d['samples']:w.writerow({k:r[k] for k in keys})
# The repeated seed is an independent run of identical conditions.
for r in [r for r in d['samples'] if r['seed']==33902]:
    ref=next(x for x in d['samples'] if x['build']==r['build'] and x['distance']==r['distance'] and x['seed']==33901 and x['seconds']<21)
    assert abs(ref['dps']-r['dps'])<.001
print('Validated 26 rows, source totals, Q windows and 3 repeated-seed comparisons.')
for r in d['samples']:
    if r['seed']==33901 and r['distance']==6:
        print(r['build'],r['slots'],round(r['seconds'],2),round(r['dps'],3),'Q=',r['q_activations'])
