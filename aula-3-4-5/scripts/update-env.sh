#!/bin/bash
set -e  # para parar se algo der errado

source ~/.nvm/nvm.sh

# echo "Versão atual do nvm"
# nvm -v

# echo "Baixar e instalar a última versão do nvm"
# curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash

# echo "Carregar nvm"
# source ~/.nvm/nvm.sh
# echo "Versão do nvm após a instalação"
# nvm -v

# echo "Instalando a versão 22 do Node.js no último patch"
# nvm install 22
# nvm alias default 22
# nvm use 22

# echo "Instalando o npm-check-updates"
# npm install -g npm-check-updates
# echo "Versão do npm-check-updates"
# ncu -v

echo "-------- INICIANDO UPGRADE NO REPO --------"

echo "Resetando alterações no repositório"
git reset --hard HEAD
git clean -f -d

echo "Habilitando o Corepack"
corepack enable
echo "Preparando o Yarn sem perguntar nada"
yes | corepack prepare yarn@stable --activate
yarn set version berry
echo "Forçar Yarn a usar node_modules"
cat > .yarnrc.yml <<EOL
nodeLinker: node-modules
EOL

echo "Versão do Yarn"
yarn -v

echo "Atualizando as dependências do projeto"
ncu -u

echo "Removendo o caractere ^ das dependências"
node -e "
const fs = require('fs');
const pkg = JSON.parse(fs.readFileSync('package.json', 'utf8'));
['dependencies','devDependencies','peerDependencies'].forEach(s=>{
  if(pkg[s]) Object.keys(pkg[s]).forEach(dep=>{
    pkg[s][dep] = pkg[s][dep].replace(/^\^/, '');
  });
});
fs.writeFileSync('package.json', JSON.stringify(pkg, null, 2) + '\n');
"

echo "Removendo node_modules e arquivos de lock"
rm -fr node_modules

rm -f package-lock.json
rm -f yarn.lock

echo "Instalando as dependências do projeto"
touch yarn.lock
yarn install