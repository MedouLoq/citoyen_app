// lib/screens/problem_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:citoyen_app/providers/problem_provider.dart';
import 'package:intl/intl.dart';
import 'problem_detail_screen.dart';

class ProblemListScreen extends StatefulWidget {
  const ProblemListScreen({Key? key}) : super(key: key);

  @override
  State<ProblemListScreen> createState() => _ProblemListScreenState();
}

class _ProblemListScreenState extends State<ProblemListScreen> {
  final ScrollController _scrollController = ScrollController();
  String _filterStatus = 'ALL';
  
  @override
  void initState() {
    super.initState();
    // Fetch problems when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProblemProvider>(context, listen: false).fetchProblems();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mes Problèmes Signalés',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Consumer<ProblemProvider>(
        builder: (context, problemProvider, _) {
          if (problemProvider.isLoading) {
            return _buildLoadingState(colors);
          } else if (problemProvider.errorMessage.isNotEmpty) {
            return _buildErrorState(problemProvider.errorMessage, colors);
          } else if (problemProvider.problems.isEmpty) {
            return _buildEmptyState(colors);
          } else {
            // Filter problems based on selected status
            final filteredProblems = _filterStatus == 'ALL'
                ? problemProvider.problems
                : problemProvider.problems
                    .where((problem) => problem['status'] == _filterStatus)
                    .toList();
                    
            return RefreshIndicator(
              onRefresh: () => problemProvider.fetchProblems(),
              child: CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // Status filter chips
                  SliverToBoxAdapter(
                    child: _buildFilterChips(colors),
                  ),
                  
                  // Problem count
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: Text(
                        '${filteredProblems.length} problème${filteredProblems.length > 1 ? 's' : ''}',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: colors.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ),
                  ),
                  
                  // Problem list
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final problem = filteredProblems[index];
                        return _buildProblemCard(problem, colors, index);
                      },
                      childCount: filteredProblems.length,
                    ),
                  ),
                  
                  // Bottom padding
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 80),
                  ),
                ],
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/report_problem');
        },
        icon: const Icon(Icons.add),
        label: Text(
          'Signaler',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
  
  Widget _buildFilterChips(ColorScheme colors) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildFilterChip('ALL', 'Tous', colors),
          const SizedBox(width: 8),
          _buildFilterChip('PENDING', 'En attente', colors),
          const SizedBox(width: 8),
          _buildFilterChip('IN_PROGRESS', 'En cours', colors),
          const SizedBox(width: 8),
          _buildFilterChip('RESOLVED', 'Résolu', colors),
          const SizedBox(width: 8),
          _buildFilterChip('REJECTED', 'Rejeté', colors),
        ],
      ),
    );
  }
  
  Widget _buildFilterChip(String value, String label, ColorScheme colors) {
    final isSelected = _filterStatus == value;
    
    return FilterChip(
      selected: isSelected,
      label: Text(
        label,
        style: GoogleFonts.inter(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color: isSelected ? colors.onPrimary : colors.onSurface,
        ),
      ),
      backgroundColor: colors.surface,
      selectedColor: colors.primary,
      checkmarkColor: colors.onPrimary,
      elevation: 1,
      pressElevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? colors.primary : colors.outline.withOpacity(0.3),
          width: 1,
        ),
      ),
      onSelected: (selected) {
        setState(() {
          _filterStatus = value;
        });
      },
    );
  }
  
  Widget _buildProblemCard(Map<String, dynamic> problem, ColorScheme colors, int index) {
    final statusColors = {
      'PENDING': colors.secondary,
      'IN_PROGRESS': Colors.blue,
      'RESOLVED': Colors.green,
      'REJECTED': Colors.red,
    };
    
    final statusLabels = {
      'PENDING': 'En attente',
      'IN_PROGRESS': 'En cours',
      'RESOLVED': 'Résolu',
      'REJECTED': 'Rejeté',
    };
    
    final statusColor = statusColors[problem['status']] ?? colors.primary;
    final statusLabel = statusLabels[problem['status']] ?? 'Inconnu';
    
    // Format date
    String formattedDate = '';
    try {
      final date = DateTime.parse(problem['created_at']);
      formattedDate = DateFormat('dd MMM yyyy, HH:mm').format(date);
    } catch (e) {
      formattedDate = 'Date inconnue';
    }
    
    return Card(
      margin: EdgeInsets.fromLTRB(16, index == 0 ? 0 : 8, 16, 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ProblemDetailScreen(problemId: problem['id']),
  ),
);

        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status chip and date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Chip(
                    label: Text(
                      statusLabel,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    backgroundColor: statusColor,
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  Text(
                    formattedDate,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: colors.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Category
              if (problem['category'] != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: colors.primaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    problem['category']['name'] ?? 'Catégorie inconnue',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: colors.primary,
                    ),
                  ),
                ),
              
              const SizedBox(height: 12),
              
              // Description
              Text(
                problem['description'] ?? 'Pas de description',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 8),
              
              // Location
              if (problem['municipality'] != null)
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: colors.onSurface.withOpacity(0.6),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        problem['municipality']['name'] ?? 'Lieu inconnu',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: colors.onSurface.withOpacity(0.6),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              
              // Show image thumbnail if available
              if (problem['image'] != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      problem['image'],
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 120,
                          width: double.infinity,
                          color: colors.surfaceVariant,
                          child: Center(
                            child: Icon(
                              Icons.image_not_supported,
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    ).animate()
      .fadeIn(duration: 300.ms, delay: (50 * index).ms)
      .slideY(begin: 0.1, end: 0, duration: 300.ms, curve: Curves.easeOutQuad);
  }
  
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Filtrer par statut',
            style: GoogleFonts.inter(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFilterOption('ALL', 'Tous les problèmes'),
              _buildFilterOption('PENDING', 'En attente'),
              _buildFilterOption('IN_PROGRESS', 'En cours'),
              _buildFilterOption('RESOLVED', 'Résolu'),
              _buildFilterOption('REJECTED', 'Rejeté'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Fermer'),
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildFilterOption(String value, String label) {
    return RadioListTile<String>(
      title: Text(label),
      value: value,
      groupValue: _filterStatus,
      onChanged: (newValue) {
        setState(() {
          _filterStatus = newValue!;
        });
        Navigator.pop(context);
      },
    );
  }
  
  Widget _buildLoadingState(ColorScheme colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: colors.primary),
          const SizedBox(height: 16),
          Text(
            'Chargement des problèmes...',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: colors.onBackground.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildErrorState(String errorMessage, ColorScheme colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 60,
              color: colors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Erreur de chargement',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colors.onBackground,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: colors.onBackground.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Provider.of<ProblemProvider>(context, listen: false).fetchProblems();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEmptyState(ColorScheme colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 60,
              color: colors.onBackground.withOpacity(0.4),
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun problème signalé',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colors.onBackground,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Vous n\'avez pas encore signalé de problème. Utilisez le bouton ci-dessous pour signaler un nouveau problème.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: colors.onBackground.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/report_problem');
              },
              icon: const Icon(Icons.add),
              label: const Text('Signaler un problème'),
            ),
          ],
        ),
      ),
    );
  }
}
