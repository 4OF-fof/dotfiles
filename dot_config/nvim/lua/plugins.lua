-- Auto install Packer.nvim
local fn = vim.fn
local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
  packer_bootstrap = fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
end

vim.cmd[[packadd packer.nvim]]

require'packer'.startup(function()
    use{
        'nvim-treesitter/nvim-treesitter',
        run = ':TSUpdate'
    }
    use{
        'nvim-lualine/lualine.nvim',
        requires = { 'kyazdani42/nvim-web-devicons', opt = true }
    }
    use{
        'nvim-telescope/telescope.nvim',
        requires = { 'nvim-lua/plenary.nvim' }
    }
    use 'akinsho/toggleterm.nvim'
    use 'windwp/nvim-autopairs'
    use 'glepnir/dashboard-nvim'
    use 'folke/which-key.nvim'
    use 'folke/tokyonight.nvim'
    
    if packer_bootstrap then
        require('packer').sync()
    end
end)
