import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/noticias_visitante_viewmodel.dart';
import '../../models/noticias.dart';
import 'detalle_noticia_visitante_view.dart';

class NoticiasVisitanteView extends StatefulWidget {
  const NoticiasVisitanteView({super.key});

  @override
  State<NoticiasVisitanteView> createState() => _NoticiasVisitanteViewState();
}

class _NoticiasVisitanteViewState extends State<NoticiasVisitanteView> {
  late NoticiasVisitanteViewModel _viewModel;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _viewModel = NoticiasVisitanteViewModel();
    _scrollController.addListener(_onScroll);
    
    // Cargar noticias iniciales
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.cargarNoticias();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      // Cargar más cuando esté cerca del final
      _viewModel.cargarMasNoticias();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<NoticiasVisitanteViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            backgroundColor: Colors.grey[50],
            body: CustomScrollView(
              controller: _scrollController,
              slivers: [
                _buildSliverAppBar(viewModel),
                _buildFiltrosSection(viewModel),
                _buildNoticiasContent(viewModel),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSliverAppBar(NoticiasVisitanteViewModel viewModel) {
    return SliverAppBar(
      expandedHeight: 200.0,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFF8B1B1B),
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Noticias PerúFest',
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
                  Icons.article,
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
                      'Mantente informado',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    Text(
                      'Últimas noticias',
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
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: () => viewModel.actualizarNoticias(),
          tooltip: 'Actualizar noticias',
        ),
      ],
    );
  }

  Widget _buildFiltrosSection(NoticiasVisitanteViewModel viewModel) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.filter_list, color: Colors.grey[600], size: 20),
                const SizedBox(width: 8),
                Text(
                  'Filtrar por fecha:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFiltroChip('Todas', '', viewModel),
                  const SizedBox(width: 8),
                  _buildFiltroChip('Hoy', 'hoy', viewModel),
                  const SizedBox(width: 8),
                  _buildFiltroChip('Esta semana', 'semana', viewModel),
                  const SizedBox(width: 8),
                  _buildFiltroChip('Este mes', 'mes', viewModel),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltroChip(String label, String valor, NoticiasVisitanteViewModel viewModel) {
    final isSelected = viewModel.filtroFecha == valor;
    
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : const Color(0xFF8B1B1B),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          viewModel.aplicarFiltroFecha(valor);
        } else {
          viewModel.limpiarFiltros();
        }
      },
      backgroundColor: Colors.white,
      selectedColor: const Color(0xFF8B1B1B),
      checkmarkColor: Colors.white,
      side: BorderSide(
        color: isSelected ? const Color(0xFF8B1B1B) : Colors.grey[300]!,
      ),
    );
  }

  Widget _buildNoticiasContent(NoticiasVisitanteViewModel viewModel) {
    if (viewModel.isLoading && viewModel.noticias.isEmpty) {
      return const SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B1B1B)),
              ),
              SizedBox(height: 16),
              Text('Cargando noticias...'),
            ],
          ),
        ),
      );
    }

    if (viewModel.errorMessage.isNotEmpty && viewModel.noticias.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
              const SizedBox(height: 16),
              Text(
                'Error al cargar noticias',
                style: TextStyle(fontSize: 18, color: Colors.red[600]),
              ),
              const SizedBox(height: 8),
              Text(
                viewModel.errorMessage,
                style: const TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => viewModel.actualizarNoticias(),
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

    if (viewModel.noticias.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.article_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'No hay noticias disponibles',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Las noticias aparecerán aquí cuando se publiquen',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index < viewModel.noticias.length) {
            return _buildNoticiaCard(viewModel.noticias[index]);
          } else if (viewModel.hasMore) {
            return _buildLoadMoreButton(viewModel);
          } else {
            return _buildFinMessage();
          }
        },
        childCount: viewModel.noticias.length + (viewModel.hasMore ? 1 : 1),
      ),
    );
  }

  Widget _buildNoticiaCard(Noticia noticia) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetalleNoticiaVisitanteView(noticia: noticia),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header con fecha y tipo
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B1B1B).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.article,
                            size: 16,
                            color: const Color(0xFF8B1B1B),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Noticia',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF8B1B1B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 12,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(noticia.fechaPublicacion),
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Imagen si existe
                if (noticia.imagenUrl != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: NetworkImage(noticia.imagenUrl!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                
                // Título
                Text(
                  noticia.titulo,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 12),
                
                // Texto corto
                Text(
                  noticia.textoCorto,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 16),
                
                // Footer con autor y botón leer más
                Row(
                  children: [
                    // Autor
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B1B1B).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.person,
                        size: 18,
                        color: const Color(0xFF8B1B1B),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Por ${noticia.autorNombre}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Indicadores
                    if (noticia.enlaceExterno != null)
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.link,
                          size: 14,
                          color: Colors.green.shade600,
                        ),
                      ),
                    
                    // Botón leer más
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B1B1B).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'Leer más',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF8B1B1B),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadMoreButton(NoticiasVisitanteViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: viewModel.isLoading
            ? const Column(
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B1B1B)),
                  ),
                  SizedBox(height: 8),
                  Text('Cargando más noticias...'),
                ],
              )
            : ElevatedButton.icon(
                onPressed: () => viewModel.cargarMasNoticias(),
                icon: const Icon(Icons.expand_more),
                label: const Text('Ver más noticias'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B1B1B),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildFinMessage() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.grey[400], size: 48),
            const SizedBox(height: 12),
            Text(
              'Has visto todas las noticias disponibles',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const meses = [
      'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic'
    ];
    
    final now = DateTime.now();
    final difference = now.difference(date);
    
    String formatTime(DateTime dt) {
      final hour = dt.hour.toString().padLeft(2, '0');
      final minute = dt.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    }
    
    if (difference.inDays == 0) {
      return 'Hoy ${formatTime(date)}';
    } else if (difference.inDays == 1) {
      return 'Ayer ${formatTime(date)}';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays} días';
    } else {
      return '${date.day} ${meses[date.month - 1]} ${date.year}';
    }
  }
}