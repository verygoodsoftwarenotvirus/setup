# Cross-platform environment variables

# User-local binaries (browsh, etc. from make setup)
export PATH="${HOME}/.local/bin:$PATH"
# Go binaries (journal, etc.) - go install puts binaries in $GOPATH/bin
export GOPATH="${GOPATH:-$HOME/go}"
export PATH="$GOPATH/bin:$PATH"

# Add setup scripts to PATH if you have any
# export PATH="$SETUP_DIR/scripts:$PATH"
