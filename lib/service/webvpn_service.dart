import 'package:custed2/api/mysso.dart';
import 'package:custed2/api/sys8.dart';
import 'package:custed2/api/webvpn.dart';
import 'package:custed2/core/service/cat_service.dart';
import 'package:custed2/locator.dart';
import 'package:custed2/service/mysso_service.dart';
import 'package:custed2/store/user_store.dart';
import 'package:html/parser.dart' show parse;

class WebvpnService extends CatService {
  static const baseUrl = 'https://webvpn.cust.edu.cn';

  final Pattern sessionExpirationTest = RegExp(r'g_lines|Sangine');

  final MyssoService _mysso = locator<MyssoService>();

  Future<bool> login() async {
    final ticket = await _mysso.getTicketForWebvpn();

    final resp = await get(
      '$baseUrl/auth/cas_validate?entry_id=1&ticket=$ticket',
      maxRedirects: 0,
    );

    if (resp.body.contains('success')) {
      return true;
    }
    
    return false;
  }
}