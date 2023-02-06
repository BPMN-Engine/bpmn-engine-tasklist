import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:simple_json_form/simple_json_form.dart';

void main() {
  runApp(const MyApp());
}

var client = Dio();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: "/",
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
          future: future(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              final data = snapshot.data!;
              return Center(
                child: Container(
                  width: 450,
                  child: ListView.builder(
                      itemCount: (data["tasks"] as List).length,
                      itemBuilder: (context, index) {
                        final el = data["tasks"][index];
                        return InkWell(
                          onTap: () {
                            showDialog(
                                context: (context),
                                builder: (context) => UserForm(
                                    el["task"]["userTaskForm"], el["id"]));
                          },
                          child: Column(
                            children: [
                              Text("Instance id ${el["instanceId"]}"),
                              Text("Task id ${el["id"]}"),
                              Text("Task name id ${el["task"]["name"]}"),
                            ],
                          ),
                        );
                      }),
                ),
              );
            }
            return Text("Loading");
          }),
    );
  }

  Future<Map> future() async {
    final sw = Stopwatch()..start();
    var x = ((await client.get(("http://localhost:8080/tasks/"))).data);
    print(sw.elapsedMilliseconds);
    return Map.from(x);
  }
}

class UserForm extends StatelessWidget {
  final initialData;
  final taskId;

  UserForm(this.initialData, this.taskId);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: 450,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SimpleJsonForm(
            jsonSchema: JsonSchema.fromJson(initialData),
            title: "Task form",
            titleStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
            crossAxisAlignment: CrossAxisAlignment.center,
            index: 0,
            imageUrl: '',
            defaultValues: DefaultValues(),
            descriptionStyleText: const TextStyle(
              color: Colors.lightBlue,
            ),
            titleStyleText: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.blue,
            ),
            onSubmit: (val) async {
              val = val as JsonSchema;
              if (val == null) {
                print("no data");
              } else {
                var values = Map();

                for (var f in val.form) {
                  for (var p in (f.properties ?? [])) {
                    p = p as Properties;
                    values[p.key] = p.answer;
                  }
                }
                var resp =
                    (await client.post(("http://localhost:8080/completeTask/"),
                        data: jsonEncode({"taskId": taskId, "values": values}),
                        options: Options().copyWith(
                          headers: {
                            "Access-Control-Allow-Origin": "*",
                            "Content-Type": "application/json",
                            "MyCustomHeader": "",
                          },
                        )));
                print("Resp is ${resp.data}");
                Navigator.of(context).pushNamed("/");
              }
            },
          ),
        ),
      ),
    );
  }
}
