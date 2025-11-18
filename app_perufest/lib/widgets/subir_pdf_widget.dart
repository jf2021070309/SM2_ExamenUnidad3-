import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'dart:io';

class SubirPDFWidget extends StatefulWidget {
  final Function(String base64, String nombre) onPDFSelected;
  final String? pdfActual; // PDF actual en base64 (si existe)
  final String? nombreActual; // Nombre del archivo actual
  
  const SubirPDFWidget({
    Key? key,
    required this.onPDFSelected,
    this.pdfActual,
    this.nombreActual,
  }) : super(key: key);

  @override
  _SubirPDFWidgetState createState() => _SubirPDFWidgetState();
}

class _SubirPDFWidgetState extends State<SubirPDFWidget> {
  String? _nombreArchivo;
  bool _cargando = false;
  String? _pdfBase64;

  @override
  void initState() {
    super.initState();
    _nombreArchivo = widget.nombreActual;
    _pdfBase64 = widget.pdfActual;
  }

  Future<void> _seleccionarPDF() async {
    setState(() => _cargando = true);
    
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        File file = File(result.files.single.path!);
        
        // Verificar tamaño del archivo (máximo 5MB)
        int fileSize = await file.length();
        if (fileSize > 5 * 1024 * 1024) {
          _mostrarError('El archivo es demasiado grande. Máximo 5MB permitido.');
          return;
        }
        
        List<int> bytes = await file.readAsBytes();
        String base64 = base64Encode(bytes);
        
        setState(() {
          _nombreArchivo = result.files.single.name;
          _pdfBase64 = base64;
        });
        
        widget.onPDFSelected(base64, result.files.single.name);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF cargado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      _mostrarError('Error al cargar PDF: $e');
    } finally {
      setState(() => _cargando = false);
    }
  }

  void _eliminarPDF() {
    setState(() {
      _nombreArchivo = null;
      _pdfBase64 = null;
    });
    
    widget.onPDFSelected('', ''); // Enviar valores vacíos para eliminar
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('PDF eliminado'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.picture_as_pdf,
                color: const Color(0xFF8B1B1B),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Documento PDF del Evento',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF8B1B1B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          if (_nombreArchivo != null) ...[
            // Mostrar archivo actual
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Archivo cargado:',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          _nombreArchivo!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.green.shade800,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _eliminarPDF,
                    icon: Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                      size: 20,
                    ),
                    tooltip: 'Eliminar PDF',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          
          // Botones de acción
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _cargando ? null : _seleccionarPDF,
                  icon: _cargando 
                    ? const SizedBox(
                        width: 16, 
                        height: 16, 
                        child: CircularProgressIndicator(strokeWidth: 2)
                      )
                    : const Icon(Icons.upload_file),
                  label: Text(_cargando ? 'Cargando...' : 
                             _nombreArchivo != null ? 'Cambiar PDF' : 'Seleccionar PDF'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B1B1B),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Información adicional
          Text(
            '• Formatos soportados: PDF\n'
            '• Tamaño máximo: 5MB\n'
            '• El documento será visible para todos los usuarios del evento',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}