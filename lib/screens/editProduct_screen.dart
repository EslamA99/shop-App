import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopApp/providers/product.dart';
import 'package:shopApp/providers/productProvider.dart';

class EditProductScreen extends StatefulWidget {
  static const route = 'editProductScreen/';
  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final priceFocus = FocusNode();
  final descriptionFocus = FocusNode();
  final imgFocus = FocusNode();
  final imgURL = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool isUpdate = true;
  bool isLoading = false;
  Product product =
      Product(description: '', id: null, imageUrl: '', price: 0, title: '');
  var initialValues = {
    'title': '',
    'price': '',
    'des': '',
    'fav': false,
  };
  @override
  void initState() {
    imgFocus.addListener(updateImg);
    super.initState();
  }

  @override
  void dispose() {
    priceFocus.dispose();
    descriptionFocus.dispose();
    imgURL.dispose();
    imgFocus.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    if (isUpdate) {
      String id = ModalRoute.of(context).settings.arguments as String;
      if (id != null) {
        product =
            Provider.of<productProvider>(context, listen: false).findById(id);
        initialValues['title'] = product.title;
        initialValues['price'] = product.price.toString();
        initialValues['des'] = product.description;
        initialValues['fav'] = product.isFavorite;
        imgURL.text = product.imageUrl;
      }
    }
    isUpdate = false;
    super.didChangeDependencies();
  }

  void updateImg() {
    if (!imgFocus.hasFocus) {
      if (imgURL.text.isEmpty ||
          (!imgURL.text.startsWith('http') &&
              !imgURL.text.startsWith('https')) ||
          (!imgURL.text.endsWith('jpg') &&
              !imgURL.text.endsWith('png') &&
              !imgURL.text.endsWith('jpeg'))) return;
    }
    setState(() {});
  }

  void save() async {
    final isValid = formKey.currentState.validate();
    if (!isValid) return;
    formKey.currentState.save();
    setState(() {
      isLoading = true;
    });
    final provider = Provider.of<productProvider>(context, listen: false);
    if (product.id != null) {
      await provider.updateProduct(product.id, product);
      setState(() {
        isLoading = false;
      });
      Navigator.of(context).pop();
    } else {
      try {
        await provider.addProduct(product);
      } catch (e) {
        await showDialog(
            context: (context),
            builder: (ctx) => AlertDialog(
                  title: Text('An error ocurred'),
                  content: Text('Somthing is wrong'),
                  actions: [
                    FlatButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                        },
                        child: Text('Ok'))
                  ],
                ));
      }
      setState(() {
        isLoading = false;
      });
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add product'),
        actions: [
          IconButton(
              icon: Icon(Icons.save),
              onPressed: () {
                save();
              })
        ],
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Form(
              key: formKey,
              child: Container(
                padding: EdgeInsets.all(10),
                child: ListView(
                  children: [
                    TextFormField(
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                      initialValue: initialValues['title'],
                      decoration: InputDecoration(labelText: 'Title'),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(priceFocus);
                      },
                      onSaved: (newValue) {
                        product = Product(
                            description: product.description,
                            id: product.id,
                            imageUrl: product.imageUrl,
                            price: product.price,
                            title: newValue);
                        product.isFavorite = initialValues['fav'];
                      },
                    ),
                    TextFormField(
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'please enter a price';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        if (double.parse(value) <= 0) {
                          return 'price must be greater than 0';
                        }
                        return null;
                      },
                      initialValue: initialValues['price'],
                      decoration: InputDecoration(labelText: 'Price'),
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      focusNode: priceFocus,
                      onFieldSubmitted: (value) {
                        FocusScope.of(context).requestFocus(descriptionFocus);
                      },
                      onSaved: (newValue) {
                        product = Product(
                            description: product.description,
                            id: product.id,
                            imageUrl: product.imageUrl,
                            title: product.title,
                            price: double.parse(newValue));
                        product.isFavorite = initialValues['fav'];
                      },
                    ),
                    TextFormField(
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter a description';
                        }
                        if (value.length <= 10) {
                          return 'description must be greater than 10 characters';
                        }
                        return null;
                      },
                      initialValue: initialValues['des'],
                      decoration: InputDecoration(labelText: 'Description'),
                      maxLines: 3,
                      focusNode: descriptionFocus,
                      onSaved: (newValue) {
                        product = Product(
                            description: newValue,
                            id: product.id,
                            imageUrl: product.imageUrl,
                            price: product.price,
                            title: product.title);
                        product.isFavorite = initialValues['fav'];
                      },
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 10),
                          height: 100,
                          width: 120,
                          decoration:
                              BoxDecoration(border: Border.all(width: 1)),
                          child: imgURL.text.isEmpty
                              ? Text(
                                  'Enter Url',
                                  textAlign: TextAlign.center,
                                )
                              : Image.network(imgURL.text),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Expanded(
                          child: TextFormField(
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Please enter an image url';
                                }
                                if (!value.startsWith('http') &&
                                    !value.startsWith('https')) {
                                  return ' Please enter a valid url';
                                }
                                if (!value.endsWith('jpg') &&
                                    !value.endsWith('png') &&
                                    !value.endsWith('jpeg')) {
                                  return ' Please enter a valid image url';
                                }
                                return null;
                              },
                              decoration:
                                  InputDecoration(labelText: 'ImageURL'),
                              keyboardType: TextInputType.url,
                              controller: imgURL,
                              focusNode: imgFocus,
                              onSaved: (newValue) {
                                product = Product(
                                    description: product.description,
                                    id: product.id,
                                    imageUrl: newValue,
                                    price: product.price,
                                    title: product.title);
                                product.isFavorite = initialValues['fav'];
                              },
                              onFieldSubmitted: (_) {
                                save();
                              }),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
