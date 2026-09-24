<p align="center">
  <img src="https://raw.githubusercontent.com/Abojawdat/iPhone-Duo-package-/main/doc/banner.svg" width="100%" alt="duo_dynamic_sizing: تخطيط متكيّف لهاتف iPhone Duo القابل للطي ولكل شاشة أخرى">
</p>

<p align="center">
  <a href="https://github.com/Abojawdat/iPhone-Duo-package-/blob/main/README.md">English</a> · <b>العربية</b>
</p>

<p align="center">
  <a href="https://pub.dev/packages/duo_dynamic_sizing"><img src="https://img.shields.io/pub/v/duo_dynamic_sizing?style=flat-square&color=6D5DFC&labelColor=0A0B14&label=pub" alt="pub version"></a>
  <img src="https://img.shields.io/badge/iPhone_Duo-ready-22D3EE?style=flat-square&labelColor=0A0B14" alt="iPhone Duo ready">
  <img src="https://img.shields.io/badge/Flutter-3.41%2B-A855F7?style=flat-square&labelColor=0A0B14" alt="Flutter 3.41+">
  <img src="https://img.shields.io/badge/native_code-none-8B7CFF?style=flat-square&labelColor=0A0B14" alt="no native code">
  <img src="https://img.shields.io/badge/RTL-ready-34D399?style=flat-square&labelColor=0A0B14" alt="RTL ready">
  <a href="https://github.com/Abojawdat/iPhone-Duo-package-/blob/main/LICENSE"><img src="https://img.shields.io/badge/license-MIT-9AA0B8?style=flat-square&labelColor=0A0B14" alt="MIT license"></a>
</p>

<div dir="rtl">

<p align="center">
  <b>واجهة واحدة <code>context.duo</code> تعرف إن كان الهاتف مطوياً أو مفتوحاً أو مائلاً أو يتقاسم الشاشة مع تطبيق آخر.</b><br>
  عناصر واجهة ترتّب المحتوى وتدير التنقل وتحفظ الحالة تماماً كما يفعل iOS 27 على أول هاتف قابل للطي من Apple.<br>
  مكتوبة بلغة Dart فقط، وتعمل اليوم على iOS وAndroid والويب وأجهزة سطح المكتب، بالعربية والإنجليزية وبأي لغة أخرى.
</p>

---

## شاهدها وهي تعمل

كل مقطع أدناه هو [التطبيق التجريبي](example/lib/main.dart) الحقيقي وهو يستخدم هذه الحزمة، مُصيَّراً إطاراً بعد إطار. لا شيء هنا مجرد تصميم وهمي.

### ١. الطي والفتح

</div>

<p align="center">
  <img src="https://raw.githubusercontent.com/Abojawdat/iPhone-Duo-package-/main/doc/fold.webp" width="100%" alt="تبقى الرسالة نفسها مفتوحة بينما يُفتح هاتف iPhone Duo من لوحة واحدة إلى قائمة وتفاصيل">
</p>

<div dir="rtl">

**ماذا يحدث:** عندما يكون الهاتف مطوياً تملأ الرسالة الشاشة الخارجية بعرض 466 نقطة. افتح الهاتف فتعود القائمة لتظهر بجانب الرسالة نفسها، وفي نفس موضع التمرير الذي تركتها عنده.<br>
**لماذا:** تعتبر Apple الاستمرارية عند الطي شرطاً أساسياً، فالمستخدم يطوي الهاتف في منتصف القراءة ويتوقع أن يعود إلى المكان نفسه تماماً. لا يُعاد بناء أي شيء من الصفر؛ الحزمة تنقل عنصر الواجهة نفسه إلى مكانه الجديد.<br>
**الكود:** `DuoListDetail` داخل `DuoNavigationScaffold`، ولا شيء غير ذلك.

### ٢. العرض المقسّم (Split View)

</div>

<p align="center">
  <img src="https://raw.githubusercontent.com/Abojawdat/iPhone-Duo-package-/main/doc/anim/split.webp" width="100%" alt="يتقلص التطبيق إلى وضع العرض المقسّم وينتقل شريط التنقل إلى الحافة الخارجية">
</p>

<div dir="rtl">

**ماذا يحدث:** ينضم تطبيق ثانٍ إلى الشاشة، فيتقلص تطبيقك مباشرة من 951 إلى 475 نقطة. وفي اللحظة التي يصبح فيها جزءاً من العرض المقسّم، ينتقل شريط التنقل من جهة الجزيرة الديناميكية إلى الحافة الخارجية للتطبيق، وتتحول القائمة إلى لوحة واحدة.<br>
**لماذا:** هذا هو المكان الذي يضع فيه iOS 27 أشرطة التطبيق الأيسر. كل عرض وسيط يُرتَّب فعلياً، فلا توجد قفزات بين مقاسات قليلة مختارة يدوياً.<br>
**الكود:** لا شيء إضافي. تخبرك `context.duo.isSplit` متى يحدث ذلك.

### ٣. نصف مفتوح: وضع الطاولة ووضع الكتاب

</div>

<p align="center">
  <img src="https://raw.githubusercontent.com/Abojawdat/iPhone-Duo-package-/main/doc/anim/postures.webp" width="100%" alt="جهاز Android قابل للطي ينثني إلى وضع الطاولة ثم وضع الكتاب ويتبع التخطيط المفصل">
</p>

<div dir="rtl">

**ماذا يحدث:** عندما يوضع الجهاز على طاولة، يقفز الفيديو إلى ما فوق خط الطي وتنزل أزرار التحكم إلى النصف السفلي. وعندما يُمسك مثل الكتاب، تنتقل أزرار التحكم إلى النصف الأخير في اتجاه القراءة.<br>
**لماذا:** الشاشة المنثنية سطحان مختلفان. المحتوى الذي يمتد فوق خط الطي صعب القراءة وصعب اللمس، وإرشادات Apple تقول الشيء نفسه.<br>
**الكود:** `DuoSplit` للنصفين، و`DuoAvoidFold` لأزرار التحكم العائمة، و`context.duo.posture` لاتخاذ القرار.

### ٤. التدوير

</div>

<p align="center">
  <img src="https://raw.githubusercontent.com/Abojawdat/iPhone-Duo-package-/main/doc/anim/rotate.webp" width="100%" alt="هاتف iPhone Duo مطوياً ومفتوحاً يدور ويتبعه التنقل">
</p>

<div dir="rtl">

**ماذا يحدث:** عند تدوير الهاتف المطوي أفقياً، تنتقل الجزيرة الديناميكية إلى الأعلى ويبقى شريط التنقل على الجانب. وعند تدوير الهاتف المفتوح عمودياً، يتحول الشريط الجانبي إلى شريط سفلي، وهي الوضعية الوحيدة التي يُبقي فيها iOS الأشرطة أفقية.<br>
**لماذا:** الشاشة الداخلية في Duo تتجاهل قفل الاتجاه، لذا يجب أن يتبع التخطيط النافذة لا اتجاه الجهاز.<br>
**الكود:** يقرر `DuoNavigationScaffold` ذلك عبر `context.duo.prefersRail`.

### ٥. النوافذ القابلة لتغيير الحجم

</div>

<p align="center">
  <img src="https://raw.githubusercontent.com/Abojawdat/iPhone-Duo-package-/main/doc/anim/resize.webp" width="100%" alt="نافذة على سطح المكتب تُسحب من عرض الهاتف إلى عرض واسع والتخطيط يواكبها">
</p>

<div dir="rtl">

**ماذا يحدث:** تُسحب نافذة على سطح المكتب من 360 إلى 1240 نقطة، فيتحدث الوضع وعدد اللوحات ونوع التنقل في كل إطار.<br>
**لماذا:** القواعد نفسها التي تتعامل مع Duo تتعامل أيضاً مع Stage Manager على iPad ومتصفحات الويب ونوافذ سطح المكتب. مجموعة واحدة من قرارات التخطيط تغطي كل الشاشات.<br>
**الكود:** التطبيق نفسه، دون أي فحص للمنصة.

### ٦. العربية والإنجليزية

</div>

<p align="center">
  <img src="https://raw.githubusercontent.com/Abojawdat/iPhone-Duo-package-/main/doc/anim/rtl.webp" width="100%" alt="التطبيق ينقلب من الإنجليزية إلى واجهة عربية من اليمين إلى اليسار">
</p>

<div dir="rtl">

**ماذا يحدث:** يتحول التطبيق إلى العربية، فتنتقل القائمة إلى اليمين والتفاصيل إلى اليسار، بينما يبقى التقسيم على خط الطي الفعلي تماماً.<br>
**لماذا:** اتجاه القراءة يحدد مكان اللوحة الأساسية، والمفصل يحدد مكان التقسيم. الخلط بين الأمرين يضع المحتوى فوق خط الطي.<br>
**الكود:** تلقائي حسب `Directionality` في تطبيقك. ويمكنك تجاوزه عبر `textDirection:` و`railSide:`.

### ٧. ملاءمة الفيديو

</div>

<p align="center">
  <img src="https://raw.githubusercontent.com/Abojawdat/iPhone-Duo-package-/main/doc/anim/media.webp" width="100%" alt="الفيديو نفسه بنسبة 16:9 يتنقل بين أوضاع contain وcover وsmart">
</p>

<div dir="rtl">

**ماذا يحدث:** يتنقل الفيديو نفسه بنسبة 16:9 بين `contain` (أشرطة سوداء)، و`cover` (مع قصّ)، و`smart` الذي لا يقص إلا إذا كان الجزء المفقود أقل من 15%.<br>
**لماذا:** شكل الشاشة الداخلية √2، فيترك فيديو 16:9 أشرطة سوداء بارتفاع 134 نقطة. أحياناً يكون القص البسيط هو الخيار الأفضل، وأحياناً لا يكون.<br>
**الكود:** `DuoMedia(aspectRatio: 16 / 9, child: player)`.

## iPhone Duo بكل وضعياته

</div>

<p align="center">
  <img src="https://raw.githubusercontent.com/Abojawdat/iPhone-Duo-package-/main/doc/iphone-duo.webp" width="100%" alt="التطبيق التجريبي على iPhone Duo مطوياً ومفتوحاً وعمودياً وأفقياً وفي العرض المقسّم">
</p>

<div dir="rtl">

| الوضعية | النافذة (نقطة) | ما يحصل عليه تطبيقك |
| --- | --- | --- |
| **مطوي** | 466 × 678 | لوحة واحدة، وشريط التنقل على اليمين بجانب الجزيرة الديناميكية العمودية. |
| **مطوي وأفقي** | 678 × 466 | لوحة واحدة في الوضع الأفقي. |
| **مفتوح** | 951 × 669 | لوحتان مقسومتان على خط الطي تماماً. |
| **مفتوح وعمودي** | 669 × 951 | لوحتان وشريط تنقل سفلي. |
| **العرض المقسّم** | نحو 475 × 669 | لوحة واحدة لكل تطبيق، وشريط التنقل على الحافة الخارجية لكل منهما. |

## وكل شاشة أخرى

</div>

<p align="center">
  <img src="https://raw.githubusercontent.com/Abojawdat/iPhone-Duo-package-/main/doc/everywhere.webp" width="100%" alt="التطبيق نفسه على iPhone وجهاز Android قابل للطي بوضعي الكتاب والطاولة وعلى iPad">
</p>

<div dir="rtl">

على أجهزة Android القابلة للطي تقرأ الحزمة خط الطي الحقيقي من `MediaQuery.displayFeatures`. وتحصل الهواتف والأجهزة اللوحية والويب وسطح المكتب على عناصر الواجهة نفسها، وفقاً لحجم النافذة.

## التثبيت

</div>

```sh
flutter pub add duo_dynamic_sizing
```

<div dir="rtl">

تحتاج إلى Flutter 3.41 أو أحدث (Dart 3.11 أو أحدث). لا إعدادات، ولا كود خاص بالمنصات، ولا صلاحيات.

## مثال بسيط

تطبيق كامل في نحو 40 سطراً: قائمة رسائل تتحول إلى قائمة وتفاصيل عندما تتسع المساحة، مع نوع التنقل المناسب على كل شاشة. الملف هو [`example/lib/minimal.dart`](example/lib/minimal.dart)، ويمكنك تشغيله عبر `flutter run -t lib/minimal.dart`.

</div>

```dart
import 'package:duo_dynamic_sizing/duo_dynamic_sizing.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: Inbox()));

class Inbox extends StatefulWidget {
  const Inbox({super.key});

  @override
  State<Inbox> createState() => _InboxState();
}

class _InboxState extends State<Inbox> {
  int tab = 0;
  int? open;

  @override
  Widget build(BuildContext context) {
    return DuoNavigationScaffold(
      appBar: AppBar(title: Text(context.duo.mode.name)),
      selectedIndex: tab,
      onDestinationSelected: (i) => setState(() => tab = i),
      destinations: const [
        DuoDestination(icon: Icon(Icons.inbox), label: 'Inbox'),
        DuoDestination(icon: Icon(Icons.star), label: 'Starred'),
      ],
      body: DuoListDetail<int>(
        selected: open,
        onClose: () => setState(() => open = null),
        empty: (_) => const Center(child: Text('Pick a message')),
        list: (_) => ListView.builder(
          itemCount: 30,
          itemBuilder: (_, i) => ListTile(
            title: Text('Message $i'),
            selected: i == open,
            onTap: () => setState(() => open = i),
          ),
        ),
        detail: (_, i) => Center(child: Text('Message $i')),
      ),
    );
  }
}
```

<div dir="rtl">

الكود نفسه يعطيك كل ما يلي:

| الشاشة | النتيجة |
| --- | --- |
| iPhone Duo مطوي | القائمة، ثم الرسالة بملء الشاشة عند لمسها، وشريط التنقل بجانب الجزيرة |
| iPhone Duo مفتوح | القائمة والرسالة جنباً إلى جنب، مقسومتان على خط الطي |
| العرض المقسّم | لوحة واحدة، وشريط التنقل على الحافة الخارجية للتطبيق |
| جهاز Android نصف مفتوح | اللوحتان مقسومتان على المفصل تماماً |
| iPhone | لوحة واحدة وشريط تنقل سفلي |
| iPad وسطح المكتب والويب | القائمة والرسالة جنباً إلى جنب مع شريط تنقل جانبي |
| تطبيق بالعربية أو العبرية | كل شيء معكوس، ويبقى التقسيم على خط الطي |

ويمكنك قراءة بيانات النافذة بنفسك في أي مكان:

</div>

```dart
final duo = context.duo; // يُعاد البناء عند الطي والتدوير والعرض المقسّم

if (duo.isExpanded) { /* لوحتان */ }
duo.mode;             // DuoMode.openLandscape
duo.safe.right;       // 59، جهة الجزيرة الديناميكية
duo.gridColumns(160); // عدد زوجي من الأعمدة حول خط الطي
```

<div dir="rtl">

## لماذا بُنيت بهذه الطريقة

هذه هي النسخة المختصرة. التفاصيل الكاملة مع البدائل التي استبعدناها موجودة في [DESIGN.ar.md](https://github.com/Abojawdat/iPhone-Duo-package-/blob/main/DESIGN.ar.md) ([English](https://github.com/Abojawdat/iPhone-Duo-package-/blob/main/DESIGN.md)).

- **الأحجام لا تُكبَّر أبداً.** لشاشتي Duo الحجم الفعلي نفسه للنقطة، نحو 153 نقطة في البوصة. لو كُبّر النص حسب العرض لقفز الخط من 16 إلى 33 نقطة عند فتح الهاتف، لذلك يكسب التخطيط لوحات إضافية لا عناصر أكبر.
- **كل شيء يأتي من `MediaQuery`.** هذا يجعل الحزمة تفاعلية وقابلة للاختبار ومتوافقة مع المحاكاة، ولا يُعاد البناء إلا عندما تتغير النافذة فعلاً.
- **Dart فقط.** تعمل اليوم على كل إصدار من Flutter بدءاً من 3.41 وعلى كل المنصات، دون الحاجة إلى Xcode 27.1 أو CocoaPods.
- **يُكتشف iPhone Duo من مقاسات شاشته الدقيقة** بكثافة 3x على iOS، فلا يُخلط أبداً مع iPad أو هواتف Android أو نوافذ سطح المكتب.
- **الحالة تبقى بعد كل طيّة** لأن الحزمة تنقل عناصر الواجهة بدلاً من إعادة بنائها.
- **مُختبرة بقسوة:** 97 اختباراً للوحدات وعناصر الواجهة والحالات الحدّية والصور المرجعية (golden)، إضافة إلى 10 اختبارات تكامل على تطبيق macOS الحقيقي.

## ماذا تحتوي الحزمة

| | |
| --- | --- |
| `context.duo` | الوضع، مطوي أو مفتوح، عدد اللوحات، خط الطي، الوضعية، المناطق الآمنة لكل جهة، الهوامش، أعمدة الشبكة. |
| `DuoLayout` + `DuoKeep` | تخطيط منفصل للوضع المطوي وآخر للمفتوح، مع الحفاظ على حالة العناصر المشتركة وموضع التمرير. |
| `DuoSplit` | لوحتان تحاذيان خط الطي أو المفصل، ولوحة واحدة عندما لا تتسع المساحة. نسخة Flutter من `ArrangementView` المقسّم لدى Apple. |
| `DuoListDetail` | قائمة وتفاصيل على طريقة تطبيقات البريد، مع معالجة زر الرجوع واستمرارية الطي. |
| `DuoNavigationScaffold` | شريط سفلي أو شريط جانبي، في المكان الذي يضع فيه iOS 27 أشرطته العمودية. ويختار `railSide` الجهة للتطبيقات من اليسار إلى اليمين ومن اليمين إلى اليسار. |
| `DuoAvoidFold` | يُبعد أزرار التحكم عن خط الطي عند نصف الفتح: النصف الأخير في وضع الكتاب، والنصف السفلي على الطاولة. |
| `DuoMedia` | يلائم فيديو 16:9 مع شاشة بنسبة √2، ولا يقص إلا عندما يكون الفاقد قليلاً. |
| `DuoSimulator` + `DuoPose` | كل وضعيات iPhone Duo وأجهزة Android القابلة للطي وiPhone وiPad، على أي جهاز وفي اختبارات عناصر الواجهة. |
| `DuoDebugOverlay` | عرض حيّ للوضع والحجم والمنطقة الآمنة وخط الطي. |

## `context.duo`

| العضو | النوع | ماذا يخبرك |
| --- | --- | --- |
| `mode` | `DuoMode` | `closedPortrait` و`closedLandscape` و`openLandscape` و`openPortrait` و`splitView` و`tablet` و`desktop` |
| `isIphoneDuo` | `bool` | النافذة تطابق إحدى شاشتي iPhone Duo. |
| `isOpen` و`isClosed` و`isSplit` | `bool` | حالة الجهاز. |
| `isExpanded` و`columns` | `bool` و`int` | هل تتسع المساحة للوحتين (600 × 480 فأكثر). اعتمد عليهما في التخطيط. |
| `fold` و`foldDirection` | `Rect?` و`Axis?` | مكان خط الطي بإحداثيات النافذة. |
| `isSeparating` و`posture` | `bool` و`DuoPosture` | طية نصف مفتوحة أو مفصل: `flat` و`book` و`tabletop` و`closed`. |
| `safe` و`symmetricSafe` | `EdgeInsets` | الحواف الآمنة لكل جهة على حدة، أو أكبرها معكوساً للمحتوى المتمركز. |
| `margin` | `double` | 16 على الشاشات الضيقة، و24 فيما عداها (Material 3). |
| `prefersRail` | `bool` | شريط جانبي بدلاً من الشريط السفلي. |
| `gridColumns(minWidth)` | `int` | عدد الأعمدة الممكن، ويبقى زوجياً حول خط الطي العمودي. |

ولتغيير الحدود لجزء من الشجرة استخدم `DuoScope(expandedWidth: 700, child: ...)`.

## عناصر الواجهة

**تخطيطان وحالة واحدة.** ينقل `DuoKeep` العنصر نفسه بين التخطيطين بدلاً من إعادة بنائه:

</div>

```dart
DuoLayout(
  closed: (_) => DuoKeep(id: 'feed', child: const Feed()),
  open: (_) => Row(children: [
    Expanded(child: DuoKeep(id: 'feed', child: const Feed())),
    const Expanded(child: Trends()),
  ]),
)
```

<div dir="rtl">

**لوحات تتبع خط الطي:**

</div>

```dart
DuoSplit(primary: const Player(), secondary: const UpNext())
```

<div dir="rtl">

**أزرار تحكم تتجنب خط الطي:**

</div>

```dart
Stack(children: [
  const VideoPlayer(),
  const DuoAvoidFold(
    child: Align(alignment: Alignment.bottomCenter, child: Controls()),
  ),
])
```

<div dir="rtl">

**فيديو يلائم الشاشة:**

</div>

```dart
DuoMedia(aspectRatio: 16 / 9, child: player) // smart: يقص حتى 15% وإلا أضاف أشرطة
```

<div dir="rtl">

## من اليمين إلى اليسار ومن اليسار إلى اليمين

كل شيء يتبع `Directionality` في تطبيقك، فتحصل تطبيقات العربية والعبرية والفارسية على تخطيطات معكوسة دون أي كود إضافي. وعندما تتبادل اللوحتان مكانيهما، يبقى التقسيم على خط الطي الفعلي تماماً.

| | تطبيق من اليسار إلى اليمين | تطبيق من اليمين إلى اليسار |
| --- | --- | --- |
| `DuoSplit` و`DuoListDetail` | اللوحة الأساسية (القائمة) على اليسار | اللوحة الأساسية (القائمة) على اليمين |
| `DuoAvoidFold` في وضع الكتاب | النصف الأيمن | النصف الأيسر |
| `DuoSplit(ratio: .3)` | اللوحة الأساسية تأخذ 30% من اليسار | اللوحة الأساسية تأخذ 30% من اليمين |

وتختار أنت مكان شريط التنقل عبر `railSide`:

| `railSide` | iPhone Duo | الأجهزة الأخرى |
| --- | --- | --- |
| `auto` (الافتراضي) | اليمين بجانب الجزيرة الديناميكية، مثل أشرطة iOS 27 العمودية في كل اللغات | جهة البداية: اليسار في الإنجليزية، واليمين في العربية |
| `start` | جهة البداية | جهة البداية |
| `end` | جهة النهاية | جهة النهاية |
| `left` و`right` | تلك الجهة دائماً | تلك الجهة دائماً |

</div>

```dart
DuoNavigationScaffold(railSide: DuoRailSide.start, ...) // اتبع اتجاه القراءة في كل مكان
DuoListDetail(textDirection: TextDirection.ltr, ...)     // ثبّت تخطيطاً واحداً مهما كانت لغة التطبيق
```

<div dir="rtl">

## اختبر كل الوضعيات دون جهاز

</div>

```dart
testWidgets('unfolding keeps the draft', (tester) async {
  await tester.pumpWidget(
    const DuoSimulator(pose: DuoPose.closedPortrait, child: MyApp()),
  );
  await tester.enterText(find.byType(TextField), 'draft');

  await tester.pumpWidget(
    const DuoSimulator(pose: DuoPose.openLandscape, child: MyApp()),
  );
  expect(find.text('draft'), findsOneWidget);
});
```

<div dir="rtl">

الوضعيات الجاهزة: `closedPortrait` و`closedLandscape` و`openLandscape` و`openPortrait` و`splitLeft` و`splitRight` و`foldableBook` و`foldableTabletop` و`iPhone` و`iPad`. ويمكنك إنشاء وضعياتك الخاصة عبر `DuoPose(...)`.

ولرؤية القيم الحية أثناء التطوير:

</div>

```dart
MaterialApp(
  builder: (context, child) =>
      DuoDebugOverlay(enabled: kDebugMode, child: child!),
)
```

<div dir="rtl">

## قبل النشر على iPhone Duo

- **ابنِ تطبيقك باستخدام iOS 27.1 SDK (Xcode 27.1).** التطبيقات المبنية بإصدارات أقدم تعمل داخل إطار ضيق على الشاشة الداخلية.
- **اعتمد دورة حياة UIScene.** تطبيقات Xcode 27 تتوقف عند التشغيل بدونها. يقوم Flutter 3.41 وما بعده بالتحويل تلقائياً إذا لم تعدّل `AppDelegate`؛ راجع [دليل UIScene من Flutter](https://docs.flutter.dev/release/breaking-changes/uiscenedelegate).
- **لا تعتمد على قفل الاتجاه.** الشاشة الداخلية تتجاهل `SystemChrome.setPreferredOrientations`.
- **لا تخزّن الأحجام داخل `State`.** اقرأ `MediaQuery` أو `context.duo` داخل `build`.
- **عامل الحافة اليسرى واليمنى كلاً على حدة.** الجزيرة الديناميكية تمتد على جانب واحد فقط.
- **أوقف الوسائط عند `paused` لا عند `inactive`.** في العرض المقسّم يبقى تطبيقك ظاهراً وهو في حالة `inactive`.
- **أبعد عناصر اللمس عن خط الطي عند نصف الفتح.** استخدم `DuoAvoidFold` و`DuoSplit`.

## iPhone Duo في لمحة

| | الشاشة الخارجية | الشاشة الداخلية |
| --- | --- | --- |
| القطر | 5.4 بوصة | 7.6 بوصة |
| اللوحة | 1398 × 2034 بكسل، 460 بكسل في البوصة | 1878 × 2670 بكسل، 430 بكسل في البوصة |
| النقاط (ما يراه Flutter) | 466 × 678 بكثافة 3x | 669 × 951 بكثافة 3x، تُرسم بدقة 2007 × 2853 ثم تُصغَّر إلى اللوحة |
| فئة الحجم | ضيقة (compact) | عادية × عادية (regular) |

أعلنت عنه Apple في 9 سبتمبر 2026، ويصل إلى الأسواق في 23 أكتوبر 2026 بنظام iOS 27.1. أبعاده 164.6 × 117.8 ملم مفتوحاً و84.1 × 117.8 ملم مطوياً، ووزنه 254 غراماً.

## القيود الحالية

- **لا توجد زاوية المفصل ولا وضعية نصف الفتح على iOS حتى الآن.** محرك Flutter على iOS لا يمرّر بيانات مفصل iPhone Duo إلى Dart ([flutter#192515](https://github.com/flutter/flutter/issues/192515)). إلى أن يحدث ذلك، تكون `posture` على Duo إما `closed` أو `unknown`، ويكون خط الطي هو خط المنتصف الفعلي المعروف. وعندما يبدأ المحرك بإرسال هذه البيانات ستلتقطها الحزمة تلقائياً عبر `displayFeatures`. وإذا احتجت زاوية المفصل الحية اليوم، فاستخدمها مع إضافة أصلية مثل [`foldable`](https://pub.dev/packages/foldable).
- **المناطق الآمنة في المحاكاة تقديرية.** لم تنشر Apple قيم الحواف الآمنة لجهاز Duo، لذلك تستخدم `DuoPose` القيمتين 59 و21 نقطة. أما الأجهزة الحقيقية فتستخدم القيم الحية دائماً.
- **جهة التطبيق في العرض المقسّم تُستنتج** من الجهة التي تحمل حافة الجزيرة الديناميكية.
- **لا يوجد في Flutter مقابل للأشرطة العمودية الأصلية.** يحاكي `DuoNavigationScaffold` أماكنها باستخدام عناصر Material.

## التطبيق التجريبي

</div>

```sh
cd example
flutter run                    # العرض الكامل مع أداة اختيار الوضعيات
flutter run -t lib/minimal.dart # التطبيق ذو الأربعين سطراً أعلاه
```

<div dir="rtl">

في العرض الكامل، اختر أي وضعية من شريط الخيارات لمحاكاتها على جهازك الحالي، أو فعّل **RTL** لرؤية النسخة العربية، أو اختر **This device** لتشغيله على جهازك فعلياً.

## المساهمة

نرحب بالإبلاغ عن الأخطاء وطلبات الدمج في [صفحة المشكلات](https://github.com/Abojawdat/iPhone-Duo-package-/issues). وإذا لاحظت شيئاً غير صحيح على جهاز iPhone Duo حقيقي، فإن لقطة شاشة مع تفعيل `DuoDebugOverlay` ستساعد كثيراً.

</div>

<p align="center">
  <img src="https://raw.githubusercontent.com/Abojawdat/iPhone-Duo-package-/main/doc/logo.svg" width="56" alt="شعار duo_dynamic_sizing"><br>
  <sub>MIT © Mohammad Othman</sub><br>
  <sub>iPhone وiPhone Duo علامتان تجاريتان لشركة Apple Inc. هذه الحزمة غير تابعة لشركة Apple ولا معتمدة منها.</sub>
</p>
