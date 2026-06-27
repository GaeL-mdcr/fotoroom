import 'package:flutter/material.dart';

import '../editor/editor_page.dart';
import '../projects/projects_page.dart';
import '../settings/settings_page.dart';

/// Tela principal de navegação do FotoRoom.
///
/// Ela organiza as abas principais da interface e preserva o estado visual de
/// cada seção sem concentrar regras de negócio da aplicação.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _indiceAtual = 0;

  void _alterarPagina(int novoIndice) {
    setState(() {
      _indiceAtual = novoIndice;
    });
  }

  @override
  Widget build(BuildContext context) {
    final paginas = [
      ProjectsPage(
        onOpenProject: () {
          _alterarPagina(1);
        },
      ),
      const EditorPage(),
      const SettingsPage(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _indiceAtual,
        children: paginas,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indiceAtual,
        onDestinationSelected: _alterarPagina,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.folder_outlined),
            selectedIcon: Icon(Icons.folder),
            label: 'Projetos',
          ),
          NavigationDestination(
            icon: Icon(Icons.edit_outlined),
            selectedIcon: Icon(Icons.edit),
            label: 'Editor',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'ConfiguraÃ§Ãµes',
          ),
        ],
      ),
    );
  }
}
