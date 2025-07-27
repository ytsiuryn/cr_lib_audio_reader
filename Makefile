test:
	crystal spec
benchmark:
	# --mcpu=native
	crystal build --release --no-debug benchmarks/speed/mp3_benchmark.cr -o bin/mp3_bench
	crystal build --release --no-debug benchmarks/speed/wv_benchmark.cr -o bin/wv_bench
	crystal build --release --no-debug benchmarks/speed/flac_benchmark.cr -o bin/flac_bench
	crystal build --release --no-debug benchmarks/speed/dsf_benchmark.cr -o bin/dsf_bench
	sudo cpupower frequency-set -g performance
	./bin/mp3_bench
	./bin/wv_bench
	./bin/flac_bench
	./bin/dsf_bench
	sudo cpupower frequency-set -g powersave
