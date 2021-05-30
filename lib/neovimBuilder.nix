{ pkgs, lib ? pkgs.lib, ...}:

{ config }:
let
  neovimPlugins = pkgs.neovimPlugins;

  vimOptions = lib.evalModules {
    modules = [
      { imports = [../modules]; }
      config 
    ];

    specialArgs = {
      inherit pkgs; 
    };
  };

  vim = vimOptions.config.vim;

  packdir = pkgs.symlinkJoin {
    name = "vimpackdir";
    paths = (builtins.attrValues neovimPlugins);
    postBuild = ''
	mkdir $out/pack/MyPacks/opt -p
	mv $out/share/vim-plugins $out/pack/MyPacks/start
	
    '';
  };

  vimcfg = pkgs.writeTextFile {
    name = "init.vim";
    text = ''
      " Configuration generated by NIX
      set nocompatible

      set packpath^=${packdir}
      set runtimepath^=${packdir}

      ${vim.configRC}
    '';
  };


in pkgs.writeScriptBin "nvim" ''
  !# ${pkgs.bash}/bin/bash
  exec -a "$0" ${pkgs.neovim-nightly}/bin/nvim -u ${vimcfg} $@
''
