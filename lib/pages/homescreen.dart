import 'package:drpechayapp/pages/Scanner.dart';
import 'package:flutter/material.dart';


class HomeWidget extends StatelessWidget {
  const HomeWidget({Key? key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      //backgroundColor: Theme.of(context).colorScheme.background,
      //body: Container(
      //color: const Color.fromARGB(255, 255, 255, 255),
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'assets/images/plant1.jpg', // Path to your GIF image
                width: double.infinity,
                height: 200,
                fit: BoxFit.none,
              ),
              const SizedBox(height: 20),
              const Text(
                'Welcome to Pechay Doctor',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Text(
                'Your friendly doctor here to assist you in identifying Pechay Disease',
                style: TextStyle(fontSize: 16), 
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const Scannermain()));
                },
                label: const Text("Scan my Pechay",
                  style: TextStyle(color: Colors.black)),
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(const Color.fromARGB(255, 71, 235, 77)),
                    padding: WidgetStateProperty.all(
                      const  EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    ),
                )
              ),
            ],
          ),
        ),
      ),
    );
  }
}
