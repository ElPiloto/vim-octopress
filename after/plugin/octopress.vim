" Allows rake preview to work if the dispatch command is installed
if exists(':Dispatch')
	" check that this system has a pgrep command which we rely on to detect if
	" background rake processes are running.  We do this by checking an
	" impossible pid, which should return an empty value if pgrep is
	" installed, otherwise, the system command will return an error saying
	" couldn't run that command and thus it won't be empty
	if empty(system("pgrep 9999999999999"))
		let g:octopress_allow_bg = 1
	else
		let g:octopress_allow_bg = 0
	endif
else
	let g:octopress_allow_bg = 0
end
