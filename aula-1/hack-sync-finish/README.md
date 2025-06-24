

## Instalar o Github CLI

Seguir as instruções em https://cli.github.com/

Criar um Personal token no github em https://github.com/settings/tokens. Sugestão de criar um Personal access Tokens (classic) com curta duração para as validações e testes desse exemplo.

🔐 Autenticação

Depois de instalado, autentique com:

```sh
gh auth login
# Exemplo de escolhas
# > GitHub.com
#  HTTPS
#> SSH
#> /Users/christiano.m.almeida/.ssh/id_ed25519.pub
# ? Title for your SSH key: (GitHub CLI) [DEIXA EM BRANCO]
# > Paste an authentication token
# ? Paste your authentication token: [COLAR O TOKEN AQUI]
```

Pode testar o status com:
```sh
› gh auth status
#github.com
#  ✓ Logged in to github.com account cmilfont (keyring)
#  - Active account: true
#  - Git operations protocol: ssh
#  - Token: ghp_************************************
#  - Token scopes: 'admin:enterprise', 'admin:gpg_key', 'admin:org', 'admin:org_hook', 'admin:public_key', 'admin:repo_hook', 'admin:ssh_signing_key', 'audit_log', 'codespace', 'copilot', 'delete:packages', 'delete_repo', 'gist', 'notifications', 'project', 'repo', 'user', 'workflow', 'write:discussion', 'write:network_configurations', 'write:packages'
```

## Fluxo Hack Sync Finish

### hack

Listando as issues:

```sh
gh issue list --label "bug" --assignee "@me"
```

```md
Showing 1 of 1 issue in produtoreativo/pre that matches your search

ID  TITLE                                    LABELS  UPDATED             
#1  Alerta do NewRelic não está funcionando  bug     about 14 minutes ago
```