# Bali-heritage-mobile 🍹

## Anggota Kelompok D07
- Bastian Adiputra Siregar - 2306245005
- Muhammad Akmal Abdul Halim - 2306245125
- Muhammad Adiansyah - 2306244980
- Husin Hidayatul Hakim - 2306152481
- Muhammad Zaid Ats Tsabit - 2306224410

## Deskripsi dan Manfaat Aplikasi
Dengan semangat untuk melestarikan budaya dan kerajinan lokal Bali, kami dengan bangga mempersembahkan **Bali Heritage**, sebuah platform inovatif yang memudahkan Anda menjelajahi keindahan kerajinan Bali, khususnya di kota **Denpasar**. Bali Heritage dirancang untuk memfasilitasi para wisatawan, kolektor seni, hingga pencinta budaya tradisional dalam menemukan lokasi-lokasi terbaik untuk membeli barang-barang Bali. Website ini menawarkan fitur-fitur yang lengkap dan interaktif, sehingga Anda bisa dengan mudah menemukan toko atau pasar lokal yang menjual barang-barang yang terdapat di Bali. Tidak hanya membantu menemukan produk terbaik, tetapi Bali Heritage juga memberikan informasi yang bermanfaat mengenai asal-usul kerajinan, tradisi yang melatarbelakanginya, dan tips untuk berbelanja secara cerdas dari review review user kami.

Bali Heritage bukan hanya sekadar platform untuk mencari suvenir khas, tetapi juga menjadi jembatan penting untuk mengenal lebih dalam budaya Bali melalui produk-produk yang dijual di Bali. Fokusnya tidak terbatas pada barang-barang tradisional, melainkan mencakup berbagai produk lokal yang dijual oleh para pengrajin dan pedagang Bali.

## Daftar Module:
| Fitur (Module)         | Deskripsi                                                                                   |
|------------------------|---------------------------------------------------------------------------------------------|
| Pengelolaan Produk (Bastian Adiputra Siregar)    | Menampilkan lokasi-lokasi souvenir dengan informasi lengkap.                                |
| Forum (Husin Hidayatul Hakim)                 | Ruang diskusi bagi pengguna untuk bertanya atau memberikan rekomendasi lokasi baru.         |
| Review (Muhammad Akmal Abdul Halim)                | Pengguna dapat memberikan ulasan mengenai lokasi yang mereka kunjungi.                      |
| Bookmark (Muhammad Zaid Ats Tsabit)               | Simpan lokasi-lokasi favorit untuk dikunjungi di kemudian hari.                             |
| BaliLoka Stories  (Muhammad Adiansyah)     | Memberikan cerita dan sejarah-sejarah terkait beberapa benda unik dari Bali.               |

## Peran/Aktor Pengguna Aplikasi
- **User**
  Bisa menambah, mengedit dan mendelete isi dari `homepage` serta bisa menambah, mengedit dan mendelete artikel untuk `BaliLoka Stories`
  Bisa menggunakan fitur fitur pada aplikasi seperti forum, mereview dan memberi ulasan tempat dan lokasi yang pernah dikunjungi serta menggunakan fitur bookmark untuk menyimpan tempat favorit mereka

## Alur pengintegrasian dengan web service
- **Django Menyediakan API**

Aplikasi mobile tidak langsung berinteraksi dengan elemen-elemen Django seperti views.py atau templates. Sebagai gantinya, Django bertindak sebagai backend yang menyediakan API berbasis web. API ini menggunakan format JSON untuk mengirim dan menerima data. Dengan cara ini, Django tidak hanya melayani aplikasi web tetapi juga aplikasi mobile seperti yang dikembangkan dengan Flutter.

- **Aplikasi Mobile Mengirimkan Permintaan ke API Django**
  
Aplikasi mobile (seperti aplikasi Android atau iOS yang dibuat menggunakan Flutter) mengirimkan HTTP request ke Django melalui endpoint API. Contohnya, aplikasi mobile dapat mengakses endpoint seperti https://pbp.cs.ui.ac.id/bali-heritage/json.
Permintaan ini dapat berupa metode GET (untuk membaca data) atau POST (untuk mengirim data baru).

- **Django Memproses Permintaan**
  
Django memproses permintaan dari aplikasi mobile menggunakan:
Serializers: Data dari database Django diubah menjadi format JSON yang dapat dimengerti oleh aplikasi mobile.
Django juga memvalidasi data yang diterima dari aplikasi mobile jika metode yang digunakan adalah POST, PUT, atau PATCH.

- **Mengembalikan Respons ke Aplikasi Mobile**
  
Setelah memproses permintaan:
Django mengirimkan data dalam bentuk JSON response kembali ke aplikasi mobile.
Contohnya, jika aplikasi mobile meminta daftar produk, Django akan mengambil data produk dari database, memformatnya dalam JSON, dan mengirimkannya kembali ke aplikasi mobile.

- **Aplikasi Mobile Menampilkan Data**

Aplikasi mobile menggunakan data JSON yang diterima dari Django untuk memperbarui antarmuka pengguna. Misalnya:
Menampilkan daftar produk atau lokasi tertentu.
Mengupdate data pada aplikasi sesuai dengan hasil respons dari Django.
