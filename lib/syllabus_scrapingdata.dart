class SyllabusScrapingdata {
  final String course;
  final String courseofferedby;
  final String term;
  final String dayperiod;
  final String semesteroffered;
  final String maininstructor;
  final String classroom;
  final String numberoftimes;

  SyllabusScrapingdata(
      this.course,
      this.courseofferedby,
      this.term,
      this.dayperiod,
      this.semesteroffered,
      this.maininstructor,
      this.classroom,
      this.numberoftimes);
  Map<String, dynamic> tomap() {
    return {
      'course': course,
      'courseofferedby': courseofferedby,
      'term': term,
      'dayperiod': dayperiod,
      'semesteroffered': semesteroffered,
      'maininstructor': maininstructor,
      'classroom': classroom,
      'numberoftimes': numberoftimes,
    };
  }

  // 元から用意していたゲッター
  String get dayofweek => dayperiod.substring(0, 1);
  int get period => int.parse(dayperiod.substring(1, 2));
  int get periodoftime => int.parse(dayperiod.substring(1, dayperiod.length));
  int get numberoftimesint => int.parse(numberoftimes);

  // 週に2回授業があるパターンへの対策
  List<String> get dayperiodParts => dayperiod.split(RegExp(r"(?=[月火水木金土日])"));
  List<String> get dayofweeks =>
      dayperiodParts.map((part) => part.substring(0, 1)).toList();
  List<int> get periods =>
      dayperiodParts.map((part) => int.parse(part.substring(1, 2))).toList();
}
