import sys

def secret(x: str) -> bool:
    acc = 0
    for i, ch in enumerate(x):
        acc = ((acc << 5) - acc) ^ (ord(ch) + i)
    return acc & 0xFFFFFFFF == 0xC0FFEE11

if __name__ == "__main__":
    data = input("Guess: ")
    print("OK" if secret(data) else "NO")
