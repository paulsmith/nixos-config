export PS1="\[\e[1;34m\]\W\[\e[0m\] \[\e[1;\$(if [ \$? -ne 0 ]; then echo 31; else echo 33; fi)m\]\$\[\e[0m\] "

export MANPATH=$(xcode-select --show-manpaths | tr '\n' ':')

# Ghostty shell integration
if [ -n "$GHOSTTY_RESOURCES_DIR" ]; then
    builtin source "${GHOSTTY_RESOURCES_DIR}/shell-integration/bash/ghostty.bash"
fi

function t {
    pushd $(mktemp -d -p /tmp -q "${1}.XXXXXX")
}

# uv https://docs.astral.sh/uv/getting-started/installation/#shell-autocompletion
if command -v uv >/dev/null; then
    eval "$(uv generate-shell-completion bash)"
fi

if command -v uvx >/dev/null; then
    eval "$(uvx --generate-shell-completion bash)"
fi

google() {
    claude --allowedTools=web_search -p "Search google for <query>$1</query> and summarize the results"
}
