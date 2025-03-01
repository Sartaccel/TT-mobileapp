class Job {
  final int id;
  final String jobTitle;
  final String jobCode;
  final String position;
  final String eligibility;
  final double experience;
  final String salary;
  final String payFrequency;
  final String currency;
  final String location;
  final String vacancies;
  final String workType;
  final bool priority;
  final int isFavorite;
  final String? dueDate; // Due to nullable
  final String? skillSet; // Due to nullable
  final String? technology; // Due to nullable

  Job({
    required this.id,
    required this.jobTitle,
    required this.jobCode,
    required this.position,
    required this.eligibility,
    required this.experience,
    required this.salary,
    required this.payFrequency,
    required this.currency,
    required this.location,
    required this.vacancies,
    required this.workType,
    required this.priority,
    required this.isFavorite,
    this.dueDate,
    this.skillSet,
    this.technology,
  });

  // Factory method to create Job from JSON
  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'],
      jobTitle: json['jobTitle'],
      jobCode: json['jobCode'],
      position: json['position'] ?? '',
      eligibility: json['eligibility'],
      experience: json['experience'].toDouble(),
      salary: json['salary'],
      payFrequency: json['payFrequency'],
      currency: json['currency'],
      location: json['location'],
      vacancies: json['vacancies'],
      workType: json['workType'],
      priority: json['priority'],
      isFavorite: json['isFavorite'],
      dueDate: json['dueDate'], // Nullable
      skillSet: json['skillSet'], // Nullable
      technology: json['technology'], // Nullable
    );
  }
}
