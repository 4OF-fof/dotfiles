Mac
```sh
brew bundle
./install.sh
```
Windows
```powershell
.\install.ps1
```

`install.toml` の `host` は配列で指定できます。未指定なら両方、`host = ["windows"]` は PowerShell のみ、`host = ["mac"]` は `install.sh` のみ、`host = ["mac", "windows"]` は両方で有効です。

Vite+
```sh
curl -fsSL https://vite.plus | bash
```
