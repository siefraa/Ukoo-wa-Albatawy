import 'package:flutter/material.dart';
import '../models/mtu.dart';
import '../utils/app_colors.dart';

class MtuNode extends StatelessWidget {
  final Mtu mtu;
  final bool isSelected;
  final bool isRelated;
  final bool isDimmed;
  final double size;
  final VoidCallback? onTap;

  const MtuNode({
    super.key,
    required this.mtu,
    this.isSelected = false,
    this.isRelated = false,
    this.isDimmed = false,
    this.size = 80,
    this.onTap,
  });

  Color get _bg => mtu.jinsia == 'Kike'
      ? AppColors.female
      : AppColors.male;
  Color get _bgLight => mtu.jinsia == 'Kike'
      ? AppColors.femaleLight
      : AppColors.maleLight;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 250),
        opacity: isDimmed ? 0.08 : 1.0,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutBack,
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_bgLight, _bg],
            ),
            border: Border.all(
              color: isSelected
                  ? AppColors.goldGlow
                  : isRelated
                      ? AppColors.forestLight
                      : Colors.white.withOpacity(0.8),
              width: isSelected ? 3.5 : 2.5,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? AppColors.goldGlow.withOpacity(0.4)
                    : _bg.withOpacity(0.35),
                blurRadius: isSelected ? 18 : 10,
                spreadRadius: isSelected ? 2 : 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                mtu.jinsia == 'Kike' ? '👩' : '👨',
                style: TextStyle(fontSize: size * 0.34),
              ),
              const SizedBox(height: 1),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  mtu.jina.split(' ').first,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: size * 0.115,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    shadows: [Shadow(color: Colors.black.withOpacity(0.4), blurRadius: 4)],
                  ),
                ),
              ),
              if (mtu.amefariki)
                Text('✝', style: TextStyle(fontSize: size * 0.12, color: Colors.white70)),
            ],
          ),
        ),
      ),
    );
  }
}
