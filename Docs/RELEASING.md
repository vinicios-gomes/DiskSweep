# Processo de release

`main` é a branch de produção e é protegida (ruleset `prod`): tudo entra por Pull Request com **Lint** e **Unit Tests** verdes
(merge por squash ou rebase — histórico linear). Uma release é uma **tag `vX.Y.Z` criada a partir da `main`**.

## Fluxo

```
branch de trabalho ──► Pull Request ──► Lint + Unit Tests ──► merge na main
                                                                  │
                                       ./scripts/release.sh X.Y.Z │  (cria e envia a tag vX.Y.Z)
                                                                  ▼
                 workflow Release: valida tag na main → testes → build do app → .dmg + .sha256 → GitHub Release
```

1. Trabalhe numa branch (`feat/...`, `fix/...`) e abra um PR para a `main`.
2. Os workflows **Lint** (`.github/workflows/lint.yml`) e **Unit Tests** (`tests.yml`) rodam no PR; o merge só é liberado com ambos verdes.
3. Após o merge, atualize a `main` local e rode `./scripts/release.sh 1.2.0`. O script exige estar na `main`, sem alterações e igual ao `origin/main`, e pede confirmação.
4. O workflow **Release** (`release.yml`) dispara pela tag:
   - recusa tags fora da `main`;
   - roda `swift test`;
   - compila o app com a versão da tag (`CFBundleShortVersionString`) e o número do run (`CFBundleVersion`);
   - gera `DiskSweep-X.Y.Z.dmg` (com atalho para Applications) e o `.sha256`;
   - cria a GitHub Release com notas automáticas. Tags com sufixo (`./scripts/release.sh 0.1.0-rc.1`) viram *pre-release*; o app grava só `0.1.0` como versão do bundle.

## Gerar o .dmg localmente

```bash
VERSION=1.2.0 ./scripts/build-app.sh
VERSION=1.2.0 ./scripts/make-dmg.sh      # → build/DiskSweep-1.2.0.dmg + .sha256
```

## Assinatura e notarização

Hoje o app usa **assinatura ad hoc**: o macOS mostra um aviso na primeira abertura (Ajustes do Sistema → Privacidade e Segurança → Abrir Mesmo Assim, ou
`xattr -dr com.apple.quarantine /Applications/DiskSweep.app`; o clique direito → Abrir não funciona mais no macOS recente). Para distribuição sem aviso é preciso uma conta Apple Developer:

1. Exporte o certificado *Developer ID Application* como `.p12` e guarde em Secrets (`DEVELOPER_ID_CERT_BASE64`, `DEVELOPER_ID_CERT_PASSWORD`).
2. No `release.yml`, importe-o num keychain temporário antes do build e exporte `CODESIGN_IDENTITY="Developer ID Application: Seu Nome (TEAMID)"` — o `build-app.sh` já usa essa variável.
3. Notarize o `.dmg` com `xcrun notarytool submit ... --wait` e `xcrun stapler staple`.

## Se um check for renomeado
O ruleset `prod` exige os checks pelo nome (`Lint`, `Unit Tests`). Ao renomear jobs, atualize em Settings → Rules → Rulesets → prod.

## Distribuição pelo Homebrew Cask

O app é distribuído por um tap próprio: [`vinicios-gomes/homebrew-disksweep`](https://github.com/vinicios-gomes/homebrew-disksweep).

- O cask (`Casks/disksweep.rb`) aponta para o `.dmg` da GitHub Release e confere o `sha256`; o `postflight_steps` remove a
  quarentena porque o app não é notarizado.
- O workflow `bump.yml` do tap roda a cada 6 horas (ou manualmente) e atualiza `version` e `sha256` para a release mais recente.
  Não usa segredos: lê as releases públicas e o arquivo `.dmg.sha256` anexado pelo workflow Release.
- Não há passo extra no processo de release: criar a tag basta; o tap acompanha sozinho.
- Para instalar (Homebrew 7+ exige confiar em casks de terceiros):
  ```bash
  brew tap vinicios-gomes/disksweep
  brew trust --cask vinicios-gomes/disksweep/disksweep
  brew install --cask disksweep
  ```
