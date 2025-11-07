// ignore_for_file: public_member_api_docs

/// Utility class for formatting and rounding quantities based on units
class QuantityFormatter {
  QuantityFormatter._();

  /// Rounds quantity based on unit type to prevent floating-point precision
  /// issues
  static double roundQuantity(double quantity, String unit) {
    final String unitLower = unit.toLowerCase().trim();
    
    if (unitLower == 'kg' || unitLower == 'kilogram' || 
        unitLower == 'lt' || unitLower == 'l' || 
        unitLower == 'litre' || unitLower == 'liter') {
      // 0.1 precision (e.g., 1.1, 1.2, 1.3)
      return (quantity * 10).round() / 10;
    } else if (unitLower == 'g' || unitLower == 'gr' || 
               unitLower == 'gram' || unitLower == 'ml' || 
               unitLower == 'mililitre') {
      // Round to whole number (e.g., 25, 50, 75)
      return quantity.roundToDouble();
    } else if (unitLower == 'adet' || unitLower == 'tane' || 
               unitLower == 'paket' || unitLower == 'kutu' || 
               unitLower == 'demet') {
      // Round to whole number
      return quantity.roundToDouble();
    } else {
      // Default: 0.1 precision
      return (quantity * 10).round() / 10;
    }
  }

  /// Formats quantity to remove unnecessary decimal places for display
  static String formatQuantity(double quantity, String unit) {
    final String unitLower = unit.toLowerCase().trim();
    
    // Adet bazlı birimler için tam sayı göster
    if (unitLower == 'adet' || unitLower == 'tane' || unitLower == 'paket' || 
        unitLower == 'kutu' || unitLower == 'demet') {
      return '${quantity.toInt()}';
    }
    
    // Gram ve ML için tam sayı göster
    if (unitLower == 'g' || unitLower == 'gr' || unitLower == 'gram' || 
        unitLower == 'ml' || unitLower == 'mililitre') {
      return '${quantity.toInt()}';
    }
    
    // Kg ve Litre için maksimum 1 ondalık basamak göster
    if (unitLower == 'kg' || unitLower == 'kilogram' || 
        unitLower == 'lt' || unitLower == 'l' || 
        unitLower == 'litre' || unitLower == 'liter') {
      // Gereksiz sıfırları kaldır (örn: 1.0 -> 1, 1.2 -> 1.2)
      final String formatted = quantity.toStringAsFixed(1);
      if (formatted.endsWith('.0')) {
        return formatted.substring(0, formatted.length - 2);
      }
      return formatted;
    }
    
    // Varsayılan: maksimum 1 ondalık basamak
    final String formatted = quantity.toStringAsFixed(1);
    if (formatted.endsWith('.0')) {
      return formatted.substring(0, formatted.length - 2);
    }
    return formatted;
  }
}

