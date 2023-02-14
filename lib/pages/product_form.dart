// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:multiselect_formfield/multiselect_formfield.dart';
import 'package:provider/provider.dart';
import 'package:sales_app/models/product.dart';

import '../components/image_input.dart';
import '../models/product_list.dart';

class ProductForm extends StatefulWidget {
  const ProductForm({Key? key}) : super(key: key);

  @override
  _ProductFormState createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {


  final _formKey = GlobalKey<FormState>();
  final _formData = <String, Object>{};
  List<String> _selectedCategories = [];

  bool _isLoading = false;
  File? _pickedImage;

  void _selectImage(File pickedImage) {
    setState(() {
      _pickedImage = pickedImage;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_formData.isEmpty) {
      final arg = ModalRoute.of(context)?.settings.arguments;

      if (arg != null) {
        final product = arg as Product;
        _formData['id'] = product.id;
        _formData['name'] = product.name;
        _formData['description'] = product.description;
        _formData['characteristics'] = product.characteristics;
        _formData['aplications'] = product.aplications;
        _formData['category'] = product.category;
      }
    }
  }

  Future<void> _submitForm() async {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) {
      return;
    }

    _formKey.currentState?.save();

    setState(() => _isLoading = true);

    try {
      await Provider.of<ProductList>(
        context,
        listen: false,
      ).saveProduct(_formData, _pickedImage);

      Navigator.of(context).pop();
    } catch (error) {
      print(error);
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Ocorreu um erro!'),
          content: const Text('Ocorreu um erro para salvar o produto.'),
          actions: [
            TextButton(
              child: const Text('Ok'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        title: const Text('Adicione um Produto'),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _submitForm,
        icon: const Icon(Icons.save), 
        label: const Text('Salvar')
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(15),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    const Text(
                      'Adicione',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w400,
                        color: Color.fromARGB(255, 46, 44, 44)
                      ),
                    ),
                    const Text(
                      'seu Produto!',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w400,
                        color: Color.fromARGB(255, 46, 44, 44)
                      ),
                    ),
                    const SizedBox(height: 20,),
                    TextFormField(
                      initialValue: _formData['name']?.toString(),
                      decoration: const InputDecoration(
                        labelText: 'Nome',
                      ),
                      textInputAction: TextInputAction.next,
                      onSaved: (name) => _formData['name'] = name ?? '',
                      validator: (_name) {
                        final name = _name ?? '';

                        if (name.trim().isEmpty) {
                          return 'Nome é obrigatório';
                        }

                        if (name.trim().length < 3) {
                          return 'Nome precisa no mínimo de 3 letras.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20,),
                    TextFormField(
                      initialValue: _formData['description']?.toString(),
                      decoration: const InputDecoration(
                        labelText: 'Descrição',
                      ),
                      textInputAction: TextInputAction.next,
                      onSaved: (description) => _formData['description'] = description ?? '',
                      validator: (_description) {
                        final description = _description ?? '';

                        if (description.trim().isEmpty) {
                          return 'Descrição é obrigatória';
                        }

                        if (description.trim().length < 3) {
                          return 'O nome do engenheiro precisa de no mínimo de 3 letras.';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 20,),
                    TextFormField(
                      initialValue: _formData['characteristics']?.toString(),
                      decoration: const InputDecoration(
                        labelText: 'Características',
                      ),
                      textInputAction: TextInputAction.next,
                      onSaved: (characteristics) => _formData['characteristics'] = characteristics ?? '',
                    ),
                    TextFormField(
                      initialValue: _formData['aplications']?.toString(),
                      decoration: const InputDecoration(labelText: 'Aplicações'),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.multiline,
                      maxLines: 3,
                      onSaved: (aplications) =>
                          _formData['aplications'] = aplications ?? '',
                    ),
                    const SizedBox(height: 20,),
                    MultiSelectFormField(
                      title: const Text(
                        'Categorias',
                        style: TextStyle(
                          color: Color.fromARGB(255, 46, 44, 44)
                        ),
                      ),
                      checkBoxActiveColor: Colors.green,
                      dialogShapeBorder: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
                      dataSource: const [
                        {'value': '1', 'display': 'Algebra'},
                        {'value': '2', 'display': 'Calculus'},
                        {'value': '3', 'display': 'Geometry'},
                      ],
                      textField: 'display',
                      valueField: 'value',
                      okButtonLabel: 'OK',
                      cancelButtonLabel: 'CANCEL',
                      hintWidget: const Text('Escolha as categorias'),
                      initialValue: _selectedCategories,
                      onSaved: (value) {
                        if (value == null) return;
                        _selectedCategories = List<String>.from(value.map((item) => item.toString()));
                        _formData['category'] = _selectedCategories;
                      },
                    ),
                    const SizedBox(height: 20,),
                    Padding(
                      padding: const EdgeInsets.only(left: 25, right: 25, bottom: 10),
                      child: ImageInput(_selectImage),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

}
