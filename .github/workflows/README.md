# GitHub Actions Workflows

## 🚀 BidWar APK Auto Build

### الوصف
Workflow تلقائي لبناء APK لتطبيق BidWar مع إصلاح المشاكل الشائعة تلقائياً.

### المحفزات (Triggers)
- **Push** إلى branch `main` أو `develop`
- **Pull Request** إلى branch `main`
- **Manual Trigger** (workflow_dispatch) مع خيار اختيار نوع البناء

### الميزات

#### ✅ الإصلاحات التلقائية:
- إصلاح مشاكل Theme (CardTheme → CardThemeData)
- إصلاح مشاكل Routing (AppRoutes.initial → AppRoutes.home)
- تعيين أذونات Gradle
- قبول تراخيص Android SDK

#### 🛠️ عملية البناء:
- إعداد Java 17
- إعداد Flutter 3.35.2
- إعداد Android SDK
- إنشاء ملف البيئة (env.json)
- تحليل الكود
- تشغيل الاختبارات
- بناء APK

#### 📤 النتائج:
- رفع APK كـ artifact
- إنشاء تقرير مفصل
- إنشاء release تلقائي عند وجود tag

### الاستخدام

#### 1. البناء التلقائي
```bash
# Push إلى main أو develop
git push origin main
```

#### 2. البناء اليدوي
1. اذهب إلى GitHub → Actions
2. اختر "BidWar APK Auto Build"
3. اضغط "Run workflow"
4. اختر نوع البناء (debug/release)

#### 3. إنشاء Release
```bash
# إنشاء tag وpush
git tag v1.0.0
git push origin v1.0.0
```

### المتغيرات البيئية (Secrets)

يمكن إضافة المتغيرات التالية في GitHub Secrets:

| Secret Name | Description | Required |
|-------------|-------------|----------|
| `SUPABASE_URL` | Supabase project URL | No |
| `SUPABASE_ANON_KEY` | Supabase anonymous key | No |
| `OPENAI_API_KEY` | OpenAI API key | No |
| `GEMINI_API_KEY` | Google Gemini API key | No |
| `ANTHROPIC_API_KEY` | Anthropic API key | No |
| `PERPLEXITY_API_KEY` | Perplexity API key | No |

### النتائج المتوقعة

#### ✅ عند النجاح:
- APK file في Artifacts
- تقرير بناء مفصل
- معلومات الحجم والتاريخ
- Release تلقائي (للـ tags)

#### ❌ عند الفشل:
- رسائل خطأ واضحة
- سجلات مفصلة للتشخيص
- معلومات الخطوة التي فشلت

### الأمان
- استخدام أحدث إصدارات Actions
- عدم تسريب المتغيرات الحساسة
- تشفير الـ secrets
- صلاحيات محدودة

### الصيانة
- تحديث إصدارات Flutter دورياً
- مراجعة dependencies
- تحديث Android SDK versions
- مراقبة أداء البناء

---
*تم إنشاؤه بواسطة Manus AI Assistant*

