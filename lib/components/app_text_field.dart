import 'package:foap/helper/imports/common_import.dart';
import '../universal_components/rounded_input_field.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? hintText;
  final ThemeIcon? icon;
  final String? label;
  final int? maxLines;
  final ValueChanged<String>? onChanged;

  const AppTextField(
      {Key? key,
      required this.controller,
      this.hintText,
      this.label,
      this.maxLines,
      this.onChanged,
      this.icon})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InputField(
      controller: controller,
      hintText: hintText,
      icon: icon,
      label: label,
      maxLines: maxLines,
      onChanged: onChanged,
      backgroundColor: AppColorConstants.inputFieldBackgroundColor,
      cornerRadius: 10,
      iconColor: AppColorConstants.iconColor,
    );
  }
}

class AppPasswordTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? hintText;
  final ThemeIcon? icon;

  const AppPasswordTextField(
      {Key? key, required this.controller, this.hintText, this.icon})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PasswordField(
      controller: controller,
      hintText: hintText,
      icon: icon,
      backgroundColor: AppColorConstants.inputFieldBackgroundColor,
      cornerRadius: 10,
      iconColor: AppColorConstants.iconColor,
      onChanged: (text) {},
    );
  }
}

class AppMobileTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? hintText;
  final ThemeIcon? icon;
  final String? label;
  final String? countryCodeText;

  final ValueChanged<String>? countryCodeValueChanged;
  final ValueChanged<String>? onChanged;

  const AppMobileTextField({
    Key? key,
    required this.controller,
    this.hintText,
    this.label,
    this.icon,
    this.countryCodeText,
    this.countryCodeValueChanged,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RoundedInputMobileNumberField(
      controller: controller,
      hintText: hintText,
      countryCodeText: countryCodeText,
      countrycodeValueChanged: countryCodeValueChanged,
      label: label,
      backgroundColor: AppColorConstants.inputFieldBackgroundColor,
      textStyle: TextStyle(fontSize: FontSizes.h6),
      cornerRadius: 10,
      onChanged: onChanged,
      iconColor: AppColorConstants.iconColor,
    );
  }
}

class AppDateTextField extends StatelessWidget {
  final String? hintText;
  final String? defaultText;

  final ThemeIcon? icon;
  final String? label;
  final String? countryCodeText;

  final ValueChanged<TimeOfDay>? onChanged;

  const AppDateTextField({
    Key? key,
    this.defaultText,
    this.hintText,
    this.label,
    this.icon,
    this.countryCodeText,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RoundedInputDateField(
      defaultText: defaultText,
      hintText: hintText,
      label: label,
      backgroundColor: AppColorConstants.inputFieldBackgroundColor,
      textStyle: TextStyle(fontSize: FontSizes.h6),
      cornerRadius: 5,
      onChanged: onChanged,
      iconColor: AppColorConstants.iconColor,
    );
  }
}

class AppDateTimeTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? hintText;
  final ThemeIcon? icon;
  final String? label;
  final String? countryCodeText;

  final ValueChanged<DateTime>? onChanged;
  final DateTime? minDate;
  final DateTime? maxDate;

  const AppDateTimeTextField({
    Key? key,
    required this.controller,
    this.hintText,
    this.label,
    this.icon,
    this.countryCodeText,
    this.onChanged,
    this.minDate,
    this.maxDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RoundedInputDateTimeField(
      controller: controller,
      minDate: minDate,
      maxDate: maxDate,
      hintText: hintText,
      label: label,
      backgroundColor: AppColorConstants.inputFieldBackgroundColor,
      textStyle: TextStyle(fontSize: FontSizes.h6),
      cornerRadius: 10,
      onChanged: onChanged,
      iconColor: AppColorConstants.iconColor,
    );
  }
}

class AppPriceTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? hintText;
  final ThemeIcon? icon;
  final String? label;
  final String? currency;

  final ValueChanged<String>? currencyValueChanged;
  final ValueChanged<String>? onChanged;

  const AppPriceTextField({
    Key? key,
    required this.controller,
    this.hintText,
    this.label,
    this.icon,
    this.currency,
    this.currencyValueChanged,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RoundedInputPriceField(
      controller: controller,
      hintText: hintText,
      currency: currency,
      disable: true,
      label: label,
      backgroundColor: AppColorConstants.inputFieldBackgroundColor,
      textStyle: TextStyle(fontSize: FontSizes.h6),
      cornerRadius: 10,
      onChanged: onChanged,
      currencyValueChanged: currencyValueChanged,
      iconColor: AppColorConstants.iconColor,
    );
  }
}

class AppDropdownField extends StatelessWidget {
  final String? hintText;
  final ThemeIcon? icon;
  final String? label;
  final String? value;

  final ValueChanged<String> onChanged;
  final List<String> options;

  const AppDropdownField(
      {Key? key,
      this.hintText,
      this.label,
      this.icon,
      this.value,
      required this.onChanged,
      required this.options})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RoundedDropdownField(
      options: options,
      hintText: hintText,
      label: label,
      value: value,
      backgroundColor: AppColorConstants.inputFieldBackgroundColor,
      textStyle: TextStyle(fontSize: FontSizes.h6),
      cornerRadius: 10,
      onChanged: onChanged,
      iconColor: AppColorConstants.iconColor,
    );
  }
}
