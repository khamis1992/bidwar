# BidWar - Flutter Auction App

## 🚀 مشروع محدث مع حلول مشاكل APK

تم تحديث هذا المشروع لحل مشاكل بناء APK وإضافة سكريبتات تحديث شاملة.

## 📋 المشاكل التي تم حلها

### 1. مشكلة بناء APK
- **المشكلة**: عدم إمكانية إنشاء ملف APK بسبب مشاكل في تكوين Android SDK
- **الحل**: 
  - إعداد Android SDK بشكل صحيح
  - قبول جميع التراخيص المطلوبة
  - تحديث إعدادات Gradle
  - إصلاح مشاكل التوافق في الكود

### 2. مشاكل التوافق
- **المشكلة**: أخطاء في Theme وRouting
- **الحل**:
  - تحديث `CardTheme` إلى `CardThemeData`
  - تحديث `TabBarTheme` إلى `TabBarThemeData`
  - إصلاح مشاكل التوجيه في `AppRoutes`

### 3. مشاكل البيئة
- **المشكلة**: عدم توفر بيئة تطوير مناسبة
- **الحل**: إنشاء سكريبتات إعداد شاملة

## 🛠️ السكريبتات الجديدة

### 1. `setup_development_environment.sh`
سكريبت إعداد بيئة التطوير الكاملة:
```bash
./setup_development_environment.sh
```

**الميزات:**
- تثبيت Flutter SDK
- تثبيت Android SDK
- تكوين متغيرات البيئة
- إنشاء aliases مفيدة
- تكوين VS Code

### 2. `update_and_build.sh`
سكريبت شامل للتحديث والبناء:
```bash
# بناء عادي
./update_and_build.sh

# بناء debug مع تنظيف
./update_and_build.sh -t debug -c

# تحديث التبعيات وبناء release
./update_and_build.sh -u -t release

# بناء مع تفاصيل إضافية
./update_and_build.sh -v
```

**الخيارات:**
- `-t, --type`: نوع البناء (debug/release)
- `-c, --clean`: تنظيف قبل البناء
- `-u, --update`: تحديث التبعيات
- `-v, --verbose`: إخراج مفصل
- `--no-fix`: تجاهل الإصلاحات التلقائية
- `--skip-tests`: تجاهل الاختبارات

### 3. `deploy_and_update.sh`
سكريبت النشر والتحديث:
```bash
# commit وpush
./deploy_and_update.sh -m "Fix UI issues" -p

# إنشاء release
./deploy_and_update.sh -m "Version 1.2.0" -r v1.2.0 -d

# commit بدون بناء
./deploy_and_update.sh --no-build -m "Update docs" -p
```

**الميزات:**
- إدارة Git (commit, push, tag)
- بناء APK تلقائي
- إنشاء GitHub releases
- تقارير النشر

### 4. `build_apk_fixed.sh`
سكريبت بناء APK محسن:
```bash
# بناء release
./build_apk_fixed.sh

# بناء debug
./build_apk_fixed.sh -t debug

# بناء مع تنظيف
./build_apk_fixed.sh -c -t release
```

## 🔧 الإعداد السريع

### 1. إعداد متغيرات البيئة
```bash
# نسخ نموذج البيئة
cp env.json.example env.json

# تحرير الملف وإضافة قيم Supabase الحقيقية
nano env.json
```

**محتوى env.json:**
```json
{
  "SUPABASE_URL": "https://your-project.supabase.co",
  "SUPABASE_ANON_KEY": "your-anonymous-key-here"
}
```

### 2. إعداد البيئة (مرة واحدة)
```bash
chmod +x setup_development_environment.sh
./setup_development_environment.sh
```

### 3. بناء APK مع متغيرات البيئة
```bash
chmod +x update_and_build.sh
./update_and_build.sh
```

### 4. التحقق من البيئة
```bash
/home/ubuntu/validate_environment.sh
```

## 📱 بناء APK

### الطريقة السريعة
```bash
./update_and_build.sh -t release
```

### الطريقة المفصلة
```bash
# 1. تنظيف المشروع
flutter clean

# 2. الحصول على التبعيات
flutter pub get

# 3. بناء APK مع متغيرات البيئة
flutter build apk --release --dart-define-from-file=env.json --android-skip-build-dependency-validation
```

## 🌍 إدارة متغيرات البيئة

### 📄 ملف env.json

يستخدم التطبيق ملف `env.json` لتخزين متغيرات البيئة مثل مفاتيح Supabase.

#### إنشاء ملف env.json

```bash
# 1. نسخ النموذج
cp env.json.example env.json

# 2. تحرير الملف
nano env.json  # أو أي محرر نصوص آخر
```

#### محتوى الملف المطلوب

```json
{
  "SUPABASE_URL": "https://your-project-id.supabase.co",
  "SUPABASE_ANON_KEY": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."
}
```

#### الحصول على قيم Supabase

1. انتقل إلى [Supabase Dashboard](https://app.supabase.com/)
2. اختر مشروعك
3. انتقل إلى **Settings** → **API**
4. انسخ:
   - **Project URL** → `SUPABASE_URL`
   - **anon public** key → `SUPABASE_ANON_KEY`

### 🚀 تشغيل التطبيق

#### التطوير (Development)
```bash
# تشغيل عادي مع متغيرات البيئة
flutter run --dart-define-from-file=env.json

# تشغيل في وضع debug مع hot reload
flutter run --debug --dart-define-from-file=env.json

# تشغيل على جهاز محدد
flutter run -d <device-id> --dart-define-from-file=env.json
```

#### البناء (Build)
```bash
# بناء APK للإنتاج
flutter build apk --release --dart-define-from-file=env.json

# بناء APK للتطوير
flutter build apk --debug --dart-define-from-file=env.json

# بناء App Bundle للـ Play Store
flutter build appbundle --release --dart-define-from-file=env.json
```

### ⚠️ تنبيهات أمنية

#### ❌ لا تفعل:
- **لا ترفع** ملف `env.json` إلى GitHub أو أي مستودع عام
- **لا تشارك** مفاتيح Supabase في الكود أو الوثائق
- **لا تضع** المفاتيح في ملفات التكوين العامة

#### ✅ افعل:
- استخدم `env.json.example` كنموذج فقط (بدون قيم حقيقية)
- احتفظ بـ `env.json` محلياً فقط
- استخدم GitHub Secrets للـ CI/CD
- راجع ملف `.gitignore` للتأكد من استبعاد `env.json`

### 🔍 استكشاف مشاكل البيئة

#### المشكلة: "Environment variables not found"
```bash
# التحقق من وجود الملف
ls -la env.json

# التحقق من محتوى الملف
cat env.json

# التأكد من صحة JSON
python3 -m json.tool env.json
```

#### المشكلة: "Invalid Supabase configuration"
```bash
# التحقق من صحة URL
echo $SUPABASE_URL  # يجب أن يبدأ بـ https://

# التحقق من طول المفتاح
echo $SUPABASE_ANON_KEY | wc -c  # يجب أن يكون طويل (عادة 200+ حرف)
```

#### المشكلة: التطبيق يعمل في "Demo Mode"
هذا يعني أن متغيرات البيئة غير صحيحة أو غير موجودة:

1. تحقق من وجود `env.json`
2. تحقق من صحة القيم
3. تأكد من استخدام `--dart-define-from-file=env.json`
4. راجع رسائل التشخيص في الكونسول

### 📋 أوامر سريعة

```bash
# إنشاء env.json من النموذج
cp env.json.example env.json

# تشغيل التطبيق مع البيئة
flutter run --dart-define-from-file=env.json

# بناء APK مع البيئة
flutter build apk --release --dart-define-from-file=env.json

# التحقق من حالة البيئة
flutter run --dart-define-from-file=env.json | grep "Environment"
```

## 📂 هيكل الملفات الجديد

```
bidwar/
├── setup_development_environment.sh  # إعداد بيئة التطوير
├── update_and_build.sh              # تحديث وبناء شامل
├── deploy_and_update.sh             # نشر وتحديث
├── build_apk_fixed.sh               # بناء APK محسن
├── artifacts/                       # ملفات APK المبنية
├── .vscode/                         # إعدادات VS Code
│   ├── settings.json
│   └── launch.json
└── env.json                         # متغيرات البيئة
```

## 🎯 الميزات الجديدة

### 1. إصلاح تلقائي للمشاكل
- إصلاح مشاكل Theme
- إصلاح مشاكل Routing
- تحديث إعدادات Gradle
- إصلاح أذونات الملفات

### 2. إدارة شاملة للبناء
- دعم أنواع بناء متعددة
- تنظيف تلقائي
- تحديث التبعيات
- تقارير مفصلة

### 3. تكامل Git
- commit تلقائي
- إنشاء tags
- push للمستودع
- إنشاء releases

### 4. تقارير مفصلة
- معلومات البناء
- أحجام الملفات
- أوقات البناء
- معلومات البيئة

## 🔍 استكشاف الأخطاء

### مشكلة: Flutter غير موجود
```bash
# الحل
./setup_development_environment.sh
source ~/.bashrc
```

### مشكلة: Android SDK غير مكون
```bash
# الحل
export ANDROID_HOME="/usr/lib/android-sdk"
flutter config --android-sdk /usr/lib/android-sdk
```

### مشكلة: تراخيص Android غير مقبولة
```bash
# الحل
yes | flutter doctor --android-licenses
```

### مشكلة: فشل بناء APK
```bash
# الحل
./update_and_build.sh -c -v
```

## 📊 الأداء

### أوقات البناء المتوقعة
- **Debug Build**: 2-5 دقائق
- **Release Build**: 3-7 دقائق
- **Clean Build**: 5-10 دقائق

### أحجام APK المتوقعة
- **Debug APK**: 50-80 MB
- **Release APK**: 20-40 MB

## 🚀 النشر

### نشر محلي
```bash
./update_and_build.sh -t release
# APK متوفر في artifacts/
```

### نشر GitHub
```bash
./deploy_and_update.sh -m "Release v1.0.0" -r v1.0.0 -d
```

## 📞 الدعم

### الأوامر المفيدة
```bash
# فحص البيئة
flutter doctor -v

# تنظيف المشروع
flutter clean

# تحديث التبعيات
flutter pub upgrade

# فحص الأجهزة المتصلة
adb devices

# عرض سجلات Flutter
flutter logs
```

### الملفات المهمة
- `env.json`: متغيرات البيئة
- `artifacts/`: ملفات APK المبنية
- `android/build.gradle`: إعدادات Android
- `pubspec.yaml`: تبعيات Flutter

## 🎉 الخلاصة

تم حل جميع مشاكل بناء APK وإضافة سكريبتات شاملة للتطوير والنشر. المشروع الآن جاهز للاستخدام مع:

✅ بيئة تطوير مكتملة  
✅ بناء APK يعمل بشكل صحيح  
✅ سكريبتات تحديث تلقائية  
✅ إدارة Git متكاملة  
✅ تقارير مفصلة  
✅ استكشاف أخطاء شامل  

---

**تم التحديث:** $(date)  
**الإصدار:** 1.0.0  
**المطور:** Manus AI Assistant

