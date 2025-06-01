import 'package:flutter/material.dart';
// Assuming problem_details_screen.dart exists and defines ProblemDetailsScreen
// Assuming category_model.dart exists and defines CategoryModel
import 'report_problem_details_screen.dart';
class CategorySelectionScreen extends StatelessWidget {
  // Replace with your actual category data, potentially fetched from an API
  final List<CategoryModel> categories = [
    CategoryModel(id: '1', name: 'Routes', logoPath: 'assets/images/logo_routes.png'),
    CategoryModel(id: '2', name: 'Eau', logoPath: 'assets/images/logo_eau.png'),
    CategoryModel(id: '3', name: 'Électricité', logoPath: 'assets/images/logo_electricite.png'),
    CategoryModel(id: '4', name: 'Déchets', logoPath: 'assets/images/logo_dechets.png'),
    CategoryModel(id: '5', name: 'Permis de construire ou de démolir', logoPath: 'assets/images/logo_permis.png'),
    CategoryModel(id: '6', name: 'Autre', logoPath: 'assets/images/logo_autre.png'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Choisir une catégorie'),
        // Add styling as needed
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Adjust number of columns
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
            childAspectRatio: 1.0, // Adjust aspect ratio for desired item size
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return CategoryGridItem(category: category);
          },
        ),
      ),
    );
  }
}

class CategoryGridItem extends StatefulWidget {
  final CategoryModel category;

  const CategoryGridItem({Key? key, required this.category}) : super(key: key);

  @override
  _CategoryGridItemState createState() => _CategoryGridItemState();
}

class _CategoryGridItemState extends State<CategoryGridItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
    // Navigate to the details screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReportProblemDetailsScreen(category: widget.category),
      ),
    );
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Card(
          elevation: 4.0, // Add some shadow
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // IMPORTANT: Flutter cannot directly load local file system paths like this.
                // You MUST use asset paths (e.g., 'assets/logos/logo_routes.png') 
                // and declare them in pubspec.yaml, or load from network.
                // Using placeholder icon for now.
                Image.asset(
                  widget.category.logoPath, // THIS WILL FAIL - NEEDS ASSET PATH
                  height: 60, // Adjust size
                  width: 60,
                  errorBuilder: (context, error, stackTrace) {
                    // Placeholder in case image loading fails
                    return Icon(Icons.image_not_supported, size: 60);
                  },
                ),
                SizedBox(height: 12.0),
                Text(
                  widget.category.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14, // Adjust font size
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Dummy Category Model - Define this properly in category_model.dart

// Dummy Problem Details Screen - Define this properly in problem_details_screen.dart
class ProblemDetailsScreen extends StatelessWidget {
  final CategoryModel category;

  const ProblemDetailsScreen({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Signaler: ${category.name}'),
      ),
      body: Center(
        child: Text('Details for ${category.name}'),
      ),
    );
  }
}

