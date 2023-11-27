import 'dart:math';

import 'package:example/lipsum.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fading Edge ScrollView Example',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
      ),
      home: const ExamplesList(),
    );
  }
}

class ExamplesList extends StatelessWidget {
  const ExamplesList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FadingEdgeScrollView examples'),
      ),
      body: ListView(
        children: <Widget>[
          NavigatorButton(
            text: 'ListView',
            builder: (_) => const ListViewScreen(),
          ),
          NavigatorButton(
            text: 'PageView (LTR)',
            builder: (_) =>
                const PageViewScreen(textDirection: TextDirection.ltr),
          ),
          NavigatorButton(
            text: 'PageView (RTL)',
            builder: (_) =>
                const PageViewScreen(textDirection: TextDirection.rtl),
          ),
          NavigatorButton(
            text: 'Long text',
            builder: (_) => const LongTextScreen(),
          ),
          NavigatorButton(
            text: 'Cities images',
            builder: (_) => const CitiesListView(),
          ),
          NavigatorButton(
            text: "ListWheelScrollView",
            builder: (_) => const ListWheelScrollViewScreen(),
          ),
        ],
      ),
    );
  }
}

class NavigatorButton extends StatelessWidget {
  final String text;
  final WidgetBuilder builder;

  const NavigatorButton({
    super.key,
    required this.text,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(text),
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: builder));
      },
    );
  }
}

class ListViewScreen extends StatefulWidget {
  const ListViewScreen({super.key});

  @override
  State<ListViewScreen> createState() => _ListViewScreenState();
}

class _ListViewScreenState extends State<ListViewScreen> {
  final _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Example with ListView'),
      ),
      body: Container(
        color: Colors.greenAccent,
        child: FadingEdgeScrollView.fromScrollView(
          child: ListView.builder(
            controller: _controller,
            itemBuilder: (context, index) => ListTile(
                title: Text('Item #$index'),
                leading: const CircleAvatar(
                  backgroundImage: NetworkImage(
                      'https://images.freeimages.com/images/large-previews/848/a-cat-1313470.jpg'),
                )),
            itemCount: 30,
          ),
        ),
      ),
    );
  }
}

class PageViewScreen extends StatelessWidget {
  final TextDirection textDirection;

  const PageViewScreen({
    super.key,
    required this.textDirection,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Example with PageView'),
      ),
      body: Directionality(
        textDirection: textDirection,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: FadingEdgeScrollView.fromPageView(
            gradientFractionOnStart: 0.1,
            gradientFractionOnEnd: 0.1,
            child: PageView(
              children: const <Widget>[
                Card(color: Colors.red),
                Card(color: Colors.green),
                Card(color: Colors.blue),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LongTextScreen extends StatefulWidget {
  const LongTextScreen({super.key});

  @override
  State<LongTextScreen> createState() => _LongTextScreenState();
}

class _LongTextScreenState extends State<LongTextScreen> {
  final _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Example with long text'),
      ),
      body: FadingEdgeScrollView.fromSingleChildScrollView(
        child: SingleChildScrollView(
          controller: _controller,
          child: const Padding(
              padding: EdgeInsets.all(5), child: Text(lipsumText)),
        ),
      ),
    );
  }
}

class CitiesListView extends StatefulWidget {
  const CitiesListView({super.key});

  @override
  State<CitiesListView> createState() => _CitiesListViewState();
}

class _CitiesListViewState extends State<CitiesListView> {
  final _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Example with cities images'),
      ),
      body: LayoutBuilder(builder: (context, size) {
        return SizedBox(
          width: min(420.0, size.maxWidth),
          height: min(720.0, size.maxHeight),
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                child: Image.asset(
                  'assets/world.jpeg',
                  fit: BoxFit.cover,
                ),
              ),
              Positioned.fill(
                top: 100,
                bottom: 100,
                left: 20,
                right: 20,
                child: FadingEdgeScrollView.fromScrollView(
                  child: ListView(
                    controller: _controller,
                    children: [
                      'paris',
                      'rome',
                      'moscow',
                      'tokyo',
                    ]
                        .map((city) => Padding(
                              padding: const EdgeInsets.all(12),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20.0),
                                child: Image.asset('assets/$city.jpeg'),
                              ),
                            ))
                        .toList(),
                  ),
                ),
              )
            ],
          ),
        );
      }),
    );
  }
}

class ListWheelScrollViewScreen extends StatefulWidget {
  const ListWheelScrollViewScreen({super.key});

  @override
  State<ListWheelScrollViewScreen> createState() =>
      _ListWheelScrollViewScreenState();
}

class _ListWheelScrollViewScreenState extends State<ListWheelScrollViewScreen> {
  final _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Example with ListWheelScrollView"),
      ),
      body: Container(
        color: Colors.greenAccent,
        child: FadingEdgeScrollView.fromListWheelScrollView(
          gradientFractionOnStart: 0.3,
          gradientFractionOnEnd: 0.3,
          child: ListWheelScrollView(
            itemExtent: 60,
            perspective: 0.0001,
            controller: _controller,
            children: lipsumText.split(" ").sublist(0, 20).map((e) {
              return ListTile(
                  title: Text("Item #$e"),
                  leading: const CircleAvatar(
                    backgroundImage: NetworkImage(
                        "https://images.freeimages.com/images/large-previews/848/a-cat-1313470.jpg"),
                  ));
            }).toList(),
          ),
        ),
      ),
    );
  }
}
