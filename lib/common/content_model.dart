class UnbordingContent {
  String images;
  String image;
  String title;
  String discription;

  UnbordingContent(
      {required this.images,
      required this.image,
      required this.title,
      required this.discription});
}

List<UnbordingContent> contents = [
  UnbordingContent(
      images: 'assets/images/logos.png',
      title: 'Izinkan Pemberitahuan',
      image: 'assets/images/notif.png',
      discription: "Ini Penting untuk memperoleh pesan mengenai order"),
  UnbordingContent(
      images: 'assets/images/logos.png',
      title: 'Izinkan akses ke geolokasi',
      image: 'assets/images/lokasi.png',
      discription:
          "Pencarian alamat akan menjadi lebih tepat. Ini akan membantu menghemat wktu dan mempercepet pemenuhan order"),
  UnbordingContent(
      images: 'assets/images/logos.png',
      title: 'Izinkan akses ke telepon',
      image: 'assets/images/ponsel.png',
      discription:
          "Ini diperlukan untuk memastikan keamanan data. Informasi pribadi akan tetap terlindungi "),
];
