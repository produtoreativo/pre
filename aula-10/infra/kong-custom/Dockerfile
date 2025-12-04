# Use a imagem oficial do Kong como base
FROM kong:3.8

# Troca para root para instalar dependências do sistema
USER root

# Atualiza e instala ferramentas de build e dependências para luarocks / compilação nativa
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      build-essential \
      gcc \
      make \
      wget \
      unzip \
      libssl-dev \
      libpcre3-dev \
      luarocks \
      ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Opcional: copie um arquivo com versões de rocks (se quiser pinagem)
# COPY luarocks-versions.txt /tmp/luarocks-versions.txt

# Instala plugins via luarocks
# Substitua/adicione nomes e versões conforme seu plugin real
RUN luarocks install kong-opa || echo "kong-opa install failed" && \
    luarocks install kong-oidc || echo "kong-oidc install failed"

# Se precisar instalar outras dependências que os plugins requisitam, adicione aqui.
# Exemplo (se seu plugin exigir lua-cjson):
# RUN luarocks install lua-cjson

# Permite que o processo volte a rodar como usuário kong (boa prática)
USER kong

# Entrypoint padrão do Kong (mantemos o mesmo)
CMD ["docker-entrypoint.sh", "kong", "docker-start"]