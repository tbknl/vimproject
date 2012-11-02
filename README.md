vimproject
==========

VimProject is a plugin for Vim, that let's you easily manage editor settings per project. It lets you create project file (called `.vimproject` by default) in the root directory of each of your projects. Each time you open an editor window the plugin will detect to which project the contained file belongs to. It will then set the current directory and path to the root directory of your project, so that file search commands (e.g. Vim's `:find` command) and file browse actions will automatically go to and look in the project's directory. Also, the `.vimproject` file is a Vim script file, which is executed for each window that is opened for the project.

Install
-------

The easiest way to install VimProject is using [Pathogen](https://github.com/tpope/vim-pathogen). Just clone this repository inside Pathogen's bundle directory and your done. Alternatively you can just download the `vimproject.vim` file separately and copy it into your Vim plugin directory.

Usage
-----

These Vim commands are currently supported:

* `:VPcreate <ProjectName>`
  Create a new project called 'ProjectName'.

* `:VPedit`
  `:VPedit <ProjectName>`
  Edit the project file of the current project, or the project named 'ProjectName'. Note that after editing, when you switch to a window for that project, the script in the project file will be automatically executed again for that window.

* `:VPsource`
  Manually trigger the execution of the project file script.

* `:VPtab <ProjectName>`
  Open a new tab showing the files in the root directory of the project called 'ProjectName'.

* `:VPinfo`
  View information about the project associated with the current window.

* `:VPall`
  List all projects and their paths.

