// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sales_app/models/product.dart';

import '../models/product_list.dart';

class ProductForm extends StatefulWidget {
  const ProductForm({Key? key}) : super(key: key);

  @override
  _ProductFormState createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {


  final _formKey = GlobalKey<FormState>();
  final _formData = <String, Object>{};

  bool _isLoading = false;

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
      ).saveProduct(_formData);

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
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 9, 123, 143),
        title: const Text('Adicione um Produto'),
        actions: [
          IconButton(
            onPressed: _submitForm,
            icon: const Icon(Icons.save),
          ),
        ],
      ),
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
                    TextFormField(
                      initialValue: _formData['characteristics']?.toString(),
                      decoration: const InputDecoration(
                        labelText: 'Descrição',
                      ),
                      textInputAction: TextInputAction.next,
                      onSaved: (characteristics) => _formData['characteristics'] = characteristics ?? '',
                      validator: (_characteristics) {
                        final characteristics = _characteristics ?? '';

                        if (characteristics.trim().isEmpty) {
                          return 'Descrição é obrigatória';
                        }

                        if (characteristics.trim().length < 3) {
                          return 'O nome do engenheiro precisa de no mínimo de 3 letras.';
                        }

                        return null;
                      },
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
                    const Padding(padding: EdgeInsets.all(10)),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 9, 123, 143),
                          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20)),
                      onPressed: _submitForm,
                      child: const Text('Salvar'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

}
