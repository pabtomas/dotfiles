module github.com/tiawl/navy

go 1.22.5

replace github.com/tiawl/navy/logger => ./logger

require (
	github.com/tiawl/navy/logger v0.0.0-00010101000000-000000000000 // indirect
	github.com/tiawl/navy/logger/bar v0.0.0-00010101000000-000000000000 // indirect
	github.com/tiawl/navy/logger/queue v0.0.0-00010101000000-000000000000 // indirect
	github.com/tiawl/navy/logger/request/bar v0.0.0-00010101000000-000000000000 // indirect
	github.com/tiawl/navy/logger/request/buffer v0.0.0-00010101000000-000000000000 // indirect
	github.com/tiawl/navy/logger/request/flush v0.0.0-00010101000000-000000000000 // indirect
	github.com/tiawl/navy/logger/request/kill v0.0.0-00010101000000-000000000000 // indirect
	github.com/tiawl/navy/logger/request/log/debug v0.0.0-00010101000000-000000000000 // indirect
	github.com/tiawl/navy/logger/request/log/error v0.0.0-00010101000000-000000000000 // indirect
	github.com/tiawl/navy/logger/request/log/info v0.0.0-00010101000000-000000000000 // indirect
	github.com/tiawl/navy/logger/request/log/note v0.0.0-00010101000000-000000000000 // indirect
	github.com/tiawl/navy/logger/request/log/raw v0.0.0-00010101000000-000000000000 // indirect
	github.com/tiawl/navy/logger/request/log/trace v0.0.0-00010101000000-000000000000 // indirect
	github.com/tiawl/navy/logger/request/log/verb v0.0.0-00010101000000-000000000000 // indirect
	github.com/tiawl/navy/logger/request/log/warn v0.0.0-00010101000000-000000000000 // indirect
	github.com/tiawl/navy/logger/request/progress v0.0.0-00010101000000-000000000000 // indirect
	github.com/tiawl/navy/logger/request/spin v0.0.0-00010101000000-000000000000 // indirect
	github.com/tiawl/navy/logger/spin v0.0.0-00010101000000-000000000000 // indirect
)

replace github.com/tiawl/navy/logger/bar => ./logger/bar

replace github.com/tiawl/navy/logger/queue => ./logger/queue

replace github.com/tiawl/navy/logger/spin => ./logger/spin

replace github.com/tiawl/navy/logger/request/log/warn => ./logger/request/log/warn

replace github.com/tiawl/navy/logger/request/log/verb => ./logger/request/log/verb

replace github.com/tiawl/navy/logger/request/log/trace => ./logger/request/log/trace

replace github.com/tiawl/navy/logger/request/log/raw => ./logger/request/log/raw

replace github.com/tiawl/navy/logger/request/log/note => ./logger/request/log/note

replace github.com/tiawl/navy/logger/request/log/info => ./logger/request/log/info

replace github.com/tiawl/navy/logger/request/log/error => ./logger/request/log/error

replace github.com/tiawl/navy/logger/request/log/debug => ./logger/request/log/debug

replace github.com/tiawl/navy/logger/request/spin => ./logger/request/spin

replace github.com/tiawl/navy/logger/request/progress => ./logger/request/progress

replace github.com/tiawl/navy/logger/request/kill => ./logger/request/kill

replace github.com/tiawl/navy/logger/request/flush => ./logger/request/flush

replace github.com/tiawl/navy/logger/request/buffer => ./logger/request/buffer

replace github.com/tiawl/navy/logger/request/bar => ./logger/request/bar
