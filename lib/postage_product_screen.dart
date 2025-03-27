import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class PostageProductTypesScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onNext;
  const PostageProductTypesScreen({super.key, required this.onNext});

  @override
  PostageProductTypesScreenState createState() =>
      PostageProductTypesScreenState();
}

class PostageProductTypesScreenState extends State<PostageProductTypesScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _postageTypeController = TextEditingController();
  final List<String> _productTypes = [];
  String _selectedProductType = '';
  List<File> _businessDocuments = [];
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> _uploadFileList(List<File> files, String folder) async {
    for (File file in files) {
      String fileName =
          '$folder/${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
      UploadTask uploadTask = _storage.ref().child(fileName).putFile(file);
      await uploadTask;
    }
  }

  Future<void> _selectFiles() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      setState(() {
        _businessDocuments = result.paths.map((path) => File(path!)).toList();
      });
    }
  }

  void _validateAndNext() async {
    if (_formKey.currentState!.validate()) {
      await _uploadFileList(_businessDocuments, 'businessDocuments');
      widget.onNext({
        'postageType': _postageTypeController.text,
        'productTypes': _productTypes,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Postage and Product Types')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _postageTypeController,
                decoration: const InputDecoration(
                    labelText: 'Postage Type Available *'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the postage type available';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Column(
                children: <Widget>[
                  ..._productTypes.map((type) => ListTile(
                        title: Text(type),
                        trailing: IconButton(
                          icon: const Icon(Icons.remove_circle),
                          onPressed: () {
                            setState(() {
                              _productTypes.remove(type);
                            });
                          },
                        ),
                      )),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(
                              labelText: 'Add Product Type'),
                          onChanged: (value) {
                            _selectedProductType = value;
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle),
                        onPressed: () {
                          setState(() {
                            if (_selectedProductType.isNotEmpty) {
                              _productTypes.add(_selectedProductType);
                              _selectedProductType = '';
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Icon(
                  Icons.file_upload,
                  color: _businessDocuments.isNotEmpty ? Colors.green : null,
                ),
                title: const Text('Upload Business Documents'),
                onTap: _selectFiles,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _validateAndNext,
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
