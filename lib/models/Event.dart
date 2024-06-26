class Event {
  int? id;
  String? eventName;
  String? eventDescription;
  String startDate;
  String? endDate;
  String startTime;
  String endTime;
  String? category;
  String? repeat;
  String? planevent;
  String? inviteGmails;
  int reminderBefore;
  int? isCompleted;
  int? color; // New property to represent the color

  Event({
    this.id,
    this.isCompleted,
    required this.eventName,
    required this.eventDescription,
    required this.startDate,
    required this.endDate,
    required this.startTime,
    required this.endTime,
    required this.category,
    required this.repeat,
    required this.planevent,
    required this.inviteGmails,
    required this.reminderBefore,
    this.color, // Initialize the color property
  });

  // Factory method to create an Event from JSON
  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      eventName: json['eventName'],
      eventDescription: json['eventDescription'],
      startDate: json['startDate'],
      endDate: json['endDate'],
      startTime: json['startTime'],
      endTime: json['endTime'],
      category: json['category'],
      repeat: json['repeat'],
      planevent: json['planevent'],
      inviteGmails: json['inviteGmails'],
      reminderBefore: json['reminderBefore'],
      isCompleted: json['isCompleted'],
      color: json['color'], // Assign the color property
    );
  }

  // Method to convert an Event to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'eventName': eventName,
      'eventDescription': eventDescription,
      'startDate': startDate,
      'endDate': endDate,
      'startTime': startTime,
      'endTime': endTime,
      'category': category,
      'repeat': repeat,
      'planevent': planevent,
      'inviteGmails': inviteGmails,
      'reminderBefore': reminderBefore,
      'isCompleted': isCompleted,
      'color': color, // Include the color property
    };
  }
}
