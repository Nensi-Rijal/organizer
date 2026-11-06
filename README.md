# 01. Personal inventory management

- knowing what products I own, 
- what I have available,
- where things are stored,
- when they expire.

AI will have access to my personal inventory

- I will add things I own to the app, and I will for the first prototype I will manually add them or place them as their categories (for the ai to get more idea and insight of my habit or myself works) 

there will not be predefined categories, instead user can add categories, sub categories and inside the subcategories sub sub categories and so on.
, for the first prototype i will take a picture of the product, or upload an existing picture, manually enter product informatiomn (later use the amazon or product link and use ai to identify the product categoires based on what we have in the list and fill in details and if it doesnt find the categoies list we dont have where it should be it suggest us name as a placeholder and we can create it later and then .....)

for the inventory feature beyond adding products
we should be able to search products, filter the product, know where they are placed, expiraton, quantity, product status opened , or unopened, finished, favorites, 

---------------------

# 01. Getting started with the project

## Folder structure to begin with:
organizer/
│
├── android/
├── ios/
├── assets/
│   ├── images/
│   ├── icons/
│   └── fonts/
│
├── lib/
│   │
│   ├── main.dart
│   │
│   ├── app/
│   │   ├── organizer_app.dart
│   │   ├── router/
│   │   │   └── app_router.dart
│   │   └── theme/
│   │       ├── app_theme.dart
│   │       ├── app_colors.dart
│   │       └── app_text_styles.dart
│   │
│   ├── core/
│   │   ├── config/
│   │   ├── database/
│   │   │   ├── app_database.dart
│   │   │   └── tables/
│   │   ├── sync/
│   │   │   ├── sync_coordinator.dart
│   │   │   └── sync_queue.dart
│   │   ├── errors/
│   │   └── utils/
│   │
│   ├── features/
│   │   │
│   │   ├── inventory/
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   ├── local/
│   │   │   │   └── remote/
│   │   │   ├── models/
│   │   │   ├── repositories/
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   └── usecases/
│   │   │   └── presentation/
│   │   │       ├── screens/
│   │   │       ├── widgets/
│   │   │       └── providers/
│   │   │
│   │   ├── categories/
│   │   ├── locations/
│   │   └── authentication/
│   │
│   └── shared/
│       ├── widgets/
│       ├── extensions/
│       └── constants/
│
├── test/
│
├── pubspec.yaml
└── README.md

## Ran these commands to install the packages

```
flutter pub add supabase_flutter
flutter pub add flutter_riverpod
flutter pub add go_router
flutter pub add drift drift_flutter
flutter pub add uuid intl

```

to install the dependencies
`flutter pub add --dev drift_dev build_runner`

Finally 
`flutter pub get`

## After doing changes run these commands below in order

### First
`dart format lib test`

### Second

`flutter analyze`

### Third

`flutter test`

### Fourth

`flutter run`

## for the database 

### Generate the Drfit database code

run this command
`dart run build_runner build --delete-conflicting-outputs`

