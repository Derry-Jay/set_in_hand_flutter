import 'dart:convert';

GetCompletedDeliveriesModel getCompletedDeliveriesModelFromJson(String str) => GetCompletedDeliveriesModel.fromJson(json.decode(str));

String getCompletedDeliveriesModelToJson(GetCompletedDeliveriesModel data) => json.encode(data.toJson());

class GetCompletedDeliveriesModel {
    GetCompletedDeliveriesModel(
        this.success,
        this.deliveryData,
    );

    bool success;
    List<GetCompletedDeliveriesDeliveryDatum> deliveryData;

    factory GetCompletedDeliveriesModel.fromJson(Map<String, dynamic> json) => GetCompletedDeliveriesModel(
        json['success'],
        List<Map<String,dynamic>>.from(json['DeliveryData']).map((x) => GetCompletedDeliveriesDeliveryDatum.fromJson(x)).toList(),
    );

    Map<String, dynamic> toJson() => {
        'success': success,
        'DeliveryData': List<dynamic>.from(deliveryData.map((x) => x.toJson())),
    };
}

class GetCompletedDeliveriesDeliveryDatum {
    GetCompletedDeliveriesDeliveryDatum({
       required this.subsetDeliveryId,
       required this.productCode,
       required this.customerName,
       required this.inputby,
       required this.deliverydateId,
       required this.deliveryDate,
       required this.deliveryId,
    });

    String subsetDeliveryId;
    String productCode;
    String customerName;
    String inputby;
    String deliverydateId;
    String deliveryDate;
    int deliveryId;

    factory GetCompletedDeliveriesDeliveryDatum.fromJson(Map<String, dynamic> json) =>  GetCompletedDeliveriesDeliveryDatum(
        subsetDeliveryId: json['subsetDeliveryId'] ?? '',
        productCode: json['product_code'],
        customerName: json['customer_name'],
        inputby: json['inputby'],
        deliverydateId: json['deliverydateId'],
        deliveryDate: json['delivery_date'],
        deliveryId: json['deliveryId'],
    );

    Map<String, dynamic> toJson() => {
        'subsetDeliveryId': subsetDeliveryId,
        'product_code': productCode,
        'customer_name': customerName,
        'inputby': inputby,
        'deliverydateId': deliverydateId,
        'delivery_date': deliveryDate,
        'deliveryId': deliveryId,
    };
}

