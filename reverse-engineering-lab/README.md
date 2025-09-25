# Reverse Engineering Practice Lab

A comprehensive environment for practicing reverse engineering with Python, Go, and Cloud technologies using free resources.

## 🎯 Learning Objectives

- **Python Reverse Engineering**: Bytecode analysis, obfuscation techniques, malware analysis
- **Go Reverse Engineering**: Binary analysis, static/dynamic analysis, Go-specific patterns
- **Cloud Security**: Container security, API analysis, infrastructure reverse engineering

## 📁 Lab Structure

```
reverse-engineering-lab/
├── python-lab/           # Python reverse engineering exercises
├── go-lab/              # Go reverse engineering exercises  
├── cloud-lab/           # Cloud security and reverse engineering
├── tools/               # Free tools and utilities
├── docker/              # Containerized practice environments
├── challenges/          # Progressive difficulty challenges
└── resources/           # Learning materials and references
```

## 🚀 Quick Start

1. **Setup Environment**:
   ```bash
   cd reverse-engineering-lab
   ./setup.sh
   ```

2. **Start with Python Lab**:
   ```bash
   cd python-lab
   python beginner_exercises.py
   ```

3. **Docker Environment** (Recommended):
   ```bash
   docker-compose up -d
   ```

## 📚 Learning Path

### Phase 1: Fundamentals (Week 1-2)
- [ ] Python bytecode analysis
- [ ] Basic binary analysis tools
- [ ] Understanding assembly basics

### Phase 2: Intermediate (Week 3-4)
- [ ] Go binary reverse engineering
- [ ] Dynamic analysis techniques
- [ ] Cloud API analysis

### Phase 3: Advanced (Week 5-6)
- [ ] Malware analysis
- [ ] Container security
- [ ] Infrastructure reverse engineering

## 🛠️ Free Tools Included

- **Python**: uncompyle6, pyinstxtractor, dis
- **Go**: gobjdump, strings, hexdump
- **Cloud**: kubectl, docker, terraform
- **General**: radare2, ghidra, wireshark

## 📖 Resources

- [Free Reverse Engineering Courses](resources/courses.md)
- [CTF Platforms](resources/ctf-platforms.md)
- [Tool Documentation](resources/tools.md)
- [Practice Challenges](challenges/README.md)

## ⚠️ Legal Notice

This lab is for educational purposes only. Always ensure you have permission before reverse engineering any software or systems.