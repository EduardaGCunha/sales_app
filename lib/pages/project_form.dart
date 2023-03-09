// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:multiselect_formfield/multiselect_formfield.dart';
import 'package:provider/provider.dart';
import 'package:rolling_switch/rolling_switch.dart';
import 'package:sales_app/models/product.dart';
import 'package:sales_app/models/project.dart';
import 'package:sales_app/models/project_list.dart';

import '../components/image_input.dart';
import '../components/pdf_input.dart';
import '../models/obra.dart';
import '../models/product_list.dart';

class ProjectForm extends StatefulWidget {
  const ProjectForm({Key? key}) : super(key: key);

  @override
  _ProjectFormState createState() => _ProjectFormState();
}

class _ProjectFormState extends State<ProjectForm> {

  final _formKey = GlobalKey<FormState>();
  final _formData = <String, Object>{};
  DateTime _selectedBeginningDate = DateTime.now();
  DateTime _selectedEndingDate = DateTime.now();
  bool isCivil = false;
  bool isEletrical = false;
  bool isFinancial = false;

  bool _isLoading = false;
  File? _pickedPDF;

  void _selectImage(File pickedPDF) {
    setState(() {
      _pickedPDF = pickedPDF;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arg = ModalRoute.of(context)?.settings.arguments;

    if(arg != null){
      if((arg as Map)['id'] != null){
        final List<Project> listMethods = Provider.of<ProjectList>(context).getSpecificProject(arg['id']);      
      
        if (listMethods.isEmpty) {
          _formData['matchmakingId'] = arg['id'].toString();
        }
        else{        

          final Project product = listMethods.first;
    

          _formData['id'] = product.id;
          _formData['engineer'] = product.engineer;
          isCivil = product.civil;
          isFinancial = product.financial;
          isEletrical = product.eletrical;
          _selectedBeginningDate = product.begDate;
         _selectedEndingDate = product.endDate;
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

    _formData['civil'] = isCivil;
    _formData['eletrical'] = isEletrical;
    _formData['financial'] = isFinancial;

    try {
      await Provider.of<ProjectList>(
        context,
        listen: false,
      ).saveProduct(_formData, _pickedPDF!);

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
        backgroundColor: Color.fromARGB(209, 25, 42, 68),
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
                      'o Projeto!',
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
                        initialValue: _formData['engineer']?.toString(),
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          labelText: 'Engenheiro',
                          prefixIcon: const Icon(Icons.engineering),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        textInputAction: TextInputAction.next,
                        onSaved: (engineer) => _formData['engineer'] = engineer ?? '',
                        validator: (_engineer) {
                          final engineer = _engineer ?? '';
                          
                          if (engineer.trim().isEmpty) {
                            return 'Nome é obrigatório';
                          }
                          
                          if (engineer.trim().length < 3) {
                            return 'Nome precisa no mínimo de 3 letras.';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 15,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 150,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(
                              color: Colors.grey,
                            ),
                            color: Colors.white
                          ),
                          child: Column(
                            children: [
                              Text('Início', style: TextStyle(color: Colors.grey[800]),),
                              Padding(
                                padding: const EdgeInsets.only(left: 15),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${DateFormat('dd/MM').format(_selectedBeginningDate)}' ,
                                    ),
                                     IconButton(
                                      icon: Icon(Icons.date_range),
                                      onPressed: () async {
                                        showDatePicker(
                                            context: context, 
                                            initialDate: DateTime.now(), 
                                            firstDate: DateTime(2019), 
                                            lastDate: DateTime.now(),
                                          ).then((pickedDate) {
                                            setState(() {
                                              if (pickedDate == null){
                                                return;
                                              }
                                              _selectedBeginningDate = pickedDate;
                                              _formData['begDate'] = _selectedBeginningDate;
                                            });
                                          });
                                      },
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20,),
                        Container(
                          width: 150,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(
                              color: Colors.grey,
                            ),
                            color: Colors.white,
                          ),
                          child: Column(
                            children: [
                              Text('Final', style: TextStyle(color:  Colors.grey[800]),),
                              Padding(
                                padding: const EdgeInsets.only(left: 15),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                       '${DateFormat('dd/MM').format(_selectedEndingDate)}' ,
                                    ),
                                     IconButton(
                                      icon: Icon(Icons.date_range),
                                      onPressed: () async {
                                        showDatePicker(
                                            context: context, 
                                            initialDate: DateTime.now(), 
                                            firstDate: DateTime(2019), 
                                            lastDate: DateTime(2030),
                                          ).then((pickedDate) {
                                            setState(() {
                                              if (pickedDate == null){
                                                return;
                                              }
                                              _selectedEndingDate = pickedDate;
                                              _formData['endDate'] = _selectedEndingDate;
                                            });
                                          });
                                      },
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20,),
                    Container(
                      width: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(
                          color: Colors.grey,
                        ),
                        color: Colors.white,
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 25, top: 0, bottom: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                    'civil:',
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                      color: Color.fromARGB(255, 66, 66, 66),
                                    ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: Transform.scale(
                                    scale: 0.7,
                                    child: RollingSwitch.icon(
                                      onChanged: (bool value) {
                                        setState(() {
                                          isCivil = value;
                                        });
                                      },
                                      rollingInfoRight: const RollingIconInfo(
                                        backgroundColor: Colors.greenAccent,
                                        icon: Icons.check,
                                        text: Text(''),
                                      ),
                                      rollingInfoLeft: const RollingIconInfo(
                                        icon: Icons.flag,
                                        backgroundColor: Colors.grey,
                                        text: Text(''),
                                      ),
                                    )
                                  )
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 25, top: 0, bottom: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                    'elétrico:',
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                      color: Color.fromARGB(255, 66, 66, 66),
                                    ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: Transform.scale(
                                    scale: 0.7,
                                    child: RollingSwitch.icon(
                                      onChanged: (bool value) {
                                        setState(() {
                                          isEletrical = value;
                                        });
                                      },
                                      rollingInfoRight: const RollingIconInfo(
                                        backgroundColor: Colors.greenAccent,
                                        icon: Icons.check,
                                        text: Text(''),
                                      ),
                                      rollingInfoLeft: const RollingIconInfo(
                                        icon: Icons.flag,
                                        backgroundColor: Colors.grey,
                                        text: Text(''),
                                      ),
                                    )
                                  )
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 25, top: 0, bottom: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                    'financiamento:',
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                      color: Color.fromARGB(255, 66, 66, 66),
                                    ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: Transform.scale(
                                    scale: 0.7,
                                    child: RollingSwitch.icon(
                                      onChanged: (bool value) {
                                        setState(() {
                                          isFinancial = value;
                                        });
                                      },
                                      rollingInfoRight: const RollingIconInfo(
                                        backgroundColor: Colors.greenAccent,
                                        icon: Icons.check,
                                        text: Text(''),
                                      ),
                                      rollingInfoLeft: const RollingIconInfo(
                                        icon: Icons.flag,
                                        backgroundColor: Colors.grey,
                                        text: Text(''),
                                      ),
                                    )
                                  )
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 25, right: 25, bottom: 10),
                            child: PdfInput(_selectImage),
                          ),
                        ],
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
