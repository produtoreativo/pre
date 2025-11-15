

```sh
# Usando o node v22.18.0
npm install -g @nestjs/cli

› npx nest g resource group-buying  
# ✔ What transport layer do you use? REST API
# ✔ Would you like to generate CRUD entry points? No
# CREATE src/group-buying/group-buying.controller.spec.ts (628 bytes)
# CREATE src/group-buying/group-buying.controller.ts (248 bytes)
# CREATE src/group-buying/group-buying.module.ts (292 bytes)
# CREATE src/group-buying/group-buying.service.spec.ts (496 bytes)
# CREATE src/group-buying/group-buying.service.ts (95 bytes)
# UPDATE src/app.module.ts (668 bytes)

npm run test:e2e -- test/group-buying/formacao-grupo.e2e-spec.ts


npm install -D @stoplight/prism-cli

# npx prism mock test/group-buying/openapi/swagger.json -p 4010
npx prism mock test/group-buying/openapi/swagger.json -p 4010 --errors

npx prism mock test/group-buying/openapi/swagger.json -p 4010 --errors --dynamic false

npx ts-node -r tsconfig-paths/register scripts/swagger.ts

```
