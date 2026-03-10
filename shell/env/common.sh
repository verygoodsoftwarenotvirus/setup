# Cross-platform environment variables

# Go binaries (journal, etc.) - go install puts binaries in $GOPATH/bin
export GOPATH="${GOPATH:-$HOME/go}"
export PATH="$GOPATH/bin:$PATH"

# Add setup scripts to PATH if you have any
# export PATH="$SETUP_DIR/scripts:$PATH"
