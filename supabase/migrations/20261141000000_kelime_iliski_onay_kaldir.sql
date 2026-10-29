-- Kelime Evreni: sözcük ilişkilerinde toplu "onayı kaldır" (yayından al).
-- Onaylama kuralı değişmedi (kelime_iliski_onayla: iki model ailesi "pass" + dört göz).
-- Yalnızca yönetici; en çok 200 kayıt; durumu uymayan kayıt atlanır, işlem durmaz.
-- Onay kalkınca ilişki yeni sorularda ve oyunda kullanılmaz (kelime_iliski_onayli_mi false döner).

create or replace function public.kelime_iliski_onay_kaldir(p_ids uuid[])
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_id       uuid;
  v_row      public.kelime_iliskileri%rowtype;
  v_kaldirilan integer := 0;
  v_atlanan  jsonb := '[]'::jsonb;
begin
  perform public.kelime_yonetici_kontrol();

  if p_ids is null or coalesce(array_length(p_ids, 1), 0) not between 1 and 200 then
    raise exception 'BAD_LISTE' using errcode = '22023';
  end if;

  foreach v_id in array p_ids loop
    select * into v_row from public.kelime_iliskileri where id = v_id for update;
    if not found then
      v_atlanan := v_atlanan || jsonb_build_object('id', v_id, 'neden', 'yok');
    elsif v_row.onay_tarihi is null then
      v_atlanan := v_atlanan || jsonb_build_object('id', v_id, 'neden', 'durum');
    else
      update public.kelime_iliskileri
         set onaylayan_id = null, onay_tarihi = null
       where id = v_id;
      v_kaldirilan := v_kaldirilan + 1;
    end if;
  end loop;

  perform public.log_admin_action('kelime_iliski_onay_kaldir', jsonb_build_object(
    'istenen', array_length(p_ids, 1), 'kaldirilan', v_kaldirilan));

  return jsonb_build_object('kaldirilan', v_kaldirilan, 'atlanan', v_atlanan);
end;
$$;
revoke all on function public.kelime_iliski_onay_kaldir(uuid[]) from public, anon;
grant execute on function public.kelime_iliski_onay_kaldir(uuid[]) to authenticated;
