import 'package:flutter/material.dart';
import 'package:nyore/features/main/data/mock/feature_data_mock.dart';
import 'package:nyore/features/main/data/model/feature_model.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List<FeatureModel> listData = [];

  @override
  void initState() {
    listData = getMockFeatures();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nyore'),
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Welcome, gaes!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 16,
            ),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                itemCount: listData.length, // Example item count
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      onTap: () {
                        Navigator.pushNamed(
                            context, listData[index].pathRoute ?? '/');
                      },
                      title: Text(listData[index].name ?? '-'),
                      subtitle: Text(listData[index].description ?? '-'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
