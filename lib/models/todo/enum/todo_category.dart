enum TodoCategory {
  reminder(id: 0, name: 'Reminder', msg: 'No Reminder'),
  musteat(id: 1, name: 'Must Eat', msg: 'Nothing to Eat'),
  placesvisit(id: 2, name: 'Places to Visit', msg: 'No Places to Visit'),
  tobuy(id: 3, name: 'To Buy', msg: 'Nothing to Buy');

  const TodoCategory({
    required this.id,
    required this.name,
    required this.msg, //no message
  });

  final int id;
  final String name;
  final String msg;
}
