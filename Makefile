.PHONY: test test-file install-hooks check clean autogen

test:
	nvim --headless --noplugin -u test/minimal_init.lua -c "lua require(\"plenary.test_harness\").test_directory_command('test/spec {minimal_init = \"test/minimal_init.lua\"}')"

test-file:
	nvim --headless --noplugin -u test/minimal_init.lua -c "lua require(\"plenary.busted\").run(\"$(FILE)\")"

install-hooks:
	pre-commit install --install-hooks

check:
	pre-commit run --all-files

clean:
	rm -rf .tests/

# do not run manually! (runs via CI)
autogen:
	bash scripts/autogen.sh
