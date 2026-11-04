enum ShiftType {
  dayShift,   // نهار
  nightShift, // ليل
  rest,       // راحة
}

class ShiftCalculator {
  /// دورة الـ 30 يوماً:
  /// 0 إلى 9: نهار (10 أيام)
  /// 10 إلى 14: راحة (5 أيام)
  /// 15 إلى 24: ليل (10 أيام)
  /// 25 إلى 29: راحة (5 أيام)
  static ShiftType getShiftTypeForDay(int dayInCycle) {
    int normalizedDay = dayInCycle % 30;
    if (normalizedDay >= 0 && normalizedDay < 10) {
      return ShiftType.dayShift;
    } else if (normalizedDay >= 10 && normalizedDay < 15) {
      return ShiftType.rest;
    } else if (normalizedDay >= 15 && normalizedDay < 25) {
      return ShiftType.nightShift;
    } else {
      return ShiftType.rest;
    }
  }

  /// حساب رقم اليوم في الدورة بناءً على تاريخ البداية وتاريخ اليوم المستهدف
  static int getDayInCycle(DateTime startDate, DateTime targetDate) {
    final difference = targetDate.difference(startDate).inDays;
    if (difference < 0) {
      int mod = difference % 30;
      return mod == 0 ? 0 : 30 + mod;
    }
    return difference % 30;
  }

  /// حساب ساعات السهرة، أيام الراحة، والتكليف المالي للفترة
  /// - كل يوم عمل يمنح 4 ساعات سهرة أساسية.
  /// - المعيار: 40 ساعة سهرة في الفترة = 5 أيام راحة ثابتة.
  /// - إذا كانت أقل من 40: أيام الراحة = floor(ساعات السهرة ÷ 8) بدون كسور.
  /// - إذا كانت 40 أو أكثر: الراحة 5 أيام ثابتة، والزيادة تُحسب تكليفاً مالياً.
  /// - العمل في عطلة رسمية = تكليف بقيمة 12 ساعة سهرة.
  /// - إذا وقعت عطلة رسمية في فترة راحة وكان هناك نقص سهرات، تُحسب يوم راحة لتعويض النقص ويُلغى التكليف.
  static Map<String, dynamic> calculatePeriodStats({
    required int actualWorkedDays,          // عدد أيام العمل الفعلية
    required int officialHolidaysWorked,   // عدد العطل الرسمية التي تم العمل فيها
    required int officialHolidaysInRest,   // عدد العطل الرسمية التي وقعت في فترة الراحة وتسببت في نقص سهرات
  }) {
    // حساب ساعات السهرة الأساسية (كل يوم عمل = 4 ساعات سهرة)
    int baseSaharaHours = actualWorkedDays * 4;

    // العطل الرسمية المكتسبة (كل عطلة عمل = 12 ساعة سهرة)
    int holidaySaharaHours = officialHolidaysWorked * 12;

    int totalSaharaHours = baseSaharaHours + holidaySaharaHours;

    int calculatedRestDays = 5;
    int financialBonusHours = 0;

    if (totalSaharaHours < 40) {
      // إذا كانت السهرات أقل من 40
      calculatedRestDays = totalSaharaHours ~/ 8;
    } else {
      // إذا كانت 40 أو أكثر
      calculatedRestDays = 5;
      financialBonusHours = totalSaharaHours - 40;
    }

    // معالجة العطل الرسمية الواقعة في فترة الراحة في حال وجود نقص سهرات
    if (officialHolidaysInRest > 0 && totalSaharaHours < 40) {
      calculatedRestDays += officialHolidaysInRest;
    }

    return {
      'totalSaharaHours': totalSaharaHours,
      'restDays': calculatedRestDays,
      'financialBonusHours': financialBonusHours,
    };
  }
}

