-- GÖR-046 düzeltmesi (K-0024, E-7): veli özeti veri paylaşım onayını sunucuda uygular.
-- Eski gövde kelime_veli_ozeti_ham adıyla korunur. İstemcinin çağırdığı ad ve mevcut
-- dönüş alanları aynıdır; tek eklenen alan 'riza' ('verildi' | 'geri_cekildi' | 'yok').
-- Kapsam dışı (ayrı migration): export_my_data'nın Kelime tablolarını kapsaması.

alter function public.kelime_veli_ozeti(uuid) rename to kelime_veli_ozeti_ham;
revoke all on function public.kelime_veli_ozeti_ham(uuid) from public, anon, authenticated;

create or replace function public.kelime_veli_ozeti(p_cocuk_id uuid)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_riza text;
begin
  -- Yetki: yalnızca bağlı veli. Rıza yoksa özet hesaplanmaz.
  if (select auth.uid()) is null or not public.is_parent_of(p_cocuk_id) then
    raise exception 'FORBIDDEN' using errcode = '42501';
  end if;

  v_riza := public._veli_riza_durumu(p_cocuk_id);

  if v_riza is distinct from 'verildi' then
    -- İstemcinin beklediği alanlar null olarak döner.
    return jsonb_build_object(
      'riza', v_riza,
      'deneme_sayisi', null,
      'dogru_orani', null,
      'ipucusuz_dogru_orani', null,
      'ipucu_kullanim_orani', null,
      'tekrar_bekleyen', null,
      'son_7_gun_deneme', null,
      'zorlanilan', '[]'::jsonb,
      'oneriler', '[]'::jsonb
    );
  end if;

  return public.kelime_veli_ozeti_ham(p_cocuk_id) || jsonb_build_object('riza', v_riza);
end;
$$;

revoke all on function public.kelime_veli_ozeti(uuid) from public, anon;
grant execute on function public.kelime_veli_ozeti(uuid) to authenticated;
