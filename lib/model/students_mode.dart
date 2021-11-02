class Student {
  int? id;
  String? name;
  int? aktivmi;

  Student(this.name, 
  this.aktivmi);

  Student.withID(this.id, 
  this.name, this.aktivmi);
  // DB GA YOZISH UCHUN
  Map<String, dynamic> toMapToDb() {
    Map<String, dynamic> map = Map<String, dynamic>();
    map['id'] = id;
    map['name'] = name;
    map['aktivmi'] = aktivmi;
    return map;
  }
  // DB DAN O'QISH UCHUN
  Student.fromMapFromDb(Map<String, dynamic> map) {
    id = map['id'];
    name = map['name'];
    aktivmi = map['aktivmi'];
  }
}
