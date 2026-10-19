import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('سياسة الخصوصية والشروط')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.palePurple,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Column(
                  children: [
                    Text('🛡️', style: TextStyle(fontSize: 36)),
                    SizedBox(height: 8),
                    Text(
                      'خصوصيتكم وأمان بياناتكم أولويتنا',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.deepPurple,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildSection(
                title: '1. البيانات التي نجمعها',
                body:
                    '• لا نطلب أي بيانات شخصية حساسة للعب الأساسي.\n• يتم حفظ البطاقات المفضلة والأسئلة الخاصة محليًا على جهازكم عبر التخزين الآمن.\n• عند إنشاء حساب عبر Supabase، نحفظ فقط البريد الإلكتروني المعتمد لتمكين مزامنة الغرف بين الشريكين.',
              ),
              const SizedBox(height: 18),
              _buildSection(
                title: '2. سرية اللعب وتسليم الجهاز',
                body:
                    '• صممت اللعبة مع شاشة أمان وتسليم واضحة (Pass Device) لحماية إجاباتكم واختياراتكم السرية من الكشف العرضي أثناء اللعب على جهاز واحد.\n• في اللعب عن بعد، تُنقل الأحداث عبر قنوات مشفرة مؤمنة بسياسات أمان Row Level Security (RLS).',
              ),
              const SizedBox(height: 18),
              _buildSection(
                title: '3. التخزين المحلي والنسخ الاحتياطي',
                body:
                    '• جميع الأسئلة والملاحظات الخاصة التي تكتبونها تبقى على هاتفكم ولا تُرفع إلى أي خادم خارجي إلا عند تفعيل المزامنة باختياركم.',
              ),
              const SizedBox(height: 18),
              _buildSection(
                title: '4. شروط الاستخدام',
                body:
                    '• هذا التطبيق مخصص للتقارب وبناء الحوار الإيجابي الممتع بين الأزواج.\n• جميع المحتويات والبطاقات خضعت لمراجعة لغوية وثقافية تناسب القيم والتقاليد العربية.',
              ),
              const SizedBox(height: 28),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('فهمت وموافق'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String body}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: AppDecorations.outlinedCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 13,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
