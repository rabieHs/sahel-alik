import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ValidationUtils {
  // Email validation
  static String? validateEmail(String? value, BuildContext context) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context)!.emailRequired;
    }
    
    // Regular expression for email validation
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(value)) {
      return AppLocalizations.of(context)!.invalidEmail;
    }
    
    return null;
  }
  
  // Password validation
  static String? validatePassword(String? value, BuildContext context) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context)!.passwordRequired;
    }
    
    if (value.length < 6) {
      return AppLocalizations.of(context)!.passwordTooShort;
    }
    
    return null;
  }
  
  // Name validation
  static String? validateName(String? value, BuildContext context) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context)!.nameRequired;
    }
    
    if (value.length < 2) {
      return AppLocalizations.of(context)!.nameTooShort;
    }
    
    return null;
  }
  
  // Phone number validation
  static String? validatePhone(String? value, BuildContext context) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context)!.phoneRequired;
    }
    
    // Regular expression for phone validation (international format)
    final phoneRegExp = RegExp(r'^\+?[0-9]{8,15}$');
    if (!phoneRegExp.hasMatch(value)) {
      return AppLocalizations.of(context)!.invalidPhone;
    }
    
    return null;
  }
  
  // Service title validation
  static String? validateServiceTitle(String? value, BuildContext context) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context)!.serviceTitleRequired;
    }
    
    if (value.length < 3) {
      return AppLocalizations.of(context)!.serviceTitleTooShort;
    }
    
    return null;
  }
  
  // Service description validation
  static String? validateServiceDescription(String? value, BuildContext context) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context)!.serviceDescriptionRequired;
    }
    
    if (value.length < 10) {
      return AppLocalizations.of(context)!.serviceDescriptionTooShort;
    }
    
    return null;
  }
  
  // Price validation
  static String? validatePrice(String? value, BuildContext context) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context)!.priceRequired;
    }
    
    final price = double.tryParse(value);
    if (price == null) {
      return AppLocalizations.of(context)!.invalidPrice;
    }
    
    if (price <= 0) {
      return AppLocalizations.of(context)!.priceMustBePositive;
    }
    
    return null;
  }
  
  // Location validation
  static String? validateLocation(dynamic value, BuildContext context) {
    if (value == null) {
      return AppLocalizations.of(context)!.locationRequired;
    }
    
    return null;
  }
  
  // Booking date validation
  static String? validateBookingDate(DateTime? value, BuildContext context) {
    if (value == null) {
      return AppLocalizations.of(context)!.dateTimeRequired;
    }
    
    if (value.isBefore(DateTime.now())) {
      return AppLocalizations.of(context)!.dateTimeMustBeFuture;
    }
    
    return null;
  }
  
  // Booking description validation
  static String? validateBookingDescription(String? value, BuildContext context) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context)!.descriptionRequired;
    }
    
    if (value.length < 10) {
      return AppLocalizations.of(context)!.descriptionTooShort;
    }
    
    return null;
  }
}
