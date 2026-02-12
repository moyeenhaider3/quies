import 'package:equatable/equatable.dart';

class Quote extends Equatable {
  final String id;
  final String text;
  final String author;
  final String category;
  final List<String> tags;
  final int energy;
  final int valence;
  final List<String> timeOfDay;

  const Quote({
    required this.id,
    required this.text,
    required this.author,
    required this.category,
    required this.tags,
    this.energy = 3,
    this.valence = 3,
    this.timeOfDay = const ['anytime'],
  });

  @override
  List<Object?> get props => [
    id,
    text,
    author,
    category,
    tags,
    energy,
    valence,
    timeOfDay,
  ];
}
