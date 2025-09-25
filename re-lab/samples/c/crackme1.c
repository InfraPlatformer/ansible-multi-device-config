#include <stdio.h>
#include <string.h>
#include <stdlib.h>

unsigned int hash_password(const char *s) {
    unsigned int acc = 0u;
    size_t n = strlen(s);
    for (size_t i = 0; i < n; i++) {
        unsigned char ch = (unsigned char)s[i];
        acc = (acc * 33u) ^ (unsigned int)(ch + 0x13u);
    }
    return acc;
}

int main(void) {
    char input[128];
    printf("Password: ");
    if (!fgets(input, sizeof(input), stdin)) {
        return 1;
    }
    input[strcspn(input, "\n")] = '\0';

    if (hash_password(input) == 0xDEADBEEF) {
        puts("Access granted");
        return 0;
    } else {
        puts("Access denied");
        return 1;
    }
}
