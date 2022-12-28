import 'package:flutter/material.dart';
import '../CommentsService.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const appTitle = 'Comments';

    return const MaterialApp(
      title: appTitle,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  CommentsService service = CommentsService();
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    refresh();
  }

  final String title = 'Comments';

  Future<void> refresh() async {
    setState(() {
      service.fetchComments();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Comments'),
        ),
        body: _buildBody(context));
  }

  //------- View Configurations -----
  
  Widget _buildBody(BuildContext context) {
    return Stack(children: [
      _buildGuideMessage(),
      _builRefreshableList(context),
      _buildMessageCounterView(),
      _buildMessageBox(),
    ]);
  }

  Widget _buildGuideMessage() {
    return Row(
      children: const [
        Text('Pull me down please to load Next Page'),
        Icon(Icons.arrow_downward, size: 50),
      ],
    );
  }

  Widget _buildMessageBox() {
    return Padding(
        padding: const EdgeInsets.only(top: 580, left: 8),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 50.0),
          child: Row(
            children: <Widget>[
              Flexible(
                child: TextField(
                  controller: _textController,
                  onSubmitted: _handleSendTapped,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Send comment',
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                child: IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () => _handleSendTapped(_textController.text)),
              ),
            ],
          ),
        ));
  }

  Widget _buildMessageCounterView() {
    return Padding(
        padding: const EdgeInsets.only(top: 600, left: 8),
        child: Text('Feched Comments amount: ${service.comments.length}'));
  }

  Widget _builRefreshableList(BuildContext context) {
    return RefreshIndicator(
          onRefresh: refresh,
          child: Padding(
              padding: const EdgeInsets.only(bottom: 150),
              child:
                _builList(context),
              ));
  }

  Widget _builList(BuildContext context) {
    return ListView.builder(
        itemCount: service.comments.length,
        itemBuilder: (context, int index) {
          if (index == service.comments.length - 1) {
            //here need to be logic for endless scrolling
            return const Center(
                child: Padding(
              padding: EdgeInsets.all(8),
              child: CircularProgressIndicator(),
            ));
          } else {
            return Container(
                width: 80,
                height: 60,
                color: Colors.white,
                child: Card(
                    elevation: 5,
                    child: ListTile(
                        title: Text(
                      service.comments[index].title,
                      style: const TextStyle(fontSize: 14, color: Colors.black),
                    ))));
          }
        });
  }

//------- Event Handlers -----

  void _handleSendTapped(String text) {
     _textController.clear();
    Status status = service.sendMessageToServer(text) as Status;
    if (status == Status.success) {
      // ignore: avoid_print
      print('message sent!');
    } else {
      // ignore: avoid_print
      print('error!');
    }
   
  }
}
