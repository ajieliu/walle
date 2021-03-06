BUILD_FILES = $(shell go list -f '{{range .GoFiles}}{{$$.Dir}}/{{.}}\
{{end}}' ./...)

WALLE_VERSION ?= $(shell git describe --tags 2>/dev/null || git rev-parse --short HEAD)
DATE_FMT = +%Y-%m-%d
ifdef SOURCE_DATE_EPOCH
	BUILD_DATE ?= $(shell date -u -d "@$(SOURCE_DATE_EPOCH)" "$(DATE_FMT)" 2>/dev/null || date -u -r "$(SOURCE_DATE_EPOCH)" "$(DATE_FMT)" 2>/dev/null || date -u "$(DATE_FMT)")
else
    BUILD_DATE ?= $(shell date "$(DATE_FMT)")
endif

export CGO_ENABLED=0

GO_LDFLAGS := -X walle/pkg/build.Version=$(WALLE_VERSION) $(GO_LDFLAGS)
GO_LDFLAGS := -X walle/pkg/build.Date=$(BUILD_DATE) $(GO_LDFLAGS)


.PHONY: bin/walle
bin/walle: $(BUILD_FILES)
	go build -trimpath -ldflags "${GO_LDFLAGS}" -o "$@" ./pkg/cmd/walle


.PHONY: clean
clean:
	@rm -rf ./bin


.PHONY: lint
lint:
	@golangci-lint run
