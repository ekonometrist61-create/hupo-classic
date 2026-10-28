#!/usr/bin/env python3
"""24+1 SKILL.md ve kullanıcı kaynak manifest kontrolü."""
import json,hashlib,sys
from pathlib import Path
R=Path(__file__).resolve().parents[1]
names=[f'hupo-s{g}-{k}' for g in range(1,9) for k in ('hikaye','soru','sozcuk')]+['hupo-egitim-uzmani']
issues=[]
for n in names:
    f=R/'.claude'/'skills'/n/'SKILL.md'
    if not f.is_file():issues.append('SKILL missing '+n)
    elif not f.read_text().startswith('---\nname: '+n+'\n'):issues.append('YAML frontmatter missing '+n)
manifest=json.loads((R/'data'/'user_sources_manifest.json').read_text())
for x in manifest['files']:
    p=R/'references'/'onceki_hupo_calismalari'/x['name']
    if not p.is_file() or hashlib.sha256(p.read_bytes()).hexdigest()!=x['sha256']:issues.append('reference integrity: '+x['name'])
r=json.loads((R/'data'/'grade_profiles.json').read_text());issues+=[] if len(r['grades'])==8 else ['8 grade profiles missing']
with (R/'references'/'onceki_hupo_calismalari'/'Kavram_Envanteri_241_Aday.csv').open(encoding='utf-8-sig') as f:
    import csv
    count=sum(1 for _ in csv.DictReader(f))
if count!=241:issues.append(f'241 expected, got {count}')
print(json.dumps({'skills':len(names),'grades':8,'word_candidates':count,'source_files':len(manifest['files']),'errors':issues,'passed':not issues},ensure_ascii=False,indent=2))
sys.exit(1 if issues else 0)
