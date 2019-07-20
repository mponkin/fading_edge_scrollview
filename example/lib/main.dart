import 'package:example/lipsum.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fading Edge ScrollView Example',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
      ),
      home: ExamplesList(),
    );
  }
}

class ExamplesList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("FadingEdgeScrollView examples"),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            NavigatorButton(text: "ListView", builder: (_) => ListViewScreen()),
            NavigatorButton(text: "PageView", builder: (_) => PageViewScreen()),
            NavigatorButton(text: "Long text", builder: (_) => LongTextScreen())
          ],
        ),
      ),
    );
  }
}

class NavigatorButton extends StatelessWidget {
  final String text;
  final WidgetBuilder builder;

  NavigatorButton({
    @required this.text,
    @required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      child: Text(text),
      onPressed: () {
        Navigator.of(context).push(MaterialPageRoute(builder: builder));
      },
    );
  }
}

class ListViewScreen extends StatelessWidget {
  final _controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Example with ListView"),
      ),
      body: Container(
        color: Colors.greenAccent,
        child: FadingEdgeScrollView.fromScrollView(
          child: ListView.builder(
            controller: _controller,
            itemBuilder: (context, index) => ListTile(
                title: Text("Item #$index"),
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(
                      "https://images.freeimages.com/images/large-previews/848/a-cat-1313470.jpg"),
                )),
            itemCount: 30,
          ),
        ),
      ),
    );
  }
}

class PageViewScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Example with PageView"),
      ),
      body: FadingEdgeScrollView.fromPageView(
        child: PageView(
          children: <Widget>[
            Card(color: Colors.red),
            Card(color: Colors.green),
            Card(color: Colors.blue),
          ],
        ),
        gradientFractionOnStart: 0.05,
        gradientFractionOnEnd: 0.05,
      ),
    );
  }
}

class LongTextScreen extends StatelessWidget {
  final controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Example with long text"),
      ),
      body: FadingEdgeScrollView.fromSingleChildScrollView(
        child: SingleChildScrollView(
          controller: controller,
          child: Padding(padding: EdgeInsets.all(5), child: Text(lipsumText)),
        ),
      ),
    );
  }
}
