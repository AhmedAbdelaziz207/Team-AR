# 🏛️ الوثيقة الهندسية الشاملة لمنظومة التدريب والتغذية (Master System Specification V2)
## تطبيق ومنصة Team AR

**الإصدار:** 2.0 (Master Draft)  
**الحالة:** وثيقة حية نشطة (Active Master Document) قابلة للإلحاق والتوسيع  
**التاريخ:** 5 أكتوبر 2026  

---

## 📑 فهرس المحتويات
1. [الرؤية وفصل الصلاحيات (Roles & Permissions Architecture)](#1-الرؤية-وفصل-الصلاحيات)
2. [مخطط قاعدة البيانات والعلاقات (Database Schema & Relations)](#2-مخطط-قاعدة-البيانات-والعلاقات)
3. [شاشات وتدفقات المدرب (Coach Panel & Workflows)](#3-شاشات-وتدفقات-المدرب)
4. [شاشات وتجربة المتدرب الكاملة (Trainee Applications & Screens)](#4-شاشات-وتجربة-المتدرب-الكاملة)
5. [المعايير الفنية وتجربة الاستخدام (Technical & UX Standards)](#5-المعايير-الفنية-وتجربة-الاستخدام)
6. [مساحة استيعاب التفاصيل الإضافية القادمة (Incoming Details Staging Area)](#6-مساحة-استيعاب-التفاصيل-الإضافية-القادمة)

---

## 1. الرؤية وفصل الصلاحيات (Roles & Permissions Architecture)

النظام مصمم وفق مبدأ فصل الصلاحيات والمسؤوليات (Role-Based Access Control):

```
┌──────────────────────────────────────────────────────────────┐
│                    نظام صلاحيات Team AR                      │
├──────────────────────────────┬───────────────────────────────┤
│        المدرب (Coach)         │       المتدرب (Trainee)       │
├──────────────────────────────┼───────────────────────────────┤
│ • بناء أيام التمارين          │ • استعراض اليوم التدريبي       │
│ • ضبط معايير الأحمال بدقة     │ • تتبع تمرين مفرد مع الفيديو  │
│   (RIR, Tempo, Rest, Tips)   │ • خوض "وضع التركيز" الحي 🔥    │
│ • بناء الخطط الغذائية الكاملة │ • تسجيل المجموعات والأداء      │
│   (الماكروز، لترات الماء،     │ • تفعيل مؤقت الراحة التلقائي   │
│    المكونات بالجرامات)        │ • تتبع الماكروز واستهلاك الماء │
│ • متابعة الالتزام وتطور الأوزان│ • تأكيد تناول الوجبات         │
└──────────────────────────────┴───────────────────────────────┘
```

---

## 2. مخطط قاعدة البيانات والعلاقات (Database Schema & Relations)

جميع الجداول مترابطة بمفاتيح خارجية (Foreign Keys) ومدعومة بـ Row Level Security (RLS) في Supabase:

### 1) جدول المستخدمين `users`
* `id`: UUID (Primary Key - references `auth.users`)
* `role`: ENUM (`coach`, `trainee`)
* `coach_id`: UUID (Nullable - Foreign Key references `users.id` للمتدربين المرتبطين بمدرب)
* `created_at`: TIMESTAMPTZ

### 2) جدول التمارين اليومية `workouts` (يُنشئه المدرب ويُعيَّن للمتدرب)
* `id`: UUID (Primary Key)
* `coach_id`: UUID (Foreign Key references `users.id`)
* `trainee_id`: UUID (Foreign Key references `users.id`)
* `title`: VARCHAR (مثل: `"Push Day"`, `"Leg Hypertrophy"`, `"Flat Dumbbell Fly Routine"`)
* `target_muscles`: TEXT[] (مصفوفة العضلات المستهدفة: مثل `['Chest', 'Triceps', 'Shoulders']`)
* `pdf_attachment_url`: TEXT (رابط ملف الـ PDF الإرشادي المخزن والمحمي)
* `intro_video_url`: TEXT (رابط فيديو توجيهي عام للمدرب يشرح فلسفة اليوم والـ Tempo)
* `scheduled_date`: DATE (أو `day_of_week` لتحديد اليوم المجدول)
* `created_at`: TIMESTAMPTZ

### 3) جدول الحركات والتمارين `exercises` (المكونة لجدول التمرين)
* `id`: UUID (Primary Key)
* `workout_id`: UUID (Foreign Key references `workouts.id` ON DELETE CASCADE)
* `name`: VARCHAR (مثل: `"Flat Dumbbell Fly"`, `"Lateral Raises"`)
* `video_guide_url`: TEXT (فيديو توضيح التكنيك مع الـ Overlays التوجيهية)
* `technical_tip`: TEXT (الملاحظة التكنيكية السريعة، مثل: `"HORIZONTAL GRIP!! Keep elbows slightly bent"`)
* `target_sets`: INT (عدد المجموعات المطلوبة من المدرب، مثلاً: `3`)
* `target_reps_range`: VARCHAR (مدى التكرارات المطلوب، مثلاً: `"8-10"`, `"12-15"`)
* `rest_seconds`: INT (وقت الراحة المطلوب بالثواني، مثلاً: `120`)
* `rir`: INT (مؤشر التكرارات في الاحتياط Reps in Reserve، مثلاً: `2` أي التوقف قبل الفشل بتكرارين)
* `tempo`: VARCHAR (نظام سرعة الحركة Eccentric-Isometric-Concentric، مثلاً: `"3-2-2"`)
* `order_index`: INT (ترتيب التمرين داخل الجلسة: 1, 2, 3...)

### 4) جدول جلسات تسجيل التمارين `exercise_logs` (سجلات المتدرب)
* `id`: UUID (Primary Key)
* `exercise_id`: UUID (Foreign Key references `exercises.id` ON DELETE CASCADE)
* `trainee_id`: UUID (Foreign Key references `users.id` ON DELETE CASCADE)
* `date`: TIMESTAMPTZ (تاريخ ووقت أداء التمرين)
* `effort_rating`: ENUM (`easy`, `moderate`, `hard`, `max_effort`)
* `coach_feedback_notes`: TEXT (ملاحظة اختيارية من المتدرب للمدرب، أو تعليق المدرب لاحقاً)
* `completed`: BOOLEAN (هل اكتمل التمرين بالكامل)

### 5) جدول مجموعات التمرين الفردية `exercise_set_logs`
* `id`: UUID (Primary Key)
* `exercise_log_id`: UUID (Foreign Key references `exercise_logs.id` ON DELETE CASCADE)
* `set_number`: INT (رقم المجموعة: 1, 2, 3...)
* `weight`: DOUBLE PRECISION (الوزن المرفوع)
* `weight_unit`: ENUM (`kg`, `lbs`)
* `reps`: INT (عدد التكرارات المنجزة)
* `is_completed`: BOOLEAN (حالة خانة الاختيار Checkbox في وضع التركيز)

### 6) جدول الخطط الغذائية `diet_plans` (يُنشئه المدرب)
* `id`: UUID (Primary Key)
* `trainee_id`: UUID (Foreign Key references `users.id`)
* `coach_id`: UUID (Foreign Key references `users.id`)
* `plan_type`: VARCHAR (مثل: `"Low Carb Day"`, `"Moderate Carb Day"`, `"High Carb Day"`)
* `target_calories`: DOUBLE PRECISION (مثلاً `1460` kcal)
* `target_protein`: DOUBLE PRECISION (مثلاً `131.5` g)
* `target_carbs`: DOUBLE PRECISION (مثلاً `103.7` g)
* `target_fats`: DOUBLE PRECISION (مثلاً `56.8` g)
* `water_target_liters`: DOUBLE PRECISION (هدف شرب الماء اليومي، مثلاً `4.0` لتر)
* `coach_instructions`: TEXT (تعليمات خاصة بالدايت)
* `created_at`: TIMESTAMPTZ

### 7) جدول الوجبات `meals`
* `id`: UUID (Primary Key)
* `diet_plan_id`: UUID (Foreign Key references `diet_plans.id` ON DELETE CASCADE)
* `meal_type`: ENUM (`breakfast`, `lunch`, `dinner`, `snack`)
* `total_calories`: DOUBLE PRECISION
* `total_protein`: DOUBLE PRECISION
* `total_carbs`: DOUBLE PRECISION
* `total_fats`: DOUBLE PRECISION
* `cooking_video_url`: TEXT (رابط اختياري لفيديو طريقة التحضير)

### 8) جدول مكونات الوجبة `meal_ingredients`
* `id`: UUID (Primary Key)
* `meal_id`: UUID (Foreign Key references `meals.id` ON DELETE CASCADE)
* `name`: VARCHAR (مثل: `"Whole Eggs"`, `"Turkey Meat"`, `"Olive Oil"`)
* `quantity_unit`: VARCHAR (مثل: `"large 4"`, `"40 g"`, `"15 ml"`, `"tablet 1"`)
* `calories`: DOUBLE PRECISION
* `icon_key`: VARCHAR (مفتاح الأيقونة أو الصورة المخصصة للعنصر)

### 9) جدول سجلات وجبات المتدرب `trainee_meal_logs`
* `id`: UUID (Primary Key)
* `meal_id`: UUID (Foreign Key references `meals.id`)
* `trainee_id`: UUID (Foreign Key references `users.id`)
* `logged_at`: TIMESTAMPTZ
* `is_consumed`: BOOLEAN (تم تناول الوجبة)

---

## 3. شاشات وتدفقات المدرب (Coach Panel & Workflows)

### 1. شاشة بناء اليوم التدريبي (Workout Builder Screen)
* اختيار المتدرب من قائمة المشتركين.
* تحديد اسم ومسمى اليوم (Push / Pull / Legs / Upper / Lower).
* اختيار العضلات المستهدفة (عبر Chips أو خريطة عضلات تفاعلية).
* إرفاق رابط الفيديو التوجيهي العام الخاص بفلسفة اليوم ونظام التيمبو.
* إرفاق ملف الـ PDF ليكون جاهزاً للعرض الفوري لدى المتدرب.

### 2. محرر معايير التمرين الدقيقة (Exercise Parameter Configurator)
يحدد المدرب لكل تمرين:
* **اسم التمرين**: مع رابط فيديو الأداء والتكنيك الصحيح.
* **الملاحظة الفنية (`Technical Tip`)**: مثل `"HORIZONTAL GRIP!!"` أو `"Elbows tucked 45 degrees"`.
* **محددات الحمل الخمسة**:
  1. `Target Sets`: عدد المجموعات (مثال: 3).
  2. `Reps Range`: مدى التكرارات (مثال: "8-10").
  3. `Rest Time`: وقت الراحة بالثواني (مثال: 120 ثانية / دقيقتين).
  4. `RIR` (Reps In Reserve): مؤشر القرب من الفشل العضلي (من 0 إلى 4).
  5. `Tempo`: إيقاع وسرعة التكرار (مثال: 3-2-2: ثلاث ثوانٍ نزول، ثانيتان ثبات، ثانيتان صعود).

### 3. منشئ الخطة الغذائية (Diet Plan Builder)
* تحديد نمط اليوم الغذائي (Low Carb / High Carb / Moderate Carb).
* وضع أهداف الماكروز الإجمالية لليوم (السعرات، البروتين، الكارب، الدهون، لترات الماء).
* تقسيم الوجبات (فطار، غداء، عشاء، سناك).
* إدخال تفاصيل المكونات لكل وجبة بدقة: اسم المكون، الكمية/الوزن بالجرام، السعرات، وأيقونة العنصر.

### 4. لوحة متابعة المتدربين (Coach Monitoring Dashboard)
* فحص أداء المتدربين: استعراض الأوزان والتكرارات المنفذة فعلياً ومقارنتها بالأسبوع السابق.
* مراجعة تقييم الجهد (`Effort Rating: Easy / Moderate / Hard / Max Effort`) لتقرير هل يحتاج المتدرب زيادة أو تخفيف الأوزان.
* متابعة نسبة التزام المتدرب بالوجبات (`Meal Compliance Rate`) ومعدل استهلاك الماء.

---

## 4. شاشات وتجربة المتدرب الكاملة (Trainee Applications & Screens)

تتألف تجربة المتدرب من **4 شاشات رئيسية متكاملة**:

### الشاشة الأولى: نظرة عامة على يوم التمرين (Workout Overview Screen)
* **بطاقة البطل الرأسية (Hero Card)**:
  * خريطة العضلات المستهدفة بصورة توضيحية.
  * زر تحميل وعرض ملف الـ PDF الإرشادي (مع الفتح الفوري في 0 ثانية عبر الكاش الدائم).
* **شريط الإحصائيات الرقمية لليوم**:
  * إجمالي التمارين (مثلاً: 6 تمارين).
  * إجمالي المجموعات (مثلاً: 18 مجموعة).
  * إجمالي التكرارات التقديرية.
* **بوابتا الدخول الكبرى**:
  1. **"تتبع التمرين (Exercise View)"**: للدخول في التتبع المفرد لكل تمرين ومشاهدة الفيديو والتكنيك بالتفصيل.
  2. **"وضع التركيز (Focus Mode) 🔥"**: للدخول في جلسة التدريب الحية داخل الجيم.

---

### الشاشة الثانية: شاشة التمرين الفردي (Single Exercise Detail View / Logger)
* **مشغل فيديو التكنيك (Technique Video Player)**:
  * مشغل فيديو مدمج مع نصوص توجيهية مرئية (`Technical Tip Overlay`) مثل `"HORIZONTAL GRIP!!"`.
* **بطاقات مؤشرات المدرب (Coach Target Cards)**:
  * كبسولات بيانات ملونة: `Sets`, `Reps Range`, `Target Rest`, `RIR`, `Tempo`.
* **زر تبديل وحدة الوزن (`kg / lbs`)**:
  * تحويل آني دقيق عبر `WeightUtils`.
* **بطاقة الأداء السابق (Previous History Card)**:
  * جلب وعرض بيانات آخر جلسة نفذها المتدرب لنفس التمرين (المجموعات السابقة بالأوزان والتكرارات مع إيموجي الشعور السابق).
* **الجدول الديناميكي للجلسة الحالية**:
  * صفوف بعدد المجموعات المطلوبة مع حقول الوزن والتكرار وأزرار الحذف وزر إضافة مجموعة.
* **تقييم ما بعد التمرين (Post-Exercise Feedback)**:
  * شريط خيارات الإحساس: (😊 سهل / 💪 متوسط / 🔥 صعب / ⚡ أقصى مجهود).
  * حقل ملاحظات اختياري للمدرب + زر "سجل التمرين".

---

### الشاشة الثالثة: وضع التركيز أثناء التدريب (Focus Mode / Active Session) 🔥
* **شريط الرأس الثابت (Sticky HUD Header)**:
  * مؤقت زمني تراكمي مستمر (Stopwatch) لحساب زمن الجلسة بالكامل.
  * زر أحمر فخم: "إنهاء الجلسة".
* **قائمة التمارين المتتابعة (Sequential Workout Flow)**:
  * التمارين معروضة بالتسلسل كبطاقات قابلة للتمرير.
  * كل تمرين يوضح مؤشرات المدرب (RIR, Tempo, Rest) مع جدول المجموعات والأداء السابق للمقارنة السريعة.
* **نظام مؤقت الراحة التلقائي (Auto Rest Timer Bottom Bar)**:
  * بمجرد النقر على مربع الاختيار (`Checkbox`) لإنهاء أي مجموعة:
    1. يتحول المؤشر للأخضر الزمردي فوراً مع اهتزاز لمسي (Haptic Feedback).
    2. يرتفع شريط مؤقت الراحة في أسفل الشاشة ويبدأ العد التنازلي التلقائي من قيمة الراحة المحددة للتمرين (مثلاً `02:00 دقيقة`).
    3. شريط تقدم (Progress Bar) يتناقص تدريجياً.
    4. أزرار التحكم بالمؤقت: `+15s` لزيادة الوقت، `-15s` لإنقاصه، وزر `تخطي (Skip)` لإلغاء العد فوراً.
    5. عند وصول العداد لـ `00:00`: تشغيل تنبيه صوتي واهتزاز تحذيري لإعلام المتدرب ببدء المجموعة التالية.

---

### الشاشة الرابعة: لوحة التغذية وتتبع الماكروز اليومية (Diet & Nutrition Screen)
* **لوحة الماكروز التفاعلية (Daily Macros Dashboard)**:
  * حساب وطرح الماكروز المستهلكة مقابل المستهدفة:
    * السعرات: المستهلك / الهدف (المتبقي).
    * البروتين (g)، الكاربوهيدرات (g)، الدهون (g).
* **عداد الماء التفاعلي (Water Intake Tracker)**:
  * تتبع استهلاك الماء مقابل الهدف اليومي (مثلاً `4L`) بأزرار سريعة (`+250ml`).
* **أقسام الوجبات التفاعلية (Tabbed Meals: Breakfast, Lunch, Dinner, Snack)**:
  * عرض مكونات كل وجبة بدقة: اسم المكون، الكمية/الوزن بالجرام، السعرات، والأيقونة.
* **زر "سجل الوجبة" الفوري**:
  * بلمسة واحدة تتحول الوجبة إلى مكتملة، ويتم تحديث الماكروز فوراً وتسجيل الالتزام للمدرب.

---

## 5. المعايير الفنية وتجربة الاستخدام (Technical & UX Standards)

* **الألوان والهوية**:
  * الكحلي الملكي `#102E50` كلون أساسي.
  * الخلفيات النظيفة البيضاء والرمادية الفاتحة `#F8F9FA`.
  * الأخضر الزمردي `#10B981` للإنجاز ومؤقتات الراحة.
* **سرعة الجيم (Gym Fast-Flow)**:
  * تقليل الاعتماد على الكيبورد إلى الصفر كلما أمكن.
  * ردود فعل لمسية (Haptic Feedback) عند كل إنجاز مجموعة أو ضغط زر.
* **التخزين الدائم والعمل بدون إنترنت (Offline-First)**:
  * الاستفادة من التخزين الدائم بـ `getApplicationDocumentsDirectory` لفتح الجداول في 0 ثانية ومزامنة السجلات عند عودة الاتصال.

---

## 6. مساحة استيعاب التفاصيل الإضافية القادمة (Incoming Details Staging Area)

> [!NOTE]
> هذا القسم مخصص لتوثيق ودمج كافة التفاصيل، الشاشات الإضافية، أو الملاحظات الدقيقة التي ستزودنا بها تباعاً.

*(بانتظار التفاصيل الإضافية القادمة لدمجها هنا ومطابقتها مع المعمارية العامة...)*

---
*تم إنشاء هذا الملف ليكون المرجع التقني الشامل والموحد لكل ما سيتم تنفيذه في Team AR V2.*
