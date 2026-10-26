# Arquitetura do DiskSweep

## Visão geral

```
 SwiftUI Views ──► ViewModels ──► protocolos (Domain) ◄── Infrastructure ──► shell/cleaners/*.sh
     (UI)         (estado)        CleanerGateway            ShellCleanerGateway     (contrato)
                                  DiskInfoProviding         FileSystemDiskInfo
                                  HistoryStoring            JSONHistoryStore
```

A direção das dependências é sempre para dentro: Views → ViewModels → Domain. `Infrastructure` implementa os
protocolos de `Domain`; só `AppModel.live()` conhece as implementações concretas.

## Camadas Swift (`Sources/DiskSweep`)

| Pasta | Responsabilidade | Arquivos principais |
|---|---|---|
| `App/` | Cena, janela, `MenuBarExtra`; liga o `AppModel` | `DiskSweepApp.swift` |
| `Views/` | Desenho; sem regras de negócio | `ContentView`, `DiskHeaderView`, `CleanerRowView`, `PlanSheetView` |
| `ViewModels/` | Estado observável e fluxo | `AppModel` (disco, histórico, lista), `PlanViewModel` (um item aberto) |
| `Domain/` | Modelos e protocolos | `Cleaner`, `PlanItem`, `CleanerKind`, `CleanerGateway`… |
| `Infrastructure/` | Detalhes externos | `ShellRunner`, `ShellCleanerGateway`, `ToolsLocator`, `FileSystemDiskInfo`, `JSONHistoryStore` |
| `Support/` | Utilitários | `ByteFormat` |

Observação: usa `ObservableObject`/`@Published`/`@StateObject` (e não `@Observable`/`@State`) porque o Command Line
Tools instalado não traz o plugin de macros do SwiftUI. Com Xcode completo dá para migrar.

## Fluxo de uma limpeza

1. `AppModel.reload()` → `gateway.discover()` lista `shell/cleaners/*.sh` (`name`, `kind`).
2. `measureAll()` chama `kb` de cada um (no máximo 4 em paralelo) e preenche os tamanhos.
3. Clicar num item abre `PlanSheetView` → `PlanViewModel.load()` → `gateway.plan(...)` (somente leitura).
4. O usuário marca itens, entra em subpastas (duplo clique) e clica em *Apagar*.
5. Diálogo de confirmação nativo → `gateway.apply(paths)` → o script executa e devolve a saída.
6. `AppModel.remeasure(id)` atualiza tamanho e espaço livre.

## Contrato dos cleaners (`shell/lib/contract.sh`)

Todo `shell/cleaners/NN-nome.sh` responde a:

| Comando | Saída |
|---|---|
| `name` | nome exibido |
| `kind` | `path` · `cmd` · `explore` · `nm` · `items` |
| `kb` | tamanho recuperável em KB (`-1` = desconhecido) |
| `size` | tamanho legível (derivado de `kb`) |
| `plan [dir]` | linhas `kb<TAB>id[<TAB>label]` — **não altera nada** |
| `apply [ids…]` | executa **sem perguntar** (a confirmação é de quem chama) |
| `run` | fluxo interativo de terminal: plan + confirmação + apply |

`id` é um caminho (`path`, `explore`, `nm`) ou um identificador (`items`, ex.: UUID de simulador).

### Kinds (strategies em `shell/lib/`)

| kind | strategy | O que faz | Drill-down |
|---|---|---|---|
| `path` | `strategy_path.sh` | apaga caminhos/globs fixos | sim, nas pastas |
| `cmd` | `strategy_cmd.sh` | roda um comando (ex.: `docker system prune`) | não |
| `explore` | `strategy_explore.sh` | pasta navegável, apaga subitens | sim |
| `nm` | `strategy_nodemodules.sh` | busca `node_modules` nos projetos | não |
| `items` | `strategy_items.sh` | itens por id (simuladores, imagens Docker) | lista plana |

## Como adicionar um item

Crie `shell/cleaners/NN-nome.sh` com `chmod +x`. Exemplos (4 linhas):

```bash
#!/bin/bash
source "$(dirname "$0")/../lib/strategy_path.sh"
CLEANER_NAME="Cache do Yarn"
CLEANER_TARGETS=("$HOME/Library/Caches/Yarn")
cleaner_dispatch "$@"
```

Para itens por id, use `strategy_items.sh` e defina `items_list` e `items_delete` (veja `33-simulators.sh`).
O app e o menu de terminal descobrem o novo item sozinhos; nada em Swift precisa mudar.

## Princípios (SOLID) onde aparecem

- **S**: cada cleaner cuida de um item; `ShellRunner` só executa processos; `ByteFormat` só formata.
- **O**: novo item = novo arquivo; `AppModel` e o menu não mudam.
- **L**: todo cleaner respeita o mesmo contrato, então qualquer um substitui outro.
- **I**: protocolos pequenos (`CleanerGateway`, `DiskInfoProviding`, `HistoryStoring`).
- **D**: ViewModels dependem de protocolos; os testes injetam um `FakeGateway`.

## Segurança

- `fs_safe_rm` só remove dentro de `$HOME` e nunca a própria home.
- `explore`/`path`/`nm` validam que cada caminho está no escopo do item (realpath); `items` só aceita ids presentes na listagem.
- O app nunca apaga sozinho: toda exclusão passa por `confirmationDialog`.

## Build e limitações do ambiente

- `Package.swift` é o projeto. `scripts/build-app.sh` tenta `swift build` e, se o SwiftPM do toolchain não conseguir
  linkar o manifest (problema do Command Line Tools instalado), usa `swiftc` com os mesmos fontes.
- Os testes em `Tests/` usam XCTest, que só existe com Xcode completo; **não foram executados** neste ambiente.
