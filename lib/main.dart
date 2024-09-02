import 'dart:convert'; // For converting JSON data
import 'package:flutter/material.dart'; // Flutter UI framework
import 'package:provider/provider.dart'; // State management package
import 'package:http/http.dart' as http; // Package for making HTTP requests

// The main function that starts the app
void main() {
  runApp(MyApp());
}

// Root widget of the application
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Providing PostProvider to the widget tree
    return ChangeNotifierProvider(
      create: (context) =>
          PostProvider(), // Creates an instance of PostProvider
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: PostScreen(), // The home screen of the app
      ),
    );
  }
}

// Provider class for managing the state of posts
class PostProvider with ChangeNotifier {
  List<Post> _posts = []; // List to hold fetched posts (_ means private)
  bool _isLoading = false; // Loading indicator state

  // Getter for the list of posts
  List<Post> get posts => _posts;

  // Getter for the loading state
  bool get isLoading => _isLoading;

  // Method to fetch posts from the API and update the state
  Future<void> fetchAndSetPost() async {
    _isLoading = true; // Set loading to true
    notifyListeners(); // Notify listeners about the state change

    try {
      _posts = await fetchPosts(); // Fetch posts from the API
    } catch (error) {
      Text('$error');
      print(error); // Handle any errors
    } finally {
      _isLoading = false; // Set loading to false
      notifyListeners(); // Notify listeners about the state change
    }
  }
}

// Model class for a Post
class Post {
  final int id; // ID of the post
  final String title; // Title of the post
  final String body; // Body content of the post

  // Constructor for creating a Post object
  Post({required this.id, required this.title, required this.body});

  // Factory constructor to create a Post from JSON data
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      title: json['title'],
      body: json['body'],
    );
  }
}

// Function to fetch posts from the API
Future<List<Post>> fetchPosts() async {
  final response =
      await http.get(Uri.parse("https://jsonplaceholder.typicode.com/posts"));

  // If the response is successful, parse the JSON and return a list of posts
  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((post) => Post.fromJson(post)).toList();
  } else {
    throw Exception('Failed to load API Data'); // Handle errors
  }
}

// The screen that displays the list of posts
class PostScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Getting Dimensions of Screen
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    // Accessing the PostProvider to get the state
    final postProvider = Provider.of<PostProvider>(context);

    return Scaffold(
      appBar: AppBar(
        elevation: height * 0.006,
        shadowColor: Colors.black,
        toolbarHeight: height * 0.1,
        title: Center(
            child: Text(
          "API Data",
          style: TextStyle(
              fontSize: height * 0.04,
              color: Colors.white,
              fontWeight: FontWeight.bold),
        )), // Title of the screen
        backgroundColor: Colors.lightBlue,
        shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.vertical(bottom: Radius.circular(height * 0.02))),
      ),
      body: postProvider.isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(), // Show loading indicator if data is being fetched
            )
          : ListView.builder(
              itemCount:
                  postProvider.posts.length, // Number of posts to display
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.fromLTRB(
                      height * 0.01, height * 0.01, height * 0.01, 0),
                  child: Card(
                    color: Colors.white54,
                    child: ListTile(
                      title: Text('${postProvider.posts[index].id}. ${
                        postProvider.posts[index].title
                      }'), // Display the post title
                      subtitle: Text(postProvider
                          .posts[index].body), // Display the post body
                    ),
                  ),
                );
              }),
      floatingActionButton: SizedBox(
        height: height * 0.09,
        width: width * 0.2,
        child: FloatingActionButton(
          backgroundColor: Colors.lightBlue,
          onPressed: () {
            postProvider
                .fetchAndSetPost(); // Fetch and update posts when button is pressed
          },
          child: Icon(Icons.refresh,color: Colors.white,size: height * 0.06,), // Icon for the button
        ),
      ),
    );
  }
}
