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
}
