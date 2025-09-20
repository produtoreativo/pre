# Baixa e inicia o container do SonarQube
docker run -d --name sonarqube \
  -p 9000:9000 \
  -e SONAR_ES_BOOTSTRAP_CHECKS_DISABLE=true \
  sonarqube:community

open http://localhost:9000

# user e senha é admin
# troco para @Fu147/258*369