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


function! s:fileModificationTime(filePath)
	return system('stat --printf=%Y ' . a:filePath) + 0
endfunction


function! s:sourceVimProjectFile(filePath)
	if filereadable(a:filePath)
		exec 'source ' . a:filePath
		let w:vimProjectFileModified = s:fileModificationTime(a:filePath)
	endif
endfunction


function! g:resourceVimProjectFileIfModified()
	if exists('w:vimProjectRoot')
		let filePath = w:vimProjectRoot . g:vimProjectFilename
		let modified = s:fileModificationTime(filePath)
		if modified > w:vimProjectFileModified
			call s:sourceVimProjectFile(filePath)
		endif
	endif
endfunction


"" Determine the project path and then:
""  1) Change the current directory to it.
""  2) Set the current path as it.
""  3) Source the vimproject file.
function! g:autoVimProject(loadBuf)
	" Check whether the buffer is already loaded for the window:
	if a:loadBuf != 1 && !exists('w:vimProjectRoot')
		return
	endif

	" Check whether window already belongs to a project:
	if a:loadBuf != 1 && exists('w:vimProjectRoot')
		exec 'set path=' . join(w:vimProjectPath, ',')
		call g:resourceVimProjectFileIfModified()
		return
	endif

	" Find the project path:
	let currentPath = expand("%:p:h")
	let projectRoot = g:findFileInAncestorDir(g:vimProjectFilename, currentPath)
	if projectRoot == ""
		unlet! w:vimProjectRoot
		unlet! w:vimProjectName
		unlet! w:vimProjectPath
		return
	endif

	" Set Vim path based on the project path:
	exec 'lcd ' . projectRoot
	exec 'set path=' . projectRoot . '**'

	" VimProject info variables:
	let w:vimProjectRoot = projectRoot

	" VimProject info variables to be defined or extended in vimrproject file:
	let w:vimProjectName = 'UndefinedProject'
	let w:vimProjectPath = [projectRoot . '**']

	" Source the VimProject file:
	let filePath = projectRoot . g:vimProjectFilename
	call s:sourceVimProjectFile(filePath)

	" Add project to project dict:
	if has_key(g:vimProjects, w:vimProjectName) && g:vimProjects[w:vimProjectName] != w:vimProjectRoot
		echoerr 'Duplicate project names detected: ' . w:vimProjectName . '. Overriding existing entry.'
	endif
	let g:vimProjects[w:vimProjectName] = w:vimProjectRoot
endfunction


"" Show Vim Project information:
function! g:vimProjectInfo()
	if exists('w:vimProjectRoot')
		echo 'Project name: ' . w:vimProjectName
		echo 'Project root path: ' . w:vimProjectRoot
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
autocmd BufWinEnter,BufRead * call g:autoVimProject(1)
autocmd WinEnter * call g:autoVimProject(0)
autocmd BufRead,BufNewFile .vimproject set syntax=vim


"" Commands

" Information about the current project:
command! VPinfo call g:vimProjectInfo()

" List all projects:
command! VPall call g:vimProjectListAll()

" Create a tab and open the directory at the Vim Project path:
command! -nargs=1 -complete=customlist,VimProjectNames VPtab exec 'tabedit ' . g:vimProjects[<f-args>] | call g:autoVimProject(1)
function! VimProjectNames(A,L,P)
	return filter(keys(g:vimProjects), 'strlen(v:val) >= strlen(a:A) && stridx(v:val, a:A) == 0')
endfunction

" Edit the current Vim Project file:
function! s:vimProjectEditProjectFile(...)
	if a:0 == 1
		exec 'tabedit ' . g:vimProjects[a:1] . g:vimProjectFilename
	elseif exists('w:vimProjectRoot')
		exec 'tabedit ' . w:vimProjectRoot . g:vimProjectFilename
	else
		echo 'No VimProject'
	endif
endfunction
command! -nargs=? -complete=customlist,VimProjectNames VPedit call s:vimProjectEditProjectFile()

" Create a new Vim Project file:
function! s:vimProjectCreate(name)
	let filePath = getcwd() . '/' . g:vimProjectFilename
	if filereadable(filePath)
		echoerr 'Vim Project file already exists. Will not overwrite it.'
		return
	endif
	exec 'tabedit ' . filePath
	call setline(1, "let w:vimProjectName = '" . a:name . "'")
	call setline(2, '')
	call setline(3, '" Insert your project specific window initialization code here.')
	w
	call g:autoVimProject(1)
endfunction
command! -nargs=1 VPcreate call s:vimProjectCreate(<f-args>)

" Re-source Vim Project file for current window:
" TODO: Not sure about the name of this command.
command! VPsource call g:resourceVimProjectFileIfModified()

