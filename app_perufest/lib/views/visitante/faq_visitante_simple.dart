import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/faq.dart';

class FAQVisitanteSimple extends StatefulWidget {
  const FAQVisitanteSimple({super.key});

  @override
  State<FAQVisitanteSimple> createState() => _FAQVisitanteSimpleState();
}

class _FAQVisitanteSimpleState extends State<FAQVisitanteSimple> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _busquedaController = TextEditingController();
  
  List<FAQ> _todasLasFAQs = [];
  List<FAQ> _faqsFiltradas = [];
  bool _isLoading = false;
  String? _error;
  bool _isLoadingData = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarFAQs();
    });
  }

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }

  Future<void> _cargarFAQs() async {
    if (!mounted || _isLoadingData) return;
    
    _isLoadingData = true;
    
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Consulta simple sin índices compuestos - solo FAQs activas
      final querySnapshot = await _firestore
          .collection('faqs')
          .where('estado', isEqualTo: true)
          .get()
          .timeout(const Duration(seconds: 10));

      final faqs = querySnapshot.docs
          .map((doc) => FAQ.fromFirestore(doc))
          .toList();

      // Ordenar en memoria
      faqs.sort((a, b) {
        if (a.orden != b.orden) {
          return a.orden.compareTo(b.orden);
        }
        return a.fechaCreacion.compareTo(b.fechaCreacion);
      });

      if (mounted) {
        setState(() {
          _todasLasFAQs = faqs;
          _faqsFiltradas = faqs;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error al cargar FAQs: $e';
          _isLoading = false;
        });
      }
    } finally {
      _isLoadingData = false;
    }
  }

  void _buscarFAQs(String texto) {
    if (texto.isEmpty) {
      setState(() {
        _faqsFiltradas = _todasLasFAQs;
      });
      return;
    }

    final textoLower = texto.toLowerCase();
    setState(() {
      _faqsFiltradas = _todasLasFAQs
          .where((faq) =>
              faq.pregunta.toLowerCase().contains(textoLower) ||
              faq.respuesta.toLowerCase().contains(textoLower))
          .toList();
    });
  }

  Future<void> _contactarWhatsApp() async {
    const telefono = '51987654321'; // Número de WhatsApp del soporte
    const mensaje = 'Hola, tengo una pregunta sobre el PeruFest 2025';
    final url = Uri.parse('https://wa.me/$telefono?text=${Uri.encodeComponent(mensaje)}');

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se puede abrir WhatsApp'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al abrir WhatsApp: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _contactarEmail() async {
    const email = 'soporte@perufest.com';
    const asunto = 'Consulta sobre PeruFest 2025';
    final url = Uri.parse('mailto:$email?subject=${Uri.encodeComponent(asunto)}');

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se puede abrir el cliente de email'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al abrir email: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(child: _buildBusqueda()),
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B1B1B)),
                ),
              ),
            )
          else if (_error != null)
            SliverFillRemaining(child: _buildErrorState())
          else if (_faqsFiltradas.isEmpty && _busquedaController.text.isNotEmpty)
            _buildNoResultados()
          else if (_faqsFiltradas.isEmpty)
            _buildEmptyState()
          else
            _buildFAQsList(_faqsFiltradas),
          _buildSoporteSection(),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200.0,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFF8B1B1B),
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Preguntas Frecuentes',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                offset: Offset(1.0, 1.0),
                blurRadius: 3.0,
                color: Color.fromARGB(127, 0, 0, 0),
              ),
            ],
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF8B1B1B).withOpacity(0.9),
                const Color(0xFF8B1B1B),
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -50,
                top: -50,
                child: Icon(
                  Icons.help_center,
                  size: 200,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
              const Positioned(
                bottom: 60,
                left: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Encuentra respuestas a',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    Text(
                      'tus preguntas',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBusqueda() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: TextField(
        controller: _busquedaController,
        decoration: InputDecoration(
          hintText: 'Buscar preguntas...',
          prefixIcon: const Icon(Icons.search, color: Color(0xFF8B1B1B)),
          suffixIcon: _busquedaController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _busquedaController.clear();
                    _buscarFAQs('');
                  },
                )
              : IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _cargarFAQs,
                ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: const BorderSide(color: Color(0xFF8B1B1B), width: 2),
          ),
          fillColor: Colors.white,
          filled: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        onChanged: _buscarFAQs,
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Error al cargar',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.red[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Error desconocido',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[500]),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _cargarFAQs,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B1B1B),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQsList(List<FAQ> faqs) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => _buildFAQCard(faqs[index], index),
          childCount: faqs.length,
        ),
      ),
    );
  }

  Widget _buildFAQCard(FAQ faq, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF8B1B1B).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${index + 1}',
            style: const TextStyle(
              color: Color(0xFF8B1B1B),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          faq.pregunta,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              faq.respuesta,
              style: const TextStyle(
                fontSize: 15,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return SliverFillRemaining(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.quiz_outlined,
                size: 80,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No hay preguntas frecuentes disponibles',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Vuelve más tarde o contacta con el soporte',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoResultados() {
    return SliverFillRemaining(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                size: 80,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No se encontraron resultados',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Intenta con otras palabras clave',
                style: TextStyle(fontSize: 16, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSoporteSection() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 32, 16, 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF8B1B1B),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            const Icon(
              Icons.headset_mic,
              color: Colors.white,
              size: 48,
            ),
            const SizedBox(height: 16),
            const Text(
              '¿Tienes más preguntas?',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Estamos aquí para ayudarte. Contáctanos en cualquier momento.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _contactarWhatsApp,
                    icon: const Icon(Icons.chat, size: 20),
                    label: const Text('WhatsApp'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _contactarEmail,
                    icon: const Icon(Icons.email, size: 20),
                    label: const Text('Email'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF8B1B1B),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}