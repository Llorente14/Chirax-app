<div align="center">

<!-- GANTI LOGO INI NANTI DENGAN IKON APP ANDA SENDIRI -->

<!-- Atau gunakan link gambar placeholder yang lucu -->

<img src="https://www.google.com/search?q=https://img.icons8.com/3d-fluency/94/pixel-heart.png" width="100" />

<h1>Chirax 👩‍❤️‍👨</h1>

<p>
<strong>Gamifying Love. Membangun Kebiasaan Bersama Pasangan.</strong>
</p>

<p>
<a href="https://flutter.dev/">
<img src="https://www.google.com/search?q=https://img.shields.io/badge/Built%2520with-Flutter-02569B%3Fstyle%3Dfor-the-badge%26logo%3Dflutter" alt="Flutter">
</a>
<a href="https://pub.dev/packages/get">
<img src="https://www.google.com/search?q=https://img.shields.io/badge/State-GetX-purple%3Fstyle%3Dfor-the-badge" alt="GetX">
</a>
<a href="#">
<img src="https://www.google.com/search?q=https://img.shields.io/badge/Style-Duolingo%2520Vibes-green%3Fstyle%3Dfor-the-badge" alt="Style">
</a>
</p>

<p align="center">
<a href="#-tentang-project">Tentang</a> •
<a href="#-fitur-unggulan">Fitur</a> •
<a href="#-tech-stack">Teknologi</a> •
<a href="#-galeri">Galeri</a> •
<a href="#-instalasi">Instalasi</a>
</p>
</div>

<br />

📖 Tentang Project

Chirax adalah aplikasi Relationship Habit Builder yang dirancang khusus hanya untuk dua pengguna (saya & pasangan). Project ini bersifat Indie dan dibuat dengan penuh cinta.

Terinspirasi dari pendekatan Duolingo, aplikasi ini mengubah interaksi hubungan harian menjadi permainan yang menyenangkan. Kami tidak hanya sekadar chatting, tapi kami menjaga streak, merawat Virtual Pet, dan mencatat Perjalanan (Journey) bersama.

Aplikasi ini dibangun dengan Flutter dan GetX, mengutamakan performa cepat, ukuran ringan, dan UI yang "Juicy" (interaktif, membal, dan penuh warna).

✨ Fitur Unggulan

🎮 Gamified Interaction

Shared Streak 🔥: Streak milik berdua. Jika salah satu lupa check-in seharian, streak kami berdua akan "pecah". High stakes, high rewards!

Mood Pet 🐶: Maskot virtual yang bereaksi terhadap keaktifan kami. Dia bisa sedih (nangis), lapar, atau berjoget girang pakai kacamata hitam.

Daily Check-in: Tombol interaksi cepat untuk menyapa pasangan dan memberi makan Pet.

📅 The Journey (Calendar)

Visual Memories: Kalender interaktif di mana setiap event ditandai dengan Stiker/Emoji unik, bukan sekadar titik membosankan.

Days Together Counter: Penghitung hari otomatis (e.g., "❤️ 365 Days") yang terpampang bangga di halaman utama.

Staggered Animation: Daftar kenangan muncul dengan animasi slide & fade yang halus dan elegan.

🎨 Juicy UI/UX (Duolingo Style)

Chunky Design System: Tombol 3D dengan border tebal, sudut membulat, dan warna vibrant.

Micro-Interactions: Efek bouncy (membal) saat tombol ditekan.

Gesture Control: Swipe untuk menghapus event atau mengatur jadwal.

🛠 Tech Stack

Project ini dibangun dengan pendekatan efisien untuk performa maksimal.

Kategori

Teknologi

Alasan Penggunaan

Framework

Flutter (Dart)

Cross-platform (Android/iOS), animasi 60fps mulus.

State Mgt

GetX

Boilerplate minim, reaktif tanpa context, navigasi simpel.

Animation

Flutter Staggered Anim

Memberikan efek premium pada list event di kalender.

Calendar

Table Calendar

Highly customizable untuk fitur stiker "Journey".

Backend

Firebase (Coming Soon)

Real-time database untuk sinkronisasi antar device.

📸 Galeri

<!-- TUGAS ANDA:

Buat folder bernama "screenshots" atau "docs" di dalam folder project Anda.

Masukkan screenshot aplikasi Anda ke sana (misal: home.png, journey.png).

Ganti path di bawah ini sesuai nama file Anda.
-->

Home Dashboard

Journey Calendar

Add Event

<img src="docs/home.png" alt="Home Screen" width="250"/>

<img src="docs/journey.png" alt="Calendar" width="250"/>

<img src="docs/add.png" alt="Add Event" width="250"/>

Note: Tampilan didesain dengan gaya "Chunky" & "Playful" untuk meningkatkan engagement pengguna.

📂 Struktur Project

Menggunakan arsitektur Modular berbasis fitur untuk menjaga kode tetap rapi.

lib/
├── core/ # Tema (Colors), Widget reusable (ChunkyButton), Utils
├── data/ # Models (Event, Pet) & Services
├── modules/ # Fitur-fitur Aplikasi (View + Controller)
│ ├── dashboard/ # Logic Navigasi Bawah (IndexedStack)
│ ├── home/ # Logic Streak, Pet, & Days Counter
│ ├── journey/ # Logic Kalender, Staggered List, & Event
│ └── finance/ # (Coming Soon) Tabungan Bersama
└── main.dart # Titik Masuk Aplikasi

🚀 Instalasi

Ingin mencoba menjalankan project ini di mesin lokal Anda?

Clone Repo

git clone [https://github.com/username-anda/couple-quest.git](https://github.com/username-anda/couple-quest.git)

Masuk ke Direktori

cd couple-quest

Install Dependencies

flutter pub get

Jalankan Aplikasi

flutter run

🗺 Roadmap Pengembangan

[x] Phase 1: Setup Project, Dashboard UI, & Logika Gamifikasi Dasar.

[x] Phase 2: Fitur Journey/Kalender dengan Animasi & Gesture.

[ ] Phase 3: Integrasi Firebase (Auth & Firestore Realtime).

[ ] Phase 4: Shared Finance (Tabungan Bersama & Visualisasi Target).

[ ] Phase 5: Home Screen Widget & Local Notifications (Countdown).

👨‍💻 Author

Dibuat dengan ❤️ oleh Axel untuk Gea.
Indie project for personal use.

<div align="center">
<small>Jika Anda suka konsep ini, jangan lupa kasih ⭐️ (Star) ya!</small>
</div>
