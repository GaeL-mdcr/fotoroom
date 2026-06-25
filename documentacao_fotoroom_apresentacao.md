# Documentação do Projeto FotoRoom para Apresentação

Documento gerado com base na estrutura atual da pasta `lib` enviada em `lib(2).zip`.

## 1. Visão geral

O FotoRoom é um aplicativo mobile em Flutter para criação de projetos locais de edição de imagem. O usuário cria projetos a partir de imagens da galeria, edita a imagem com `pro_image_editor`, salva a edição localmente e compartilha a imagem final.

A arquitetura foi organizada com MVVM, Provider, Repository Pattern, Services separados e encapsulamento do editor por Adapter e Facade.

## 2. Arquitetura geral

| Camada/Pasta | Responsabilidade |
| --- | --- |
| app | Composição principal do app: Providers, tema e MaterialApp. |
| common | Componentes reutilizáveis, constantes, diálogos e resultado genérico. |
| core | Contratos abstratos centrais, como o adapter do editor. |
| models | Estruturas de dados do domínio e configurações. |
| repositories | Contratos e persistência local de dados. |
| services | Integrações com arquivos, galeria, compartilhamento, regras e editor externo. |
| viewmodels | Estado e ações das telas no padrão MVVM. |
| views | Telas e widgets visuais. |

## 3. Pastas e arquivos

### lib/

| Arquivo | Responsabilidade | O que existe dentro | Como explicar na apresentação |
| --- | --- | --- | --- |
| main.dart | Ponto de entrada do app. | Executa runApp(const AppWidget()). | Mostra que o app começa em uma raiz única e organizada. |

### lib/app/

| Arquivo | Responsabilidade | O que existe dentro | Como explicar na apresentação |
| --- | --- | --- | --- |
| app_widget.dart | Widget raiz do FotoRoom. | Monta MultiProvider, MaterialApp, tema claro/escuro e HomePage. Converte AppThemeMode para ThemeMode. | Mostra a composição principal do aplicativo. |
| app_providers.dart | Centraliza injeção de dependências. | Registra Services, Repositories, Adapter e ViewModels com Provider. Inicializa carregarProjetos() e carregarConfiguracoes(). | Demonstra DIP e baixo acoplamento. |
| app_theme.dart | Centraliza o tema visual. | Define ThemeData light() e dark() usando AppColors. Controla roxo, preto, branco, AppBar, FAB e botões. | Mostra identidade visual isolada da lógica. |

### lib/common/

| Arquivo | Responsabilidade | O que existe dentro | Como explicar na apresentação |
| --- | --- | --- | --- |
| app_colors.dart | Paleta de cores global. | Define primary, primaryDark, primaryLight, background, surface, preto e branco. | Facilita troca de identidade visual. |
| app_spacing.dart | Constantes de espaçamento. | Define small, medium e large. | Evita números mágicos em layouts. |
| app_strings.dart | Textos fixos gerais. | Guarda nome do app e rótulos das abas. | Pode ser expandido para padronização de textos. |
| result.dart | Resultado genérico de operações. | Representa sucesso ou falha com data, error, isSuccess, isFailure, dataOrThrow e errorOrDefault. | Ajuda a tratar regras sem lançar exceções desnecessárias. |

### lib/common/dialogs/

| Arquivo | Responsabilidade | O que existe dentro | Como explicar na apresentação |
| --- | --- | --- | --- |
| confirmation_dialog.dart | Diálogo de confirmação genérico. | showConfirmationDialog retorna bool; usado para confirmar ações como excluir projeto. | Reutilização de UI comum. |
| project_name_dialog.dart | Diálogo para nome de projeto. | showProjectNameDialog retorna String?; valida nome não vazio antes de confirmar. | Usado para criar e renomear projetos. |
| save_edited_image_dialog.dart | Diálogo para salvar edição. | Enum SaveEditedImageMode: overwrite, createNewFile, cancel. Função showSaveEditedImageDialog escolhe sobrescrever ou criar arquivo novo. | Explica o controle de salvamento da imagem editada. |
| unsaved_changes_dialog.dart | Diálogo para alterações não salvas. | Enum UnsavedChangesAction: save, discard, cancel. Função showUnsavedChangesDialog decide o que fazer antes de trocar/fechar projeto. | Protege o usuário contra perda de edição. |

### lib/common/widgets/

| Arquivo | Responsabilidade | O que existe dentro | Como explicar na apresentação |
| --- | --- | --- | --- |
| app_empty_state_widget.dart | Widget reutilizável de estado vazio. | Mostra ícone, título, mensagem e ação opcional. | Usado quando não há projeto ou imagem. |
| app_section_title_widget.dart | Título de seção reutilizável. | Exibe títulos em listas/telas, como Configurações. | Padroniza visual de seções. |

### lib/core/adapters/

| Arquivo | Responsabilidade | O que existe dentro | Como explicar na apresentação |
| --- | --- | --- | --- |
| image_editor_adapter.dart | Contrato abstrato do editor. | Define buildEditor() recebendo imagePath, onImageEditingComplete e onCloseEditor. | Aplica GoF Adapter e DIP: o app não depende direto do plugin. |

### lib/models/

| Arquivo | Responsabilidade | O que existe dentro | Como explicar na apresentação |
| --- | --- | --- | --- |
| project_model.dart | Modelo de domínio de projeto. | Campos: id, name, originalImagePath, editedImagePath, thumbnailPath, createdAt, updatedAt. Métodos: currentImagePath, hasEditedImage, copyWith, toMap, fromMap. | Representa o projeto salvo localmente. |
| app_settings_model.dart | Modelo de configurações. | Enum AppThemeMode e campos themeMode, saveExportHistory, showSystemMessages. Métodos copyWith, toMap, fromMap. | Representa preferências persistidas. |
| editor_state_model.dart | Modelo de estado de edição manual. | Enum EditorFilterType e classe EditorStateModel com brilho, contraste, saturação, filtro, rotação e flip. Inclui serialização e igualdade. | Está preparado para estado de edição próprio ou extensão futura. |

### lib/repositories/

| Arquivo | Responsabilidade | O que existe dentro | Como explicar na apresentação |
| --- | --- | --- | --- |
| project_repository.dart | Interface do repositório de projetos. | Define listarProjetos(), salvarProjeto() e excluirProjeto(). | DIP: ViewModel depende da abstração, não da implementação. |
| project_local_repository.dart | Persistência local de projetos. | Implementa ProjectRepository usando projetos.json. Carrega, salva, atualiza e exclui projetos. Remove diretório do projeto ao excluir. | Repository Pattern aplicado aos projetos. |
| settings_repository.dart | Interface do repositório de configurações. | Define carregarConfiguracoes() e salvarConfiguracoes(). | Permite trocar persistência sem alterar ViewModel. |
| settings_local_repository.dart | Persistência local de configurações. | Implementa SettingsRepository usando configuracoes.json. Usa AppSettingsModel.toMap/fromMap. | Fecha o ciclo de persistência local das preferências. |

### lib/services/

| Arquivo | Responsabilidade | O que existe dentro | Como explicar na apresentação |
| --- | --- | --- | --- |
| file_storage_service.dart | Serviço de arquivos locais. | Cria diretórios, salva imagem original, salva imagem editada, prepara JPG para compartilhamento, lê/escreve arquivos internos e exclui diretórios. | Centraliza acesso ao sistema de arquivos. |
| image_picker_service.dart | Serviço de seleção de imagem. | Usa image_picker para selecionar imagem da galeria com qualidade 100. | Isola dependência do plugin de galeria. |
| project_rules_service.dart | Regras de criação de projeto. | Valida nome e imagem, gera id por timestamp, cria ProjectModel temporário e sugere nome. | Concentra regra de domínio fora da UI. |
| export_rules_service.dart | Regras de exportação/compartilhamento. | Valida se existe caminho de imagem final para exportação. | Evita compartilhar imagem inválida. |
| image_export_service.dart | Prepara imagem para compartilhamento. | Chama FileStorageService.exportarImagemJpg() e registra debugPrint. | Mantém o ExportViewModel limpo. |
| share_service.dart | Serviço de compartilhamento. | Valida arquivo e usa share_plus com ShareParams e XFile. | Isola dependência de compartilhamento. |
| system_message_service.dart | Serviço de mensagens do sistema. | Mostra SnackBars informativos respeitando configuração e sempre mostra erros. | Centraliza feedback visual ao usuário. |

### lib/services/adapters/

| Arquivo | Responsabilidade | O que existe dentro | Como explicar na apresentação |
| --- | --- | --- | --- |
| pro_image_editor_adapter.dart | Adapter concreto do editor. | Implementa ImageEditorAdapter e retorna ProImageEditorFacadeWidget. | Adapta o contrato do app ao plugin real. |

### lib/services/facades/

| Arquivo | Responsabilidade | O que existe dentro | Como explicar na apresentação |
| --- | --- | --- | --- |
| pro_image_editor_facade_widget.dart | Facade do pro_image_editor. | Constrói ProImageEditor.file, define callbacks, tema roxo/escuro, ferramentas disponíveis e estilos de subeditores. | Esconde a complexidade do plugin e integra visualmente ao FotoRoom. |

### lib/viewmodels/

| Arquivo | Responsabilidade | O que existe dentro | Como explicar na apresentação |
| --- | --- | --- | --- |
| project_view_model.dart | Estado e ações da tela Projetos. | Carrega, cria, seleciona, renomeia, exclui e atualiza projetos. Usa ProjectRepository, ImagePickerService, ProjectRulesService e FileStorageService. | Controller MVVM da área de projetos. |
| editor_view_model.dart | Estado e ações da edição aberta. | Guarda projeto atual, imagem original/editada, bytes temporários, alterações não salvas, modo de edição e previewVersion. Salva bytes editados em arquivo. | Controller MVVM do editor. |
| export_view_model.dart | Estado do compartilhamento. | Valida imagem, prepara JPG, chama ShareService, controla compartilhando e mensagemErro. | Controller MVVM do fluxo de compartilhar imagem. |
| settings_view_model.dart | Estado das configurações. | Carrega, altera e persiste tema, histórico de exportação e mensagens do sistema. | Controller MVVM das configurações. |

### lib/views/home/

| Arquivo | Responsabilidade | O que existe dentro | Como explicar na apresentação |
| --- | --- | --- | --- |
| home_page.dart | Tela principal com navegação. | Usa IndexedStack e NavigationBar com Projetos, Editor e Configurações. Ao abrir projeto, muda para a aba Editor. | Mantém estado das abas sem recriar telas. |

### lib/views/projects/

| Arquivo | Responsabilidade | O que existe dentro | Como explicar na apresentação |
| --- | --- | --- | --- |
| projects_page.dart | Tela de listagem de projetos. | Exibe loading, estado vazio, grid de projetos, cria projeto, renomeia, exclui e verifica alterações não salvas antes de abrir outro projeto. | View da área de projetos. |
| project_card_widget.dart | Card visual do projeto. | Mostra miniatura, nome e menu de opções. _ProjectImage renderiza arquivo com ValueKey por updatedAt; _ProjectMenuButton abre renomear/excluir. | Componente visual reutilizável e coeso. |

### lib/views/editor/

| Arquivo | Responsabilidade | O que existe dentro | Como explicar na apresentação |
| --- | --- | --- | --- |
| editor_page.dart | Tela principal de edição. | Mostra estado vazio, cabeçalho do projeto, preview, ações, editor embutido via ImageEditorAdapter, compartilhamento, salvamento e fechamento com confirmação. | View principal do editor, coordenando interação com ViewModels. |
| editor_actions_widget.dart | Botões de ação do editor. | Mostra Editar imagem e Compartilhar imagem, desabilitando compartilhamento durante processo. | Extrai UI repetitiva da EditorPage. |
| editor_preview_widget.dart | Preview da imagem. | Mostra imagem em memória ou arquivo, com InteractiveViewer e fallback se falhar. | Responsável apenas pela visualização da imagem. |
| editor_project_header_widget.dart | Cabeçalho do projeto aberto. | Mostra nome, caminho da imagem, chip “Não salvo” e botão de fechar projeto. | Separa informações do projeto da lógica da tela. |

### lib/views/settings/

| Arquivo | Responsabilidade | O que existe dentro | Como explicar na apresentação |
| --- | --- | --- | --- |
| settings_page.dart | Tela de configurações. | Permite escolher tema, ativar histórico de exportação, ativar mensagens do sistema, restaurar padrão e mostrar informações do app. | View de preferências do usuário. |

## 4. Elementos internos importantes

### ProjectModel

| Elemento interno | Função |
| --- | --- |
| id | Identificador único do projeto. |
| name | Nome exibido ao usuário. |
| originalImagePath | Caminho interno da imagem original. |
| editedImagePath | Caminho da imagem editada, quando existir. |
| thumbnailPath | Caminho usado para miniatura do card. |
| currentImagePath | Retorna imagem editada quando existe; senão retorna original. |
| hasEditedImage | Indica se o projeto possui edição salva. |
| copyWith() | Cria uma cópia alterando campos específicos. |
| toMap()/fromMap() | Serializa e desserializa para JSON local. |

### EditorViewModel

| Elemento interno | Função |
| --- | --- |
| carregarProjeto() | Carrega dados do projeto selecionado para edição. |
| fecharProjeto() | Limpa estado do projeto aberto. |
| iniciarModoEdicao()/fecharModoEdicao() | Controla se o editor embutido está ativo. |
| definirImagemEditada() | Guarda bytes temporários retornados pelo editor e marca alterações não salvas. |
| salvarImagemEditadaEmArquivo() | Envia os bytes para FileStorageService salvar no diretório do projeto. |
| marcarImagemEditadaComoSalva() | Atualiza caminho editado, limpa temporários, fecha edição e força atualização do preview. |
| currentImagePath | Resolve qual imagem deve ser exibida ou compartilhada. |
| podeEditarImagem/podeCompartilharImagem | Getters semânticos para a UI não conhecer detalhes internos. |

### ProjectViewModel

| Elemento interno | Função |
| --- | --- |
| carregarProjetos() | Busca projetos no repository e controla carregando/mensagemErro. |
| criarProjeto() | Valida, copia imagem original para armazenamento interno e salva o projeto. |
| criarProjetoComImagemSelecionada() | Seleciona imagem da galeria e chama criarProjeto(). |
| selecionarProjeto() | Define projeto atual selecionado. |
| renomearProjeto() | Atualiza nome e updatedAt. |
| excluirProjeto() | Remove projeto, arquivos e seleção se necessário. |
| atualizarImagemEditadaDoProjeto() | Atualiza editedImagePath, thumbnailPath e updatedAt. |
| _salvarProjetoERecarregar() | Centraliza salvamento e atualização da lista em memória. |

### ProImageEditorFacadeWidget

| Elemento interno | Função |
| --- | --- |
| build() | Constrói ProImageEditor.file com callbacks e configurações. |
| _buildEditorTheme() | Cria tema escuro/roxo específico para o editor. |
| onImageEditingComplete | Recebe bytes editados e repassa para a tela via callback. |
| onCloseEditor | Fecha modo edição quando usuário cancela/sai. |
| MainEditorConfigs | Define ferramentas principais e comportamento de zoom/subeditor. |
| Paint/Text/Crop/Tune/Filter/Blur configs | Customiza cores e aparência dos subeditores. |
| LayerInteractionConfigs | Customiza cor de seleção e botões de manipulação de camadas. |

### FileStorageService

| Elemento interno | Função |
| --- | --- |
| _obterDiretorioBase() | Obtém diretório de documentos do app. |
| _obterDiretorioDoFotoRoom() | Cria/retorna pasta principal fotoroom. |
| _obterDiretorioDoProjeto() | Cria/retorna pasta específica de um projeto. |
| _obterDiretorioDeExportacoes() | Cria/retorna pasta de exportações. |
| salvarImagemOriginal() | Copia imagem escolhida para o diretório do projeto. |
| salvarImagemEditada() | Grava bytes editados como edited.jpg ou edited_timestamp.jpg. |
| exportarImagemJpg() | Cria arquivo JPG temporário para compartilhar. |
| salvarArquivoInterno()/lerArquivoInterno() | Persiste JSONs internos como projetos.json e configuracoes.json. |
| excluirDiretorioDoProjeto() | Remove arquivos do projeto excluído. |

## 5. Fluxos principais

| Fluxo | Sequência |
| --- | --- |
| Criação de projeto | ProjectsPage → ProjectViewModel.criarProjetoComImagemSelecionada() → ImagePickerService → ProjectRulesService → FileStorageService.salvarImagemOriginal() → ProjectRepository.salvarProjeto() → ProjectLocalRepository grava projetos.json. |
| Abertura de projeto | ProjectsPage verifica alterações não salvas → ProjectViewModel.selecionarProjeto() → EditorViewModel.carregarProjeto() → HomePage muda para aba Editor. |
| Edição de imagem | EditorPage ativa modo edição → ImageEditorAdapter.buildEditor() → ProImageEditorAdapter → ProImageEditorFacadeWidget → pro_image_editor retorna bytes editados. |
| Salvamento da edição | EditorPage recebe bytes → showSaveEditedImageDialog → EditorViewModel.definirImagemEditada() → FileStorageService.salvarImagemEditada() → ProjectViewModel.atualizarImagemEditadaDoProjeto() → EditorViewModel.marcarImagemEditadaComoSalva(). |
| Compartilhamento | EditorPage chama ExportViewModel.compartilharImagem() → ExportRulesService valida → ImageExportService prepara JPG → ShareService chama share_plus. |
| Configurações | SettingsPage altera valores → SettingsViewModel atualiza AppSettingsModel → SettingsRepository salva em configuracoes.json → AppWidget reflete tema e mensagens. |

## 6. Padrões arquiteturais aplicados

| Padrão | Onde aparece | Por que foi usado |
| --- | --- | --- |
| MVVM | Views ficam em lib/views; ViewModels em lib/viewmodels; Models em lib/models. | Separa interface, estado e dados. Facilita manutenção e apresentação. |
| Provider | AppProviders registra Services, Repositories, Adapter e ViewModels. | Permite injeção de dependência e notificação de mudanças com ChangeNotifier. |
| Repository Pattern | ProjectRepository/ProjectLocalRepository e SettingsRepository/SettingsLocalRepository. | Isola persistência local e reduz dependência das ViewModels. |
| GoF Adapter | ImageEditorAdapter + ProImageEditorAdapter. | O app fala com um contrato próprio, não diretamente com pro_image_editor. |
| GoF Facade | ProImageEditorFacadeWidget. | Oculta configurações complexas do plugin e expõe uso simples ao restante do app. |
| Services | FileStorageService, ImagePickerService, ShareService, etc. | Cada integração externa fica isolada e mais fácil de trocar. |

## 7. SOLID

| Princípio | Nome | Aplicação no FotoRoom | Benefício |
| --- | --- | --- | --- |
| SRP | Responsabilidade única | AppTheme cuida do tema; AppProviders das dependências; ViewModels do estado; Services de integrações; Repositories de persistência. | Evita classes gigantes e facilita manutenção. |
| OCP | Aberto para extensão | ImageEditorAdapter permite trocar o motor de edição sem alterar EditorPage. | O app pode evoluir para outro editor no futuro. |
| LSP | Substituição segura | As interfaces ProjectRepository, SettingsRepository e ImageEditorAdapter podem receber outras implementações compatíveis. | Preserva comportamento esperado. |
| ISP | Interfaces pequenas | ProjectRepository tem só operações de projeto; SettingsRepository só operações de configurações; ImageEditorAdapter só constrói editor. | Evita contratos inchados. |
| DIP | Inversão de dependência | ViewModels dependem de abstrações e services injetados via Provider. EditorPage depende de ImageEditorAdapter. | Reduz acoplamento com detalhes concretos. |

## 8. GRASP

| Princípio GRASP | Aplicação no projeto |
| --- | --- |
| Controller | ViewModels coordenam ações da tela sem colocar regra diretamente nos widgets. |
| Information Expert | ProjectRulesService sabe criar projeto; FileStorageService sabe lidar com arquivos; EditorViewModel sabe o estado da edição. |
| Low Coupling | Plugin de edição, galeria, compartilhamento e arquivos ficam isolados em services/adapters/facades. |
| High Cohesion | Arquivos têm responsabilidades específicas: tela, estado, regra, persistência ou integração. |
| Pure Fabrication | Services, Repositories, AppProviders e Facade são classes criadas para organizar o sistema, não entidades do domínio. |
| Indirection | Adapter, Repository e Provider criam camadas intermediárias úteis para reduzir dependência direta. |

## 9. Roteiro de fala para apresentação

| Momento | Fala sugerida |
| --- | --- |
| Abertura | “O FotoRoom é um aplicativo Flutter de edição de imagens com projetos locais. O objetivo foi entregar um app funcional, simples para o escopo acadêmico e com arquitetura organizada.” |
| Arquitetura | “A estrutura principal segue MVVM com Provider. As telas ficam em views, o estado fica em viewmodels, os dados ficam em models, e as integrações externas ficam em services.” |
| Persistência | “Os projetos e configurações são salvos localmente em JSON. Para isso, usei Repository Pattern, separando contrato e implementação local.” |
| Editor externo | “O editor real usa o pacote pro_image_editor, mas ele não fica espalhado pelo sistema. Ele foi encapsulado com Adapter e Facade.” |
| SOLID/GRASP | “A arquitetura evita acoplamento direto com plugins e separa responsabilidades. O AppProviders centraliza a composição, e os ViewModels coordenam as ações da interface.” |
| Fechamento | “A prioridade foi manter o projeto viável para TCC, funcional em Android físico e com qualidade suficiente para manutenção futura.” |

## 10. Decisões de escopo

| Decisão | Justificativa |
| --- | --- |
| Não adicionar login/nuvem agora | Aumenta escopo e risco sem necessidade para o TCC. |
| Não criar editor próprio | O pro_image_editor reduz complexidade e permite foco na arquitetura do app. |
| Manter testes manuais em lotes | Como o computador é limitado, testar a cada três mudanças reduz tempo sem perder controle. |
| Documentar decisões | Ajuda a banca a entender que as escolhas foram intencionais. |

## 11. Pontos fortes para defender

- O app é funcional em dispositivo Android físico.
- O editor externo está encapsulado, reduzindo acoplamento com o plugin.
- Projetos e configurações têm persistência local.
- MVVM separa interface, estado e dados.
- Provider centraliza injeção e atualização de estado.
- Repository Pattern protege a camada de ViewModel da forma concreta de persistência.
- A identidade visual roxa está centralizada em AppColors/AppTheme e na Facade do editor.

## 12. Limitações conscientes

- Não há login, nuvem ou sincronização, pois isso aumentaria o escopo do TCC.
- O app edita uma imagem por vez, simplificando o fluxo e reduzindo risco.
- O editor é externo, mas encapsulado por Adapter e Facade.
- A persistência local usa JSON por simplicidade e adequação ao escopo acadêmico.
