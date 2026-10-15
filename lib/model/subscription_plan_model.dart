class SubscriptionPlan {
  int id;
  String name;
  int? value;

  SubscriptionPlan({
    required this.id,
    required this.name,
    this.value
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'],
      name: json['name'] ?? json['subscriptionPlanName'],
      value: json['value'],
    );
  }
}
