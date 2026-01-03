import 'package:lumina_finance/data/models/models.dart';

class AIService {
  static int? suggestCategory(String merchant, List<Category> categories) {
    final merchantLower = merchant.toLowerCase();

    // Simple keyword mapping
    final Map<String, List<String>> keywordMap = {
      'Food': ['starbucks', 'mcdonalds', 'swiggy', 'zomato', 'grocery', 'restaurant', 'pizza', 'burger', 'kfc', 'blinkit', 'zepto'],
      'Transportation': ['uber', 'ola', 'fuel', 'petrol', 'diesel', 'parking', 'metro', 'train', 'bus', 'rapido'],
      'Utilities': ['electricity', 'water', 'gas', 'internet', 'verizon', 'att', 'recharge', 'jio', 'airtel', 'vi', 'bill'],
      'Shopping': ['amazon', 'flipkart', 'myntra', 'apple', 'walmart', 'target', 'clothes', 'nike', 'ajio'],
      'Entertainment': ['netflix', 'spotify', 'hulu', 'movies', 'gaming', 'steam', 'hotstar', 'prime video', 'vacation'],
      'Living': ['rent', 'furniture', 'maintenance', 'repairs', 'apartment'],
      'Finance': ['emi', 'loan', 'investment', 'stock', 'mutual fund', 'insurance', 'tax'],
      'Healthcare': ['hospital', 'pharmacy', 'medicine', 'doctor', 'lab', 'gym', 'fitness'],
      'Education': ['tuition', 'course', 'udemy', 'coursera', 'book', 'exam', 'school', 'college'],
    };

    for (var entry in keywordMap.entries) {
      if (entry.value.any((kw) => merchantLower.contains(kw))) {
        // Try to find the first child category of this parent
        final parent = categories.firstWhere(
          (c) => c.name == entry.key && c.parentId == null,
          orElse: () => categories.first,
        );
        final firstChild = categories.firstWhere(
          (c) => c.parentId == parent.id,
          orElse: () => parent,
        );
        return firstChild.id;
      }
    }

    return null;
  }
}
