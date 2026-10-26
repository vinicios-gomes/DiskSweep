# DiskSweep

<img src="Resources/AppIcon-1024.png" width="128" align="right" alt="Ícone do DiskSweep">

App nativo para macOS (SwiftUI + Swift Package Manager) que mostra o quanto o disco está cheio e ajuda a
recuperar espaço: caches de desenvolvimento, imagens Docker, simuladores iOS, `node_modules`, logs e mais.
Cada item pode ser aberto e detalhado, para você escolher exatamente o que apagar.

🇺🇸 [Read in English](README.md)

> ⚠️ **O DiskSweep apaga arquivos.** Nada é removido sem confirmação explícita e cada item mostra antes o que
> será afetado. Mesmo assim, revise cada lista e mantenha backup do que for importante.
> Fornecido "como está", sem garantias (veja [LICENSE](LICENSE)).

## Recursos
- Espaço livre em tempo real, gráfico de histórico de uso e item na barra de menu.
- Mais de 25 limpezas: caches de npm/Yarn/pnpm/pip/Gradle/CocoaPods, DerivedData do Xcode, simuladores iOS,
  Docker, Homebrew, caches de navegador, logs, Lixeira, Downloads, busca de `node_modules` e explorador de pastas grandes.
- **Drill-down**: abra qualquer item, navegue por subpastas, marque entradas individuais e apague só elas.
- Diálogo de confirmação nativo e indicador de progresso durante a exclusão.
- Também funciona no terminal (`scripts/clean-cli.sh`).

## Requisitos
macOS 14+ e Swift 5.10+ (Xcode ou Command Line Tools). Alguns locais (ex.: `~/Library/Containers`) podem exigir
**Acesso Total ao Disco** para o app: Ajustes do Sistema → Privacidade e Segurança → Acesso Total ao Disco.

## Compilar e executar
```bash
git clone https://github.com/vinicios-gomes/DiskSweep.git
cd DiskSweep
./scripts/run-app.sh      # compila build/DiskSweep.app e abre
./scripts/build-app.sh    # só compila
./scripts/clean-cli.sh    # menu de terminal
swift build && swift test # SwiftPM puro (requer toolchain completo / Xcode)
```

## Estrutura, como adicionar limpezas e segurança
Veja [Docs/ARCHITECTURE.md](Docs/ARCHITECTURE.md) e [CONTRIBUTING.md](CONTRIBUTING.md).

## Licença
[MIT](LICENSE)
