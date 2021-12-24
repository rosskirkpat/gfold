MAKEPATH := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
NEW := $(MAKEPATH)/target/release/gfold
INSTALLED := $(shell which gfold)

.DEFAULT_GOAL := prepare

prepare: fmt
	cd $(MAKEPATH); cargo update
	cd $(MAKEPATH); cargo fix --edition-idioms --allow-dirty --allow-staged
	cd $(MAKEPATH); cargo clippy --all-features --all-targets
.PHONY: prepare

fmt:
	cd $(MAKEPATH); cargo +nightly fmt
.PHONY: fmt

ci:
	cd $(MAKEPATH); cargo +nightly fmt --all -- --check
	cd $(MAKEPATH); cargo clippy -- -D warnings
	cd $(MAKEPATH); cargo test -- --nocapture
.PHONY: ci

release:
	cd $(MAKEPATH); cargo build --release
.PHONY: release

build: release
.PHONY: build

scan:
	cd $(MAKEPATH); cargo +nightly udeps
	cd $(MAKEPATH); cargo bloat --release
	cd $(MAKEPATH); cargo bloat --release --crates
	cd $(MAKEPATH); cargo audit
.PHONY: scan

bench-loosely:
	@echo "============================================================="
	@time $(INSTALLED) ~/
	@echo "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	@time $(NEW) ~/
	@echo "============================================================="
	@du -h $(INSTALLED)
	@du -h $(NEW)
.PHONY: bench-loosely