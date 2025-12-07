import 'package:dose_certa/_Core/theme/app_colors.dart';
import 'package:dose_certa/_Core/theme/app_text_style.dart';
import 'package:flutter/material.dart';

class TarefaCardCuidador extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool checked;
  final ValueChanged<bool>? onChanged;
  final VoidCallback? onTap;

  const TarefaCardCuidador({
    super.key,
    required this.title,
    required this.subtitle,
    this.checked = false,
    this.onChanged,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 400,
        height: 70,
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Checkbox(
              value: checked,
              onChanged: (value) {
                if (onChanged != null && value != null) onChanged!(value);
              },
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.medium16.copyWith(
                      fontWeight: FontWeight.bold,
                      decoration: (checked == true)
                          ? TextDecoration.lineThrough
                          : null,
                      decorationThickness: 3.0,
                    ),
                  ),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      style: AppTextStyles.medium16.copyWith(
                        color: AppColors.gray800,
                      ),
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
