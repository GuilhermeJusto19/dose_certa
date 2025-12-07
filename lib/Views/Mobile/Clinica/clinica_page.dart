import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dose_certa/viewmodels/mobile/user_viewmodel.dart';
import 'package:dose_certa/Models/Models/clinica.dart';
import 'package:dose_certa/Views/_shared/custom_back_button.dart';
import 'package:dose_certa/_Core/theme/app_colors.dart';
import 'package:dose_certa/_Core/theme/app_text_style.dart';
import 'package:dose_certa/_Core/utils/utils.dart';
import 'package:flutter/material.dart';

class ClinicaPage extends StatefulWidget {
  const ClinicaPage({super.key});

  @override
  State<ClinicaPage> createState() => _ClinicaPageState();
}

class _ClinicaPageState extends State<ClinicaPage> {
  final _userController = UserViewModel();
  Clinica? _clinica;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadClinica();
  }

  Future<void> _loadClinica() async {
    final user = _userController.currentUser;
    if (user?.associetedClinica != null &&
        user!.associetedClinica!.isNotEmpty) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('clinicas')
            .doc(user.associetedClinica!)
            .get();

        if (doc.exists && doc.data() != null && mounted) {
          setState(() {
            _clinica = Clinica.fromMap(doc.data()!);
            _isLoading = false;
          });
        } else if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Erro ao carregar clínica: $e",
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      appBar: AppBar(
        leading: const CustomBackButton(),
        backgroundColor: AppColors.mainBackground,
        title: Text('Minha Clínica', style: AppTextStyles.semibold20),
      ),
      body: RefreshIndicator(
        onRefresh: _loadClinica,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverFillRemaining(
              hasScrollBody: true,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _clinica == null
                  ? _buildNoClinica()
                  : _buildClinicaInfo(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoClinica() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.local_hospital_outlined,
              size: 80,
              color: AppColors.gray700,
            ),
            const SizedBox(height: 24),
            Text(
              'Você não está vinculado a nenhuma clínica',
              textAlign: TextAlign.center,
              style: AppTextStyles.semibold16.copyWith(
                color: AppColors.gray700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClinicaInfo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Text('Sua clínica', style: AppTextStyles.bold20),
          const SizedBox(height: 30),
          Image.asset('assets/images/cuidador.png', height: 150),
          const SizedBox(height: 40),
          _buildInfoCard(),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              Utils.capitalize(_clinica!.name),
              style: AppTextStyles.semibold24,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          _buildInfoRow(
            icon: Icons.phone,
            label: 'Telefone',
            value: _formatPhone(_clinica!.phone),
          ),
          const Divider(height: 32),
          _buildInfoRow(
            icon: Icons.location_on,
            label: 'Endereço',
            value: _clinica!.address,
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    int maxLines = 1,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.blueAccent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.blueAccent, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.medium14.copyWith(
                  color: AppColors.gray700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: AppTextStyles.semibold16,
                maxLines: maxLines,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatPhone(String phone) {
    // Remove todos os caracteres não numéricos
    final numbers = phone.replaceAll(RegExp(r'[^\d]'), '');

    // Formata para (XX) XXXXX-XXXX ou (XX) XXXX-XXXX
    if (numbers.length == 11) {
      return '(${numbers.substring(0, 2)}) ${numbers.substring(2, 7)}-${numbers.substring(7)}';
    } else if (numbers.length == 10) {
      return '(${numbers.substring(0, 2)}) ${numbers.substring(2, 6)}-${numbers.substring(6)}';
    }
    return phone;
  }
}
