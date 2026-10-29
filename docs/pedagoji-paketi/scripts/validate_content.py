#!/usr/bin/env python3
"""Hupo teknik içerik denetimi; resmî MEB ve uzman onayı yerine geçmez."""
import argparse, json, re, sys
from pathlib import Path
BANDS = {1:(250,300),2:(300,350),3:(350,400),4:(450,500),5:(2000,3000),6:(3000,3500),7:(3500,4000),8:(4000,5000)}
CURR={1:'TYMM',2:'TYMM',3:'TYMM',4:'GECIS_ONCEKI_PROGRAM',5:'TYMM',6:'TYMM',7:'TYMM',8:'GECIS_ONCEKI_PROGRAM'}

def count_words(txt):
    # Basit boşluk/token sayımı; tireli ve dilsel tokenizasyon için insan kontrolü gerekir.
    return len(re.findall(r"\b[^\W_]+(?:['’\-][^\W_]+)*\b",txt,flags=re.UNICODE))

def validate(obj,mode):
    e=[];w=[]
    g=obj.get('grade')
    if g not in BANDS:return ['grade 1..8 tamsayı olmalı'],[]
    year=obj.get('school_year')
    if not year:e.append('school_year zorunlu')
    if year=='2026-2027' and obj.get('curriculum_version') and obj['curriculum_version']!=CURR[g]: e.append(f'{g}. sınıf 2026–27 müfredatı {CURR[g]} olmalı')
    if obj.get('source_trace_status')=='official_outcome_verified' and not (obj.get('outcome_code') and obj.get('source_url')):e.append('official_outcome_verified kanıt/kod olmadan kullanılamaz')
    if obj.get('published') and not (obj.get('rights_cleared') and obj.get('curriculum_verified') and obj.get('editor_approved')):e.append('published için üç onay gerekli')
    if mode=='story':
        story=obj.get('complete_story')
        if not story:e.append('Tam hikâye gövdesi eksik');return e,w
        n=count_words(story)
        lo,hi=BANDS[g]
        if not lo<=n<=hi:e.append(f'Tam hikâye kelimesi {n}, Hupo hedefi {lo}-{hi} dışında')
        for k in ['hero_choice','genre','value_priority','comprehension_items','target_exposures']:
            if not obj.get(k): w.append(f'{k}: gözden geçir')
    elif mode=='question':
        if not obj.get('stem'): e.append('soru kökü eksik')
        options=obj.get('options') or []
        if options:
            keys=[x.get('key') for x in options]
            if len(options)<2 or len(set(keys))!=len(keys):e.append('seçenek anahtarları benzersiz ve >=2 olmalı')
            if obj.get('key') not in keys:e.append('cevap anahtarı seçeneklerde yok')
            if len({x.get('text','').strip().casefold() for x in options})!=len(options):e.append('aynı seçenek tekrarı')
        else:
            if not obj.get('scoring_rubric'):e.append('seçeneksiz açık uçlu soruda rubrik zorunlu')
        if not obj.get('reasoning'):e.append('çözüm gerekçesi eksik')
        if obj.get('assessment_mode') in ('school_written','oyss_style') and not obj.get('scenario_id'):w.append('Senaryo yok: resmî senaryo uyum iddiası yapılamaz')
        if obj.get('empirical_p_value') is None:w.append('gerçek öğrenci verisi yok; güçlük tahminidir')
    elif mode=='word':
        for k in ('lemma','sense_id','context','meaning_child_friendly'):
            if not obj.get(k):e.append(f'{k} zorunlu')
        if obj.get('mastery_observed') and not obj.get('learner_evidence'):e.append('gözlenen öğrenme kanıtı yok')
    else:e.append('mode story|question|word olmalı')
    return e,w

def main():
    ap=argparse.ArgumentParser();ap.add_argument('--file',required=True);ap.add_argument('--mode',choices=['story','question','word'],required=True);a=ap.parse_args()
    obj=json.loads(Path(a.file).read_text(encoding='utf-8'))
    errs,warns=validate(obj,a.mode)
    print(json.dumps({'file':a.file,'mode':a.mode,'passed_technical_validation':not errs,'errors':errs,'warnings':warns,'human_review_still_required':True},ensure_ascii=False,indent=2))
    sys.exit(1 if errs else 0)
if __name__=='__main__':main()
