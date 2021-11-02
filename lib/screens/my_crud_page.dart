import 'package:backend/db_helper/db_helper.dart';
import 'package:backend/model/students_mode.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyCRUDPage extends StatefulWidget {
  @override
  _MyCRUDPageState createState() => _MyCRUDPageState();
}

class _MyCRUDPageState extends State<MyCRUDPage> {
  DatabaseHelper? _databaseHelper;
  List<Student>? allStudents;

  bool _onlineMi = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _updateNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    allStudents = [];
    _databaseHelper = DatabaseHelper();
    _databaseHelper!.getAllStudents().then((allStudentsFromDb) {
      for (var item in allStudentsFromDb) {
        allStudents!.add(Student.fromMapFromDb(item));
      }
      debugPrint(allStudents!.length.toString());
    }).catchError((err) {
      debugPrint(err.toString());
    });
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Center(
          child: Text(
            "CRUD",
            style: TextStyle(color: Colors.teal),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(13.0),
              child: getForm(),
            ),
            getButtonsRow(),
            allStudents!.isNotEmpty
                ? SizedBox(
                    height: 630.0,
                    child: RefreshIndicator(
                      onRefresh: () async {
                        allStudents = [];
                        _databaseHelper = DatabaseHelper();
                        _databaseHelper!
                            .getAllStudents()
                            .then((allStudentsFromDb) {
                          for (var item in allStudentsFromDb) {
                            allStudents!.add(Student.fromMapFromDb(item));
                          }
                          debugPrint(allStudents!.length.toString());
                        }).catchError((err) {
                          debugPrint(err.toString());
                        });
                        Future.delayed(const Duration(seconds: 1), () {
                          setState(() {});
                        });
                      },
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics()),
                        shrinkWrap: true,
                        itemBuilder: (context, index) => ListTile(
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    content: SizedBox(
                                      height: 200.0,
                                      child: Form(
                                        child: Column(
                                          children: [
                                            TextFormField(
                                              controller: _updateNameController,
                                              decoration: const InputDecoration(
                                                border: OutlineInputBorder(),
                                                hintText:
                                                    "Write Name Of Student...",
                                                labelText: "Name Of Student",
                                              ),
                                            ),
                                            ListTile(
                                              onTap: () {
                                                setState(() =>
                                                    _onlineMi = !_onlineMi);
                                              },
                                              title: const Text("Online Mi?"),
                                              trailing: CupertinoSwitch(
                                                value: allStudents![index]
                                                            .aktivmi ==
                                                        1
                                                    ? true
                                                    : false,
                                                onChanged: (e) {
                                                  setState(() =>
                                                      _onlineMi = !_onlineMi);
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    actions: [
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            primary: Colors.redAccent),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text("Cancel"),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          _databaseHelper!.updateStudent(
                                            Student.withID(
                                              allStudents![index].id,
                                              _updateNameController.text,
                                              _onlineMi ? 1 : 0,
                                            ),
                                          );
                                          Navigator.pop(context);
                                          setState(() {});
                                        },
                                        child: const Text("UPDATE"),
                                      ),
                                    ],
                                  );
                                });
                          },
                          leading: CircleAvatar(
                            child: Text("${allStudents![index].id}"),
                          ),
                          title: Text("${allStudents![index].name}"),
                          trailing: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.2,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    _databaseHelper!
                                        .deleteStudent(allStudents![index].id!);
                                    setState(() {
                                      allStudents!.removeAt(index);
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        backgroundColor: Colors.yellow,
                                        content: Text(
                                          "Data Has Been Deleted !",
                                          style: TextStyle(
                                            fontSize: 22.0,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                CircleAvatar(
                                  radius: 10.0,
                                  backgroundColor:
                                      allStudents![index].aktivmi != 1
                                          ? Colors.blue
                                          : Colors.grey,
                                ),
                              ],
                            ),
                          ),
                        ),
                        itemCount: allStudents!.length,
                      ),
                    ),
                  )
                : const Padding(
                    padding: EdgeInsets.only(top: 250),
                    child: Center(
                      child: CupertinoActivityIndicator(
                        radius: 20,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  getButtonsRow() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(primary: Colors.green),
            child: const Text("Create Data"),
            onPressed: () {
              _addStudent(Student(_nameController.text, _onlineMi ? 1 : 0));
              _nameController.clear();
              _onlineMi = false;
            },
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(primary: Colors.redAccent),
            child: const Text("Delete All Data"),
            onPressed: () {
              _deleteStudents();
            },
          ),
        ],
      );

  getForm() => Form(
        child: Column(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Write Name Of Student...",
                labelText: "Name Of Student",
              ),
            ),
            ListTile(
              onTap: () {
                setState(() => _onlineMi = !_onlineMi);
              },
              title: const Text("Online Mi?"),
              trailing: CupertinoSwitch(
                value: _onlineMi,
                onChanged: (e) {
                  setState(() => _onlineMi = !_onlineMi);
                },
              ),
            ),
          ],
        ),
      );

  // DATABASE METHODS
  _addStudent(Student s) async {
    try {
      var addedStudentId = await _databaseHelper!.addStudent(s);
      s.id = addedStudentId;
      if (addedStudentId > 0) {
        setState(() {
          allStudents!.insert(0, s);
        });
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  _deleteStudents() async {
    var deletedStudents = await _databaseHelper!.deleteAllStudents();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.redAccent,
        content: Text(
          "All Data Has Been Deleted !",
          style: TextStyle(
            fontSize: 22.0,
            color: Colors.white,
          ),
        ),
      ),
    );
    setState(() {
      allStudents!.clear();
    });
  }
}
