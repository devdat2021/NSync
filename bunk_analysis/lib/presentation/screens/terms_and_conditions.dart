import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class TermsAndConditionsPage extends StatelessWidget {
  const TermsAndConditionsPage({super.key});

  static const routeName = '/terms-and-conditions';

  static const String _content = '''
# NSync Terms & Conditions

**Last Updated:** 02-06-2026
#
## 1. Acceptance of Terms

By downloading, installing, accessing, or using NSync ("the App"), you agree to these Terms & Conditions. If you do not agree to these Terms, please discontinue use of the App.

#
## 2. Description of Service

NSync is an independent student-developed application designed to help students monitor attendance, analyze attendance trends, plan attendance requirements, and access academic resources.

The App may retrieve attendance and profile information from institutional systems using credentials provided by the user. NSync does not modify institutional records and is intended solely as a personal academic planning tool.

#
## 3. Independent Application

NSync is an independent project and is not affiliated with, endorsed by, sponsored by, or officially associated with NMAM Institute of Technology (NMAMIT), NITTE University, or any of their departments, services, or staff.

All trademarks, institutional names, and related intellectual property remain the property of their respective owners.

#
## 4. User Credentials and Security

Users are responsible for maintaining the confidentiality of their login credentials.

NSync stores authentication information locally on the user's device using secure storage mechanisms. The developer does not collect, store, transmit, sell, or have access to user passwords.

Users are responsible for ensuring that access to their device is adequately protected.

#
## 5. Data Accuracy and Availability

Attendance information, profile information, and other academic data displayed within NSync are obtained from external institutional systems and are presented for informational purposes only.

While reasonable efforts are made to provide accurate calculations and projections, NSync does not guarantee the accuracy, completeness, timeliness, or availability of any information displayed.

Users should verify important academic information through official institutional channels before making decisions based on the App's calculations or recommendations.

#
## 6. Acceptable Use

You agree to use NSync only for legitimate academic purposes.

You agree not to:

- Abuse, overload, interfere with, or disrupt institutional systems.
- Use the App in violation of applicable institutional policies.
- Reverse engineer, modify, distribute, or create unauthorized derivative versions of the App.

The developer reserves the right to restrict access to the App if misuse is detected.

#
## 7. Academic Resources

NSync may provide access to notes, previous-year question papers, reference materials, external links, or other academic resources.

Such resources may be contributed by students, obtained from publicly shared sources, or provided by third parties.

The developer does not guarantee the accuracy, completeness, legality, ownership, or suitability of any resource provided through the App.

Users remain responsible for ensuring compliance with copyright laws and institutional policies when using shared materials.

#
## 8. Third-Party Services

NSync may rely on third-party services, including but not limited to cloud storage providers, hosting platforms, external websites, and content delivery services.

The developer is not responsible for the availability, accuracy, security, or privacy practices of such third-party services.

#
## 9. Intellectual Property

The NSync application, including its source code, design, branding, user interface, and original content, remains the intellectual property of the developer unless otherwise stated.

Users retain ownership of their personal data. Institutional attendance and profile data remain the property of the respective institution.

#
## 10. Limitation of Liability

To the fullest extent permitted by law, the developer shall not be liable for any direct, indirect, incidental, consequential, special, or punitive damages arising from the use or inability to use NSync.

This includes, but is not limited to:

- Attendance shortages
- Academic penalties
- Detention or disciplinary action
- Incorrect calculations or projections
- Data loss
- Service interruptions
- Resource inaccuracies

Use of the App is entirely at the user's own risk.

#
## 11. Termination

The developer reserves the right to modify, suspend, restrict, or discontinue any part of NSync at any time without prior notice.

Users may stop using the App and remove it from their device at any time.

#
## 12. Changes to These Terms

These Terms & Conditions may be updated periodically as the app grows.

Continued use of NSync after updates become effective constitutes acceptance of the revised Terms.

Material changes may be communicated through the App or associated project pages.

#
## 13. Contact

For questions regarding these Terms or the App, please submit your queries through the **Help & Feedback** section within NSync.
''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Terms & Conditions')),
      body: Markdown(
        data: _content,
        selectable: true,
        padding: const EdgeInsets.all(16),
      ),
    );
  }
}
