# Praetorian Catalog - Final Project 2026

Aplikasi katalog barang pribadi dengan Flutter + Supabase.

## Setup

### 1. Supabase
- Buka supabase.com, buat project baru
- Pergi ke Settings > API
- Copy Project URL dan anon key
- Paste ke `lib/config/app_config.dart`:

```dart
static const String supabaseUrl = 'https://xxxxx.supabase.co';
static const String supabaseAnonKey = 'eyJ...';
```

### 2. Buat Tabel
Buka SQL Editor di Supabase, jalankan ini:

```sql
create extension if not exists "uuid-ossp";

create table public.profiles (
  id uuid references auth.users(id) on delete cascade primary key,
  full_name text not null,
  username text unique not null,
  phone text not null default '',
  email text not null,
  created_at timestamptz default now()
);

create table public.items (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references public.profiles(id) on delete cascade not null,
  title text not null,
  description text default '',
  image_url text default '',
  category text default 'General',
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

alter table public.profiles enable row level security;
alter table public.items enable row level security;

create policy "profiles_select" on public.profiles for select using (auth.uid() = id);
create policy "profiles_insert" on public.profiles for insert with check (auth.uid() = id);
create policy "profiles_update" on public.profiles for update using (auth.uid() = id);

create policy "items_select" on public.items for select using (auth.uid() = user_id);
create policy "items_insert" on public.items for insert with check (auth.uid() = user_id);
create policy "items_update" on public.items for update using (auth.uid() = user_id);
create policy "items_delete" on public.items for delete using (auth.uid() = user_id);
```

### 3. Jalankan App

```bash
flutter pub get
flutter run
```

## Struktur Folder

```
lib/
├── main.dart
├── config/app_config.dart
├── models/
│   ├── user_model.dart
│   └── item_model.dart
├── services/
│   ├── auth_service.dart
│   └── item_service.dart
├── providers/
│   ├── auth_provider.dart
│   └── item_provider.dart
├── screens/
│   ├── login_screen.dart
│   ├── signup_screen.dart
│   ├── home_screen.dart
│   ├── detail_screen.dart
│   └── profile_screen.dart
└── widgets/
    ├── custom_button.dart
    ├── custom_text_field.dart
    └── item_card.dart
```

## Dependencies

- supabase_flutter: auth + database
- provider: state management
