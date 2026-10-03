abstract final class MapStyles {
  static const String light = '''
[
  {"elementType":"geometry","stylers":[{"color":"#f3f1ec"}]},
  {"elementType":"labels.icon","stylers":[{"visibility":"off"}]},
  {"elementType":"labels.text.fill","stylers":[{"color":"#53635f"}]},
  {"elementType":"labels.text.stroke","stylers":[{"color":"#f3f1ec"}]},
  {"featureType":"poi","elementType":"geometry","stylers":[{"color":"#e4ece7"}]},
  {"featureType":"road","elementType":"geometry","stylers":[{"color":"#ffffff"}]},
  {"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#d8e5df"}]},
  {"featureType":"transit","stylers":[{"visibility":"off"}]},
  {"featureType":"water","elementType":"geometry","stylers":[{"color":"#b7d9dc"}]}
]
''';

  static const String dark = '''
[
  {"elementType":"geometry","stylers":[{"color":"#18211f"}]},
  {"elementType":"labels.icon","stylers":[{"visibility":"off"}]},
  {"elementType":"labels.text.fill","stylers":[{"color":"#a9bbb5"}]},
  {"elementType":"labels.text.stroke","stylers":[{"color":"#18211f"}]},
  {"featureType":"poi","elementType":"geometry","stylers":[{"color":"#24322f"}]},
  {"featureType":"road","elementType":"geometry","stylers":[{"color":"#2d3c38"}]},
  {"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#3c514b"}]},
  {"featureType":"transit","stylers":[{"visibility":"off"}]},
  {"featureType":"water","elementType":"geometry","stylers":[{"color":"#102f38"}]}
]
''';
}
