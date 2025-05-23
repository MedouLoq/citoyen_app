import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:citoyen_app/screens/complaint/complaint_detail_screen.dart'; // Placeholder

// Placeholder Model for a Complaint
class ComplaintItem {
  final String id;
  final String subject;
  final String descriptionSnippet;
  final String status;
  final DateTime createdAt;

  ComplaintItem({
    required this.id,
    required this.subject,
    required this.descriptionSnippet,
    required this.status,
    required this.createdAt,
  });
}

class ComplaintListScreen extends StatefulWidget {
  const ComplaintListScreen({super.key});

  @override
  State<ComplaintListScreen> createState() => _ComplaintListScreenState();
}

class _ComplaintListScreenState extends State<ComplaintListScreen> {
  // Placeholder data - replace with actual data fetching
  final List<ComplaintItem> _complaints = List.generate(
    7,
    (index) => ComplaintItem(
      id: 'complaint_$index',
      subject: 'Retard de traitement de dossier N°${12345 + index}',
      descriptionSnippet: 'Cela fait plus de 3 semaines que mon dossier est en attente de validation...',
      status: index % 3 == 0 ? 'Clôturée' : (index % 3 == 1 ? 'En cours de traitement' : 'Soumise'),
      createdAt: DateTime.now().subtract(Duration(days: index * 2, hours: index * 5)),
    ),
  );

  String _selectedFilter = 'Toutes';
  final List<String> _filterOptions = ['Toutes', 'Soumise', 'En cours de traitement', 'Clôturée'];

  List<ComplaintItem> get _filteredComplaints {
    if (_selectedFilter == 'Toutes') {
      return _complaints;
    }
    return _complaints.where((complaint) => complaint.status == _selectedFilter).toList();
  }

  Widget _buildStatusBadge(String status, ColorScheme colors) {
    Color backgroundColor;
    Color textColor;
    IconData iconData;

    switch (status) {
      case 'Soumise':
        backgroundColor = colors.errorContainer.withOpacity(0.7);
        textColor = colors.onErrorContainer;
        iconData = Icons.forward_to_inbox_outlined;
        break;
      case 'En cours de traitement':
        backgroundColor = colors.secondaryContainer.withOpacity(0.7);
        textColor = colors.onSecondaryContainer;
        iconData = Icons.hourglass_top_outlined;
        break;
      case 'Clôturée':
        backgroundColor = colors.tertiaryContainer.withOpacity(0.7);
        textColor = colors.onTertiaryContainer;
        iconData = Icons.check_circle_outline_rounded;
        break;
      default:
        backgroundColor = Colors.grey.shade300;
        textColor = Colors.black;
        iconData = Icons.help_outline_rounded;
    }

    return Chip(
      avatar: Icon(iconData, size: 16, color: textColor),
      label: Text(status, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: textColor)),
      backgroundColor: backgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      labelPadding: const EdgeInsets.only(left: 4, right: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text('Mes Réclamations', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        backgroundColor: colors.background,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filter Chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _filterOptions.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final filter = _filterOptions[index];
                  final isSelected = _selectedFilter == filter;
                  return ChoiceChip(
                    label: Text(filter, style: GoogleFonts.inter(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedFilter = filter;
                        });
                      }
                    },
                    selectedColor: colors.primary.withOpacity(0.9),
                    labelStyle: GoogleFonts.inter(color: isSelected ? colors.onPrimary : colors.onSurface.withOpacity(0.8)),
                    backgroundColor: colors.surfaceVariant.withOpacity(0.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ).animate().fadeIn(delay: (100 * index).ms).slideX(begin: 0.2);
                },
              ),
            ),
          ),
          Expanded(
            child: _filteredComplaints.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded, size: 80, color: colors.onSurface.withOpacity(0.4)),
                        const SizedBox(height: 16),
                        Text(
                          'Aucune réclamation trouvée pour "$_selectedFilter"',
                          style: GoogleFonts.inter(fontSize: 16, color: colors.onSurface.withOpacity(0.6)),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ).animate().fadeIn(duration: 500.ms).scale(curve: Curves.elasticOut),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _filteredComplaints.length,
                    itemBuilder: (context, index) {
                      final complaint = _filteredComplaints[index];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => ComplaintDetailScreen(complaintId: complaint.id), // Placeholder
                              ),
                            );
                          },
                          splashColor: colors.primary.withOpacity(0.1),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        complaint.subject,
                                        style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: colors.primary),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    _buildStatusBadge(complaint.status, colors),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  complaint.descriptionSnippet,
                                  style: GoogleFonts.inter(fontSize: 14, color: colors.onSurface.withOpacity(0.8), fontWeight: FontWeight.normal),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Icon(Icons.calendar_today_outlined, size: 14, color: colors.onSurface.withOpacity(0.6)),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${complaint.createdAt.day}/${complaint.createdAt.month}/${complaint.createdAt.year}',
                                      style: GoogleFonts.inter(fontSize: 12, color: colors.onSurface.withOpacity(0.6)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ).animate().fadeIn(delay: (100 * index).ms, duration: 400.ms).slideY(begin: 0.2, curve: Curves.easeOutCubic);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Navigate to Submit Complaint Screen
          print('Submit new complaint tapped');
        },
        backgroundColor: colors.primary,
        icon: Icon(Icons.add_comment_outlined, color: colors.onPrimary),
        label: Text('Nouvelle Réclamation', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: colors.onPrimary)),
      ).animate().scale(delay: 500.ms, duration: 500.ms, curve: Curves.elasticOut),
    );
  }
}

// Placeholder for ComplaintDetailScreen
class ComplaintDetailScreen extends StatelessWidget {
  final String complaintId;
  const ComplaintDetailScreen({super.key, required this.complaintId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Détail Réclamation $complaintId (Placeholder)')),
      body: Center(child: Text('Détail de la réclamation $complaintId - À implémenter')),
    );
  }
}

