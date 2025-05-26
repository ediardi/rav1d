# Justfile for rav1d

set dotenv-load

BENCH_VIDEO_PATH := env('BENCH_VIDEO_PATH')
BENCH_WARMUPS := env('BENCH_WARMUPS')
BENCH_RUNS := env('BENCH_RUNS')

# Default recipe
default:
    just build

# Build (debug)
build:
    cargo build

# Build (release)
build-release:
    cargo build --release

# Build (optimized development profile)
build-profile:
    cargo build --profile opt-dev

# perform checks
check:
    cargo clippy --all-targets -- -D warnings
    cargo fmt --all --check
    cargo check
    cargo doc --all-features

# Run all tests
test: test-unit test-integration

# Run unit tests
test-unit:
    cargo test

# Run integration tests
test-integration:
    .github/workflows/test.sh

# Runs a hyperfine benchmark
bench: build-release
    hyperfine -w {{BENCH_WARMUPS}} -r {{BENCH_RUNS}} "target/release/dav1d -q -i {{BENCH_VIDEO_PATH}} -o /dev/null"

# Runs a hyperfine benchmark with single thread
bench-single: build-release
    hyperfine -w {{BENCH_WARMUPS}} -r {{BENCH_RUNS}} "target/release/dav1d -q -i {{BENCH_VIDEO_PATH}} -o /dev/null --threads 1"

# Runs a samply benchmark
profile: build-profile
    samply record -o ../bench_data/profile.json target/opt-dev/dav1d -q -i {{BENCH_VIDEO_PATH}} -o /dev/null

# Runs a samply benchmark with single thread
profile-single: build-profile
    samply record -o ../bench_data/profile.json target/opt-dev/dav1d -q -i {{BENCH_VIDEO_PATH}} -o /dev/null --threads 1

# Clean the build artifacts
clean:
    cargo clean
