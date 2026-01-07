DEFAULT_REMOTE_DIR := '$DEFAULT_REMOTE_DIR' # We can't set this to a default sadly
DEFAULT_DIRECTORY := `echo ${DEFAULT_DIRECTORY:-"$HOME/video"}`
DEFAULT_INSTALL_DIR := `echo ${DEFAULT_INSTALL_DIR:-"$HOME/.local/bin"}`
DEFAULT_FORMAT := `echo ${DEFAULT_FORMAT:-"y4m"}`
test VIDEO FORMAT=DEFAULT_FORMAT DIRECTORY=DEFAULT_DIRECTORY DECODE_SUFFIX='-decode':
	#!/usr/bin/env bash
	set -euo pipefail
	function check_run_location {
		if [ -z ${VQMCLI_IGNORE_WORKING_DIR+x} ]; then
			local correct_dir
			correct_dir=$(ls | grep -o "vqmcli" | wc -c)
			if [ "$correct_dir" -eq "0" ]; then
				printf "WARNING: IT APPEARS VQMCLI IS RUNNING IN THE WRONG DIRECTORY!\n"
				printf "This could be for several reasons, but likely means it is not working correctly\n"
				printf "To run this script anyways run, `export VQMCLI_IGNORE_WORKING_DIR=1`, and rerun this command\n"
				exit -1
			fi
		fi
	}

	check_run_location
	# WARN: SCARY!
	# This is fine however since:
	# it is local to the CWD,
	# we have checked that we are in the correct dir,
	# and we have already uploaded old data to wandb.
	rm -rf results_*
	sh vqmcli -r {{DIRECTORY}}/{{VIDEO}}.{{FORMAT}} -d {{DIRECTORY}}/{{VIDEO}}{{DECODE_SUFFIX}}.{{FORMAT}} -o results -l
dev-test VIDEO: (test VIDEO DEFAULT_FORMAT DEFAULT_DIRECTORY '')
	set -euxo pipefail
