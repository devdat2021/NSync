import 'package:supabase_flutter/supabase_flutter.dart';

class AccessControlService {
  static final _supabase = Supabase.instance.client;

  static Future<bool> isBlocked(String mobileNumber) async {
    try {
      final response = await _supabase
          .from('blocked')
          .select('mobile_number')
          .eq('mobile_number', mobileNumber)
          .maybeSingle();

      return response != null;
    } catch (e) {
      // Fail open don't lock users out if the check itself fails

      return false;
    }
  }
}
