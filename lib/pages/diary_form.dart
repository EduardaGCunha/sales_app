// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:multiselect_formfield/multiselect_formfield.dart';
import 'package:provider/provider.dart';
import 'package:rolling_switch/rolling_switch.dart';
import 'package:sales_app/models/diary.dart';
import 'package:sales_app/models/diary_list.dart';
import 'package:sales_app/models/product.dart';
import 'package:sales_app/models/project.dart';
import 'package:sales_app/models/project_list.dart';

import '../components/image_input.dart';
import '../components/pdf_input.dart';
import '../models/obra.dart';
import '../models/product_list.dart';

class DiaryForm extends StatefulWidget {
  const DiaryForm({Key? key}) : super(key: key);

  @override
  _DiaryFormState createState() => _DiaryFormState();
}

class _DiaryFormState extends State<DiaryForm> {

  final _formKey = GlobalKey<FormState>();
  final _formData = <String, Object>{};
  bool isCivil = false;
  bool isEletrical = false;
  bool isFinancial = false;

  bool _isLoading = false;
  File? _pickedImage;
  String? currentPhase;

  void _selectImage(File pickedImage) {
    setState(() {
      _pickedImage = pickedImage;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arg = ModalRoute.of(context)?.settings.arguments;

    if(arg != null){
      if((arg as Map)['id'] != null){
        final List<Diary> listMethods = Provider.of<DiaryList>(context).getSpecificDiary(arg['id']);      
      
        if (listMethods.isEmpty) {
          _formData['matchmakingId'] = arg['id'].toString();
        }
        else{        

          final Diary product = listMethods.first;
    

          _formData['id'] = product.id;
          _formData['description'] = product.description;
          _formData['finishedServ'] = product.finishedServ;
          _formData['initiatedServ'] = product.initiatedServ;
          currentPhase = product.currentPhase;
          _formData['matchmakingId'] = product.matchmakingId;
        }
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

    _formData['currentPhase'] = currentPhase!;

    try {
      await Provider.of<DiaryList>(
        context,
        listen: false,
      ).saveDiary(_formData, _pickedImage!);

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

    List<String> allPhases = ['Phase1', 'Phase2', 'Phase3', 'Phase4'];

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
                    Color.fromARGB(255, 7, 41, 70).withOpacity(0.8),
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
                    const Text(
                      'Adicione',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w600,
                        color: Color.fromARGB(255, 255, 255, 255)
                      ),
                    ),
                    const Text(
                      'o Diário!',
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
                        initialValue: _formData['description']?.toString(),
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          labelText: 'Descrição',
                          prefixIcon: const Icon(Icons.book),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        textInputAction: TextInputAction.next,
                        onSaved: (description) => _formData['description'] = description ?? '',
                        validator: (_description) {
                          final description = _description ?? '';
                          
                          if (description.trim().isEmpty) {
                            return 'Descrição é obrigatória';
                          }
                          
                          if (description.trim().length < 3) {
                            return 'Descrição precisa de no mínimo 3 letras.';
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
                        initialValue: _formData['initiatedServ']?.toString(),
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          labelText: 'Serviços Iniciados',
                          prefixIcon: const Icon(Icons.rocket),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        textInputAction: TextInputAction.next,
                        onSaved: (initiatedServ) => _formData['initiatedServ'] = initiatedServ ?? '',
                      ),
                    ),
                    const SizedBox(height: 20,),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: TextFormField(
                        initialValue: _formData['finishedServ']?.toString(),
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          labelText: 'Serviços Terminados',
                          prefixIcon: const Icon(Icons.check),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        textInputAction: TextInputAction.next,
                        onSaved: (finishedServ) => _formData['finishedServ'] = finishedServ ?? '',
                      ),
                    ),
                    const SizedBox(height: 20,),
                    Container(
                      width: 240,
                      color: Colors.white,
                      padding: const EdgeInsets.all(8),
                      child: DropdownButton<String>(
                        underline: const SizedBox(),
                        isExpanded: true,
                        isDense: true,
                        borderRadius: BorderRadius.circular(5),
                        value: currentPhase,
                        onChanged: (escolha) {
                          setState(() {
                            currentPhase = escolha!;
                            _formData['currentPhase'] = escolha;
                          });
                        },
                        items: allPhases.map((phase) => DropdownMenuItem(
                          value: phase,
                          child: Text(phase)
                          ),
                        ).toList(), 
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 25, right: 25, bottom: 10),
                      child: ImageInput(_selectImage),
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
