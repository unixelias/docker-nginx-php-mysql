# Makefile for Docker Nginx PHP Composer MySQL

include lemp-stack/.env

# MySQL
MYSQL_DUMPS_DIR=lemp-stack/db/dumps

help:
	@echo ""
	@echo "usage: make COMMAND"
	@echo ""
	@echo "Commands:"
	@echo "  apidoc              Generate documentation of API"
	@echo "  code-sniff          Check the API with PHP Code Sniffer (PSR2)"
	@echo "  clean               Clean directories for reset"
	@echo "  composer-up         Update PHP dependencies with composer"
	@echo "  docker-start        Create and start containers"
	@echo "  docker-stop         Stop and clear all services"
	@echo "  gen-certs           Generate SSL certificates"
	@echo "  logs                Follow log output"
	@echo "  mysql-dump          Create backup of whole database"
	@echo "  mysql-restore       Restore backup from whole database"
	@echo "  test                Test application"

init:
	@$(shell cp -n $(shell pwd)/lemp-stack/web/app/composer.json.dist $(shell pwd)/lemp-stack/web/app/composer.json 2> /dev/null)

apidoc:
	@cd lemp-stack && docker-compose exec -T php $(BACKEND_DIR)/vendor/bin/apigen generate app/src --destination app/doc
	@make resetOwner

clean:
	@rm -Rf lemp-stack/db/data/mysql/*
	@rm -Rf $(MYSQL_DUMPS_DIR)/*
	@rm -Rf lemp-stack/web/app/vendor
	@rm -Rf lemp-stack/web/app/composer.lock
	@rm -Rf lemp-stack/web/app/doc
	@rm -Rf lemp-stack/web/app/report
	@rm -Rf lemp-stack/etc/ssl/*

code-sniff:
	@echo "Checking the standard code..."
	@cd lemp-stack && docker-compose exec -T php $(BACKEND_DIR)/vendor/bin/phpcs -v --standard=PSR2 app/src

composer-up:
	@docker run --rm -v $(BACKEND_DIR):/app composer update

docker-start: init
	cd lemp-stack && docker-compose up -d

docker-stop:
	@cd lemp-stack && docker-compose down -v
	@make clean

gen-certs:
	@docker run --rm -v $(shell pwd)/etc/ssl:/certificates -e "SERVER=$(NGINX_HOST)" jacoelho/generate-certificate

logs:
	@cd lemp-stack && docker-compose logs -f

mysql-dump:
	@mkdir -p $(MYSQL_DUMPS_DIR)
	@docker exec $(shell cd lemp-stack && docker-compose ps -q mysql) mysqldump --all-databases -u"$(MYSQL_ROOT_USER)" -p"$(MYSQL_ROOT_PASSWORD)" > $(MYSQL_DUMPS_DIR)/db.sql 2>/dev/null
	@make resetOwner

mysql-restore:
	@docker exec -i $(shell cd lemp-stack && docker-compose ps -q mysql) mysql -u"$(MYSQL_ROOT_USER)" -p"$(MYSQL_ROOT_PASSWORD)" < $(MYSQL_DUMPS_DIR)/db.sql 2>/dev/null

test: code-sniff
	@cd lemp-stack && docker-compose exec -T php $(BACKEND_DIR)/vendor/bin/phpunit --colors=always --configuration ./lemp-stack/web/app/
	@make resetOwner

resetOwner:
	@$(shell chown -Rf $(SUDO_USER):$(shell id -g -n $(SUDO_USER)) $(MYSQL_DUMPS_DIR) "$(shell pwd)/etc/ssl" "$(shell pwd)/lemp-stack/web/app" 2> /dev/null)

.PHONY: clean test code-sniff init