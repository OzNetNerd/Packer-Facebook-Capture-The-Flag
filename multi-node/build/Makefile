.PHONY: build-hhvm
build-hhvm:
	@packer validate configs/hhvm-node.json
	@packer build configs/hhvm-node.json

.PHONY: build-memcached
build-memcached:
	@packer validate configs/memcached-node.json
	@packer build configs/memcached-node.json

.PHONY: build-mysql
build-mysql:
	@packer validate configs/mysql-node.json
	@packer build configs/mysql-node.json

.PHONY: build-nginx
build-nginx:
	@packer validate configs/nginx-node.json
	@packer build configs/nginx-node.json

.PHONY: build-all
build-all: | build-hhvm build-memcached build-nginx build-mysql