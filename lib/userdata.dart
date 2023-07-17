import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:home/syllabus_scrapingdata.dart';

class UserData {
  final String faculty;
  final String year;
  final Map<String, List<SyllabusScrapingdata>> coursestaken;
  final DocumentReference reference;
  UserData(this.faculty, this.year, this.coursestaken, this.reference);
  factory UserData.fromfirestore(DocumentSnapshot ds) {
    final map = ds.data() as Map<String, dynamic>;
    return UserData(
        map['faculty'],
        map['year'],
        (map['coursestaken'] as Map? ?? {}).map(
          (key, value) => MapEntry(
            key,
            (value as List).map((e) {
              final syllabus = e as Map;
              return SyllabusScrapingdata(
                  syllabus['course'],
                  syllabus['courseofferedby'],
                  syllabus['term'],
                  syllabus['dayperiod'],
                  syllabus['semesteroffered'],
                  syllabus['maininstructor'],
                  syllabus['classroom'],
                  syllabus['numberoftimes']);
            }).toList(),
          ),
        ),
        ds.reference);
  }
  Map<String, dynamic> tomap() {
    return {
      'faculty': faculty,
      'year': year,
      'coursestaken': coursestaken.map(
          (key, value) => MapEntry(key, value.map((e) => e.tomap()).toList())),
    };
  }
}
