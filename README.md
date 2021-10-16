# Assembly XOR file encryption

Small assembly program that XORs any file with another file. If KEYFILE is smaller than TARGET it just resets KEYFILE's offset.

- GNU/Linux
- x86_64
- fasm
## Usage
```shell
$ make
$ ./crypt KEYFILE TARGET OUTPUT
```
**KEYFILE** is a file used as a key to encrypt another file.  
**TARGET** is a file to encrypt/decrypt.  
**OUTPUT** is a filename for the new encrypted/decrypted file.
