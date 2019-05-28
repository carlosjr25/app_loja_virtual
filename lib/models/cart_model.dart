import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:loja_virtual/datas/cart_product.dart';
import 'package:loja_virtual/models/user_model.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter/material.dart';

class CartModel extends Model{

  UserModel user;

  bool isLoading = false;

  String couponCode;
  int discountPercentege = 0;


  List<CartProduct> products = [];

  CartModel(this.user){
    if(user.isLoggedIn())
      _loadCartItems();
  }

  static CartModel of(BuildContext context) =>
      ScopedModel.of<CartModel>(context);

  void addCardItem(CartProduct cartProduct){
    products.add(cartProduct);

    Firestore.instance.collection("users").document(user.firebaseUser.uid)
    .collection("cart").add(cartProduct.toMap()).then((doc){
      cartProduct.cid = doc.documentID;
    });

    notifyListeners();

  }

  void removeCartItem(CartProduct cartProduct){
    Firestore.instance.collection("users").document(user.firebaseUser.uid)
        .collection("cart").document(cartProduct.cid).delete();

    products.remove(cartProduct);

    notifyListeners();


  }

  void decProduct(CartProduct cartProduct){
    cartProduct.quantity -- ;

    Firestore.instance.collection("users").document(user.firebaseUser.uid).collection("cart")
    .document(cartProduct.cid).updateData(cartProduct.toMap());

    notifyListeners();
  }

  void incProduct(CartProduct cartProduct){
    cartProduct.quantity ++ ;

    Firestore.instance.collection("users").document(user.firebaseUser.uid).collection("cart")
        .document(cartProduct.cid).updateData(cartProduct.toMap());

    notifyListeners();
  }

  void setCoupon(String couponCode, int discountPercentage){
    this.couponCode = couponCode;
    this.discountPercentege = discountPercentage;
  }

  void _loadCartItems() async{
   QuerySnapshot query = await Firestore.instance.collection("users").document(user.firebaseUser.uid).collection("cart")
        .getDocuments();

   products = query.documents.map((doc) => CartProduct.fromDocument(doc)).toList();

   notifyListeners();

  }

}