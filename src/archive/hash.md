
![](https://cdn-images-1.medium.com/max/2000/1*KvnXSdcocOy8tpxGbLUCnw.jpeg)

# Choosing a good hash function

Securing your application is one of the hardest part of the development cycle. There are a lot of security aspects one has to look far ahead and variety of tools are available to solve each issue. But choosing the right tool is always a hardship. Specifically when it comes to encryption or hashing.
### Passwords

Hashing passwords is the best way of storing passwords in database. But it is’t that simple. If your database is compromised and you have just hashed the password, they could easily look for matching hashes by constructing a Rainbow table with commonly used passwords.

### Salt

To solve this problem, every password is concatenated with a random string called the *SALT* and then the string is hashed. The salt is stored in the database and used when we have to authenticate the user. This increases the security exponentially as there won’t be any common hashes and finding a correlation between the salt and hash is practically impossible.

However choosing the right hash algorithm is difficult. People always use the obvious choice ***SHA1/2/3*** which is completely wrong. SHA is constructed mainly to be fast making them suitable for large files. They have a speed of 12–15 ***cpb*** and hence bruteforce is highly possible. A more preferable algorithm for hashing is **pbkdf2-hmac** which repeatedly uses SHA on the logic of a **PRNG**. These algorithms are relatively slower that SHA and hence takes bruteforce out of the table.

### Files

The SHA algorithm is specifically designed for acting as a digital signature to large files. The SHA1/2/3 algorithms are designed by group of cryptologists who compete in the competition organized by **NIST**. These competitions are conducted when a collision is detected in the previous SHA. Before SHA, Message Digest was “THE” secure algorithm. Nowadays people barely use it because of too many collisions.

Every software is provided with a hash which helps us to verify the authenticity of the file. However this can only help us identify if the file was damaged during the download. If someone was able to hack into the website and modify the software, it’s doesn’t take much time to modify the hash too. Hence there isn’t a completely secure way to check the authenticity of the file.

The main factor which comes with hashing large files is speed. SHA2 provides a speed of 208mbps. However this can be further improved. A tree based hash structure is constructed which improves security as well as speed by utilizing the multi-core system. Merkel tree is widely used nowadays. The present SHA3 provides us with Sakura method for a tree based hash construction. These are much faster than previous algorithm and hence large files can be hashed easily.

### Data encryption

The data encryption is used to encrypt files when transferred over unsecure networks so that even if the file is retrieved they couldn’t be accessed. The algorithms use for this purpose are **DES** and **AES** which work on a key based encryption. However software gaints develop their own encryption algorithm which provides even more security as the algorithm isnt exposed. One such example is how YouTube URL is produced from just the Video’s title (or maybe more :P)

### Key Exchange

There are times when we need to transfer to a short information but must be highly secure. This is established by **RSA**. RSA was one of the primitive algorithms which uses key based encryption to transfer data. Key based algorithm are of two types

* Symmetrical (public)

* Asymmetrical(public/private)

DES and AES are of symmetrical types. RSA is an asymmetric algorithm. It uses public key to encrypt which can be decrypted only by the private key. These algorithms are slow and hence used only on very short information.

Modern day money is Bitcoin. They use a further complicated algorithm called **ECDSA** which is widely used nowadays.

This is just an outline of where hashes and encryption are used frequently. Some algorithms like Blowfish, bcrypt, BLAKE2 haven’t been mentioned here but at specific constraints, others don’t stand a chance against these methods.

## May the security be with you.

* [SHA](https://en.wikipedia.org/wiki/SHA-1?wprov=sfla1) — Secure Hash Algorithm

* CPB — cycles per byte.

* [PBKDF2-HMAC](https://en.wikipedia.org/wiki/PBKDF2?wprov=sfla1) — Password-Based Key Derivation Function — Hash Message Authentication Code

* PRNG — Pseudo Random Number Generator

* NIST — National Institute of standards and technology

* DES — Data Encryption Standard

* AES — Advanced Encryption Standard

* RSA — Rivest,Shamir,Adleman

* ECDSA — Elliptic Curve Digital Signature Algorithm

Useful Links.

* [http://security.stackexchange.com/questions/16354/whats-the-advantage-of-using-pbkdf2-vs-sha256-to-generate-an-aes-encryption-key](http://security.stackexchange.com/questions/16354/whats-the-advantage-of-using-pbkdf2-vs-sha256-to-generate-an-aes-encryption-key)

* [https://www.addedbytes.com/blog/why-you-should-always-salt-your-hashes/](https://www.addedbytes.com/blog/why-you-should-always-salt-your-hashes/)

* [https://en.wikipedia.org/wiki/Advanced_Encryption_Standard?wprov=sfla1](https://en.wikipedia.org/wiki/Advanced_Encryption_Standard?wprov=sfla1)

* [https://en.bitcoin.it/wiki/Elliptic_Curve_Digital_Signature_Algorithm](https://en.bitcoin.it/wiki/Elliptic_Curve_Digital_Signature_Algorithm)
