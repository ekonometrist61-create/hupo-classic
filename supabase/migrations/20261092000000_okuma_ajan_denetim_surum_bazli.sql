-- =====================================================================
-- Okuma Dünyası: 2026-10-24 Ajan A/B denetim sonuçlarını sürüm bazında işle (kullanıcı onayı 2026-10-25).
-- Kaynak: docs/okuma-entegrasyon/denetim/2026-10-24/ (112 sürüm, 224 rapor; her rapor sürüm id'si taşır).
-- 20261091 (2026-10-23 turu, eski metin) sonuçlarını bu sürümler için düzeltir. Yalnız ajan_a/ajan_b yazılır;
-- "insan" kararına ve yayındaki/arşivdeki sürümlere dokunulmaz. Eşleşmeyen sürüm olursa işlem hata verip durur.
-- =====================================================================

do $ajan_yaz2$
declare
  r record;
  v_n integer;
  v_toplam integer := 0;
begin
  for r in
    select * from (values
    ('00f4f1b6-08b2-40ac-a362-cfa6f2cc17d0'::uuid, 'review_needed', 'review_needed'),
    ('0a092bc7-c2ba-483e-b23e-5dc661fdb193'::uuid, 'review_needed', 'review_needed'),
    ('0b324565-c65c-4088-8e55-d5330ee60bb4'::uuid, 'pass', 'review_needed'),
    ('0f4b3904-d285-4743-9dee-5a29de99aa6d'::uuid, 'pass', 'pass'),
    ('0f5d14b4-2774-433a-bd77-880c75578e3a'::uuid, 'review_needed', 'review_needed'),
    ('124bcc04-d687-41e0-8ffe-e0b5f531ef7f'::uuid, 'review_needed', 'review_needed'),
    ('12deb88b-2219-4b0b-9652-05b81e1e368a'::uuid, 'pass', 'pass'),
    ('130daa4f-5394-49a9-8b5a-c58f0329d50c'::uuid, 'review_needed', 'review_needed'),
    ('14e1da73-ab60-4994-8de6-7f91f59ddd53'::uuid, 'pass', 'pass'),
    ('14f4a620-7c60-4729-9b16-bc1fef36da87'::uuid, 'pass', 'pass'),
    ('14fb092a-352f-42f7-8c73-fdd5fbcc760e'::uuid, 'review_needed', 'review_needed'),
    ('15c7b8ae-bbb1-4ef0-a24b-5ddbe8b682d0'::uuid, 'pass', 'pass'),
    ('1b9d9eb0-de56-4fc8-a40f-87e17b84d9d3'::uuid, 'pass', 'pass'),
    ('1ef00a9e-4e2a-4319-8123-c54aa469311c'::uuid, 'pass', 'pass'),
    ('1f20f260-249c-4b9a-aa7a-bbfcb15c84f2'::uuid, 'review_needed', 'review_needed'),
    ('20b1e315-95c6-421c-96e2-c3b3ceb97786'::uuid, 'pass', 'review_needed'),
    ('23d280d2-7c17-460f-8318-f5e89e8cf89a'::uuid, 'review_needed', 'review_needed'),
    ('23d8eeaf-1f29-4a7e-8c5d-3f8434ac1aa4'::uuid, 'pass', 'review_needed'),
    ('25172f0f-9ae3-4b69-b090-3cdcaaaedda8'::uuid, 'review_needed', 'review_needed'),
    ('258d588f-b6be-4ba5-a30b-a720884fae49'::uuid, 'pass', 'review_needed'),
    ('2931475c-e6e0-4e0e-9d27-54aca90654fc'::uuid, 'review_needed', 'review_needed'),
    ('2983e37c-9907-4919-ad08-3ee27d6d3cdf'::uuid, 'review_needed', 'review_needed'),
    ('2abed330-998a-4ef9-9bcc-64e8eae32e6d'::uuid, 'review_needed', 'review_needed'),
    ('2be110fc-3043-41b5-9d34-72a53f523143'::uuid, 'review_needed', 'review_needed'),
    ('2d49d546-a490-4148-bfac-1ab78f47efba'::uuid, 'review_needed', 'review_needed'),
    ('32521ac5-2c96-40fc-b9a8-e37d2a43c885'::uuid, 'review_needed', 'review_needed'),
    ('336815af-2d0a-44da-b0b6-f3365f041099'::uuid, 'review_needed', 'review_needed'),
    ('342c6af5-aa78-4631-af0d-828cbba5041e'::uuid, 'review_needed', 'review_needed'),
    ('3fa9b284-5f68-44db-b70b-74f349cfc651'::uuid, 'pass', 'review_needed'),
    ('400f0ed0-c2da-4fc3-b3de-6f4a2276f3e9'::uuid, 'pass', 'review_needed'),
    ('413e55a3-22ee-4ba8-abcb-b5b580bf24b6'::uuid, 'review_needed', 'review_needed'),
    ('42ef1bff-9eb9-4bc0-95d7-c5a9ed936b5e'::uuid, 'review_needed', 'review_needed'),
    ('44129b29-d795-4b6f-9671-8fa026fb8208'::uuid, 'review_needed', 'review_needed'),
    ('44d9f533-2038-4268-b65b-7c373ae9c00c'::uuid, 'pass', 'review_needed'),
    ('4d7f3d3a-e472-4d8d-9b59-f8c0466e0d5f'::uuid, 'review_needed', 'review_needed'),
    ('510b1545-36d0-461d-a677-f62b3e1224c9'::uuid, 'review_needed', 'review_needed'),
    ('522c4c23-aa9a-4d1d-8baf-c14e0cfced27'::uuid, 'review_needed', 'review_needed'),
    ('59ec1055-e753-42ec-8911-66095d538254'::uuid, 'pass', 'review_needed'),
    ('5a3ac220-0c29-4717-a0c9-9db369b2f12d'::uuid, 'review_needed', 'review_needed'),
    ('5c599a9f-31b0-4741-ab47-57b17c5e39a9'::uuid, 'pass', 'pass'),
    ('61747e43-5ff0-4044-8dfb-feef94118e93'::uuid, 'review_needed', 'review_needed'),
    ('64b3fc68-7025-4772-aa30-57499ebcad46'::uuid, 'pass', 'review_needed'),
    ('66c11ab6-fde8-4ed6-92b3-bccc30d6b7b2'::uuid, 'pass', 'pass'),
    ('6770d89a-ca58-4e3f-a810-2bb7bc8f7f2b'::uuid, 'pass', 'pass'),
    ('69307097-ca5f-4eba-b844-6176ebfccbc9'::uuid, 'review_needed', 'review_needed'),
    ('6d8b3f4b-965e-4d2d-abd0-3e02d330259e'::uuid, 'pass', 'pass'),
    ('6df22e4c-0924-4b5e-b88d-04829c7b31cf'::uuid, 'pass', 'review_needed'),
    ('6ec8b79c-acae-4484-808b-24a7fd9c0f97'::uuid, 'review_needed', 'review_needed'),
    ('70e43535-f781-412f-8698-01ed7478ffd2'::uuid, 'review_needed', 'review_needed'),
    ('7267da54-f7e2-4cd3-8d7f-1233ec807c15'::uuid, 'review_needed', 'review_needed'),
    ('72c8d625-a21c-467b-834a-12073d86fcdb'::uuid, 'review_needed', 'review_needed'),
    ('7449a97b-dd57-4a03-a3c0-252057608e1d'::uuid, 'pass', 'review_needed'),
    ('7970ce69-64d0-4ce2-a7c3-ed8bf7913394'::uuid, 'review_needed', 'review_needed'),
    ('7a7f8e8f-71eb-447d-859b-3a86346e6392'::uuid, 'review_needed', 'review_needed'),
    ('7ac9b53f-6c35-42fd-a7bc-ed24f5118966'::uuid, 'pass', 'review_needed'),
    ('7beb04ee-04c9-484e-9179-77a3e9995f69'::uuid, 'review_needed', 'review_needed'),
    ('7d312062-a5d2-4686-8a25-217bb41411d9'::uuid, 'review_needed', 'review_needed'),
    ('7f2aa754-40e2-4010-8203-1f4446c740c1'::uuid, 'pass', 'review_needed'),
    ('836cf504-e0e7-4807-b424-483a5332cb3f'::uuid, 'review_needed', 'review_needed'),
    ('840dec0e-a8be-453e-bbc9-12e33c044ff5'::uuid, 'review_needed', 'review_needed'),
    ('867941ee-ec95-465b-888b-9841722ccf22'::uuid, 'pass', 'review_needed'),
    ('87d01d93-2e8d-43a8-a3c6-b3069ff8bdb6'::uuid, 'review_needed', 'review_needed'),
    ('888c3405-be60-4110-95b1-9691cde41e9b'::uuid, 'review_needed', 'review_needed'),
    ('8b1668aa-52b7-47a0-8686-8c261820b0ff'::uuid, 'review_needed', 'review_needed'),
    ('8b3c3760-d5d0-421e-9273-e0958aa393a2'::uuid, 'pass', 'review_needed'),
    ('911eb87c-e385-418f-a6db-1522892613ca'::uuid, 'review_needed', 'review_needed'),
    ('91d6c613-7380-4d69-9416-21676e10d5c5'::uuid, 'review_needed', 'review_needed'),
    ('95c0803c-a45e-4666-9213-e49fa5a4dd52'::uuid, 'pass', 'review_needed'),
    ('96491ac6-a9e3-457b-8f27-7616b8587227'::uuid, 'review_needed', 'review_needed'),
    ('9a8bc801-2aba-4545-88d5-e8dc0846d8b4'::uuid, 'pass', 'review_needed'),
    ('9c974d9d-a60a-44fd-9795-096fbb0b3803'::uuid, 'review_needed', 'review_needed'),
    ('9db1b49e-25c2-409a-8d30-984c14123818'::uuid, 'review_needed', 'review_needed'),
    ('9f911983-fce7-478f-baa1-12c006b4ad76'::uuid, 'review_needed', 'review_needed'),
    ('a268612d-5a69-414f-aba7-a406938a4685'::uuid, 'review_needed', 'review_needed'),
    ('a9ce8f75-108f-415c-a57c-d786523f50f1'::uuid, 'pass', 'review_needed'),
    ('aca49c43-25df-4a57-b98b-278634b1cc11'::uuid, 'review_needed', 'review_needed'),
    ('ae90b4dc-2e07-40df-97cd-0a47d78ee413'::uuid, 'review_needed', 'review_needed'),
    ('b1054c87-7d3d-4911-8faa-0363145d139b'::uuid, 'pass', 'review_needed'),
    ('b327331c-26ce-48f6-97df-3e03b97b4dd5'::uuid, 'pass', 'review_needed'),
    ('b3f2755a-f817-47e4-9203-7ddfb3eb5826'::uuid, 'pass', 'pass'),
    ('b4475689-22fe-4f3a-a889-e79a1afb3c79'::uuid, 'pass', 'review_needed'),
    ('b48a761a-9a70-420e-9fd1-49d4acaf3c4f'::uuid, 'pass', 'pass'),
    ('b53b4e50-ffbe-46ee-97fd-5b31e944097d'::uuid, 'review_needed', 'review_needed'),
    ('b91b600b-2115-419e-b667-1a20503c2f5a'::uuid, 'review_needed', 'review_needed'),
    ('c15fb04c-d480-4506-9e84-06103d069b8f'::uuid, 'review_needed', 'review_needed'),
    ('c519af4c-0ba6-4580-92cb-e93216f3613e'::uuid, 'pass', 'review_needed'),
    ('c58e1d79-ee62-4c04-921a-81a0baa2a61b'::uuid, 'pass', 'pass'),
    ('c84329d3-8fa6-4f9a-b109-e5314420d123'::uuid, 'review_needed', 'review_needed'),
    ('c89dff19-1a87-4ce2-b28a-6a199b6eab56'::uuid, 'pass', 'review_needed'),
    ('c8c206d3-cb7a-4186-9b20-3e665d184aa5'::uuid, 'review_needed', 'review_needed'),
    ('c9f099f5-8f1b-41b8-9af6-8aa98ce0947b'::uuid, 'pass', 'review_needed'),
    ('ccff0f6e-351e-4d70-a3d2-b2a77adb7478'::uuid, 'pass', 'pass'),
    ('cd8a1282-8daf-49a7-88df-834d4a2c17cb'::uuid, 'review_needed', 'review_needed'),
    ('db6fc1e8-bcb9-40b7-b061-aba0f08ca95f'::uuid, 'review_needed', 'review_needed'),
    ('dc51166b-d69d-4fb2-a3aa-165b149b65da'::uuid, 'review_needed', 'review_needed'),
    ('dd4e2565-1a45-43a8-9d8b-4f05540d0b9c'::uuid, 'review_needed', 'review_needed'),
    ('dea9f9eb-d2b8-468d-9e14-930e908d5cef'::uuid, 'pass', 'review_needed'),
    ('dfd51109-6ffe-4c00-a235-baabfed8fd29'::uuid, 'review_needed', 'review_needed'),
    ('e006ce85-3c66-41aa-a910-040a67527972'::uuid, 'review_needed', 'review_needed'),
    ('e31d1b71-cd18-49a9-8a67-78cb046dc932'::uuid, 'review_needed', 'review_needed'),
    ('eb2b0230-8b7a-48c5-bf68-1be405c4b178'::uuid, 'review_needed', 'review_needed'),
    ('eb5d0f24-2fea-4b87-9a24-5c43c1a57093'::uuid, 'review_needed', 'review_needed'),
    ('ebe5db30-c071-49e8-bc0b-480352944f3e'::uuid, 'pass', 'review_needed'),
    ('ef4fa4bc-baab-43d3-9248-f7439e2bc256'::uuid, 'pass', 'review_needed'),
    ('f11179c5-25e8-4b32-a701-851750eb35eb'::uuid, 'pass', 'pass'),
    ('f242825c-0a34-4f1b-bca0-fda91db2e9bc'::uuid, 'pass', 'review_needed'),
    ('f39ccf6f-28fe-4098-8cc5-0e080974a8fd'::uuid, 'pass', 'review_needed'),
    ('f53964c7-d859-433c-ad19-92e0451c22d4'::uuid, 'pass', 'review_needed'),
    ('fa74a028-5663-4b8d-95e7-3faf2091302b'::uuid, 'pass', 'review_needed'),
    ('fc152a6c-6bfd-4374-a33f-f4f7463d5f5a'::uuid, 'pass', 'review_needed'),
    ('fd8896a6-5cc6-4346-84fa-b4131cc972cb'::uuid, 'pass', 'review_needed'),
    ('ffa4fecd-2038-4265-9000-483f44887db7'::uuid, 'review_needed', 'review_needed')
    ) as t(sid, a, b)
  loop
    update public.okuma_hikaye_surumleri s
       set denetim = coalesce(s.denetim, '{}'::jsonb) || jsonb_build_object('ajan_a', r.a, 'ajan_b', r.b)
     where s.id = r.sid
       and s.durum in ('taslak', 'incelemede');
    get diagnostics v_n = row_count;
    if v_n <> 1 then
      raise exception 'SURUM_EŞLEŞMEDI: %', r.sid using errcode = '22023';
    end if;
    v_toplam := v_toplam + v_n;
  end loop;

  perform public.log_admin_action('okuma_ajan_denetim_isleme', jsonb_build_object(
    'not', 'Kullanıcı onayı 2026-10-25: 2026-10-24 Ajan A/B denetimi sürüm id bazında yazıldı (20261091 düzeltmesi); insan kararı değişmedi.',
    'surum_sayisi', v_toplam));
end
$ajan_yaz2$;