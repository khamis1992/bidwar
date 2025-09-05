# BidWar – Cursor User Rules (قواعد العمل مع كورسر)

## الهدف
- إكمال تطبيق مزادات لحظي (Real-time bidding) على Flutter مع Supabase (Auth + DB + Realtime).
- تسليم MVP يعمل: تسجيل/دخول، إنشاء مزاد، عرض قائمة المزادات، شاشة تفاصيل مع مزايدة فورية، قائمة متابعة (Watchlist)، إشعارات أساسية.

## التِقنيات الأساسية
- Flutter (>= 3.29.2) وDart. احترم الإصدارات في `pubspec.yaml`.
- Responsive: Sizer (موجود).
- قاعدة البيانات وRealtime/Auth: Supabase.
- إدارة الحالة: **التزم بما هو موجود**. إن لم يوجد نمط واضح، استخدم Riverpod.
- التخزين المحلي: Hive أو SharedPreferences (الأولوية لـ Hive).
- Push Notifications: Firebase Messaging (غوغل) – لاحقًا إن لزم.

## مبادئ معمارية
- بنية Features: 
  - `lib/features/auth`, `features/auctions`, `features/bids`, `features/profile`, `features/notifications`, `features/watchlist`.
  - داخل كل Feature: `data/` (sources/models/repo), `domain/` (entities/usecases), `presentation/` (pages/widgets/controllers).
- طبقة `core/`: 
  - `core/config` (env, constants)
  - `core/network` (supabase client)
  - `core/utils`, `core/errors`, `core/theme` (التزم بالثيمينج الموجود).
- التوجيه: استخدم ملف routes الموجود، وأضف المسارات كالتالي: 
  - `Splash -> Auth -> Home (AuctionsList) -> AuctionDetails -> CreateAuction -> Profile`

## معايير الكود والجودة
- تحافظ على Null-safety. 
- تسمية الملفات: `snake_case.dart`, الأصناف: `PascalCase`, الدوال/المتغيرات: `camelCase`.
- استخدم `dart format` و `flutter analyze` ويفضل `very_good_analysis` أو `lint` كحزمة Lints.
- الاختبارات: على الأقل Unit لطبقة الدومين، وWidget tests لشاشات المزاد والتفاصيل.
- الوصول للبيانات: Repositories + DataSources (Supabase) مع DTO/Entity mapping.

## البيئة والأسرار
- لا تُضمّن أسرار حقيقية. استخدم `env.json` (محليًا) وGitHub Secrets للـCI.
- مفاتيح Supabase: `SUPABASE_URL`, `SUPABASE_ANON_KEY`.
- `env.json` لا يُرفع للإنتاج، استخدم `env.json.example` كنموذج.

## الـCI/CD
- حافظ على وركفلو بناء الـAPK الموجود. أضف فحص lint/analyze/tests قبل البناء.
- artifacts تُسمى بالتاريخ/الفرع. PRs تضع رابط APK في تعليق.

## الـUX/RTL
- اللغة: إنجليزي افتراضي، مع تمكين RTL. النصوص في `l10n/` لاحقًا.
- استخدم Material 3 والثيم الموجود.

## “Definition of Done” لكل مهمة
- الكود مُغَطّى باختبارات أساسية.
- `analyze` نظيف، و`format` مُطبَّق.
- شاشة/ميزة تعمل End‑to‑End ضد Supabase (أو Mock عند غياب الباك).
- مذكورة بالتغيير داخل `CHANGELOG.md` وتوثيق مختصر في `README_UPDATED.md`.

## تفاعل كورسر (مهم جدًا)
- قبل تعديل بنية كبيرة، افحص الملفات الموجودة والتزم بها.
- عند عدم وجود نمط واضح، طبّق ما ورد أعلاه.
- أعطني التغييرات على شكل Patch موحّد/PR diff، واذكر مسارات الملفات المضافة/المعدلة.
- إن واجهت غموضًا يمنع التقدم، اقترح خيارين مع تفضيل واضح وسبب مختصر.

