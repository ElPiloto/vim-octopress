" octopress.vim - Wrapper for Octopress Rake commands
" Language:         Octopress (Markdown/Textile with Liquid)
" Maintainer:       Dan Lowe (dan@tangledhelix.com)
" URL:              https://github.com/tangledhelix/vim-octopress
"
" TODO: store state of swapfile, then restore it.
" only change state if it was set previously.

if exists('g:loaded_octopress') || &cp
	finish
endif
let g:loaded_octopress = 1

if exists('g:octopress_rake_executable')
	" Just use the global if it's set
else
	" Otherwise set the global to 'rake'
	let g:octopress_rake_executable = 'rake'
endif

function! s:Octopress(task, ...)
	redraw!
	if a:task ==# 'new_post'
		if a:0 == 0
			echoerr 'Missing post_title'
			return
		endif
		let rakefile_path = substitute(system(g:octopress_rake_executable . " -e 'puts (Rake.application.find_rakefile_location())[1]'"), "\n", '', '')
		let rake_output = system(g:octopress_rake_executable . ' ' . a:task . '[' . shellescape(join(a:000)) . ']')
		let post_path = ''
		for line in split(rake_output, "\n")
			if line =~? 'Creating new post:'
				let post_path = substitute(line, '^Creating new post: ', '', '')
				break
			endif
		endfor
		if post_path == ''
			echoerr 'Unable to find path to new post file'
		else
			execute ':edit ' . rakefile_path . '/' . post_path
		endif
	" TODO add task new_page
	elseif a:task ==# 'generate' || a:task ==# 'deploy' || a:task ==# 'gen_deploy' || a:task ==# 'push' || a:task ==# 'rsync' || a:task ==# 'clean'
		if a:task ==# 'deploy' || a:task ==# 'gen_deploy' || a:task ==# 'rsync'
			execute 'set noswapfile'
		endif
		execute '!' . g:octopress_rake_executable . ' ' . a:task
	elseif a:task ==# 'preview'
		if g:octopress_allow_bg
			" only execute rake preview if it isn't already running
			if !system("pgrep -f '^ruby.*rake preview'")
				execute ':Start! ' . g:octopress_rake_executable . ' preview'
			else
				echo 'rake preview is already running'
			endif
		else
			echo "Dispatch plugin (tpope/vim-dispatch @ git) not detected, cannot launch rake preview"
		endif
	elseif a:task ==# 'watch'
		if g:octopress_allow_bg
			" only execute rake preview if it isn't already running
			if !system("pgrep -f '^ruby.*rake watch'")
				execute ':Start! ' . g:octopress_rake_executable . ' watch'
			else
				echo 'rake watch is already running'
			endif
		else
			echo "Dispatch plugin (tpope/vim-dispatch @ git) not detected, cannot launch rake watch"
		endif

	else
		echo "I don't know about that Octopress task."
	endif
	redraw!
endfunction

function! s:Complete(ArgLead, CmdLine, CursorPos)
	if g:octopress_allow_bg == 0
		return "new_post\nclean\ndeploy\ngen_deploy\ngenerate\npush\nrsync\n"
	else
		return "new_post\nclean\ndeploy\ngen_deploy\ngenerate\npush\nrsync\npreview\nwatch"
	endif
endfunction

command! -bang -nargs=* -complete=custom,s:Complete Octopress call s:Octopress(<f-args>)

