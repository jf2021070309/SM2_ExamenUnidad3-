import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import '../../models/evento.dart';
import 'actividades_evento_view.dart';
import 'stands_evento_view.dart';

class EventoOpcionesView extends StatelessWidget {
  final Evento evento;
  final String userId;

  const EventoOpcionesView({
    super.key,
    required this.evento,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          evento.nombre,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF8B1B1B),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF8B1B1B), Color(0xFFA52A2A)],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [const Color(0xFF8B1B1B).withOpacity(0.1), Colors.white],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    kToolbarHeight,
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header con información del evento
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 32,
                            color: const Color(0xFF8B1B1B),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${_formatearFecha(evento.fechaInicio)} - ${_formatearFecha(evento.fechaFin)}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF8B1B1B),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 14,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  evento.lugar,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Botón para ver información detallada (PDF)
                          SizedBox(
                            width: 220,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.picture_as_pdf, size: 18),
                              label: Text(
                                _tienePDF()
                                    ? 'Ver información detallada'
                                    : 'Sin información adicional',
                                style: const TextStyle(fontSize: 13),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    _tienePDF()
                                        ? const Color(0xFF8B1B1B)
                                        : Colors.grey,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 14,
                                ),
                              ),
                              onPressed:
                                  _tienePDF() ? () => _abrirPDF(context) : null,
                            ),
                          ),

                          const SizedBox(height: 8),
                          // Texto referencial bajo el botón
                          Text(
                            _tienePDF()
                                ? 'Documento con información más detallada del evento.'
                                : 'No hay documento adicional disponible para este evento.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Título de opciones
                    Text(
                      '¿Qué deseas explorar?',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF8B1B1B),
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 20),

                    // Opciones
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.5,
                      child: Column(
                        children: [
                          // Botón Actividades
                          Expanded(
                            child: _buildOpcionCard(
                              context: context,
                              icon: Icons.event,
                              title: 'Actividades',
                              subtitle: 'Ver todas las actividades del evento',
                              color: const Color(0xFF8B1B1B),
                              onTap: () => _navegarAActividades(context),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Botón Stands
                          Expanded(
                            child: _buildOpcionCard(
                              context: context,
                              icon: Icons.store,
                              title: 'Stands',
                              subtitle:
                                  'Explora los stands y empresas participantes',
                              color: const Color(0xFFA52A2A),
                              onTap: () => _navegarAStands(context),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOpcionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color, color.withOpacity(0.8)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Icono decorativo de fondo
            Positioned(
              right: -20,
              top: -20,
              child: Icon(
                icon,
                size: 120,
                color: Colors.white.withOpacity(0.1),
              ),
            ),

            // Contenido
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Icon(icon, size: 32, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Flexible(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Flexible(
                    child: Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        'Explorar',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        Icons.arrow_forward,
                        color: Colors.white.withOpacity(0.9),
                        size: 14,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navegarAActividades(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ActividadesEventoView(evento: evento, userId: userId),
      ),
    );
  }

  void _navegarAStands(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => StandsEventoView(evento: evento)),
    );
  }

  // Método para verificar si el evento tiene PDF
  bool _tienePDF() {
    return evento.pdfBase64 != null && evento.pdfBase64!.isNotEmpty;
  }

  // Método para abrir el PDF desde base64
  Future<void> _abrirPDF(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);

    // Mostrar indicador de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B1B1B)),
          ),
        );
      },
    );

    try {
      // Decodificar base64 a bytes
      final bytes = base64Decode(evento.pdfBase64!);

      // Obtener directorio temporal
      final dir = await getTemporaryDirectory();
      final fileName = evento.pdfNombre ?? 'documento_evento_${evento.id}.pdf';
      final filePath = '${dir.path}/$fileName';

      // Crear archivo temporal
      final file = File(filePath);
      await file.writeAsBytes(bytes, flush: true);

      // Cerrar indicador de carga
      Navigator.of(context).pop();

      // Abrir archivo
      final result = await OpenFile.open(filePath);

      // Mostrar mensaje según el resultado
      if (result.type == ResultType.done) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Documento PDF abierto correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Error al abrir PDF: ${result.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Cerrar indicador de carga si hay error
      Navigator.of(context).pop();

      messenger.showSnackBar(
        SnackBar(
          content: Text('Error al procesar el documento: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatearFecha(DateTime fecha) {
    return '${fecha.day}/${fecha.month}/${fecha.year}';
  }
}
