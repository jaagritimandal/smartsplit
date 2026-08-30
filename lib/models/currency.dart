class Currency {
  final String code;
  final String name;
  final String symbol;
  final double conversionRate; // relative to INR

  Currency({
    required this.code,
    required this.name,
    required this.symbol,
    required this.conversionRate,
  });
}

class CurrencyManager {
  static final currencies = <String, Currency>{
    'INR': Currency(code: 'INR', name: 'Indian Rupee', symbol: '₹', conversionRate: 1.0),
    'USD': Currency(code: 'USD', name: 'US Dollar', symbol: '\$', conversionRate: 0.012),
    'EUR': Currency(code: 'EUR', name: 'Euro', symbol: '€', conversionRate: 0.011),
    'GBP': Currency(code: 'GBP', name: 'British Pound', symbol: '£', conversionRate: 0.0095),
    'AUD': Currency(code: 'AUD', name: 'Australian Dollar', symbol: 'A\$', conversionRate: 0.018),
    'CAD': Currency(code: 'CAD', name: 'Canadian Dollar', symbol: 'C\$', conversionRate: 0.016),
    'SGD': Currency(code: 'SGD', name: 'Singapore Dollar', symbol: 'S\$', conversionRate: 0.016),
    'HKD': Currency(code: 'HKD', name: 'Hong Kong Dollar', symbol: 'HK\$', conversionRate: 0.094),
    'JPY': Currency(code: 'JPY', name: 'Japanese Yen', symbol: '¥', conversionRate: 1.8),
    'CNY': Currency(code: 'CNY', name: 'Chinese Yuan', symbol: '¥', conversionRate: 0.086),
    'MYR': Currency(code: 'MYR', name: 'Malaysian Ringgit', symbol: 'RM', conversionRate: 0.054),
    'THB': Currency(code: 'THB', name: 'Thai Baht', symbol: '฿', conversionRate: 0.42),
    'PHP': Currency(code: 'PHP', name: 'Philippine Peso', symbol: '₱', conversionRate: 0.67),
    'IDR': Currency(code: 'IDR', name: 'Indonesian Rupiah', symbol: 'Rp', conversionRate: 190),
    'VND': Currency(code: 'VND', name: 'Vietnamese Dong', symbol: '₫', conversionRate: 300),
    'KRW': Currency(code: 'KRW', name: 'South Korean Won', symbol: '₩', conversionRate: 15.5),
    'PKR': Currency(code: 'PKR', name: 'Pakistani Rupee', symbol: 'Rs', conversionRate: 3.3),
    'BDT': Currency(code: 'BDT', name: 'Bangladeshi Taka', symbol: '৳', conversionRate: 1.25),
    'LKR': Currency(code: 'LKR', name: 'Sri Lankan Rupee', symbol: 'Rs', conversionRate: 3.9),
    'NPR': Currency(code: 'NPR', name: 'Nepalese Rupee', symbol: 'Rs', conversionRate: 1.6),
    'AED': Currency(code: 'AED', name: 'UAE Dirham', symbol: 'د.إ', conversionRate: 0.044),
    'SAR': Currency(code: 'SAR', name: 'Saudi Riyal', symbol: 'ر.س', conversionRate: 0.045),
    'QAR': Currency(code: 'QAR', name: 'Qatari Riyal', symbol: 'ر.ق', conversionRate: 0.044),
    'KWD': Currency(code: 'KWD', name: 'Kuwaiti Dinar', symbol: 'د.ك', conversionRate: 0.0037),
    'BHD': Currency(code: 'BHD', name: 'Bahraini Dinar', symbol: '.د.ب', conversionRate: 0.0045),
    'OMR': Currency(code: 'OMR', name: 'Omani Rial', symbol: 'ر.ع.', conversionRate: 0.0046),
    'ZAR': Currency(code: 'ZAR', name: 'South African Rand', symbol: 'R', conversionRate: 0.22),
    'EGP': Currency(code: 'EGP', name: 'Egyptian Pound', symbol: 'E£', conversionRate: 0.37),
    'NGN': Currency(code: 'NGN', name: 'Nigerian Naira', symbol: '₦', conversionRate: 19.5),
    'GHS': Currency(code: 'GHS', name: 'Ghanaian Cedi', symbol: 'GH₵', conversionRate: 0.15),
    'KES': Currency(code: 'KES', name: 'Kenyan Shilling', symbol: 'KSh', conversionRate: 1.55),
    'CHF': Currency(code: 'CHF', name: 'Swiss Franc', symbol: 'CHF', conversionRate: 0.01),
    'SEK': Currency(code: 'SEK', name: 'Swedish Krona', symbol: 'kr', conversionRate: 0.13),
    'NOK': Currency(code: 'NOK', name: 'Norwegian Krone', symbol: 'kr', conversionRate: 0.13),
    'DKK': Currency(code: 'DKK', name: 'Danish Krone', symbol: 'kr', conversionRate: 0.082),
    'NZD': Currency(code: 'NZD', name: 'New Zealand Dollar', symbol: 'NZ\$', conversionRate: 0.02),
    'BRL': Currency(code: 'BRL', name: 'Brazilian Real', symbol: 'R\$', conversionRate: 0.062),
    'MXN': Currency(code: 'MXN', name: 'Mexican Peso', symbol: '\$', conversionRate: 0.21),
    'ARS': Currency(code: 'ARS', name: 'Argentine Peso', symbol: '\$', conversionRate: 10.5),
    'CLP': Currency(code: 'CLP', name: 'Chilean Peso', symbol: '\$', conversionRate: 10.2),
    'COP': Currency(code: 'COP', name: 'Colombian Peso', symbol: '\$', conversionRate: 50),
    'PEN': Currency(code: 'PEN', name: 'Peruvian Sol', symbol: 'S/', conversionRate: 0.045),
    'VEF': Currency(code: 'VEF', name: 'Venezuelan Bolívar', symbol: 'Bs', conversionRate: 3700000),
    'TRY': Currency(code: 'TRY', name: 'Turkish Lira', symbol: '₺', conversionRate: 0.39),
    'RUB': Currency(code: 'RUB', name: 'Russian Ruble', symbol: '₽', conversionRate: 1.1),
    'PLN': Currency(code: 'PLN', name: 'Polish Zloty', symbol: 'zł', conversionRate: 0.048),
    'CZK': Currency(code: 'CZK', name: 'Czech Koruna', symbol: 'Kč', conversionRate: 0.28),
    'HUF': Currency(code: 'HUF', name: 'Hungarian Forint', symbol: 'Ft', conversionRate: 4.5),
    'RON': Currency(code: 'RON', name: 'Romanian Leu', symbol: 'lei', conversionRate: 0.054),
    'BGN': Currency(code: 'BGN', name: 'Bulgarian Lev', symbol: 'лв', conversionRate: 0.021),
    'HRK': Currency(code: 'HRK', name: 'Croatian Kuna', symbol: 'kn', conversionRate: 0.082),
    'ISK': Currency(code: 'ISK', name: 'Icelandic Króna', symbol: 'kr', conversionRate: 1.6),
  };

  static Currency getByCode(String code) {
    return currencies[code] ?? currencies['INR']!;
  }

  static List<Currency> getAllSorted() {
    return currencies.values.toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }
}