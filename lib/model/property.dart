class Property{
  String id,addPublisherId,status,name,location,country,city,area,typeOfProperty,propertyCategory,
      whatsapp,call,email,beds,bath,measurementArea,datePosted,description,payment,furnish,agentName,floor,serial,description_ar,
      furnish_ar,name_ar,agentName_ar,payment_ar,city_ar,country_ar,typeOfProperty_ar,area_ar,propertyCategoryAr,coverImage,price_en,price_ar;
  int numericalPrice;
  List image;
  bool sponsered;


  /*'description_ar': ardescriptionController.text,
  'name_ar': arwordPriceController.text,
  'agentName_ar': aragentNameController.text,
  'payment_ar': arpaymentController.text,
  'furnish_ar': arfurnishController.text,
  'city_ar': selectedCityAR,
  'country_ar': selectedCountryAR,
  'area_ar': selectedAreaAR,
  'typeOfProperty_ar': selectedTypeAR,*/
  Property(this.id,this.status,this.addPublisherId,this.image, this.name ,  this.location, this.country, this.city, this.area, this.typeOfProperty, this.propertyCategory,
      this.whatsapp, this.call, this.email, this.beds, this.bath, this.measurementArea,this.datePosted,this.description,this.numericalPrice,
      this.payment,this.furnish,this.agentName,this.sponsered,this.floor,this.serial,this.name_ar,this.agentName_ar,this.area_ar,this.city_ar,
      this.country_ar,this.description_ar,this.furnish_ar,this.payment_ar,this.typeOfProperty_ar,this.propertyCategoryAr,this.price_en,this.price_ar,);
}