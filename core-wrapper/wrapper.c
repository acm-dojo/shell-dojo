#include <unistd.h>

int main() {
    setuid(0);
    execl("/run/dojo/bin/python", "python", "/mnt/core/main.py", NULL);
    return 1;
}