# Hupo — Claude Code talimatları

Proje kuralları `AGENTS.md` içindedir; başlamadan önce onu ve `MASTER_BRIEF.md`'yi oku.
Not: `MASTER_BRIEF.md` içindeki eski OneDrive yolu geçersizdir; proje `C:\Dev\hupo` konumundadır.

## Hupo Design & Growth
Hupolingo tasarım, UX, pazarlama veya iletişim görevlerinde `hupo-design-growth-director` agent'ını kullan. Bu agent projenin Orchestrator rolüne bağlı uzman olarak çalışır. Güncel kullanıcı talimatı ve repo'nun yetkili belgeleri paket özetlerinden önceliklidir.
Önce MASTER_BRIEF.md, AGENTS.md, TASKS.md ve göreve ilişkin mevcut kod/assetleri oku. Ortak kısa bağlam `docs/hupo-design-growth/PROJECT_CONTEXT.md` içindedir. Beş proje skill'i: hupo-ux-strategy, hupo-design-system, hupo-growth-marketing, hupo-ux-writing, hupo-platform-review.
Öğrenci deneyiminde öğrenme ve cesaret; veli deneyiminde fayda, güven ve açıklanabilir veri; admin'de doğruluk ve hızlı görev tamamlama önceliklidir. Satın alma veli alanında; sahte sosyal kanıt ve puan/sınav garantisi yok. Öğrenme metriğini XP/süre ile karıştırma. Onaylı Hupo assetleri ve mevcut stack korunur.
Her önemli ekranda hedef/ana eylem/durum/kabul kriterlerini tanımla. Uygulanan ekranı gerçek görüntü ve kullanıcı göreviyle kontrol et; kontrol çalışmadıysa açık yaz. Sadece gerçekten tamamlanan işleri TASKS.md'de kapat.

## Gizli anahtarlar
API anahtarları yalnızca `.claude/settings.local.json` (git'e girmez) veya ortam değişkenlerinde durur. `.claude/settings.json`, `.claude/mcp.json` ve diğer izlenen dosyalara düz metin anahtar yazılmaz; `${DEGISKEN}` referansı kullanılır.
