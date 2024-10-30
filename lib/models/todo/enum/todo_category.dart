enum TodoCategory {
  reminder(id: 0, name: 'Reminder'),
  musteat(id: 1, name: 'Must Eat'),
  placesvisit(id: 2, name: 'Places to Visit'),
  tobuy(id: 3, name: 'To Buy');

  const TodoCategory({
    required this.id,
    required this.name,
  });

  final int id;
  final String name;
}
