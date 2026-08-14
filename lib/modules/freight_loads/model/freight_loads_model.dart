import 'package:flutter/material.dart';

class FreightLoadSummaryStatModel {
  final String label;
  final String value;
  final Color themeColor;
  final IconData icon;

  FreightLoadSummaryStatModel({
    required this.label,
    required this.value,
    required this.themeColor,
    required this.icon,
  });
}

class FreightLoadItemModel {
  final String id;
  final String requestId;
  final String requestedDate;
  final String project;
  final String description;
  final String routeFrom;
  final String routeTo;
  final String pickupDate;
  final String deliveryDate;
  final String bids;
  final String status; // 'Awarded', 'Requested', 'Bids Received'
  bool isSelected;

  FreightLoadItemModel({
    this.id = '',
    required this.requestId,
    required this.requestedDate,
    required this.project,
    required this.description,
    required this.routeFrom,
    required this.routeTo,
    required this.pickupDate,
    required this.deliveryDate,
    required this.bids,
    required this.status,
    this.isSelected = false,
  });
}

class CarrierBidModel {
  final String id;
  final String carrierName;
  final double rating;
  final String bidAmount;
  final bool isBestRate;
  final String deliveryDays;

  CarrierBidModel({
    this.id = '',
    required this.carrierName,
    required this.rating,
    required this.bidAmount,
    this.isBestRate = false,
    this.deliveryDays = '2-3 Days',
  });
}
