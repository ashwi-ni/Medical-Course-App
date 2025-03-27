// import 'package:flutter/material.dart';
// import 'package:video_player/video_player.dart';
//
// class VideoPlayerWithControls extends StatefulWidget {
//   final String videoUrl;
//
//   const VideoPlayerWithControls({required this.videoUrl, Key? key}) : super(key: key);
//
//   @override
//   _VideoPlayerWithControlsState createState() => _VideoPlayerWithControlsState();
// }
//
// class _VideoPlayerWithControlsState extends State<VideoPlayerWithControls> {
//   late VideoPlayerController _controller;
//   bool _isExpanded = false; // Track if the video is expanded
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = VideoPlayerController.network(widget.videoUrl)
//       ..initialize().then((_) {
//         setState(() {});
//         _controller.play(); // Auto-play video
//       });
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   void _toggleExpandCollapse() {
//     setState(() {
//       _isExpanded = !_isExpanded; // Toggle the expanded state
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         AnimatedContainer(
//           duration: Duration(milliseconds: 300),
//           height: _isExpanded ? 300 : 150, // Change height based on expanded state
//           width: double.infinity,
//           child: _controller.value.isInitialized
//               ? AspectRatio(
//             aspectRatio: _controller.value.aspectRatio,
//             child: VideoPlayer(_controller),
//           )
//               : Center(child: CircularProgressIndicator()),
//         ),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             IconButton(
//               icon: Icon(
//                 _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
//               ),
//               onPressed: () {
//                 setState(() {
//                   _controller.value.isPlaying ? _controller.pause() : _controller.play();
//                 });
//               },
//             ),
//             IconButton(
//               icon: Icon(
//                 _isExpanded ? Icons.fullscreen_exit : Icons.fullscreen,
//               ),
//               onPressed: _toggleExpandCollapse, // Expand or collapse video
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }
