-- =====================================================================
-- Okuma Dünyası: HR-141–166 (HR-166 (düzeltme): 20261214 sürümünden sonra yol arkadaşı cümlesi düzeltilmiş paket yeni TASLAK sürüm olarak yazılır.
-- Kaynak: icerik/okuma/hikaye/hr141–hr166 (derleyiciden geçmiş paketler, sözlük dosyaları ile).
-- Ajan A/B ve insan kararları pending; yayın kapısı değişmez (yalnız insan onayı yayınlar).
-- Yol arkadaşı adları metinde zaten geçen anonim kişilere verildi; sözlük adayları TDK onayı bekliyor.
-- Katı kip: geçersiz paket varsa migrasyon hata verip durur (sessiz atlama yok). Aynı sha256 varsa atlanır.
-- Not: 20261213000000 (izinli_turler) bu dosyadan önce uygulanmadan bu migrasyon çalıştırılmamalı; sıra gereği önce o gelir.
-- =====================================================================

set client_encoding = 'UTF8';

create or replace function public._tmp_okuma_denetim_iceri_al(p_paket jsonb, p_a text, p_b text, p_siki boolean default false)
returns text
language plpgsql
set search_path = ''
as $f$
declare
  v_hatalar jsonb; v_hik jsonb; v_et jsonb; v_slug text; v_sha text; v_hikaye uuid;
  v_no integer; v_surum uuid; v_hedef jsonb; v_paket_den jsonb; v_den jsonb;
begin
  v_hatalar := public._okuma_paket_hatalari(p_paket);
  if jsonb_array_length(v_hatalar) > 0 then
    if p_siki then
      raise exception 'PAKET_RED: % %', (p_paket -> 'hikaye' ->> 'slug'), v_hatalar::text using errcode = '22023';
    end if;
    return 'RED: ' || (p_paket -> 'hikaye' ->> 'slug') || ' ' || v_hatalar::text;
  end if;
  v_hik := p_paket -> 'hikaye';
  v_et := v_hik -> 'etiketler';
  v_slug := v_hik ->> 'slug';
  v_sha := encode(sha256(convert_to(p_paket::text, 'UTF8')), 'hex');
  select id into v_hikaye from public.okuma_hikayeleri where slug = v_slug;
  if v_hikaye is not null then
    if exists (select 1 from public.okuma_hikaye_surumleri where hikaye_id = v_hikaye and sha256 = v_sha) then
      return 'MEVCUT: ' || v_slug;
    end if;
    select coalesce(max(surum_no), 0) + 1 into v_no from public.okuma_hikaye_surumleri where hikaye_id = v_hikaye;
  else
    insert into public.okuma_hikayeleri (slug) values (v_slug) returning id into v_hikaye;
    v_no := 1;
  end if;
  v_paket_den := v_et -> 'denetim';
  v_den := jsonb_build_object('ajan_a', coalesce(p_a, 'pending'), 'ajan_b', coalesce(p_b, 'pending'), 'insan', 'pending');
  insert into public.okuma_hikaye_surumleri (
    hikaye_id, surum_no, durum, icerik, sha256, baslik, tanitim, tur, konu, sinif_alt, sinif_ust, okuma_bandi,
    dunya_tipi, izinli_turler, deger_anahtarlari, yetiskin_uygun, sayfa_sayisi, soru_sayisi,
    olusturan_id, denetim, paket_denetimi)
  values (
    v_hikaye, v_no, 'taslak', p_paket, v_sha, v_hik ->> 'baslik', nullif(v_hik ->> 'tanitim', ''), v_hik ->> 'tur',
    v_hik ->> 'konu', (v_hik ->> 'sinif_alt')::smallint, (v_hik ->> 'sinif_ust')::smallint,
    (v_hik ->> 'okuma_bandi')::smallint, v_hik ->> 'dunya_tipi',
    array(select jsonb_array_elements_text(v_hik -> 'izinli_turler')),
    array(select jsonb_array_elements_text(v_hik -> 'deger_anahtarlari')),
    (v_hik ->> 'yetiskin_uygun')::boolean, jsonb_array_length(p_paket -> 'sayfalar'),
    jsonb_array_length(p_paket -> 'sorular'), null, v_den, v_paket_den)
  returning id into v_surum;
  insert into public.okuma_hikaye_etiketleri (
    surum_id, hikaye_id, ana_sinif, okuma_zorlugu, kavram_zorlugu, ilgi_egilimi, temalar, ders_baglantisi,
    ana_deger, yardimci_deger, cati_degerler, kanit_duzeyi, program_surumu, olculen)
  values (
    v_surum, v_hikaye, (v_et ->> 'ana_sinif')::smallint, (v_et ->> 'okuma_zorlugu')::smallint,
    (v_et ->> 'kavram_zorlugu')::smallint, v_et ->> 'ilgi_egilimi',
    array(select jsonb_array_elements_text(v_et -> 'temalar')),
    array(select jsonb_array_elements_text(v_et -> 'ders_baglantisi')),
    v_et #>> '{maarif,ana_deger}', v_et #>> '{maarif,yardimci_deger}',
    array(select jsonb_array_elements_text(coalesce(v_et #> '{maarif,cati_degerler}', '[]'::jsonb))),
    v_et ->> 'kanit_duzeyi', v_et ->> 'program_surumu', coalesce(v_et -> 'olculen', '{}'::jsonb));
  for v_hedef in select e from jsonb_array_elements(v_et -> 'ogrenme_hedefleri') e loop
    insert into public.okuma_ogrenme_hedefleri (id, tur, etiket, sinif, kanit_duzeyi, onayli, olusturan_id)
    values (v_hedef ->> 'id', v_hedef ->> 'tur', v_hedef ->> 'etiket', (v_et ->> 'ana_sinif')::smallint,
            v_et ->> 'kanit_duzeyi', false, null)
    on conflict (id) do nothing;
    insert into public.okuma_hikaye_hedefleri (surum_id, hedef_id, yuva, islev)
    values (v_surum, v_hedef ->> 'id', v_hedef ->> 'yuva', v_hedef ->> 'islev');
  end loop;
  return 'YAZILDI: ' || v_slug || ' surum_no=' || v_no;
end;
$f$;


do $m$ begin raise notice '%', public._tmp_okuma_denetim_iceri_al($json${
  "paket_surumu": 1,
  "hikaye": {
    "slug": "hr166-hayvan-turnanin-bekleme-cizgisi",
    "baslik": "Turnanın Bekleme Çizgisi",
    "tur": "doga",
    "konu": "goc_sulak_alan_dinlenme",
    "sinif_alt": 7,
    "sinif_ust": 7,
    "okuma_bandi": 3,
    "dunya_tipi": "gercekci",
    "izinli_turler": [
      "hayvan"
    ],
    "deger_anahtarlari": [
      "D12",
      "D14"
    ],
    "yetiskin_uygun": false,
    "etiketler": {
      "ana_sinif": 7,
      "okuma_zorlugu": 4,
      "kavram_zorlugu": 4,
      "ilgi_egilimi": "ortak",
      "temalar": [
        "doga"
      ],
      "ders_baglantisi": [
        "turkce"
      ],
      "maarif": {
        "ana_deger": "D12",
        "yardimci_deger": "D14"
      },
      "ogrenme_hedefleri": [
        {
          "id": "sozcuk1_hr166",
          "tur": "lexeme",
          "etiket": "göç",
          "yuva": "hr166_goc",
          "islev": "first_hint"
        },
        {
          "id": "sozcuk2_hr166",
          "tur": "lexeme",
          "etiket": "enerji",
          "yuva": "hr166_enerji",
          "islev": "application"
        },
        {
          "id": "sozcuk3_hr166",
          "tur": "lexeme",
          "etiket": "sürü",
          "yuva": "hr166_suru",
          "islev": "application"
        },
        {
          "id": "sozcuk4_hr166",
          "tur": "lexeme",
          "etiket": "rehberlik",
          "yuva": "hr166_rehberlik",
          "islev": "transfer"
        }
      ],
      "kanit_duzeyi": "C",
      "program_surumu": "TYMM 2026-27 (7. sınıf); kazanım kodu yok (source_pending)",
      "denetim": {
        "ajan_a": "pending",
        "ajan_b": "pending",
        "insan": "pending"
      },
      "olculen": {
        "kelime_sayisi": 660,
        "tahmini_sure_dk": 6,
        "sayfa_sayisi": 5,
        "soru_sayisi": 4,
        "soru_beceri_dagilimi": {
          "hatirlama": 1,
          "cikarim": 1,
          "sozcuk_baglami": 1,
          "yorumlama": 1
        },
        "hedef_tur_dagilimi": {
          "lexeme": 4
        },
        "yoldas_yer_sayisi": 2,
        "simge_sayisi": 0
      }
    },
    "tanitim": "Göç eden kuşların dinlenme kıyısına yürüyüş yolu yaklaşıyor. {kahraman} sürüye güvenli bir durak bulmak için doğru zamanı bekliyor.",
    "durum": "taslak",
    "fis_kodu": "HR-166"
  },
  "sayfalar": [
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " uzun yolculuklara çıkan bir turnaydı. Her mevsim değişiminde sürüsüyle birlikte farklı sulak alanlarda dinlenirdi. Bu yıl geçiş sırasında alışılmış dinlenme alanının kıyısında yeni yürüyüş yolları açıldığını gördü. Yollar insanlara doğayı izleme fırsatı veriyordu ama bazı noktalarda kuşların sakin kaldığı bölgeye fazla yaklaşılıyordu. Gökyüzünden bakıldığında sulak alan tek parça görünüyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " aşağı indikçe farklı bölümlerin birbirinden ne kadar ayrı olduğunu gördü. Bazı yerler sığ suyla, bazıları uzun sazlarla kaplıydı. Dinlenme, beslenme ve güvenli yaklaşma alanlarının aynı yerde bulunması gerekmiyordu. Sürü uzun yoldan geldiği için çok fazla deneme yapmak istemiyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " daha önce tanıdığı güvenli noktaları hatırlayarak dikkatli bir seçim yaptı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " sürüyle birlikte alçaktan uçup güvenli bir iniş alanı aradı. Göç boyunca harcanan "
        },
        {
          "t": "kelime",
          "yuva": "hr166_enerji"
        },
        {
          "t": "metin",
          "v": ", dinlenme sırasında yeniden kazanılmalıydı. Bu nedenle bir yerde kısa süre durabilmek bile önemliydi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " havadan gördüğü alanları aceleyle değerlendirmedi. Suyun derinliğini, kıyının sakinliğini ve dinlenen diğer kuşları birlikte gözledi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "İlk durak geniş sazlıkların yakınıydı. Burada sığ su ve korunaklı kıyı vardı. Fakat günün ilerleyen saatlerinde insan sesleri artıyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " sürünün daha sakin bir bölgeye yönelmesini işaret etti. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Çınar"
        },
        {
          "t": "metin",
          "v": " ve kuşlar acele etmeden hareket etti. Sazlıkta dinlenirken "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bir yandan da sürünün hareketlerini gözledi. Birkaç kuş erken havalanıp sonra tekrar indi. Bu kısa kalkışlar bile enerji harcatıyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " daha sakin kıyının "
        },
        {
          "t": "kelime",
          "yuva": "hr166_suru"
        },
        {
          "t": "metin",
          "v": " için uygun olabileceğini düşündü. Alanın uzağındaki yürüyüş yolunda insanlar kuşları merakla izliyordu. Doğayı tanımak istemeleri anlaşılırdı ama yaklaşma mesafesi dikkatle seçilmeliydi. Herkesin yararlanacağı bir düzen için farklı ihtiyaçları bilmek gerekiyordu. Uzun uçuşun ardından gereksiz yere yeniden havalanmak yorucuydu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " yakın taraftaki küçük koyu seçerken rüzgârın durumunu da düşündü. Koy, açık bölgeye göre daha az dalga alıyordu. Sulak alan farklı canlılara yiyecek ve dinlenme imkânı sağlıyordu. Fakat her köşe aynı anda herkes için uygun değildi. Sürünün güvenli biçimde birlikte kalması gerekiyordu."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Ertesi gün kıyıdaki gözlem yolu yeniden düzenlendi. İnsanların geçebileceği çizginin ötesinde sessiz bir bölüm ayrıldı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " uzaktan yeni işaretleri gördü. İlk gün bazı ziyaretçiler çizginin önemini anlamadı. Gözlem alanındaki levhalarda neden sessiz kalınması gerektiği açıklanıyordu. Bazı ziyaretçiler daha iyi görmek için yakına yürümek istiyordu. Görevlinin "
        },
        {
          "t": "kelime",
          "yuva": "hr166_rehberlik"
        },
        {
          "t": "metin",
          "v": " ettiği kısa bir tanıtımda dürbünle uzaktan izlemenin de ayrıntı görmeye yardımcı olduğu anlatıldı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " dinlenirken insanların davranışları daha düzenli hâle gelmişti. Böylece kuşları görmekle onların dinlenmesine saygı göstermek aynı anda mümkün olmuştu. Kıyıdaki sessiz çizgi, bir yasaktan çok karşılıklı özenin işaretiydi. Görevliler, kuşların yakından izlendiğinde sık sık yer değiştirmek zorunda kalabileceğini açıkladı. Ziyaretçiler dürbünlerini güvenli gözlem noktasından kullanmaya başladı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " sürünün eskisine göre daha az ürkerek dinlendiğini fark etti. Bu, insanlarla kuşlar arasında konuşulmadan kurulmuş bir anlaşma gibiydi. Herkes aynı alanı kullanıyor ama farklı ihtiyaçlara göre sınırlar belirleniyordu."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Birkaç gün sonra sert bir rüzgâr başladı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " uçuşa geçmek için uygun koşulları beklemeyi tercih etti. Sürüdeki bazı genç kuşlar hareketlenmişti. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " ve "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Çınar"
        },
        {
          "t": "metin",
          "v": " kıyıda sakin durarak grubun birlikte kalmasına yardımcı oldu. Rüzgârın en sert estiği gün sürü, açık suyun kenarına fazla yaklaşmadı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " güvenli bir konumda kalmanın da yolculuk kararı olduğunu düşündü. Havanın düzelmesini beklerken yiyecek bulmak ve dinlenmek mümkündü. Genç kuşların hareketleri zamanla sakinleşti. Hep birlikte uçabilmek için herkesi göz önünde tutmak gerekiyordu. Uygun an gelmeden ayrılmak, uzun yolun sonraki bölümünü gereksiz yere zorlaştırabilirdi. Beklemek, yolculuğu bırakmak anlamına gelmiyordu. Tam tersine, "
        },
        {
          "t": "kelime",
          "yuva": "hr166_goc"
        },
        {
          "t": "metin",
          "v": " sırasında doğru zamanlamayla hareket etmek enerjinin dikkatli kullanılmasını sağlıyordu. Sulak alanın sessiz bölümünde yiyecek aradılar, tüylerini temizlediler ve dinlendiler. Gözlem yolundaki görevliler yaklaşmadan uzaktan not aldı. Bir sonraki gün hava sakinleşince sürünün uçuş için daha hazır olduğu görüldü."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Şafak sökmeye başladığında "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " kanatlarını açtı. Sürü önce yavaşça yükseldi, ardından gökyüzünde uzun bir çizgi oluşturdu. Sulak alan geride kalırken kıyıdaki bekleme çizgisi ilk ışıkta uzaktan seçiliyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " orada birkaç gün geçirmişti ama bu kısa konaklama, uzun yolculuğun önemli bir parçasıydı. Uçuş başladıktan sonra sulak alanın kıvrımları geride küçüldü. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " sürünün düzenini bozmayacak bir hızda ilerledi. Bir sonraki durakta hangi koşullarla karşılaşacaklarını bilmiyordu ama önceki konaklamadan önemli bir deneyim kazanmışlardı. Arkada kalan sessiz bölgenin gelecek sürüler için de korunması, bu yüzden değerliydi. Gökyüzünde uzanan çizgi başka bir durağa yöneldi. Gözlem yolundaki ziyaretçiler dürbünlerini indirip sürünün yükselişini uzaktan izledi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " önündeki açık gökyüzüne baktı. Sürü uzaklaşırken kıyı sessizliğini korudu."
        }
      ]
    }
  ],
  "deger_sahneleri": {},
  "hareket_sahneleri": {},
  "deyim_cumleleri": {},
  "sorular": [
    {
      "id": "s1",
      "beceri": "hatirlama",
      "dayanak_sayfa": 1,
      "metin": "Yeni yürüyüş yoluyla ilgili sorun neydi?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Yolun tamamen su altında kalmış olması"
        },
        {
          "id": "B",
          "metin": "Yolun çok kısa olması"
        },
        {
          "id": "C",
          "metin": "Yolun kuşlara fazla yaklaşması"
        },
        {
          "id": "D",
          "metin": "Yolda hiç işaret bulunmaması"
        }
      ],
      "dogru": "C",
      "aciklama": "Metindeki \"Yollar insanlara doğayı izleme fırsatı veriyordu ama bazı noktalarda kuşların sakin kaldığı bölgeye fazla yaklaşılıyordu.\" cümlesi C seçeneğini doğrular. Yol su altında kalmamış, kısa olması sorun sayılmamış ve işaretsiz de değildi."
    },
    {
      "id": "s2",
      "beceri": "cikarim",
      "dayanak_sayfa": 2,
      "metin": "{kahraman} neden daha sakin koyu seçti?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Daha az ürkerek dinlenmek için"
        },
        {
          "id": "B",
          "metin": "Koydaki bütün taşları saymak için"
        },
        {
          "id": "C",
          "metin": "Yürüyüş yoluna yaklaşmak için"
        },
        {
          "id": "D",
          "metin": "Göçü tamamen bırakmak için"
        }
      ],
      "dogru": "A",
      "aciklama": "Metindeki \"{kahraman} sürünün daha sakin bir bölgeye yönelmesini işaret etti.\" cümlesinden önce günün ilerleyen saatlerinde insan seslerinin arttığı yazar; sakin koy bu yüzden seçildi. Taş saymak, yürüyüş yoluna yaklaşmak ve göçü bırakmak metinde amaç değildir."
    },
    {
      "id": "s3",
      "beceri": "sozcuk_baglami",
      "dayanak_sayfa": 4,
      "metin": "“Enerji” bu metinde hangi anlamda kullanılmıştır?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Gözlem yolundaki levhanın parlak boyası"
        },
        {
          "id": "B",
          "metin": "Uçuş ve hareket için gereken güç"
        },
        {
          "id": "C",
          "metin": "Sulak alandaki suyun tuz oranı"
        },
        {
          "id": "D",
          "metin": "Kuşların tüy rengi"
        }
      ],
      "dogru": "B",
      "aciklama": "Metindeki \"Tam tersine, göç sırasında doğru zamanlamayla hareket etmek enerjinin dikkatli kullanılmasını sağlıyordu.\" cümlesinde enerji, kuşun uçması ve hareket etmesi için gereken güçtür; metnin başında da uzun uçuşta harcanan enerjinin dinlenirken yeniden kazanılması gerektiği yazar. Levha boyası, suyun tuz oranı ve tüy rengi enerjiyle ilgili değildir."
    },
    {
      "id": "s4",
      "beceri": "yorumlama",
      "dayanak_sayfa": 4,
      "metin": "{kahraman} neden rüzgârın dinmesini bekledi?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Göç yönünü zamanla unutmak için"
        },
        {
          "id": "B",
          "metin": "Kıyıyı değiştirmek için"
        },
        {
          "id": "C",
          "metin": "Sürüyü dağıtmak için"
        },
        {
          "id": "D",
          "metin": "Uygun koşulda uçmak için"
        }
      ],
      "dogru": "D",
      "aciklama": "Metindeki \"{kahraman} uçuşa geçmek için uygun koşulları beklemeyi tercih etti.\" cümlesi, turnanın sert rüzgârda uçmak yerine koşulların düzelmesini beklediğini gösterir. Yönü unutmak, kıyıyı değiştirmek ve sürüyü dağıtmak metinde yoktur; tersine sürünün birlikte kalmasına yardım edilmiştir."
    }
  ],
  "uretim": {
    "kaynak": "llm_taslak",
    "tarih": "2026-11-11"
  },
  "sozluk": {
    "sozluk_surumu": 1,
    "girdiler": [
      {
        "id": "hr166_goc",
        "tur": "kelime",
        "yazim": "göç",
        "anlam": "Canlıların mevsimlere bağlı olarak uzun yolculuklarla yer değiştirmesi.",
        "sinif_alt": 7,
        "sinif_ust": 7
      },
      {
        "id": "hr166_goc_b",
        "tur": "kelime",
        "yazim": "yolculuk",
        "anlam": "Bir yerden başka bir yere uzun süreli gidiş.",
        "sinif_alt": 7,
        "sinif_ust": 7
      },
      {
        "id": "hr166_goc_c",
        "tur": "kelime",
        "yazim": "dönüş",
        "anlam": "Bir yolculuktan sonra yeniden yerine gelme.",
        "sinif_alt": 7,
        "sinif_ust": 7
      },
      {
        "id": "hr166_enerji",
        "tur": "kelime",
        "yazim": "enerji",
        "anlam": "Bir şeyin iş yapabilme gücü.",
        "sinif_alt": 7,
        "sinif_ust": 7
      },
      {
        "id": "hr166_enerji_b",
        "tur": "kelime",
        "yazim": "güç",
        "anlam": "Bir şeyi hareket ettirebilen etki.",
        "sinif_alt": 7,
        "sinif_ust": 7
      },
      {
        "id": "hr166_enerji_c",
        "tur": "kelime",
        "yazim": "yakıt",
        "anlam": "Enerji elde etmek için yakılan madde.",
        "sinif_alt": 7,
        "sinif_ust": 7
      },
      {
        "id": "hr166_suru",
        "tur": "kelime",
        "yazim": "sürü",
        "anlam": "Aynı türden hayvanların birlikte yaşayan topluluğu.",
        "sinif_alt": 7,
        "sinif_ust": 7
      },
      {
        "id": "hr166_suru_b",
        "tur": "kelime",
        "yazim": "topluluk",
        "anlam": "Birlikte yaşayan ya da hareket eden canlılar grubu.",
        "sinif_alt": 7,
        "sinif_ust": 7
      },
      {
        "id": "hr166_suru_c",
        "tur": "kelime",
        "yazim": "grup",
        "anlam": "Birlikte hareket eden insan ya da hayvanlar topluluğu.",
        "sinif_alt": 7,
        "sinif_ust": 7
      },
      {
        "id": "hr166_rehberlik",
        "tur": "kelime",
        "yazim": "rehberlik",
        "anlam": "Birine yol göstererek destek olma işi.",
        "sinif_alt": 7,
        "sinif_ust": 7
      },
      {
        "id": "hr166_rehberlik_b",
        "tur": "kelime",
        "yazim": "yönlendirme",
        "anlam": "Bir kişiyi doğru yöne çevirme işi.",
        "sinif_alt": 7,
        "sinif_ust": 7
      },
      {
        "id": "hr166_rehberlik_c",
        "tur": "kelime",
        "yazim": "danışmanlık",
        "anlam": "Bir konuda bilgi ve öneri verme hizmeti.",
        "sinif_alt": 7,
        "sinif_ust": 7
      }
    ],
    "yuvalar": [
      {
        "ad": "hr166_goc",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr166_goc"
          },
          {
            "girdi": "hr166_goc_b"
          },
          {
            "girdi": "hr166_goc_c"
          }
        ]
      },
      {
        "ad": "hr166_enerji",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr166_enerji"
          },
          {
            "girdi": "hr166_enerji_b"
          },
          {
            "girdi": "hr166_enerji_c"
          }
        ]
      },
      {
        "ad": "hr166_suru",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr166_suru"
          },
          {
            "girdi": "hr166_suru_b"
          },
          {
            "girdi": "hr166_suru_c"
          }
        ]
      },
      {
        "ad": "hr166_rehberlik",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr166_rehberlik"
          },
          {
            "girdi": "hr166_rehberlik_b"
          },
          {
            "girdi": "hr166_rehberlik_c"
          }
        ]
      }
    ]
  }
}$json$::jsonb, 'pending', 'pending', true); end $m$;

drop function public._tmp_okuma_denetim_iceri_al(jsonb, text, text, boolean);
