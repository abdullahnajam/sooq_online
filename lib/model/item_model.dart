class Item{
  String id,addPublisherId,status,name,location,country,city,area,category,subcategory,
      whatsapp,call,email,datePosted,description,payment,agentName,
      serial,description_ar,agentName_ar,city_ar,country_ar,area_ar,
      categoryAr,subcategoryAr,coverImage,price_en,price_ar;
  int numericalPrice;
  List image;
  bool sponsered,best;

  Item(
      this.id,
      this.addPublisherId,
      this.status,
      this.name,
      this.location,
      this.country,
      this.city,
      this.area,
      this.category,
      this.subcategory,
      this.whatsapp,
      this.call,
      this.email,
      this.datePosted,
      this.description,
      this.payment,
      this.agentName,
      this.serial,
      this.description_ar,
      this.agentName_ar,
      this.city_ar,
      this.country_ar,
      this.area_ar,
      this.categoryAr,
      this.subcategoryAr,
      this.coverImage,
      this.price_en,
      this.price_ar,
      this.numericalPrice,
      this.image,
      this.sponsered,
      this.best);
}