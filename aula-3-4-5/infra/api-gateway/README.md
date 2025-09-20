


curl -i -X POST http://localhost:8001/consumers \
  -d username=admin-portal


curl -X POST http://localhost:8001/consumers/admin-portal/key-auth \
      -d 'key=portal-key' || echo 'key exists'