{
  xdg.configFile = {
    "nvim/init.lua".text = builtins.readFile ../../nvim/init.lua;
    "nvim/lua/config/lazy.lua".text = builtins.readFile ../../nvim/lua/config/lazy.lua;
    "nvim/lua/plugins/init.lua".text = builtins.readFile ../../nvim/lua/plugins/init.lua;
    "nvim/lua/plugins/which-key.lua".text = builtins.readFile ../../nvim/lua/plugins/which-key.lua;
    "nvim/lua/plugins/noice.lua".text = builtins.readFile ../../nvim/lua/plugins/noice.lua;
    "nvim/lua/plugins/snacks.lua".text = builtins.readFile ../../nvim/lua/plugins/snacks.lua;
  };
}
