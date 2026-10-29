-- =====================================================================
-- Kelime Evreni — yönetim paneli: inceleme kuyruğu ve toplu yayın (20261095'in devamı)
--   * kelime_inceleme_kuyrugu: incelemedeki soruları cevap anahtarı, açıklama ve model denetimleriyle listeler.
--   * kelime_toplu_yayinla: seçilen soruları yayına alır. Kuru çalıştırma (varsayılan) yalnız kapıyı sınar.
--     Her soru kelime_soru_durum_degistir üzerinden geçer: iki farklı aileden "pass" ve onaylı ilişki
--     kuralı tek yerde (orada) uygulanır. İnsan kontrolü = yöneticinin bu RPC'yi bilerek çağırması.
-- Ek-only. Ön koşul: 20261095000000.
-- =====================================================================

set client_encoding = 'UTF8';

create or replace function public.kelime_inceleme_kuyrugu(
  p_sinif smallint default null,
  p_tur   text default null,
  p_limit integer default 100
)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_limit  integer := least(greatest(coalesce(p_limit, 100), 1), 300);
  v_toplam integer;
  v_satir  jsonb;
begin
  perform public.kelime_yonetici_kontrol();

  select count(*) into v_toplam
    from public.kelime_sorulari s
   where s.durum = 'incelemede'
     and (p_sinif is null or s.sinif = p_sinif)
     and (p_tur is null or s.iliski_turu = p_tur);

  select coalesce(jsonb_agg(x.satir order by x.sinif, x.iliski_turu, x.updated_at), '[]'::jsonb)
    into v_satir
    from (
      select s.sinif, s.iliski_turu, s.updated_at,
             jsonb_build_object(
               'id', s.id,
               'kelime', a.kelime,
               'anlam', a.anlam,
               'iliski_turu', s.iliski_turu,
               'sinif', s.sinif,
               'zorluk', s.zorluk,
               'kazanim_kodu', s.kazanim_kodu,
               'kanit_duzeyi', s.kanit_duzeyi,
               'soru_metni', s.soru_metni,
               'secenekler', s.secenekler,
               'dogru_indeks', s.dogru_indeks,
               'ipucu', s.ipucu,
               'aciklama', s.aciklama,
               'kapi', public._kelime_iki_model_gecti('soru', s.id::text, s.updated_at),
               'denetimler', coalesce((
                 select jsonb_agg(jsonb_build_object(
                          'model', d.denetci_model, 'aile', d.denetci_aile, 'karar', d.karar,
                          'not', d.not_metni, 'tarih', d.created_at) order by d.denetci_model)
                   from (
                     select distinct on (k.denetci_model) k.*
                       from public.kelime_denetim_kayitlari k
                      where k.hedef_tur = 'soru' and k.hedef_id = s.id::text and k.created_at >= s.updated_at
                      order by k.denetci_model, k.created_at desc, (k.karar = 'pass')
                   ) d), '[]'::jsonb)
             ) as satir
        from public.kelime_sorulari s
        join public.kelime_anlamlari a on a.id = s.anlam_id
       where s.durum = 'incelemede'
         and (p_sinif is null or s.sinif = p_sinif)
         and (p_tur is null or s.iliski_turu = p_tur)
       order by s.sinif, s.iliski_turu, s.updated_at
       limit v_limit
    ) x;

  return jsonb_build_object('toplam', v_toplam, 'satirlar', v_satir);
end;
$$;
revoke all on function public.kelime_inceleme_kuyrugu(smallint, text, integer) from public, anon;
grant execute on function public.kelime_inceleme_kuyrugu(smallint, text, integer) to authenticated;

create or replace function public.kelime_toplu_yayinla(
  p_ids  uuid[],
  p_kuru boolean default true
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_id        uuid;
  v_s         public.kelime_sorulari%rowtype;
  v_yayin     integer := 0;
  v_atlanan   jsonb := '[]'::jsonb;
  v_hata      text;
begin
  perform public.kelime_yonetici_kontrol();

  if p_ids is null or coalesce(array_length(p_ids, 1), 0) not between 1 and 200 then
    raise exception 'BAD_LISTE' using errcode = '22023';
  end if;

  foreach v_id in array p_ids loop
    select * into v_s from public.kelime_sorulari where id = v_id;
    if not found then
      v_atlanan := v_atlanan || jsonb_build_object('id', v_id, 'neden', 'yok');
    elsif v_s.durum <> 'incelemede' then
      v_atlanan := v_atlanan || jsonb_build_object('id', v_id, 'neden', 'durum');
    elsif p_kuru then
      if public._kelime_iki_model_gecti('soru', v_id::text, v_s.updated_at)
         and (v_s.dogru_anlam_id is null
              or public.kelime_iliski_onayli_mi(v_s.anlam_id, v_s.dogru_anlam_id, v_s.iliski_turu)) then
        v_yayin := v_yayin + 1;
      else
        v_atlanan := v_atlanan || jsonb_build_object('id', v_id, 'neden', 'denetim_eksik');
      end if;
    else
      begin
        perform public.kelime_soru_durum_degistir(v_id, 'yayinda');
        v_yayin := v_yayin + 1;
      exception when others then
        get stacked diagnostics v_hata = message_text;
        v_atlanan := v_atlanan || jsonb_build_object('id', v_id, 'neden', v_hata);
      end;
    end if;
  end loop;

  if not p_kuru then
    perform public.log_admin_action('kelime_toplu_yayinla', jsonb_build_object(
      'istenen', array_length(p_ids, 1), 'yayinlanan', v_yayin));
  end if;
  return jsonb_build_object('kuru', p_kuru, 'yayinlanan', v_yayin, 'atlanan', v_atlanan);
end;
$$;
revoke all on function public.kelime_toplu_yayinla(uuid[], boolean) from public, anon;
grant execute on function public.kelime_toplu_yayinla(uuid[], boolean) to authenticated;
