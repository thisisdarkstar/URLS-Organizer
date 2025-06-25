# 🌐 URLS-Organizer

Organize a list of URLs or hostnames by their root domain, grouping all subdomains together.  
Perfect for security, research, or just keeping your domain lists tidy!

---

## 🚀 Features

- Extracts hostnames from URLs (handles protocols, ports, credentials, queries, fragments)
- Groups subdomains under their root domain (supports SLDs like `.co.uk`)
- Deduplicates subdomains
- Skips IPs, `localhost`, and comments
- Reads from a file or from stdin
- Outputs each root domain as a folder with a `subdomains.txt` file

---

## 🏁 Quick Start

```bash
git clone https://github.com/yourusername/URLS-Organizer.git
cd URLS-Organizer
```

### 1️⃣ Install [Bats](https://github.com/bats-core/bats-core) and [bats-assert](https://github.com/bats-core/bats-assert), [bats-support](https://github.com/bats-core/bats-support):

```bash
git clone https://github.com/bats-core/bats-core.git
git clone https://github.com/bats-core/bats-assert.git
git clone https://github.com/bats-core/bats-support.git
export PATH="$PWD/bats-core/bin:$PATH"
```

### 2️⃣ Run the tests!

```bash
bats test.sh
```

You should see:

```
 Extracts hostname from URL and groups by root domain1/9 ✓ Extracts hostname from URL and groups by root domain 
 Handles ports, paths, query, and fragments properly2/9 ✓ Handles ports, paths, query, and fragments properly 
 Groups multiple subdomains and deduplicates3/9 ✓ Groups multiple subdomains and deduplicates 
 Identifies root domain with SLDs like .co.uk4/9 ✓ Identifies root domain with SLDs like .co.uk 
 Handles raw subdomain with query string (no protocol)5/9 ✓ Handles raw subdomain with query string (no protocol) 
 Skips IPs, localhost, and comments6/9 ✓ Skips IPs, localhost, and comments 
 Reads from stdin if no input file is provided7/9 ✓ Reads from stdin if no input file is provided 
 Handles credentials and ports in URL8/9 ✓ Handles credentials and ports in URL 
 shows usage message when no arguments and no stdin9/9 ✓ shows usage message when no arguments and no stdin 

9 tests, 0 failures
```

---

## 📝 Usage

```bash
script.sh input.txt
# or
cat input.txt | script.sh
```

- Each root domain gets its own folder with a `subdomains.txt` file listing all unique subdomains.

---

## 📦 Example

**input.txt**
```
https://blog.example.com/path
api.dev.example.com:8443
cdn.test.example.co.uk
localhost
127.0.0.1
```

**After running:**
```
example.com/subdomains.txt
dev.example.com/subdomains.txt
example.co.uk/subdomains.txt
```

---

## 🧩 Dependencies

- Bash (Unix-like shell)
- [Bats](https://github.com/bats-core/bats-core) for testing
- [bats-assert](https://github.com/bats-core/bats-assert) and [bats-support](https://github.com/bats-core/bats-support) for test assertions

---

## 💡 License

MIT