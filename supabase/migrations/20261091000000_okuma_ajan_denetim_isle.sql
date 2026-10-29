-- =====================================================================
-- Okuma Dünyası: Ajan A/B denetim sonuçlarını veritabanına işle (kullanıcı onayı 2026-10-25).
-- Kaynak: docs/okuma-entegrasyon/denetim/2026-10-23/OZET.md (45 hikâye, 90 rapor).
-- Yalnız taslak/incelemedeki sürümlerin ajan_a ve ajan_b alanı yazılır; "insan" kararına dokunulmaz.
-- Yayındaki ve arşivdeki sürümler değişmez. Hiçbir hikâye için eşleşen sürüm yoksa işlem hata verip durur.
-- =====================================================================

do $ajan_yaz$
declare
  r record;
  v_n integer;
  v_toplam integer := 0;
begin
  for r in
    select * from (values
    ('hr001-', 'review_needed', 'review_needed'),
    ('hr002-', 'review_needed', 'review_needed'),
    ('hr003-', 'review_needed', 'review_needed'),
    ('hr004-', 'review_needed', 'review_needed'),
    ('hr005-', 'review_needed', 'review_needed'),
    ('hr006-', 'review_needed', 'review_needed'),
    ('hr007-', 'review_needed', 'review_needed'),
    ('hr008-', 'review_needed', 'review_needed'),
    ('hr009-', 'pass', 'review_needed'),
    ('hr010-', 'review_needed', 'review_needed'),
    ('hr012-', 'pass', 'review_needed'),
    ('hr013-', 'review_needed', 'review_needed'),
    ('hr014-', 'pass', 'review_needed'),
    ('hr015-', 'pass', 'review_needed'),
    ('hr016-', 'review_needed', 'review_needed'),
    ('hr017-', 'fail', 'fail'),
    ('hr018-', 'pass', 'review_needed'),
    ('hr019-', 'pass', 'review_needed'),
    ('hr021-', 'review_needed', 'review_needed'),
    ('hr022-', 'pass', 'review_needed'),
    ('hr023-', 'pass', 'review_needed'),
    ('hr024-', 'pass', 'review_needed'),
    ('hr025-', 'pass', 'review_needed'),
    ('hr026-', 'pass', 'review_needed'),
    ('hr027-', 'pass', 'review_needed'),
    ('hr028-', 'review_needed', 'review_needed'),
    ('hr029-', 'pass', 'review_needed'),
    ('hr030-', 'review_needed', 'review_needed'),
    ('hr031-', 'review_needed', 'review_needed'),
    ('hr032-', 'pass', 'review_needed'),
    ('hr033-', 'review_needed', 'review_needed'),
    ('hr034-', 'review_needed', 'review_needed'),
    ('hr035-', 'review_needed', 'review_needed'),
    ('hr036-', 'pass', 'review_needed'),
    ('hr037-', 'pass', 'review_needed'),
    ('hr038-', 'review_needed', 'review_needed'),
    ('hr039-', 'review_needed', 'review_needed'),
    ('hr040-', 'review_needed', 'review_needed'),
    ('hr041-', 'review_needed', 'review_needed'),
    ('hr042-', 'review_needed', 'review_needed'),
    ('hr043-', 'review_needed', 'review_needed'),
    ('hr044-', 'review_needed', 'review_needed'),
    ('hr045-', 'review_needed', 'review_needed'),
    ('hr046-', 'review_needed', 'review_needed'),
    ('hr047-', 'review_needed', 'review_needed')
    ) as t(onek, a, b)
  loop
    update public.okuma_hikaye_surumleri s
       set denetim = coalesce(s.denetim, '{}'::jsonb) || jsonb_build_object('ajan_a', r.a, 'ajan_b', r.b)
      from public.okuma_hikayeleri h
     where h.id = s.hikaye_id
       and h.slug like r.onek || '%'
       and s.durum in ('taslak', 'incelemede');
    get diagnostics v_n = row_count;
    if v_n = 0 then
      raise exception 'TASLAK_SURUM_YOK: %', r.onek using errcode = '22023';
    end if;
    v_toplam := v_toplam + v_n;
  end loop;

  perform public.log_admin_action('okuma_ajan_denetim_isleme', jsonb_build_object(
    'not', 'Kullanıcı onayı 2026-10-25: 2026-10-23 Ajan A/B denetim sonuçları taslak sürümlere yazıldı; insan kararı değişmedi.',
    'surum_sayisi', v_toplam));
end
$ajan_yaz$;