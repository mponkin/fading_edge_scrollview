import 'package:example/lipsum.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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
  const ExamplesList({Key? key}) : super(key: key);

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
            builder: (_) => ListViewScreen(),
          ),
          NavigatorButton(
            text: 'PageView (LTR)',
            builder: (_) => const PageViewScreen(textDirection: TextDirection.ltr),
          ),
          NavigatorButton(
            text: 'PageView (RTL)',
            builder: (_) => const PageViewScreen(textDirection: TextDirection.rtl),
          ),
          NavigatorButton(
            text: 'Long text',
            builder: (_) => LongTextScreen(),
          ),
          NavigatorButton(
            text: 'Cities images',
            builder: (_) => CitiesListView(),
          ),
          NavigatorButton(
            text: "ListWheelScrollView",
            builder: (_) => ListWheelScrollViewScreen(),
          ),
        ],
      ),
    );
  }
}

class NavigatorButton extends StatelessWidget {
  final String text;
  final WidgetBuilder builder;

  const NavigatorButton({Key? key,
    required this.text,
    required this.builder,
  }) : super(key: key);

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

class ListViewScreen extends StatelessWidget {
  final _controller = ScrollController();

  ListViewScreen({Key? key}) : super(key: key);

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

  const PageViewScreen({Key? key,
    required this.textDirection,
  }) : super(key: key);

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

class LongTextScreen extends StatelessWidget {
  final controller = ScrollController();

  LongTextScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Example with long text'),
      ),
      body: FadingEdgeScrollView.fromSingleChildScrollView(
        child: SingleChildScrollView(
          controller: controller,
          child: const Padding(padding: EdgeInsets.all(5), child: Text(lipsumText)),
        ),
      ),
    );
  }
}

class CitiesListView extends StatelessWidget {
  final _scrollController = ScrollController();

  CitiesListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Example with cities images'),
      ),
      body: Stack(
        children: <Widget>[
          Image.asset(
            'assets/world.jpeg',
            fit: BoxFit.fitHeight,
            height: MediaQuery.of(context).size.height,
          ),
          Center(
            child: SizedBox(
              height: 400,
              child: FadingEdgeScrollView.fromScrollView(
                child: ListView(
                  controller: _scrollController,
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
            ),
          )
        ],
      ),
    );
  }
}

class ListWheelScrollViewScreen extends StatelessWidget {
  final _controller = ScrollController();

  ListWheelScrollViewScreen({Key? key}) : super(key: key);

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
