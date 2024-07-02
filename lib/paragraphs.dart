import 'dart:async';
import 'package:flutter/material.dart';
import 'main.dart';

class AutoScrollingScrollView extends StatefulWidget {
  final List<String> paragraphs;
  final Duration scrollDuration;

  const AutoScrollingScrollView(this.paragraphs, {this.scrollDuration = const Duration(seconds:5)});

  @override
  _AutoScrollingScrollViewState createState() => _AutoScrollingScrollViewState();
}

class _AutoScrollingScrollViewState extends State<AutoScrollingScrollView> {
  ScrollController _controller = ScrollController();
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startScrolling();
  }

  void _startScrolling() {
    _timer = Timer.periodic(widget.scrollDuration, (_) {
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _controller,
      itemCount: widget.paragraphs.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            widget.paragraphs[index],
            style: TextStyle(fontSize: 18),
          ),
        );
      },
    );
  }
}

class Paragraphs {
  static List<String> getParagraphs() {
    return [
      // Paragraph 1
      "Jopple, the cutting-edge job app revolutionizing the way job seekers and employers connect, was founded in the vibrant year of 2024. Born from the vision of bridging the gap between talent and opportunity, Jopple is more than just another job platform – it's a dynamic ecosystem where innovation meets necessity.\n",

      // Paragraph 2
      "At Jopple, we understand the challenges faced by both job seekers and employers in today's rapidly evolving workforce landscape. For job seekers, navigating the job market can feel like wandering through a maze without a map. That's why Jopple offers a seamless and intuitive platform designed to streamline the job search process. With powerful search filters, personalized recommendations, and real-time notifications, finding the perfect job opportunity has never been easier.\n",

      // Paragraph 3
      "For employers, sourcing top talent can be a daunting task, often requiring valuable time and resources. Jopple simplifies the hiring process by providing employers with access to a diverse pool of qualified candidates, matched perfectly to their specific needs and preferences. Our advanced algorithms ensure that every job posting reaches the right audience, maximizing exposure and minimizing time-to-hire.\n",

      // Paragraph 4
      "But Jopple is more than just a platform – it's a community. We believe in the power of networking and collaboration, which is why we've built features that facilitate meaningful connections between job seekers and employers. From virtual networking events to interactive forums, Jopple provides a space where professionals can engage, learn, and grow together.\n",

      // Paragraph 5
      "At the heart of Jopple is our commitment to diversity, equity, and inclusion. We believe that every individual deserves an equal opportunity to succeed, regardless of their background or circumstances. That's why we partner with organizations and initiatives that share our values, working together to create a more inclusive workforce for all.\n",

      // Paragraph 6
      "Whether you're a recent graduate searching for your first job, a seasoned professional looking to take the next step in your career, or an employer seeking top talent to drive your business forward, Jopple is here to help you succeed. Join us in shaping the future of work, one opportunity at a time. Welcome to Jopple – where talent meets opportunity, and possibilities are limitless.\n",

      // Paragraph 7
      "Comprehensive Job Search Tools: Jopple offers a comprehensive suite of job search tools designed to empower job seekers in their quest for the perfect opportunity. From advanced search filters that allow users to narrow down their options based on criteria such as location, industry, and salary range, to personalized recommendations that surface relevant job listings tailored to each user's unique skills and experience, Jopple ensures that no stone is left unturned in the pursuit of the ideal job.\n",

      // Paragraph 8
      "Intuitive User Experience: We understand that the job search process can be overwhelming, which is why Jopple is committed to providing an intuitive and user-friendly experience. Our platform features a clean and modern interface that makes it easy for users to navigate and find what they're looking for. Whether you're browsing job listings, updating your profile, or communicating with potential employers, Jopple's intuitive design makes the process seamless and hassle-free.\n",

      // Paragraph 9
      "Real-Time Notifications: Never miss out on an opportunity again with Jopple's real-time notifications. Whether it's a new job listing that matches your preferences, a message from a potential employer, or an upcoming networking event in your area, Jopple keeps you informed every step of the way. With instant alerts delivered straight to your device, you'll always be one step ahead in your job search.\n",

      // Paragraph 10
      "Advanced Matching Algorithms: Finding the perfect job match can feel like searching for a needle in a haystack, but not with Jopple. Our advanced matching algorithms analyze your skills, experience, and preferences to connect you with job opportunities that align with your unique profile. Say goodbye to endless scrolling and fruitless applications – with Jopple, your next career move is just a click away.\n",

      // Paragraph 11
      "Efficient Hiring Process: For employers, Jopple offers a streamlined and efficient hiring process that saves time and resources. Our platform allows employers to create customized job postings, set screening criteria, and manage applications seamlessly from start to finish. With tools for scheduling interviews, communicating with candidates, and tracking progress, Jopple empowers employers to find the right talent quickly and effectively, without the hassle of traditional recruitment methods.\n",

      // Paragraph 12
      "Networking and Community Building: Jopple isn't just a job board – it's a thriving community of professionals committed to helping each other succeed. Through virtual networking events, interactive forums, and industry-specific groups, Jopple provides a space where job seekers and employers can connect, collaborate, and learn from one another. Whether you're seeking mentorship, advice, or simply a supportive community to be a part of, Jopple has you covered.\n",

      // Paragraph 13
      "Diversity, Equity, and Inclusion: At Jopple, we believe that diversity drives innovation and fosters a more inclusive workplace culture. That's why we're dedicated to promoting diversity, equity, and inclusion in everything we do. From partnering with diverse organizations and initiatives to implementing inclusive hiring practices, Jopple is committed to creating a more equitable workforce for all. We believe that every individual deserves an equal opportunity to succeed, regardless of their background or circumstances.\n",

      // Paragraph 14
      "Continuous Improvement: We're constantly innovating and improving to ensure that Jopple remains at the forefront of the job search and hiring industry. From incorporating user feedback to staying abreast of the latest trends and technologies, we're committed to providing the best possible experience for our users. Whether it's through new features, partnerships, or initiatives, Jopple is always striving to raise the bar and exceed expectations.\n",

      // Paragraph 15
      "Join the Jopple Community: Whether you're a job seeker looking for your next opportunity or an employer seeking top talent, Jopple invites you to join our growing community. With powerful tools, intuitive features, and a commitment to diversity and inclusion, Jopple is your partner in success. Welcome to Jopple – where talent meets opportunity, and the future of work is brighter than ever.\n",
    ];
  }
}

class EnhancedText extends StatelessWidget {
  final String text;
  final FontWeight fontWeight;
  final double fontSize;
  final Color color;
  final TextAlign textAlign;
  final EdgeInsets padding;

  const EnhancedText({
    Key? key,
    required this.text,
    this.fontWeight = FontWeight.normal,
    this.fontSize = 14.0,
    this.color = Colors.black,
    this.textAlign = TextAlign.left,
    this.padding = EdgeInsets.zero,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Text(
        text,
        style: TextStyle(
          fontWeight: fontWeight,
          fontSize: fontSize,
          color: color,
        ),
        textAlign: textAlign,
      ),
    );
  }
}