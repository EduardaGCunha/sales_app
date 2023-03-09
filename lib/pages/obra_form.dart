// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:multiselect_formfield/multiselect_formfield.dart';
import 'package:provider/provider.dart';
import 'package:sales_app/models/product.dart';

import '../components/image_input.dart';
import '../models/obra.dart';
import '../models/obra_list.dart';
import '../models/product_list.dart';

class ObraForm extends StatefulWidget {
  const ObraForm({Key? key}) : super(key: key);

  @override
  _ObraFormState createState() => _ObraFormState();
}

class _ObraFormState extends State<ObraForm> {


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
        final product = arg as Obra;
        _formData['id'] = product.id;
        _formData['owner'] = product.owner;
        _formData['enterprise'] = product.enterprise;
        _formData['address'] = product.address;
        _formData['responsible'] = product.responsible;
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
      await Provider.of<ObraList>(
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
      // backgroundColor: const Color.fromARGB(157, 25, 42, 68),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(209, 25, 42, 68),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color.fromARGB(255, 236, 182, 55)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color.fromARGB(255, 236, 182, 55),
        onPressed: _submitForm,
        icon: const Icon(Icons.save), 
        label: const Text('Salvar')
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: _isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromARGB(193, 12, 54, 117),
                    Color.fromARGB(255, 25, 42, 68),
                  ],
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage('https://www.grainsystems.com/content/dam/public/grain-and-protein/grain-systems/product-images/storage/evo-50/4024-EVO24-1440.jpg'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    const Color.fromARGB(255, 7, 41, 70).withOpacity(0.8),
                    BlendMode.srcATop,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    const SizedBox(height: 100,),
                    const Text(
                      'Adicione',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w600,
                        color: Color.fromARGB(255, 255, 255, 255)
                      ),
                    ),
                    const Text(
                      'sua Obra!',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w600,
                        color: Color.fromARGB(255, 255, 255, 255)
                      ),
                    ),
                    const SizedBox(height: 20,),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: TextFormField(
                        initialValue: _formData['enterprise']?.toString(),
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          labelText: 'Empresa',
                          prefixIcon: const Icon(Icons.house),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        textInputAction: TextInputAction.next,
                        onSaved: (enterprise) => _formData['enterprise'] = enterprise ?? '',
                        validator: (_enterprise) {
                          final enterprise = _enterprise ?? '';
                          
                          if (enterprise.trim().isEmpty) {
                            return 'Empresa é obrigatório';
                          }
                          
                          if (enterprise.trim().length < 3) {
                            return 'Empresa precisa no mínimo de 3 letras.';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 20,),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: TextFormField(
                        initialValue: _formData['responsible']?.toString(),
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          labelText: 'Gerente',
                          prefixIcon: const Icon(Icons.book),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        textInputAction: TextInputAction.next,
                        onSaved: (responsible) => _formData['responsible'] = responsible ?? '',
                        validator: (_responsible) {
                          final responsible = _responsible ?? '';
                          
                          if (responsible.trim().isEmpty) {
                            return 'Gerente é obrigatória';
                          }
                          
                          if (responsible.trim().length < 3) {
                            return 'O nome do genrete precisa de no mínimo de 3 letras.';
                          }
                          
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 20,),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: TextFormField(
                        initialValue: _formData['owner']?.toString(),
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          labelText: 'Proprietário',
                          prefixIcon: const Icon(Icons.category),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        textInputAction: TextInputAction.next,
                        onSaved: (owner) => _formData['owner'] = owner ?? '',
                      ),
                    ),
                    const SizedBox(height: 20,),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: TextFormField(
                        initialValue: _formData['address']?.toString(),
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          labelText: 'Endereço',
                          prefixIcon: const Icon(Icons.apps),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.multiline,
                        onSaved: (address) =>
                            _formData['address'] = address ?? '',
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
    );
  }
}
