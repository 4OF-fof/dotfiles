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
    use{
        'kyazdani42/nvim-tree.lua',
        requires = {
            'kyazdani42/nvim-web-devicons'
        }
    }
    use 'akinsho/toggleterm.nvim'
    use 'windwp/nvim-autopairs'
    use 'glepnir/dashboard-nvim'
    use 'folke/which-key.nvim'
    use 'folke/tokyonight.nvim'
end)
