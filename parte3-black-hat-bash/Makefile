# Makefile — Parte 3 Black Hat Bash

.PHONY: deploy test logs down clean offensive

deploy:
	docker compose --env-file .env up -d --build

test:
	./tests/test-containers.sh
	./tests/test-networks.sh
	./tests/test-offensive.sh

offensive:
	docker compose exec attacker bash /lab/offensive/exploit.sh

logs:
	docker compose logs -f

down:
	docker compose down -v

clean: down
	docker system prune -f
