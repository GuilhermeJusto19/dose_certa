# Dose Certa

Aplicativo móvel/web para gerenciamento de medicação e lembretes.

Este repositório contém o código-fonte do projeto "Dose Certa": um app Flutter
que ajuda pacientes e cuidadores a gerenciar medicamentos, consultas e
notificações. O projeto utiliza Firebase (Auth + Firestore) para persistência
remota, Hive para lembretes locais e um padrão arquitetural MVVM.

**Status:** Concluido/Em melhoria.

**Stack principal:** Flutter, Dart, Firebase (Auth / Firestore), Hive,
flutter_local_notifications, timezone.

## Pré-requisitos

- Flutter SDK (versão compatível recomendada: 3.x ou superior)
- Android SDK (para builds Android)
- Xcode (macOS) para builds iOS
- Git

## Configuração local (rápido)

Clone o repositório, troque para a branch de desenvolvimento e instale as
dependências:

```powershell
git clone <repo-url>
cd dose_certa
git checkout feature/view-clinica-web
flutter pub get
```

Arquivos de configuração do Firebase não são versionados — adicione-os em:

- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`

Se seu projeto usa `local.properties` para caminhos do SDK Android, garanta
que ele esteja configurado corretamente.

## Arquitetura e organização

O projeto segue MVVM (Model — View — ViewModel) com as seguintes pastas
principais:

- `lib/viewmodels/` — ViewModels (estado e lógica de apresentação)
- `lib/Views/` ou `lib/Features/` — telas e widgets (UI)
- `lib/Models/` — modelos de dados, repositórios e data sources
- `lib/Services/` — serviços cross-cutting (notificações, background, etc.)

Estratégia de persistência:

- Firestore: dados sincronizados por usuário (medicamentos, consultas, tarefas)
- Hive: lembretes e cache local para notificações

## Contato / Autoria

Projeto mantido por Guilherme Justo.
