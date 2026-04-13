Mac
```sh
brew bundle
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
```toml
[[link]]
source = "dotfiles/path/to/file"
target = "host/path/to/file"
host = ["mac", "windows"]
[link.windows]
target = "win/path/to/file"
```