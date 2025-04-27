
class SelectionPopupModel {
  final String title;
  final String? value;
  final bool isSelected;
  SelectionPopupModel({
    required this.title,
    this.value,
    this.isSelected = false,
  });
  // Phương thức so sánh dựa trên title
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SelectionPopupModel && other.title == title;
  }
  @override
  int get hashCode => title.hashCode;
}