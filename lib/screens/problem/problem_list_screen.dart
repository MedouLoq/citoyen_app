// lib/screens/problem_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:citoyen_app/providers/problem_provider.dart';
import 'package:intl/intl.dart';
import 'problem_detail_screen.dart';
import 'package:citoyen_app/l10n/app_localizations.dart';

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

  // Pull-to-refresh handler
  Future<void> _onRefresh() async {
    await Provider.of<ProblemProvider>(context, listen: false).fetchProblems();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          localizations?.myReportedProblems ?? 'Mes Problèmes Signalés',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: colors.onPrimary,
            fontSize: 20,
          ),
        ),
        backgroundColor: colors.primary,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: colors.onPrimary),
            tooltip: localizations?.refresh ?? 'Actualiser',
            onPressed: _onRefresh,
          ),
          IconButton(
            icon: Icon(Icons.filter_list_rounded, color: colors.onPrimary),
            tooltip: localizations?.filterByStatus ?? 'Filtrer par statut',
            onPressed: () => _showFilterBottomSheet(context, localizations),
          ),
        ],
      ),
      body: Consumer<ProblemProvider>(
        builder: (context, problemProvider, child) {
          if (problemProvider.isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: colors.primary),
                  const SizedBox(height: 16),
                  Text(
                    localizations?.loadingProblems ??
                        'Chargement des problèmes...',
                    style: GoogleFonts.inter(color: colors.onSurfaceVariant),
                  ),
                ],
              ),
            ).animate().fadeIn();
          } else if (problemProvider.errorMessage.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: colors.error, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    localizations?.loadingError ?? 'Erreur de chargement',
                    style: GoogleFonts.inter(color: colors.error, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    problemProvider.errorMessage,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(color: colors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _onRefresh,
                    icon: const Icon(Icons.refresh),
                    label: Text(localizations?.retry ?? 'Réessayer'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: colors.onPrimary,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn();
          } else if (problemProvider.problems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined,
                      color: colors.onSurfaceVariant, size: 64),
                  const SizedBox(height: 24),
                  Text(
                    localizations?.noProblemsFound ?? 'Aucun problème trouvé',
                    style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: colors.onSurface),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Text(
                      localizations?.noProblemsFoundMessage ??
                          'Vous n\'avez signalé aucun problème pour le moment.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                          fontSize: 15,
                          color: colors.onSurfaceVariant,
                          height: 1.4),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn();
          } else {
            final filteredProblems = problemProvider.problems.where((problem) {
              if (_filterStatus == 'ALL') {
                return true;
              } else {
                return problem['status'] == _filterStatus;
              }
            }).toList();

            if (filteredProblems.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.filter_alt_off,
                        color: colors.onSurfaceVariant, size: 64),
                    const SizedBox(height: 24),
                    Text(
                      localizations?.noProblemsFound ?? 'Aucun problème trouvé',
                      style: GoogleFonts.inter(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: colors.onSurface),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Text(
                        localizations?.noProblemsFoundMessage ??
                            'Vous n\'avez signalé aucun problème pour le moment.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                            fontSize: 15,
                            color: colors.onSurfaceVariant,
                            height: 1.4),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn();
            }

            return RefreshIndicator(
              onRefresh: _onRefresh,
              color: colors.primary,
              backgroundColor: colors.surfaceVariant,
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16.0),
                itemCount: filteredProblems.length,
                itemBuilder: (context, index) {
                  final problem = filteredProblems[index];
                  return ProblemCard(
                    problem: problem,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ProblemDetailScreen(problemId: problem['id']),
                        ),
                      );
                    },
                  )
                      .animate()
                      .fadeIn(delay: (50 * index).ms, duration: 300.ms)
                      .slideY(begin: 0.1, end: 0);
                },
              ),
            );
          }
        },
      ),
    );
  }

  void _showFilterBottomSheet(
      BuildContext context, AppLocalizations? localizations) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        final colors = Theme.of(context).colorScheme;
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localizations?.filterByStatus ?? 'Filtrer par statut',
                style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colors.onSurface),
              ),
              const SizedBox(height: 20),
              _buildFilterOption(
                context,
                localizations?.all ?? 'Tous',
                'ALL',
                colors,
              ),
              _buildFilterOption(
                context,
                localizations?.pending ?? 'En attente',
                'PENDING',
                colors,
              ),
              _buildFilterOption(
                context,
                localizations?.inProgress ?? 'En cours',
                'IN_PROGRESS',
                colors,
              ),
              _buildFilterOption(
                context,
                localizations?.resolved ?? 'Résolu',
                'RESOLVED',
                colors,
              ),
              _buildFilterOption(
                context,
                localizations?.rejected ?? 'Rejeté',
                'REJECTED',
                colors,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(localizations?.close ?? 'Fermer'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterOption(
      BuildContext context, String title, String status, ColorScheme colors) {
    return RadioListTile<String>(
      title: Text(title, style: GoogleFonts.inter(color: colors.onSurface)),
      value: status,
      groupValue: _filterStatus,
      onChanged: (String? newValue) {
        if (newValue != null) {
          setState(() {
            _filterStatus = newValue;
          });
          Provider.of<ProblemProvider>(context, listen: false).fetchProblems();
          Navigator.pop(context); // Close bottom sheet after selection
        }
      },
      activeColor: colors.primary,
      contentPadding: EdgeInsets.zero,
    );
  }
}

class ProblemCard extends StatelessWidget {
  final Map<String, dynamic> problem;
  final VoidCallback onTap;

  const ProblemCard({
    Key? key,
    required this.problem,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final localizations = AppLocalizations.of(context);

    // Format date
    String formattedDate = localizations?.unknownDate ?? 'Date inconnue';
    try {
      final date = DateTime.parse(problem['created_at']);
      formattedDate = DateFormat('dd MMMM yyyy, HH:mm', 'fr_FR').format(date);
    } catch (e) {
      print("Error parsing date: $e");
    }

    // Status display
    String statusText = localizations?.unknownStatus ?? 'Inconnu';
    Color statusColor = colors.onSurfaceVariant;
    IconData statusIcon = Icons.help_outline;

    switch (problem['status']) {
      case 'PENDING':
        statusText = localizations?.statusPending ?? 'En attente';
        statusColor = Colors.orange.shade700;
        statusIcon = Icons.hourglass_empty_rounded;
        break;
      case 'IN_PROGRESS':
        statusText = localizations?.statusInProgress ?? 'En cours';
        statusColor = Colors.blue.shade600;
        statusIcon = Icons.sync_rounded;
        break;
      case 'RESOLVED':
        statusText = localizations?.statusResolved ?? 'Résolu';
        statusColor = Colors.green.shade700;
        statusIcon = Icons.check_circle_outline_rounded;
        break;
      case 'REJECTED':
        statusText = localizations?.statusRejected ?? 'Rejeté';
        statusColor = colors.error;
        statusIcon = Icons.cancel_outlined;
        break;
      default:
        statusText = localizations?.unknownStatus ?? 'Inconnu';
        statusColor = colors.onSurfaceVariant;
        statusIcon = Icons.help_outline_rounded;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (problem['photo_url'] != null && problem['photo_url'].isNotEmpty)
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: colors.surfaceVariant,
                  image: DecorationImage(
                    image: NetworkImage(problem['photo_url']),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Chip(
                      avatar:
                          Icon(statusIcon, size: 18, color: colors.onPrimary),
                      label: Text(statusText,
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              color: colors.onPrimary)),
                      backgroundColor: statusColor,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      labelPadding: const EdgeInsets.only(left: 4),
                      visualDensity: VisualDensity.compact,
                      elevation: 2,
                      shadowColor: statusColor.withOpacity(0.5),
                    ),
                  ),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                color: colors.surfaceVariant,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Chip(
                    avatar: Icon(statusIcon, size: 18, color: colors.onPrimary),
                    label: Text(statusText,
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            color: colors.onPrimary)),
                    backgroundColor: statusColor,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    labelPadding: const EdgeInsets.only(left: 4),
                    visualDensity: VisualDensity.compact,
                    elevation: 2,
                    shadowColor: statusColor.withOpacity(0.5),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    problem['category']?['name'] ??
                        (localizations?.unknownCategory ??
                            'Catégorie inconnue'),
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    problem['description'] ??
                        (localizations?.noDescription ?? 'Pas de description'),
                    style: GoogleFonts.inter(
                        fontSize: 14, color: colors.onSurfaceVariant),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          size: 18, color: colors.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          problem['municipality']?['name'] ??
                              (localizations?.unknownLocation ??
                                  'Lieu inconnu'),
                          style: GoogleFonts.inter(
                              fontSize: 13, color: colors.onSurfaceVariant),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.calendar_today_outlined,
                          size: 16, color: colors.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(
                        formattedDate,
                        style: GoogleFonts.inter(
                            fontSize: 13, color: colors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
