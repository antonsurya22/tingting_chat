import 'package:intl/intl.dart';

class TimeAgo{
  static String timeAgoSinceDate(int time)
  {
    DateTime notificationDate = DateTime.fromMillisecondsSinceEpoch(time);
    final date2 = DateTime.now();
    final diff = date2.difference(notificationDate);

    if(diff.inDays > 8)
      return DateFormat("dd-MM-yyyy HH:mm:ss").format(notificationDate);
    else if((diff.inDays / 7).floor() >=1)
      return 'Minggu lalu';
    else if(diff.inDays >= 2)
      return '${diff.inDays} hari yang lalu';
    else if(diff.inDays >= 1)
      return 'Kemarin';
    else if(diff.inHours >= 2)
      return '${diff.inHours} jam yang lalu';
    else if(diff.inHours >=1)
      return '1 jam yang lalu';
    else if(diff.inMinutes >= 2)
      return '${diff.inMinutes} menit yang lalu';
    else if(diff.inMinutes >= 1)
      return '1 menit yang lalu';
    else if(diff.inSeconds >= 3)
      return '${diff.inSeconds} detik yang lalu';
    else
      return 'Sekarang';
  }

  static bool isSameDay(int time)
  {
    DateTime notificationDate = DateTime.fromMicrosecondsSinceEpoch(time);
    final date2 = DateTime.now();
    final diff = date2.difference(notificationDate);

    if(diff.inDays > 0)
      return false;
    else return true;
  }
}