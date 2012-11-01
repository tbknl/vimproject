" vimproject.vim
" 
" Automatically determining project root directory and sourcing
" project-specific vim script.
"
" Version: 0.1
" Author: Dave van Soest
" Date: 2012-10-31
"       2012-09-09

"" Plugin configuration:
let g:vimProjectFilename = '.vimproject'


"" Find an ancestor directory with the specified file.
"" @param filename File name to search for.
"" @param dir Directory to start searching in.
"" @return The directory path or empty string if not found.
function! g:findFileInAncestorDir(filename, dir)
	let curdir = simplify(a:dir."/")
	while 1
		if filereadable(curdir.a:filename)
			return curdir
		elseif curdir == "/"
			return ""
		endif
		let curdir = simplify(curdir."/../")
	endwhile
endfunction


let g:vimProjects = {}

"" Determine the project path and then:
""  1) Change the current directory to it.
""  2) Set the current path as it.
""  3) Source the vimproject file.
function! g:autoVimProject()
	" Find the project path:
	let currentPath = expand("%:p:h")
	let projectPath = g:findFileInAncestorDir(g:vimProjectFilename, currentPath)
	if projectPath == ""
		return
	endif

	" Set Vim path based on the project path:
	exec 'lcd ' . projectPath
	exec 'set path=' . projectPath . '**'

	" VimProject info variables:
	let w:vimProject = 1
	let w:vimProjectPath = projectPath

	" VimProject info variables to be defined in vimrproject file:
	let w:vimProjectName = 'UndefinedProject'

	" Source the VimProject file:
	if filereadable(projectPath . g:vimProjectFilename)
		exec 'source ' . projectPath . g:vimProjectFilename
	endif

	" Add project to project dict:
	if has_key(g:vimProjects, w:vimProjectName) && g:vimProjects[w:vimProjectName] != w:vimProjectPath
		echoerr 'Duplicate project names detected: ' . w:vimProjectName . '. Overriding existing entry.'
	endif
	let g:vimProjects[w:vimProjectName] = w:vimProjectPath
endfunction


"" Show Vim Project information:
function! g:vimProjectInfo()
	if exists('w:vimProject')
		echo 'VimProject Name: ' . w:vimProjectName
		echo 'VimProject Path: ' . w:vimProjectPath
	else
		echo 'No VimProject'
	endif
endfunction


"" List all project names and paths:
function! g:vimProjectListAll()
	for [name, path] in items(g:vimProjects)
		echo name . ': ' . path
	endfor
endfunction


"" Auto commands
autocmd BufRead,BufNewFile .vimproject set syntax=vim


"" Commands

" Information about the current project:
command! VPinfo call g:vimProjectInfo()

" List all projects:
command! VPall call g:vimProjectListAll()

" Create a tab and open the directory at the Vim Project path:
command! -nargs=1 -complete=customlist,VimProjectNames VPtab exec 'tabedit ' . g:vimProjects[<f-args>] | call g:autoVimProject()
function! VimProjectNames(A,L,P)
	return filter(keys(g:vimProjects), 'strlen(v:val) >= strlen(a:A) && stridx(v:val, a:A) == 0')
endfunction

" Edit the current Vim Project file:
command! VPedit exec 'tabedit ' . w:vimProjectPath . g:vimProjectFilename

