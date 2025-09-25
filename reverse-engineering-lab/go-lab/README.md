# Go Reverse Engineering Lab

This lab focuses on reverse engineering Go binaries, understanding Go runtime, and analyzing Go-specific patterns.

## 🐹 Topics Covered

1. **Binary Analysis**
   - Go binary structure
   - ELF analysis
   - Symbol table analysis

2. **Runtime Analysis**
   - Go runtime internals
   - Garbage collector analysis
   - Goroutine analysis

3. **Static Analysis**
   - String extraction
   - Function analysis
   - Import analysis

4. **Dynamic Analysis**
   - Debugging Go binaries
   - Memory analysis
   - Runtime manipulation

## 📁 Exercise Structure

- `beginner/` - Basic binary analysis
- `intermediate/` - Runtime analysis
- `advanced/` - Advanced techniques
- `tools/` - Analysis scripts
- `samples/` - Practice binaries

## 🛠️ Required Tools

```bash
# Install Go tools
go install github.com/go-delve/delve/cmd/dlv@latest

# System tools
sudo apt-get install binutils objdump strings hexdump
```

## 🚀 Getting Started

1. Start with `beginner/binary_analysis.go`
2. Learn Go-specific patterns
3. Practice with `samples/` directory
4. Use `tools/` for analysis