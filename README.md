Mac
```sh
./install.sh
```
Windows
```powershell
.\install.ps1
```

brew(scoop)非対応

Vite+
```sh
curl -fsSL https://vite.plus | bash
```

設定
```yaml
---
links:
  - source: dotfiles/path/to/file
    target: host/path/to/file
    host: ["mac", "windows"]
    windows:
      target: win/path/to/file
brew: package
scoop:
  source: main
  name: package
winget: Package.Identifier
---
```
