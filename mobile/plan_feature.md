# 📋 Feature Plan Template — OffLearn Mobile

> **STRICT RULE**: Every new feature MUST follow this document before writing a single line of code.  
> This document ensures all code is **consistent**, **reusable**, and **maintainable** across the entire project.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3.x + Dart 3.x |
| State Management | GetX (`get: ^4.7.3`) |
| Backend | Supabase (`supabase_flutter`) |
| Local Storage | Hive (`hive`) |
| Screen Util | `flutter_screenutil` |
| Fonts | `google_fonts` |
| Network Check | `connectivity_plus` + `internet_connection_checker` |
| Env Config | `flutter_dotenv` |

---

## ✅ Feature Checklist (Fill Before Coding)

```
Feature Name  : ___________________________
Developer     : ___________________________
Date          : ___________________________
Depends On    : ___________________________  (other features/shared modules)
API Endpoints : ___________________________
Shared Used   : ___________________________  (list any shared/ components reused)
New Shared    : ___________________________  (list any new shared/ additions)
```

---

## 📁 Folder Structure

Every feature lives inside `lib/features/<feature_name>/` and follows this exact structure:

```
lib/
├── features/
│   └── <feature_name>/
│       ├── bindings/                # GetX dependency injection
│       │   └── <feature_name>_binding.dart
│       ├── controllers/
│       │   └── <feature_name>_controller.dart
│       └── views/
│           ├── components/          # feature-specific widgets ONLY
│           │   └── <widget_name>_widget.dart
│           └── ui/
│               └── <feature_name>_page.dart
│
├── shared/
│   ├── components/                  # reusable UI widgets
│   │   └── <component_name>_widget.dart
│   ├── controllers/                 # reusable global controllers
│   │   └── <controller_name>_controller.dart
│   ├── models/                      # all data models (shared across features)
│   │   └── <model_name>_model.dart
│   ├── utils/                       # helpers, extensions, formatters
│   │   └── <util_name>.dart
│   └── theme/                       # app theme, spacing constants, text styles
│       ├── app_theme.dart
│       ├── app_colors.dart
│       └── app_spacing.dart
│
├── data/
│   ├── remote/                      # Supabase / HTTP remote data sources (Repositories)
│   │   └── <feature_name>_repository.dart
│   └── local/                       # Hive local data sources
│
├── routes/
│   ├── app_pages.dart               # All GetX route definitions & bindings
│   └── app_routes.dart              # Route name constants
│
└── models/                          # global-level models (if any)
```

> **Rule #1**: If a component, controller, or utility is used in **more than one feature**, it **MUST** be moved to the appropriate `lib/shared/` subfolder immediately.

---

## 📐 Rule #2 — Design Spacing System (4 & 8 pt Grid)

All spacing **must** use multiples of **4 or 8**. No hardcoded arbitrary values.

### Spacing Constants (`lib/shared/theme/app_spacing.dart`)

```dart
/// All spacing values must be multiples of 4 or 8.
class AppSpacing {
  AppSpacing._();

  // 4pt base unit
  static const double xs  = 4.0;   // Extra small
  static const double sm  = 8.0;   // Small
  static const double md  = 16.0;  // Medium  ← default padding
  static const double lg  = 24.0;  // Large
  static const double xl  = 32.0;  // Extra large
  static const double xxl = 48.0;  // Double extra large
  static const double x3l = 64.0;  // Triple extra large

  // Named semantic aliases
  static const double pagePadding       = md;     // 16
  static const double sectionGap        = lg;     // 24
  static const double cardPadding       = md;     // 16
  static const double itemGap           = sm;     // 8
  static const double buttonHeight      = 48.0;   // 48 (multiple of 8)
  static const double inputHeight       = 56.0;   // 56 (multiple of 8)
  static const double iconSize          = 24.0;   // 24
  static const double borderRadius      = 8.0;    // 8
  static const double borderRadiusLarge = 16.0;   // 16
}
```

### Usage in Widgets

```dart
// ✅ CORRECT
Padding(
  padding: const EdgeInsets.all(AppSpacing.md),    // 16
  child: Column(
    children: [
      Widget1(),
      SizedBox(height: AppSpacing.sm),              // 8
      Widget2(),
      SizedBox(height: AppSpacing.lg),              // 24
      Widget3(),
    ],
  ),
)

// ❌ WRONG — never use arbitrary values
Padding(padding: EdgeInsets.all(13))
SizedBox(height: 15)
```

---

## 🌐 Rule #3 — API Integration & Repositories

All API/Database calls go through **Repository classes**.  
Never call Supabase directly inside a Controller or Widget. 
Every file related to DB or API must be named `<feature_name>_repository.dart`.

### Repository Pattern

```dart
// lib/data/remote/example_repository.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mobile/shared/models/example_model.dart';

class ExampleRepository {
  final _client = Supabase.instance.client;

  /// Returns list of [ExampleModel] or throws [Exception] on failure.
  Future<List<ExampleModel>> fetchAll() async {
    try {
      final response = await _client
          .from('examples')
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((e) => ExampleModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw Exception('DB Error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
```

### API Call Rules

| Rule | Detail |
|---|---|
| **No direct Supabase in Controllers** | Always go through a Repository class |
| **No direct Supabase in Widgets** | Always go through a Controller |
| **All errors must be caught** | Use try/catch, surface via controller state |
| **Loading state required** | Show loading indicator during any async call |
| **Error state required** | Show meaningful error message, never silent fail |

---

## 🎮 Rule #4 — Controllers, Bindings & Routes (GetX)

All controllers **MUST**:
1. Return typed data based on a **Model** class
2. Expose `isLoading`, `errorMessage`, and the data `RxList`/`Rx<Model>` as observables
3. Handle errors gracefully and update state accordingly
4. **Be injected using GetX Bindings** from `/features/<feature_name>/bindings/` and registered in `lib/routes/app_pages.dart`. Never instantiate them directly in the View with `Get.put()`.

### 1. The Controller

```dart
// lib/features/example/controllers/example_controller.dart
import 'package:get/get.dart';
import 'package:mobile/shared/models/example_model.dart';
import 'package:mobile/data/remote/example_repository.dart';

class ExampleController extends GetxController {
  final ExampleRepository _repository = ExampleRepository();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<ExampleModel> items = <ExampleModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchItems();
  }

  Future<void> fetchItems() async {
    isLoading.value = true;
    try {
      final result = await _repository.fetchAll();
      items.assignAll(result);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
```

### 2. The Binding

```dart
// lib/features/example/bindings/example_binding.dart
import 'package:get/get.dart';
import 'package:mobile/features/example/controllers/example_controller.dart';

class ExampleBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ExampleController>(() => ExampleController());
  }
}
```

### 3. The Route Registration (`app_pages.dart`)

```dart
// lib/routes/app_pages.dart
import 'package:get/get.dart';
import 'package:mobile/features/example/bindings/example_binding.dart';
import 'package:mobile/features/example/views/ui/example_page.dart';
import 'package:mobile/routes/app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.EXAMPLE;

  static final routes = [
    GetPage(
      name: Routes.EXAMPLE,
      page: () => const ExamplePage(),
      binding: ExampleBinding(),
    ),
  ];
}
```

---

## 🧩 Model Pattern

All models live in `lib/shared/models/` and must implement `fromJson` and `toJson`.

```dart
// lib/shared/models/example_model.dart
class ExampleModel {
  final String id;
  
  const ExampleModel({required this.id});

  factory ExampleModel.fromJson(Map<String, dynamic> json) => ExampleModel(id: json['id'] as String);
  Map<String, dynamic> toJson() => {'id': id};
}
```

---

## 🖥️ Page / View Pattern

Use `GetView<YourController>` so you don't need to manually inject or find the controller.

```dart
// lib/features/example/views/ui/example_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/features/example/controllers/example_controller.dart';
import 'package:mobile/shared/theme/app_spacing.dart';
import 'package:mobile/shared/components/loading_overlay_widget.dart';

class ExamplePage extends GetView<ExampleController> {
  const ExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Example')),
      body: Stack(
        children: [
          Obx(() => ListView.builder(
            itemCount: controller.items.length,
            itemBuilder: (context, index) {
              return Text(controller.items[index].id);
            },
          )),
          Obx(() => controller.isLoading.value
              ? const LoadingOverlayWidget()
              : const SizedBox.shrink()),
        ],
      ),
    );
  }
}
```

---

## 🔁 Shared Components Location Rules

| Component Type | Location |
|---|---|
| Buttons (primary, secondary, icon) | `lib/shared/components/` |
| Text fields / Input decorations | `lib/shared/components/` |
| Loading indicators / Overlays | `lib/shared/components/` |
| Error state / Empty state widgets | `lib/shared/components/` |
| Feature-specific card widget | `lib/features/<name>/views/components/` |

> **Rule**: If you copy-paste a widget more than once → extract to `lib/shared/components/`.

---

## 📝 Feature Description Template

When planning a new feature, paste this at the top of the feature's folder as a `README.md`.

```md
# Feature: <Feature Name>

## API / Data Sources
| Action | Supabase Table | Method |
|--------|---------------|--------|
| Fetch list | `table_name` | SELECT |

## Models Used
- `<ModelName>Model` — from `lib/shared/models/`

## Controller Methods
| Method | Returns | Description |
|--------|---------|-------------|
| `fetchItems()` | `List<ItemModel>` | Load all items |
```

---

## ⛔ Anti-Patterns (Never Do)

| ❌ Anti-Pattern | ✅ Correct Approach |
|---|---|
| Calling Supabase directly in a widget | Go through Repository → Controller → Widget |
| `Get.put(Controller())` in `build()` | Use GetX Bindings in `app_pages.dart` and `GetView<Controller>` |
| Hardcoded spacing like `SizedBox(height: 13)` | Use `AppSpacing.xs/sm/md/lg` |
| `Map<String,dynamic>` as controller return | Use typed Model class |
| Putting reused widget inside a single feature | Move to `lib/shared/components/` |
| Controller with no `isLoading` | Always expose `isLoading` and `errorMessage` |
| Business logic inside `build()` | Move to controller method |

---

## 🚀 New Feature Kickoff Checklist

```
[ ] Created folder: lib/features/<name>/bindings/
[ ] Created folder: lib/features/<name>/controllers/
[ ] Created folder: lib/features/<name>/views/ui/
[ ] Model created in lib/shared/models/
[ ] Repository created in lib/data/remote/ (named <name>_repository.dart)
[ ] Binding created and route added to app_pages.dart & app_routes.dart
[ ] Controller created — returns typed Model data
[ ] View uses GetView<Controller>
[ ] All spacing uses AppSpacing constants (4/8pt grid)
```
