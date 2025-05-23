import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

// Placeholder Model for a Complaint (can be moved to a models folder)
class ComplaintDetail {
  final String id;
  final String subject;
  final String description;
  final String status;
  final DateTime createdAt;
  final String submittedBy;
  final List<ComplaintStatusHistoryItem> statusHistory;
  // Add other relevant fields like attachments if any

  ComplaintDetail({
    required this.id,
    required this.subject,
    required this.description,
    required this.status,
    required this.createdAt,
    required this.submittedBy,
    required this.statusHistory,
  });
}

class ComplaintStatusHistoryItem {
  final String status;
  final DateTime date;
  final String? notes;
  final String? updatedBy; // e.g., 'Admin Municipality'

  ComplaintStatusHistoryItem({
    required this.status,
    required this.date,
    this.notes,
    this.updatedBy,
  });
}

class ComplaintDetailScreen extends StatefulWidget {
  final String complaintId;
  const ComplaintDetailScreen({super.key, required this.complaintId});

  @override
  State<ComplaintDetailScreen> createState() => _ComplaintDetailScreenState();
}

class _ComplaintDetailScreenState extends State<ComplaintDetailScreen> {
  late ComplaintDetail _complaintDetail;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchComplaintDetails();
  }

  Future<void> _fetchComplaintDetails() async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 700));
    setState(() {
      _complaintDetail = ComplaintDetail(
        id: widget.complaintId,
        subject: 'Problème de facturation eau - Facture N°INV00123',
        description: 'J\'ai reçu une facture d\'eau anormalement élevée pour le mois d\'avril. Ma consommation habituelle est bien inférieure. J\'aimerais une vérification de mon compteur et une explication pour cette augmentation soudaine. J\'ai joint une copie de la facture et de mes relevés précédents pour comparaison.',
        status: "En cours d'analyse",
        createdAt: DateTime.now().subtract(const Duration(days: 10, hours: 2)),
        submittedBy: 'Amina KHALIL',
        statusHistory: [
          ComplaintStatusHistoryItem(status: 'Soumise', date: DateTime.now().subtract(const Duration(days: 10, hours: 2)), notes: 'Réclamation soumise par le citoyen via l\'application mobile.'),
          ComplaintStatusHistoryItem(status: 'Prise en charge', date: DateTime.now().subtract(const Duration(days: 9)), updatedBy: 'Service Clientèle', notes: 'Réclamation assignée à un agent pour investigation.'),
          ComplaintStatusHistoryItem(status: 'En cours danalyse', date: DateTime.now().subtract(const Duration(days: 5)), updatedBy: 'Agent Traitement', notes: 'Analyse des données de consommation et vérification du compteur en cours.'),
        ],
      );
      _isLoading = false;
    });
  }

  Widget _buildStatusBadge(String status, ColorScheme colors) {
    Color backgroundColor;
    Color textColor;
    IconData iconData;
    switch (status) {
      case 'Soumise':
        backgroundColor = colors.errorContainer.withOpacity(0.8);
        textColor = colors.onErrorContainer;
        iconData = Icons.forward_to_inbox_rounded;
        break;
      case 'Prise en charge':
      case 'En cours danalyse':
        backgroundColor = colors.secondaryContainer.withOpacity(0.8);
        textColor = colors.onSecondaryContainer;
        iconData = Icons.hourglass_top_rounded;
        break;
      case 'Résolue':
      case 'Clôturée':
        backgroundColor = colors.tertiaryContainer.withOpacity(0.8);
        textColor = colors.onTertiaryContainer;
        iconData = Icons.check_circle_rounded;
        break;
      default:
        backgroundColor = Colors.grey.shade400;
        textColor = Colors.white;
        iconData = Icons.help_rounded;
    }
    return Chip(
      avatar: Icon(iconData, size: 18, color: textColor),
      label: Text(status, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: textColor)),
      backgroundColor: backgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    ).animate().fadeIn(duration: 300.ms).scale(delay: 100.ms, curve: Curves.easeOut);
  }

  Widget _buildInfoCard(IconData icon, String label, String value, ColorScheme colors) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: colors.surfaceVariant.withOpacity(0.3),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 22, color: colors.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: colors.onSurface.withOpacity(0.7))),
                  const SizedBox(height: 3),
                  Text(value, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500, color: colors.onSurface)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text('Détail Réclamation', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        backgroundColor: colors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: colors.primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: colors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          _complaintDetail.subject,
                          style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold, color: colors.primary),
                        ),
                      ),
                      const SizedBox(width: 12),
                      _buildStatusBadge(_complaintDetail.status, colors),
                    ],
                  ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, curve: Curves.easeOutCubic),
                  const SizedBox(height: 20),
                  _buildInfoCard(Icons.person_pin_circle_outlined, 'Soumise par', _complaintDetail.submittedBy, colors)
                      .animate().fadeIn(delay: 100.ms, duration: 500.ms).slideX(begin: -0.1, curve: Curves.easeOutCubic),
                  _buildInfoCard(Icons.calendar_month_outlined, 'Date de soumission', '${_complaintDetail.createdAt.day}/${_complaintDetail.createdAt.month}/${_complaintDetail.createdAt.year}', colors)
                      .animate().fadeIn(delay: 200.ms, duration: 500.ms).slideX(begin: -0.1, curve: Curves.easeOutCubic),
                  const SizedBox(height: 12),
                  Text(
                    'Description détaillée:',
                    style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: colors.onBackground),
                  ).animate().fadeIn(delay: 300.ms, duration: 500.ms),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors.surfaceVariant.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: colors.onSurface.withOpacity(0.1)),
                    ),
                    child: Text(
                      _complaintDetail.description,
                      style: GoogleFonts.inter(fontSize: 15, color: colors.onSurface.withOpacity(0.85), height: 1.55),
                    ),
                  ).animate().fadeIn(delay: 400.ms, duration: 600.ms).scale(begin: const Offset(0.98, 0.98), curve: Curves.easeOut),
                  const SizedBox(height: 24),
                  Text(
                    'Historique de la Réclamation:',
                    style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: colors.onBackground),
                  ).animate().fadeIn(delay: 500.ms, duration: 500.ms),
                  const SizedBox(height: 12),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _complaintDetail.statusHistory.length,
                    itemBuilder: (context, index) {
                      final item = _complaintDetail.statusHistory[index];
                      bool isFirst = index == 0;
                      bool isLast = index == _complaintDetail.statusHistory.length - 1;
                      return IntrinsicHeight(
                        child: Row(
                          children: [
                            Column(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  margin: EdgeInsets.only(top: isFirst ? 4 : 0, bottom: isLast ? 0 : 0),
                                  decoration: BoxDecoration(
                                    color: isFirst ? colors.primary : colors.onSurface.withOpacity(0.4),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                if (!isLast)
                                  Expanded(
                                    child: Container(
                                      width: 2,
                                      color: colors.onSurface.withOpacity(0.25),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(bottom: isLast ? 0 : 20.0, top: 0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.status, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: colors.onSurface)),
                                    Text('${item.date.day}/${item.date.month}/${item.date.year}', style: GoogleFonts.inter(fontSize: 12, color: colors.onSurface.withOpacity(0.6))),
                                    if (item.updatedBy != null && item.updatedBy!.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 2.0),
                                        child: Text('Par: ${item.updatedBy}', style: GoogleFonts.inter(fontSize: 11, color: colors.onSurface.withOpacity(0.5), fontStyle: FontStyle.italic)),
                                      ),
                                    if (item.notes != null && item.notes!.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 6.0),
                                        child: Text(item.notes!, style: GoogleFonts.inter(fontSize: 13, color: colors.onSurface.withOpacity(0.75), fontStyle: FontStyle.italic, height: 1.4)),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: (600 + index * 100).ms, duration: 400.ms).slideX(begin: -0.1, curve: Curves.easeOutCubic);
                    },
                  ),
                  // TODO: Add section for attachments if applicable
                  // TODO: Add section for user to add a follow-up message if allowed
                ],
              ),
            ),
    );
  }
}

