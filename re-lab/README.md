# Reverse Engineering Lab

A containerized, free-to-run reverse engineering practice lab with Python, Go, native binaries, and a free cloud emulator (LocalStack).

## Features
- Ubuntu 24.04 dev container with Python 3, Go, gdb+pwndbg, radare2/rizin
- Python tooling: pwntools, angr, r2pipe, gdbgui, decompyle3, pycdc
- Go debugging: delve (`dlv`)
- LocalStack (free AWS emulator): S3, SQS, Lambda, DynamoDB, etc.
- Sample challenges: C crackme, Go obfuscation, Python bytecode

## Prereqs
- Docker and Docker Compose

## Quick start
```bash
cd re-lab
docker compose build
docker compose up -d localstack
# then open a shell in the dev container
docker compose run --rm redev bash
```

Inside the container:
```bash
# Build samples
make
# Run C crackme
./build/c/crackme1
# Run Go sample
./build/go/obf
# Inspect Python bytecode
python3 -m dis samples/python/sample.py
```

## Cloud emulator (LocalStack)
From host or inside container:
```bash
# List services health
curl -s localhost:4566/health | jq

# Configure AWS env (no real creds needed)
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=us-east-1

# Create an S3 bucket and put/list objects
awslocal s3 mb s3://re-lab-bucket
awslocal s3 cp README.md s3://re-lab-bucket/README.md
awslocal s3 ls s3://re-lab-bucket
```

If `awslocal` is not on PATH, use `aws --endpoint-url=http://localhost:4566`.

## Optional: Ghidra
To install Ghidra inside the container:
```bash
sudo /workspace/scripts/install_ghidra.sh
# then
ghidra
```

## Tools overview
- gdb + pwndbg: dynamic analysis, breakpoints, memory inspection
- radare2 / rizin: static/dynamic analysis, graphs
- angr: symbolic execution (Python)
- pwntools: exploit scripting (CTF-friendly)
- delve (`dlv`): Go debugging

## Practice ideas
- Reverse `samples/c/crackme1` and recover the password
- Deobfuscate `samples/go/obf` to find valid input
- Analyze Python function `secret` and derive satisfying input; inspect bytecode
- Use `strace`/`ltrace` on binaries; compare behavior
- Disassemble with `r2 -A` and explore call graphs; then step with gdb
- Create S3 objects in LocalStack and write a minimal client in Python/Go; intercept requests

## Free learning resources
- Practical Malware Analysis Labs: `https://github.com/malware-unicorn/practical-malware-analysis-labs`
- x86-64 Assembly (UoW) notes: `https://cs.brown.edu/courses/cs033/docs/guides/x64_cheatsheet.pdf`
- Pwndbg docs: `https://github.com/pwndbg/pwndbg`
- Radare2 book: `https://radare.gitbooks.io/radare2book/`
- Rizin docs: `https://rizin.re/docs.html`
- Angr docs: `https://docs.angr.io/`
- Ghidra: `https://ghidra-sre.org/`
- LocalStack: `https://docs.localstack.cloud/`
- AWS re:Invent free videos: `https://www.youtube.com/@AWSEventsChannel`

## Notes
- The image uses distro `golang`; override with mounted toolchain if needed.
- Container grants `SYS_PTRACE` and unconfined seccomp to allow debuggers.
- For GUI tools like Ghidra, consider X11 forwarding or VSCode remote X server.
