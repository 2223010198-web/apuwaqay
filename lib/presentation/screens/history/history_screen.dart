import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:latlong2/latlong.dart';

// --- MODELO DE DATOS ACTUALIZADO ---
class HuaycoEvent {
  final String title;
  final String date;
  final String location;
  final String severity;
  final String description;
  final String source;
  final LatLng coords;
  final List<String> images; // <--- NUEVO: Lista de imágenes para el carrusel

  HuaycoEvent({
    required this.title,
    required this.date,
    required this.location,
    required this.severity,
    required this.description,
    required this.source,
    required this.coords,
    required this.images,
  });
}

class HistoryScreen extends StatefulWidget {
  final Function(LatLng)? onMapRequest;

  const HistoryScreen({super.key, this.onMapRequest});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();

  // VARIABLE DE ESTADO PARA CONTROLAR LA VISTA (Lista o Detalle)
  HuaycoEvent? _selectedEvent;

  // --- DATOS SIMULADOS ---
  final List<HuaycoEvent> _allEvents = [
    HuaycoEvent(
      title: "Desborde Quebrada del Toro",
      date: "12 Mar 2023",
      location: "Camaná, Arequipa",
      severity: "Alta",
      description: "Activación de quebrada afectando 500 viviendas y la carretera principal. Se requiere maquinaria pesada para limpieza.",
      source: "INDECI",
      coords: const LatLng(-16.625, -72.711),
      images: [
        "https://images-tools.cadena3.com/tools/r/5bb022ea-59cd-464b-9809-5545fa169074.jpg?width=1200&height=798",
        "https://eltinterodesalta.com/download/multimedia.normal.a728efb060e47fa5.bm9ybWFsLndlYnA%3D.webp",
      ],
    ),
    HuaycoEvent(
      title: "Huayco en Chosica",
      date: "05 Feb 2023",
      location: "Chosica, Lima",
      severity: "Media",
      description: "Bloqueo de la carretera central por deslizamiento de lodo y piedras en el km 40.",
      source: "IGP",
      coords: const LatLng(-11.936, -76.692),
      images: [
        "https://portal.andina.pe/EDPfotografia/Thumbnail/2015/02/09/000280980W.jpg",
        "https://peru21.pe/sites/default/efsfiles/2023-09/V23ST5V72FBXNLMW25ELKLIIVY.jpg"
      ],
    ),
    HuaycoEvent(
      title: "Deslizamiento en Jicamarca",
      date: "15 Mar 2017",
      location: "San Juan de Lurigancho",
      severity: "Alta",
      description: "El fenómeno 'El Niño Costero' provocó uno de los desastres más grandes en la zona de Cajamarquilla.",
      source: "Noticias",
      coords: const LatLng(-11.950, -76.980),
      images: ["https://cloudfront-us-east-1.images.arcpublishing.com/infobae/BPHD2NN67BAZNNL6EGIPVEM47A.png"], // Sin imágenes
    ),
    HuaycoEvent(
      title: "Alerta Río Rímac",
      date: "10 Ene 2024",
      location: "Chaclacayo",
      severity: "Baja",
      description: "Aumento de caudal preventivo por lluvias en la sierra central. No hubo desbordes mayores.",
      source: "SENAMHI",
      coords: const LatLng(-11.975, -76.765),
      images: ["https://www.infobae.com/new-resizer/CIFjV4xHQNmXjHPpWxk-HzHN3Gg=/arc-anglerfish-arc2-prod-infobae/public/XT2DJVR5HFHGZM7SYKIQQHEXUQ.jpg"],
    ),
  ];

  List<HuaycoEvent> _filteredEvents = [];

  @override
  void initState() {
    super.initState();
    _filteredEvents = _allEvents;
  }

  void _filterEvents(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredEvents = _allEvents;
      } else {
        _filteredEvents = _allEvents
            .where((event) =>
        event.location.toLowerCase().contains(query.toLowerCase()) ||
            event.title.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) debugPrint("No se pudo abrir $url");
  }

  @override
  Widget build(BuildContext context) {
    // Usamos PopScope para que el botón "Atrás" de Android cierre el detalle primero en vez de salir de la app
    return PopScope(
      canPop: _selectedEvent == null,
      onPopInvoked: (didPop) {
        if (_selectedEvent != null) {
          setState(() => _selectedEvent = null);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        // LÓGICA PRINCIPAL: Si hay un evento seleccionado, mostramos detalle, sino lista
        body: _selectedEvent != null ? _buildDetailView() : _buildListView(),
      ),
    );
  }

  // --- VISTA 1: LISTA DE EVENTOS (Dashboard normal) ---
  Widget _buildListView() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header personalizado
          Container(
            padding: const EdgeInsets.only(top: 40, left: 20, right: 20, bottom: 20),
            color: Colors.white,
            child: const Row(
              children: [
                Text("Historial y Recursos", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                Spacer(),
                Icon(Icons.history_edu, color: Colors.blueGrey),
              ],
            ),
          ),

          _buildEmergencySection(),

          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
              child: TextField(
                controller: _searchController,
                onChanged: _filterEvents,
                decoration: const InputDecoration(
                  hintText: "Buscar por lugar...",
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),
          const Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Text("Registro de Eventos", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
          const SizedBox(height: 10),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _filteredEvents.length,
            itemBuilder: (context, index) {
              return _EventCard(
                event: _filteredEvents[index],
                onTap: () {
                  // AL TOCAR LA TARJETA, CAMBIAMOS EL ESTADO A "MODO DETALLE"
                  setState(() {
                    _selectedEvent = _filteredEvents[index];
                  });
                },
              );
            },
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // --- VISTA 2: DETALLE DEL EVENTO (Carrusel + Info Completa) ---
  Widget _buildDetailView() {
    final event = _selectedEvent!;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Cabecera con Botón Atrás
          Container(
            padding: const EdgeInsets.only(top: 40, left: 10, right: 20, bottom: 10),
            color: Colors.white,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () {
                    // AL PRESIONAR ATRÁS, VOLVEMOS A LA LISTA
                    setState(() => _selectedEvent = null);
                  },
                ),
                Expanded(
                  child: Text(
                    event.title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // 2. Carrusel de Imágenes
          SizedBox(
            height: 250,
            child: event.images.isNotEmpty
                ? PageView.builder(
              itemCount: event.images.length,
              itemBuilder: (context, index) {
                return Image.network(
                  event.images[index],
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(child: CircularProgressIndicator(value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! : null));
                  },
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[300],
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.broken_image, size: 50, color: Colors.grey),
                        Text("Error al cargar imagen", style: TextStyle(color: Colors.grey))
                      ],
                    ),
                  ),
                );
              },
            )
                : Container( // Placeholder si no hay fotos
              color: Colors.grey[200],
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/logo.png', width: 60),
                    const SizedBox(height: 10),
                    const Text("Sin imágenes disponibles", style: TextStyle(color: Colors.grey))
                  ],
                ),
              ),
            ),
          ),

          // 3. Indicador de Severidad Grande
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            color: _getSeverityColor(event.severity).withOpacity(0.2),
            child: Center(
              child: Text(
                "NIVEL DE SEVERIDAD: ${event.severity.toUpperCase()}",
                style: TextStyle(
                  color: _getSeverityColor(event.severity),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),

          // 4. Información Detallada
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info Clave
                _DetailRow(icon: Icons.calendar_today, label: "Fecha:", value: event.date),
                _DetailRow(icon: Icons.location_on, label: "Ubicación:", value: event.location),
                _DetailRow(icon: Icons.source, label: "Fuente:", value: event.source),

                const SizedBox(height: 20),
                const Text("Descripción del Evento", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text(
                  event.description,
                  style: const TextStyle(fontSize: 14, height: 1.5, color: Colors.black87),
                  textAlign: TextAlign.justify,
                ),

                const SizedBox(height: 30),

                // Botón Ver en Mapa
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[800],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.map),
                    label: const Text("VER UBICACIÓN EN EL MAPA"),
                    onPressed: () {
                      if (widget.onMapRequest != null) {
                        widget.onMapRequest!(event.coords);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Mapa no disponible")));
                      }
                    },
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGETS AUXILIARES Y CLASES PRIVADAS ---

  Widget _buildEmergencySection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFCF0A2C),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Canales Oficiales", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _EmergencyButton(
                icon: Icons.local_police,
                label: "Policía",
                number: "105",
                onTap: () => _launchURL("tel:105"),
              ),
              _EmergencyButton(
                icon: Icons.fire_truck,
                label: "Bomberos",
                number: "116",
                onTap: () => _launchURL("tel:116"),
              ),
              _EmergencyButton(
                icon: Icons.support_agent,
                label: "INDECI",
                number: "115",
                onTap: () => _launchURL("tel:115"),
              ),
              _EmergencyButton(
                icon: Icons.language,
                label: "Web",
                number: "Info",
                onTap: () => _launchURL("https://www.gob.pe/indeci"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'Alta': return Colors.red;
      case 'Media': return Colors.orange;
      default: return Colors.green;
    }
  }
} // <--- FIN DE LA CLASE _HistoryScreenState

// --- CLASES AUXILIARES FUERA DEL STATE ---

class _EmergencyButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String number;
  final VoidCallback onTap;

  const _EmergencyButton({required this.icon, required this.label, required this.number, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 5),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
          Text(number, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final HuaycoEvent event;
  final Function(LatLng)? onMap; // Opcional si queremos botón directo en tarjeta
  final VoidCallback? onTap; // Callback para abrir detalle

  const _EventCard({required this.event, this.onMap, this.onTap});

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'Alta': return Colors.red;
      case 'Media': return Colors.orange;
      default: return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Al tocar la tarjeta, ejecuta la acción
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, 3))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabecera
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _getSeverityColor(event.severity).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "Severidad: ${event.severity}",
                    style: TextStyle(color: _getSeverityColor(event.severity), fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                Text(event.date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 10),

            // Título
            Text(event.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),

            // Ubicación
            Row(
              children: [
                const Icon(Icons.location_on, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(event.location, style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 10),

            // Descripción Corta
            Text(
              event.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),

            const SizedBox(height: 10),
            // Link falso "Ver más"
            const Align(
              alignment: Alignment.centerRight,
              child: Text("Ver detalles >", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 10),
          SizedBox(
            width: 80,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}