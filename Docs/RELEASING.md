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
   - cria a GitHub Release com notas automáticas. Tags com sufixo (`v1.2.0-rc1`) viram *pre-release*.

## Gerar o .dmg localmente

```bash
VERSION=1.2.0 ./scripts/build-app.sh
VERSION=1.2.0 ./scripts/make-dmg.sh      # → build/DiskSweep-1.2.0.dmg + .sha256
```

## Assinatura e notarização

Hoje o app usa **assinatura ad hoc**: o macOS mostra um aviso na primeira abertura (clique direito → Abrir, ou
`xattr -dr com.apple.quarantine /Applications/DiskSweep.app`). Para distribuição sem aviso é preciso uma conta Apple Developer:

1. Exporte o certificado *Developer ID Application* como `.p12` e guarde em Secrets (`DEVELOPER_ID_CERT_BASE64`, `DEVELOPER_ID_CERT_PASSWORD`).
2. No `release.yml`, importe-o num keychain temporário antes do build e exporte `CODESIGN_IDENTITY="Developer ID Application: Seu Nome (TEAMID)"` — o `build-app.sh` já usa essa variável.
3. Notarize o `.dmg` com `xcrun notarytool submit ... --wait` e `xcrun stapler staple`.

## Se um check for renomeado
O ruleset `prod` exige os checks pelo nome (`Lint`, `Unit Tests`). Ao renomear jobs, atualize em Settings → Rules → Rulesets → prod.
