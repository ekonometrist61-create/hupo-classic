-- CMS görselleri: Hupo maskotu ve karakter görselleri yönetim ekranından yüklenir.
-- Okuma herkese açık (kova public); yazma, silme ve listeleme yalnızca admin.
-- Yayın adresi site_icerik'te "gorseller.*" anahtarlarında tutulur; boşsa public/ yedek dosya kullanılır.

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'site-gorselleri',
  'site-gorselleri',
  true,
  2097152,
  array['image/webp', 'image/png', 'image/jpeg', 'image/svg+xml']
)
on conflict (id) do update
  set public = excluded.public,
      file_size_limit = excluded.file_size_limit,
      allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists "site_gorselleri_admin_oku" on storage.objects;
create policy "site_gorselleri_admin_oku"
  on storage.objects for select
  to authenticated
  using (bucket_id = 'site-gorselleri' and (select public.is_admin()));

drop policy if exists "site_gorselleri_admin_ekle" on storage.objects;
create policy "site_gorselleri_admin_ekle"
  on storage.objects for insert
  to authenticated
  with check (bucket_id = 'site-gorselleri' and (select public.is_admin()));

drop policy if exists "site_gorselleri_admin_guncelle" on storage.objects;
create policy "site_gorselleri_admin_guncelle"
  on storage.objects for update
  to authenticated
  using (bucket_id = 'site-gorselleri' and (select public.is_admin()))
  with check (bucket_id = 'site-gorselleri' and (select public.is_admin()));

drop policy if exists "site_gorselleri_admin_sil" on storage.objects;
create policy "site_gorselleri_admin_sil"
  on storage.objects for delete
  to authenticated
  using (bucket_id = 'site-gorselleri' and (select public.is_admin()));
