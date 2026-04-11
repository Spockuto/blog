# Reading ZIPs Without Downloading Them

Try it yourself: [zipsee.pages.dev](https://zipsee.pages.dev/)

A ZIP file can be 2GB. You want one 50KB file inside it. Do you really need to download all 2GB?

No. The ZIP format was designed for exactly this — you can read the table of contents without touching the file contents, and then fetch only the files you need. All you need is HTTP range requests.

I built zip.see, a browser-based tool that lets you browse and selectively download files from remote ZIP archives. No server-side processing, no full downloads, no plugins. Just the browser, some range requests, and a decent understanding of the ZIP spec.

## How ZIP Files Are Structured

Most archive formats put metadata at the beginning — you have to read from the start to know what's inside. ZIP is different. The table of contents lives at the *end* of the file:

```
[local file header + data][local file header + data]...
[central directory]
[end of central directory record (EOCD)]
```

The EOCD is the last thing in the file. It's a fixed-size record (minimum 22 bytes) that tells you where the central directory starts and how many entries it has. The central directory lists every file with its name, size, compression method, and most importantly — its byte offset in the archive.

This means you can read a ZIP file from the tail:

1. Fetch the last ~16KB (covers EOCD + central directory for most archives)
2. Parse the EOCD to find the central directory
3. Parse each central directory entry to get the file listing
4. For any file you want, make a targeted range request to its exact byte offset

Two HTTP requests to browse the contents. One more per file you actually download.

## The EOCD Parser

Finding the EOCD means scanning backwards from the end of the buffer for the signature `0x06054b50`:

```typescript
const EOCD_SIGNATURE = 0x06054b50;

function findEOCDOffset(view: DataView): number {
  for (let i = view.byteLength - 22; i >= 0; i--) {
    if (readUint32LE(view, i) === EOCD_SIGNATURE) {
      return i;
    }
  }
  throw new Error('Not a valid ZIP');
}
```

Once found, the EOCD gives you `totalEntries`, `centralDirSize`, and `centralDirOffset`. If any of these are `0xFFFF` or `0xFFFFFFFF`, you're dealing with ZIP64 — archives larger than 4GB — and you need to find the ZIP64 EOCD Locator 20 bytes before the regular EOCD.

## Range Requests

The core trick is the `Range` HTTP header:

```
GET /archive.zip
Range: bytes=1048576-1114111
```

The server responds with `206 Partial Content` and only sends those 64KB. Not every server supports this, so the first thing zip.see does is a HEAD request to check for `Accept-Ranges: bytes` and grab the `Content-Length`.

For cross-origin ZIPs, the browser blocks the request. zip.see handles this with a Cloudflare Worker proxy that adds the right CORS headers and forwards range requests transparently.

## Encryption

ZIP supports AES encryption (WinZip standard). An encrypted entry uses AES-CTR mode with keys derived via PBKDF2-SHA1. The process:

1. Read the AES extra field from the central directory to get the encryption strength (128/192/256-bit) and salt
2. Derive keys using PBKDF2-SHA1 (1000 iterations) from the password + salt
3. Verify the password by checking a 2-byte verification value
4. Decrypt the file data using AES-CTR with a little-endian counter
5. Verify integrity with HMAC-SHA1 over the encrypted data

All of this runs client-side using the Web Crypto API. The password and decrypted data never leave the browser.

## Streaming Decompression

For files over 50MB, loading everything into memory isn't practical. zip.see switches to a streaming path: the compressed data is fetched in chunks via range requests, piped through a `DecompressionStream` (for DEFLATE) or processed with fflate, and written to disk using the File System Access API when available.

There's also zip bomb detection — if the decompressed size exceeds 100x the compressed size, the operation is aborted. A 42KB file that decompresses to 4.5 petabytes should probably not be opened in a browser tab.

## The Result

Two range requests to browse any ZIP on the internet. One more per file you want. No server, no upload, no full download. The ZIP format's tail-first design made this possible 35 years ago — the web just needed range requests to catch up.

